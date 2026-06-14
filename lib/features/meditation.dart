import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';

// --- 1. DATA MODEL ---
class MeditationEntry {
  final String id;
  final int durationMinutes;
  final DateTime timestamp;
  final bool isInterrupted;

  MeditationEntry({
    required this.id,
    required this.durationMinutes,
    required this.timestamp,
    required this.isInterrupted,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'durationMinutes': durationMinutes,
    'timestamp': timestamp.toIso8601String(),
    'isInterrupted': isInterrupted,
  };

  factory MeditationEntry.fromMap(Map<String, dynamic> map) => MeditationEntry(
    id: map['id'] ?? '',
    durationMinutes: map['durationMinutes'] ?? 0,
    timestamp: DateTime.parse(map['timestamp']),
    isInterrupted: map['isInterrupted'] ?? false,
  );
}

// --- 2. DATA MODEL STATE ---
class TimerState {
  final int remainingSeconds;
  final int initialSeconds;
  final bool isRunning;
  final bool isFinished;
  final List<MeditationEntry> history;

  TimerState({
    required this.remainingSeconds,
    required this.initialSeconds,
    required this.isRunning,
    required this.isFinished,
    required this.history,
  });

  TimerState copyWith({
    int? remainingSeconds,
    int? initialSeconds,
    bool? isRunning,
    bool? isFinished,
    List<MeditationEntry>? history,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
      history: history ?? this.history,
    );
  }
}

// --- 3. STATE NOTIFIER ENGINE ---
class MeditationTimerNotifier extends Notifier<TimerState> {
  static const String _boxName = 'vidador_meditation_box';
  Timer? _ticker;

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    _initAndLoad();
    return TimerState(
      remainingSeconds: 0,
      initialSeconds: 0,
      isRunning: false,
      isFinished: false,
      history: [],
    );
  }

  Future<void> _initAndLoad() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? storedRaw = box.get('entries');

    if (storedRaw != null && storedRaw.isNotEmpty) {
      final loadedHistory = storedRaw
          .map((item) => MeditationEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      state = state.copyWith(history: loadedHistory);
    }
  }

  void addDuration(int minutes) {
    final additionalSeconds = minutes * 60;

    int baseRemaining = state.isFinished ? 0 : state.remainingSeconds;
    int baseInitial = state.isFinished ? 0 : state.initialSeconds;

    state = state.copyWith(
      remainingSeconds: baseRemaining + additionalSeconds,
      initialSeconds: baseInitial + additionalSeconds,
      isFinished: false,
    );
  }

  void startTimer() {
    if (state.isRunning || state.remainingSeconds <= 0) return;

    state = state.copyWith(isRunning: true, isFinished: false);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 1) {
        _ticker?.cancel();

        final completedMinutes = state.initialSeconds ~/ 60;
        _addMeditationLog(completedMinutes > 0 ? completedMinutes : 1, false);

        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isFinished: true,
        );
      } else {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      }
    });
  }

  void pauseTimer() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _ticker?.cancel();

    final elapsedSeconds = state.initialSeconds - state.remainingSeconds;

    if (elapsedSeconds > 0) {
      final elapsedMinutes = elapsedSeconds ~/ 60;
      _addMeditationLog(elapsedMinutes > 0 ? elapsedMinutes : 1, true);
    }

    state = TimerState(
      remainingSeconds: 0,
      initialSeconds: 0,
      isRunning: false,
      isFinished: false,
      history: state.history,
    );
  }

  Future<void> _addMeditationLog(int minutes, bool isInterrupted) async {
    final newEntry = MeditationEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      durationMinutes: minutes,
      timestamp: DateTime.now(),
      isInterrupted: isInterrupted,
    );

    state = state.copyWith(history: [newEntry, ...state.history]);
    await _saveToDisk();
  }

  Future<void> deleteLog(String id) async {
    final updatedHistory = state.history.where((entry) => entry.id != id).toList();
    state = state.copyWith(history: updatedHistory);
    await _saveToDisk();
  }

  Future<void> _saveToDisk() async {
    final box = Hive.box(_boxName);
    await box.put('entries', state.history.map((e) => e.toMap()).toList());
  }
}

final meditationTimerProvider =
NotifierProvider<MeditationTimerNotifier, TimerState>(MeditationTimerNotifier.new);

// --- 4. UI SCREEN COMPONENT ---
class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final timerState = ref.watch(meditationTimerProvider);
    final timerNotifier = ref.read(meditationTimerProvider.notifier);

    Color bgMain = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    Color colorForeground = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    Color containerBg = Colors.transparent;
    Color buttonOperatorBg = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    Color buttonOperatorText = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    if (timerState.isFinished) {
      bgMain = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
      colorForeground = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
      containerBg = Colors.transparent;
      buttonOperatorBg = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
      buttonOperatorText = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    }

    final int displayMins = timerState.remainingSeconds ~/ 60;
    final int displaySecs = timerState.remainingSeconds % 60;
    final String timeString =
        '${displayMins.toString().padLeft(2, '0')}:${displaySecs.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER ROW ARCHITECTURE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHRONO TIMING QUANTIZER',
                    style: TextStyle(
                      color: colorForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.0,
                    ),
                  ),
                  Icon(Icons.hourglass_empty_outlined, color: colorForeground, size: 16),
                ],
              ),
              const SizedBox(height: 32),
              Container(height: 0.8, color: colorForeground),
              const SizedBox(height: 24),

              // PREMIUM BRUTALIST TIMER MODULE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left Accent Block (Solid Block with Inverted Interior Square)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorForeground,
                      border: Border.all(color: colorForeground, width: 0.8),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        color: bgMain, // Interior solid square vector
                      ),
                    ),
                  ),

                  // Central Full-Scale Countdown Engine Card
                  Expanded(
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: containerBg,
                        border: Border(
                          top: BorderSide(color: colorForeground, width: 0.8),
                          bottom: BorderSide(color: colorForeground, width: 0.8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        timeString,
                        style: TextStyle(
                          color: colorForeground,
                          fontSize: 48, // Restored prominent visual sizing hierarchy
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),

                  // Right Accent Block (Solid Block with Inverted Interior Square)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorForeground,
                      border: Border.all(color: colorForeground, width: 0.8),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        color: bgMain, // Interior solid square vector
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CUMULATIVE TIME ADDERS
              Row(
                children: [
                  _buildDurationAdderButton(timerNotifier, 15, colorForeground),
                  const SizedBox(width: 8),
                  _buildDurationAdderButton(timerNotifier, 30, colorForeground),
                  const SizedBox(width: 8),
                  _buildDurationAdderButton(timerNotifier, 60, colorForeground),
                ],
              ),

              const SizedBox(height: 36),

              Text(
                'EXECUTION ENGINE OPERATORS',
                style: TextStyle(
                  color: colorForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),

              // BINARY OPERATOR ACTIONS
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: timerState.isRunning ? timerNotifier.pauseTimer : timerNotifier.startTimer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: buttonOperatorBg,
                          border: Border.all(
                            color: buttonOperatorBg,
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          timerState.isRunning ? '[ PAUSE INTERRUPT ]' : '[ INITIALIZE START ]',
                          style: TextStyle(
                            color: buttonOperatorText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: timerNotifier.resetTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: colorForeground,
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '[ RESET ]',
                        style: TextStyle(
                          color: colorForeground,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              Text(
                'CHRONOLOGICAL HISTORY METRICS',
                style: TextStyle(
                  color: colorForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              // PERSISTENT HISTORY LIST ENGINE
              Expanded(
                child: timerState.history.isEmpty
                    ? Center(
                  child: Text(
                    'NO MEDITATION SESSIONS RECORDED',
                    style: TextStyle(
                      color: colorForeground,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                    : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: timerState.history.length,
                  itemBuilder: (context, index) {
                    final item = timerState.history[index];
                    final String entryTime = DateFormat('HH:mm').format(item.timestamp);
                    final String entryDate = DateFormat('MMM dd').format(item.timestamp).toUpperCase();

                    final Color currentBorderColor = item.isInterrupted
                        ? const Color(0xFF5F0E0D)
                        : colorForeground;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: currentBorderColor, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  entryTime,
                                  style: TextStyle(
                                    color: currentBorderColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '[$entryDate]',
                                  style: TextStyle(
                                    color: colorForeground.withOpacity(0.5),
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                if (item.isInterrupted) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '[INTERRUPTED]',
                                    style: TextStyle(
                                      color: const Color(0xFF5F0E0D),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${item.durationMinutes} MIN',
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () => timerNotifier.deleteLog(item.id),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(Icons.close, color: colorForeground, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationAdderButton(
      MeditationTimerNotifier notifier,
      int mins,
      Color colorForeground,
      ) {
    return Expanded(
      child: InkWell(
        onTap: () => notifier.addDuration(mins),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: colorForeground, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Text(
            '[ +${mins} MIN ]',
            style: TextStyle(
              color: colorForeground,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
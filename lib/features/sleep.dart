import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';

// --- 1. DATA MODEL STRUCTS ---
class SleepSession {
  final String id;
  final DateTime sleepTime;
  final DateTime? wakeTime;

  SleepSession({
    required this.id,
    required this.sleepTime,
    this.wakeTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sleepTime': sleepTime.toIso8601String(),
    'wakeTime': wakeTime?.toIso8601String(),
  };

  factory SleepSession.fromMap(Map<String, dynamic> map) => SleepSession(
    id: map['id'] ?? '',
    sleepTime: DateTime.parse(map['sleepTime']),
    wakeTime: map['wakeTime'] != null ? DateTime.parse(map['wakeTime']) : null,
  );
}

class SleepState {
  final List<SleepSession> history;
  final SleepSession? activeSession;

  SleepState({
    required this.history,
    this.activeSession,
  });
}

// --- 2. STATE NOTIFIER ENGINE ---
class SleepNotifier extends Notifier<SleepState> {
  static const String _boxName = 'vidador_sleep_box';

  @override
  SleepState build() {
    _initAndLoad();
    return SleepState(history: [], activeSession: null);
  }

  Future<void> _initAndLoad() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? storedRaw = box.get('sessions');
    final Map<dynamic, dynamic>? activeRaw = box.get('active_session');

    List<SleepSession> loadedHistory = [];
    SleepSession? loadedActive;

    if (storedRaw != null && storedRaw.isNotEmpty) {
      loadedHistory = storedRaw
          .map((item) => SleepSession.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (activeRaw != null) {
      loadedActive = SleepSession.fromMap(Map<String, dynamic>.from(activeRaw));
    }

    state = SleepState(history: loadedHistory, activeSession: loadedActive);
  }

  Future<void> startSleepCycle() async {
    final currentMoment = DateTime.now();
    final newActive = SleepSession(
      id: currentMoment.microsecondsSinceEpoch.toString(),
      sleepTime: currentMoment,
      wakeTime: null,
    );

    state = SleepState(history: state.history, activeSession: newActive);
    final box = Hive.box(_boxName);
    await box.put('active_session', newActive.toMap());
  }

  Future<void> wakeUpAndCommit() async {
    if (state.activeSession == null) return;

    final currentMoment = DateTime.now();
    final completedSession = SleepSession(
      id: state.activeSession!.id,
      sleepTime: state.activeSession!.sleepTime,
      wakeTime: currentMoment,
    );

    final updatedHistory = [completedSession, ...state.history];
    state = SleepState(history: updatedHistory, activeSession: null);

    final box = Hive.box(_boxName);
    await box.delete('active_session');
    await box.put('sessions', updatedHistory.map((e) => e.toMap()).toList());
  }

  Future<void> deleteSession(String id) async {
    final updatedHistory = state.history.where((entry) => entry.id != id).toList();
    state = SleepState(history: updatedHistory, activeSession: state.activeSession);

    final box = Hive.box(_boxName);
    await box.put('sessions', updatedHistory.map((e) => e.toMap()).toList());
  }
}

final sleepProvider = NotifierProvider<SleepNotifier, SleepState>(SleepNotifier.new);

// --- 3. MINIMALIST UI COMPONENT ---
class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final sleepState = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);

    // Absolute Binary Styling System (Strictly Zero Gray Tones)
    final bgMain = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final colorForeground = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final bool isTrackingActive = sleepState.activeSession != null;

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
                    'SLEEP SCHEDULE',
                    style: TextStyle(
                      color: colorForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.0,
                    ),
                  ),
                  Icon(Icons.bedtime_outlined, color: colorForeground, size: 16),
                ],
              ),
              const SizedBox(height: 32),
              Container(height: 0.8, color: colorForeground),
              const SizedBox(height: 24),

              // DYNAMIC TIMING CONTROLLER BLOCK
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: colorForeground, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTrackingActive ? 'CURRENT STATE: RECOVERY TRACKING IN PROGRESS' : 'CURRENT STATE: IDLE MONITOR',
                      style: TextStyle(
                        color: colorForeground,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isTrackingActive) ...[
                      Text(
                        'ONSET TIMESTAMP',
                        style: TextStyle(
                          color: colorForeground,
                          fontSize: 9,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm:ss').format(sleepState.activeSession!.sleepTime),
                        style: TextStyle(
                          color: colorForeground,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    InkWell(
                      onTap: () {
                        if (isTrackingActive) {
                          notifier.wakeUpAndCommit();
                        } else {
                          notifier.startSleepCycle();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isTrackingActive ? Colors.transparent : colorForeground,
                          border: Border.all(color: colorForeground, width: 0.8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isTrackingActive ? '[ WAKE UP ]' : '[ ENTER SLEEP CYCLE ]',
                          style: TextStyle(
                            color: isTrackingActive ? colorForeground : bgMain,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

              // LEDGER HISTORICAL LISTING VIEW
              Expanded(
                child: sleepState.history.isEmpty
                    ? Center(
                  child: Text(
                    'NO RECOVERY SESSIONS RECORDED',
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
                  itemCount: sleepState.history.length,
                  itemBuilder: (context, index) {
                    final item = sleepState.history[index];
                    final String sleepStr = DateFormat('HH:mm').format(item.sleepTime);
                    final String wakeStr = item.wakeTime != null ? DateFormat('HH:mm').format(item.wakeTime!) : '--:--';
                    final String calendarDate = DateFormat('MMM dd').format(item.sleepTime).toUpperCase();

                    Duration? duration;
                    if (item.wakeTime != null) {
                      duration = item.wakeTime!.difference(item.sleepTime);
                    }

                    final String hourString = duration != null ? duration.inHours.toString() : '--';
                    final String minString = duration != null ? (duration.inMinutes % 60).toString() : '--';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorForeground, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '[$calendarDate]',
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$sleepStr — $wakeStr',
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${hourString}H ${minString}M',
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () => notifier.deleteSession(item.id),
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
}
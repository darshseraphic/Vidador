import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';

// --- 1. DATA MODEL ---
class WaterEntry {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amountMl': amountMl,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WaterEntry.fromMap(Map<String, dynamic> map) => WaterEntry(
    id: map['id'] ?? '',
    amountMl: map['amountMl'] ?? 0,
    timestamp: DateTime.parse(map['timestamp']),
  );
}

// --- 2. STATE NOTIFIER ---
class WaterNotifier extends Notifier<List<WaterEntry>> {
  static const String _boxName = 'vidador_water_box';
  static const int dailyTargetMl = 3000;

  @override
  List<WaterEntry> build() {
    _initAndLoad();
    return [];
  }

  Future<void> _initAndLoad() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? storedRaw = box.get('entries');

    if (storedRaw != null && storedRaw.isNotEmpty) {
      state = storedRaw
          .map((item) => WaterEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  Future<void> addLog(int ml) async {
    if (ml <= 0) return;

    final newEntry = WaterEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: ml,
      timestamp: DateTime.now(),
    );

    state = [newEntry, ...state];
    await _saveToDisk();
  }

  Future<void> deleteLog(String id) async {
    state = state.where((entry) => entry.id != id).toList();
    await _saveToDisk();
  }

  int getTodayTotal() {
    final now = DateTime.now();
    return state
        .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month && e.timestamp.day == now.day)
        .fold(0, (sum, item) => sum + item.amountMl);
  }

  Future<void> _saveToDisk() async {
    final box = Hive.box(_boxName);
    await box.put('entries', state.map((e) => e.toMap()).toList());
  }
}

final waterProvider = NotifierProvider<WaterNotifier, List<WaterEntry>>(WaterNotifier.new);

// --- 3. UI SCREEN ---
class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final entries = ref.watch(waterProvider);
    final notifier = ref.read(waterProvider.notifier);

    // Absolute Binary Styling System (Strictly Zero Gray Tones)
    final bgMain = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final colorForeground = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

    final int todayTotal = notifier.getTodayTotal();
    final double completionRatio = (todayTotal / WaterNotifier.dailyTargetMl).clamp(0.0, 1.0);

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
                    'WATER TRACKER',
                    style: TextStyle(
                      color: colorForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.0,
                    ),
                  ),
                  Icon(Icons.water_drop_outlined, color: colorForeground, size: 16),
                ],
              ),
              const SizedBox(height: 32),
              Container(height: 0.8, color: colorForeground),
              const SizedBox(height: 24),

              // QUANTITATIVE MONITOR DASHBOARD CARD
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
                      'DAILY CONSUMPTION',
                      style: TextStyle(
                        color: colorForeground,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$todayTotal ML',
                          style: TextStyle(
                            color: colorForeground,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          'TARGET: ${WaterNotifier.dailyTargetMl} ML',
                          style: TextStyle(
                            color: colorForeground,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // STRICT BINARY PROGRESS TRACKER BAR
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: colorForeground, width: 0.8),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: completionRatio,
                          child: Container(
                            color: colorForeground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PRE-SET VOLUMETRIC CONTROL MATRICES
              Row(
                children: [
                  _buildQuickLogButton(ref, 250, colorForeground),
                  const SizedBox(width: 8),
                  _buildQuickLogButton(ref, 500, colorForeground),
                  const SizedBox(width: 8),
                  _buildQuickLogButton(ref, 750, colorForeground),
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

              // WATER ITERATOR INPUT FEED
              Expanded(
                child: entries.isEmpty
                    ? Center(
                  child: Text(
                    'NO FLUID INTAKE RECORDED',
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
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    final String entryTime = DateFormat('HH:mm').format(item.timestamp);
                    final String entryDate = DateFormat('MMM dd').format(item.timestamp).toUpperCase();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: colorForeground, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  entryTime,
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '[$entryDate]',
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '+${item.amountMl} ML',
                                  style: TextStyle(
                                    color: colorForeground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () => ref.read(waterProvider.notifier).deleteLog(item.id),
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

  Widget _buildQuickLogButton(WidgetRef ref, int ml, Color colorForeground) {
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(waterProvider.notifier).addLog(ml),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: colorForeground, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Text(
            '[ +${ml}ML ]',
            style: TextStyle(
              color: colorForeground,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
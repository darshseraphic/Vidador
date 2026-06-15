import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';

// --- 1. STATE NOTIFIER WITH SECURE ANDROID HARDWARE PIECE ---
class StepNotifier extends Notifier<Map<String, int>> {
  static const String _boxName = 'vidador_steps_box';
  StreamSubscription<StepCount>? _pedometerSubscription;

  // Track live initialization diagnostics securely
  String hardwareDiagnosticStatus = "INITIALIZING SYSTEM...";

  @override
  Map<String, int> build() {
    _initAndLoad();
    ref.onDispose(() {
      _pedometerSubscription?.cancel();
    });
    return {};
  }

  Future<void> _initAndLoad() async {
    final box = await Hive.openBox(_boxName);
    final Map<dynamic, dynamic> rawMap = box.get('records', defaultValue: {});

    state = rawMap.map((key, value) => MapEntry(key.toString(), value as int));

    // Safely check permission permissions prior to activating physical motherboard channels
    _verifyAndConnectHardware();
  }

  Future<void> _verifyAndConnectHardware() async {
    var status = await Permission.activityRecognition.status;

    // FIX: If permission is not already granted, explicitly request it from the user
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
    }

    if (status.isGranted) {
      _initAndroidPedometer();
    } else if (status.isPermanentlyDenied) {
      hardwareDiagnosticStatus = "PERMISSION PERMANENTLY DENIED. GO TO SETTINGS.";
      state = Map<String, int>.from(state); // Forces Riverpod to rebuild and update the UI message
      openAppSettings(); // Automatically opens phone settings so the user can fix it
    } else {
      hardwareDiagnosticStatus = "PRIVILEGE DENIED. CANNOT TRACK STEPS.";
      state = Map<String, int>.from(state); // Forces Riverpod to rebuild and update the UI message
    }
  }

  void _initAndroidPedometer() {
    try {
      _pedometerSubscription?.cancel();
      _pedometerSubscription = Pedometer.stepCountStream.listen(
        _onStepCountUpdate,
        onError: (error) {
          debugPrint("Pedometer Error: $error");
          hardwareDiagnosticStatus = "HARDWARE CHIP SLEEPING OR DISCONNECTED";
          state = Map<String, int>.from(state); // Forces Riverpod UI rebuild
        },
      );
      hardwareDiagnosticStatus = "CONNECTED. WALK 10+ STEPS TO SYNC";
      state = Map<String, int>.from(state); // Forces Riverpod UI rebuild
    } catch (e) {
      hardwareDiagnosticStatus = "CHANNEL FAILURE: $e";
      state = Map<String, int>.from(state); // Forces Riverpod UI rebuild
    }
  }

  Future<void> _onStepCountUpdate(StepCount event) async {
    final box = Hive.box(_boxName);
    final now = DateTime.now();
    // FIXED: Removed the erroneous "- 1" to securely unify dates with the UI layers
    final String todayKey = '${now.year}-${now.month}-${now.day}';

    int systemSteps = event.steps;
    int lastSystemSteps = box.get('last_system_steps', defaultValue: systemSteps);
    String lastSavedDate = box.get('last_saved_date', defaultValue: todayKey);

    hardwareDiagnosticStatus = "HARDWARE PIPELINE: ACTIVE";

    if (lastSavedDate != todayKey) {
      await box.put('last_saved_date', todayKey);
      await box.put('last_system_steps', systemSteps);
      lastSystemSteps = systemSteps;
    }

    int stepDifference = systemSteps - lastSystemSteps;

    // Handle device boot lifecycle resets cleanly
    if (stepDifference < 0) {
      await box.put('last_system_steps', systemSteps);
      stepDifference = 0;
    }

    if (stepDifference > 0) {
      int currentStoredSteps = state[todayKey] ?? 0;
      int updatedSteps = currentStoredSteps + stepDifference;

      await box.put('last_system_steps', systemSteps);
      await logSteps(todayKey, updatedSteps);
    } else {
      // Force UI refresh to reveal the "HARDWARE PIPELINE: ACTIVE" text change immediately
      state = Map<String, int>.from(state);
    }
  }

  Future<void> logSteps(String dateKey, int steps) async {
    final updatedMap = Map<String, int>.from(state);
    if (steps <= 0) {
      updatedMap.remove(dateKey);
    } else {
      updatedMap[dateKey] = steps;
    }
    state = updatedMap;

    final box = Hive.box(_boxName);
    await box.put('records', state);
  }

  void kickstartSensorManual() {
    _verifyAndConnectHardware();
  }
}

final stepProvider = NotifierProvider<StepNotifier, Map<String, int>>(StepNotifier.new);

// --- 2. UI SCREEN COMPONENT ---
class StepScreen extends ConsumerStatefulWidget {
  const StepScreen({super.key});

  @override
  ConsumerState<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends ConsumerState<StepScreen> {
  static const int _matrixColumns = 7;
  static const List<String> _monthNames = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];
  static const List<String> _dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    // Force prompt permission checking immediately when clicking into this tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stepProvider.notifier).kickstartSensorManual();
    });
  }

  List<int> _getDaysInMonths(int year) {
    bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    return [31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  }

  Widget _buildStepMetricRow(String title, String data, Color primary, Color line) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: line, width: 0.6))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.robotoMono(
                color: primary.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            data,
            style: GoogleFonts.robotoMono(
              color: primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _openStepLogEditor(BuildContext context, String dateKey, String monthName, int day) {
    final currentSteps = ref.read(stepProvider)[dateKey] ?? 0;
    final stepController = TextEditingController(text: currentSteps > 0 ? currentSteps.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ref.read(themeProvider) ? const Color(0xFF000000) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final isDark = ref.watch(themeProvider);
        final textMain = isDark ? Colors.white : Colors.black;
        final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF888888);

        final inputBg = isDark ? Colors.black : const Color(0xFFF5F5F5);
        final inputBorder = isDark ? const Color(0xFF2D2D2D) : Colors.transparent;
        final ruleBorder = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5);

        final btnBgColor = isDark ? Colors.white : Colors.black;
        final btnTextColor = isDark ? Colors.black : Colors.white;

        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: isDark
                  ? const Color(0xFFFFFFFF).withOpacity(0.4)
                  : const Color(0xFF000000).withOpacity(0.2),
              selectionHandleColor: textMain,
              cursorColor: textMain,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24.0,
              right: 24.0,
              top: 24.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$monthName $day — STEPS TRACKER',
                        style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.04),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: textSub),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: ruleBorder, height: 1, thickness: 0.8),
                  const SizedBox(height: 20),
                  TextField(
                    controller: stepController,
                    style: TextStyle(color: textMain, fontSize: 14),
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'ENTER STEPS RECOUNT VALUE',
                      hintStyle: TextStyle(color: textSub, fontSize: 14),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: isDark ? BorderSide(color: inputBorder, width: 1) : BorderSide.none
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: isDark ? BorderSide(color: inputBorder, width: 1) : BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: isDark ? BorderSide(color: inputBorder, width: 1) : BorderSide.none
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBgColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () async {
                        final parsedVal = int.tryParse(stepController.text.trim()) ?? 0;
                        await ref.read(stepProvider.notifier).logSteps(dateKey, parsedVal);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(
                        'COMMIT',
                        style: TextStyle(color: btnTextColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.04),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final stepRecords = ref.watch(stepProvider);
    final diagnostics = ref.watch(stepProvider.notifier).hardwareDiagnosticStatus;

    final now = DateTime.now();
    final currentYear = now.year;

    // FIXED: Synchronized matching tracking key maps
    final String todayKey = '$currentYear-${now.month}-${now.day}';
    final int todaySteps = stepRecords[todayKey] ?? 0;

    final List<int> daysInMonths = _getDaysInMonths(currentYear);

    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF888888);
    final ruleBorder = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5);
    final List<String> shortDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    int totalSteps = 0;
    int maxSteps = 0;
    int activeDays = 0;

    stepRecords.forEach((key, value) {
      if (value > 0) {
        totalSteps += value;
        activeDays++;
        if (value > maxSteps) {
          maxSteps = value;
        }
      }
    });

    double averageSteps = activeDays > 0 ? totalSteps / activeDays : 0.0;

    String biologicalTier = "SEDENTARY METABOLIC BASELINE";
    if (averageSteps >= 10000) {
      biologicalTier = "HIGH-INTENSITY CARDIOVASCULAR TIER";
    } else if (averageSteps >= 7500) {
      biologicalTier = "ACTIVE HEALTH SPECIFICATION";
    } else if (averageSteps >= 4000) {
      biologicalTier = "STANDARD BIOLOGICAL ACTIVITY";
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP HEADLINE ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEPS TELEMETRY QUANTIZER',
                    style: GoogleFonts.robotoMono(color: textMain, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '[$todaySteps]',
                    style: GoogleFonts.robotoMono(color: textMain, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Divider(color: ruleBorder, height: 1, thickness: 0.8),

            // VISUAL STEP INTENSITY & TELEMETRY PANEL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Profile Performance Tier Block
                  // Profile Performance Tier Block — CYBERPUNK BRUTALIST REBUILD
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA),
                      border: Border.all(
                        color: textMain.withValues(alpha: 0.8),
                        width: 1.2, // Sharper, heavier border lines
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP VECTOR: DIAGNOSTICS
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "DIAGNOSTIC ARCHITECTURE VECTOR",
                                    style: GoogleFonts.robotoMono(
                                      color: textMain.withValues(alpha: 0.4),
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                  Text(
                                    "[SYS_VEC_01]",
                                    style: GoogleFonts.robotoMono(
                                      color: textMain.withValues(alpha: 0.3),
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "● ",
                                    style: GoogleFonts.robotoMono(
                                      color: diagnostics.contains("ACTIVE") || diagnostics.contains("CONNECTED")
                                          ? const Color(0xFF00FF66) // Neon Green when active/connected
                                          : Colors.redAccent,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      diagnostics.toUpperCase(),
                                      style: GoogleFonts.robotoMono(
                                        color: diagnostics.contains("ACTIVE") || diagnostics.contains("CONNECTED")
                                            ? textMain
                                            : Colors.redAccent,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.02,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // SOLID SEPARATOR SYSTEM RULE
                        Container(
                          height: 1.2,
                          width: double.infinity,
                          color: textMain.withValues(alpha: 0.8),
                        ),

                        // BOTTOM VECTOR: KINETICS PROFILE
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BIOLOGICAL STEP KINETICS PROFILE",
                                style: GoogleFonts.robotoMono(
                                  color: textMain.withValues(alpha: 0.4),
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "// ${biologicalTier.toUpperCase()}",
                                style: GoogleFonts.robotoMono(
                                  color: textMain,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Weekly Mini Telemetry Bar Chart
                  Row(
                    children: List.generate(7, (index) {
                      final int targetWeekday = index + 1;
                      final int dayDiff = targetWeekday - now.weekday;
                      final DateTime targetDate = now.add(Duration(days: dayDiff));
                      final String key = '${targetDate.year}-${targetDate.month}-${targetDate.day}';
                      final int steps = stepRecords[key] ?? 0;

                      const double maxHeightLimit = 10000.0;
                      double barCalculation = (steps / maxHeightLimit * 48.0).clamp(2.0, 48.0);
                      final bool isToday = targetWeekday == now.weekday;

                      return Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 48,
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Container(
                                width: double.infinity,
                                height: steps == 0 ? 2 : barCalculation,
                                color: isToday ? textMain : textMain.withOpacity(0.25),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shortDays[index],
                              style: GoogleFonts.robotoMono(
                                color: isToday ? textMain : textSub,
                                fontSize: 8,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              steps == 0
                                  ? '-'
                                  : (steps >= 10000
                                  ? '${(steps / 1000).toStringAsFixed(0)}K'
                                  : steps >= 1000
                                  ? '${(steps / 1000).toStringAsFixed(1)}K'
                                  : '$steps'),
                              style: GoogleFonts.robotoMono(
                                color: isToday ? textMain : textSub.withOpacity(0.6),
                                fontSize: 7.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: ruleBorder, height: 1, thickness: 0.5),
                  const SizedBox(height: 4),

                  // Extended Telemetry Metric Compilation Rows
                  _buildStepMetricRow("TOTAL RECOUNT VOLUMETRICS", "$totalSteps STEPS", textMain, ruleBorder),
                  _buildStepMetricRow("MAXIMUM STEP PEAK (PR)", "$maxSteps STEPS", textMain, ruleBorder),
                  _buildStepMetricRow("COMPUTED SESSION MEAN", "${averageSteps.toInt()} STEPS / DAY", textMain, ruleBorder),
                ],
              ),
            ),

            Divider(color: ruleBorder, height: 1, thickness: 0.8),

            // CONDENSED CALENDAR REGION
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.80,
                  ),
                  itemBuilder: (context, monthIndex) {
                    final String monthName = _monthNames[monthIndex];
                    final int totalDaysInMonth = daysInMonths[monthIndex];

                    final DateTime firstDayOfMonth = DateTime(currentYear, monthIndex + 1, 1);
                    final int startingWeekday = firstDayOfMonth.weekday;
                    final int leadingBlanks = startingWeekday - 1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthName,
                          style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.04),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _matrixColumns,
                              crossAxisSpacing: 3.5,
                              mainAxisSpacing: 3.5,
                            ),
                            itemCount: _matrixColumns + leadingBlanks + totalDaysInMonth,
                            itemBuilder: (context, index) {
                              if (index < _matrixColumns) {
                                return Center(
                                  child: Text(
                                    _dayHeaders[index],
                                    style: TextStyle(color: textSub, fontSize: 7.5, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              final int gridIndex = index - _matrixColumns;
                              if (gridIndex < leadingBlanks) return const SizedBox.shrink();

                              final int day = gridIndex - leadingBlanks + 1;
                              final String dateKey = '$currentYear-${monthIndex + 1}-$day';
                              final int daySteps = stepRecords[dateKey] ?? 0;

                              Color boxColor;
                              Color borderColor;
                              Color textColor;

                              if (daySteps == 0) {
                                boxColor = Colors.transparent;
                                borderColor = ruleBorder;
                                textColor = textSub;
                              } else {
                                textColor = const Color(0xFFFFFFFF);
                                if (daySteps >= 10000) {
                                  boxColor = const Color(0xFF450003);
                                  borderColor = const Color(0xFF450003);
                                } else if (daySteps >= 8000) {
                                  boxColor = const Color(0xFF5C0002);
                                  borderColor = const Color(0xFF5C0002);
                                } else if (daySteps >= 6000) {
                                  boxColor = const Color(0xFF94090D);
                                  borderColor = const Color(0xFF94090D);
                                } else if (daySteps >= 4000) {
                                  boxColor = const Color(0xFFD40D12);
                                  borderColor = const Color(0xFFD40D12);
                                } else {
                                  boxColor = const Color(0xFFFF1D23);
                                  borderColor = const Color(0xFFFF1D23);
                                }
                              }

                              return GestureDetector(
                                onTap: () => _openStepLogEditor(context, dateKey, monthName, day),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: boxColor,
                                    border: Border.all(color: borderColor, width: 0.7),
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 6.8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            Divider(color: ruleBorder, height: 1, thickness: 0.8),

            // HARMONIZED PROGRESS LEGEND
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFFFF1D23), borderRadius: BorderRadius.circular(1.0))),
                    const SizedBox(width: 6),
                    Text('1-4K', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.02)),
                    const SizedBox(width: 16),
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFFD40D12), borderRadius: BorderRadius.circular(1.0))),
                    const SizedBox(width: 6),
                    Text('4K-6K', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.02)),
                    const SizedBox(width: 16),
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFF94090D), borderRadius: BorderRadius.circular(1.0))),
                    const SizedBox(width: 6),
                    Text('6K-8K', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.02)),
                    const SizedBox(width: 16),
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFF5C0002), borderRadius: BorderRadius.circular(1.0))),
                    const SizedBox(width: 6),
                    Text('8K-10K', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.02)),
                    const SizedBox(width: 16),
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFF450003), borderRadius: BorderRadius.circular(1.0))),
                    const SizedBox(width: 6),
                    Text('10K+', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.02)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
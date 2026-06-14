import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // Handles the native OS popups
import 'package:google_fonts/google_fonts.dart'; // <-- ACCESSIBILITY KEY FOR NAVIGATION TYPOGRAPHY
import 'core/database.dart';
import 'features/sleep.dart';
import 'features/water.dart';
import 'features/step.dart';
import 'features/meditation.dart';
import 'features/setting.dart';
import 'features/splashscreen.dart';

// --- GLOBAL BINARY SPECTRUM SPECIFICATION ---
final themeProvider = StateProvider<bool>((ref) {
  final box = Hive.box('vidador_settings_box');
  return box.get('is_dark_mode', defaultValue: true);
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce secure asynchronous file-system allocation hooks
  await LocalDatabaseManager.initializeDatabase();

  runApp(
    const ProviderScope(
      child: VidadorApp(),
    ),
  );
}

class VidadorApp extends ConsumerWidget {
  const VidadorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      title: 'VIDADOR',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Courier',
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Courier',
      ),
      home: const AnimatedSplashScreen(
        child: MainLayoutRouter(),
      ),
    );
  }
}

class MainLayoutRouter extends ConsumerStatefulWidget {
  const MainLayoutRouter({super.key});

  @override
  ConsumerState<MainLayoutRouter> createState() => _MainLayoutRouterState();
}

class _MainLayoutRouterState extends ConsumerState<MainLayoutRouter> {
  int _currentMatrixIndex = 0;

  final List<Widget> _appScreens = [
    const SleepScreen(),
    const WaterScreen(),
    const StepScreen(),
    const MeditationScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestActivityRecognitionPermission();
  }

  Future<void> _requestActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.status;

    if (status.isDenied || status.isLimited) {
      await Permission.activityRecognition.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF666666) : const Color(0xFF999999);
    final borderColor = isDark ? Colors.white : Colors.black;
    final barBgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentMatrixIndex,
          children: _appScreens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: barBgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 1.0),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildChronoTabItem(0, 'SLEEP', textMain, textSub),
              _buildChronoTabItem(1, 'WATER', textMain, textSub),
              _buildChronoTabItem(2, 'STEPS', textMain, textSub),
              _buildChronoTabItem(3, 'MEDITATION', textMain, textSub),
              _buildChronoTabItem(4, 'SETTING', textMain, textSub),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChronoTabItem(int index, String uppercaseLabel, Color selectedColor, Color unselectedColor) {
    final bool isCurrent = _currentMatrixIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMatrixIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            isCurrent ? '[$uppercaseLabel]' : uppercaseLabel,
            // FIXED: Replaced default system inheritance with clear Inter geometric font styles
            style: GoogleFonts.inter(
              color: isCurrent ? selectedColor : unselectedColor,
              fontSize: 9.0, // Tweak slightly to optimize Inter proportional tracking
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0.05,
            ),
          ),
        ),
      ),
    );
  }
}
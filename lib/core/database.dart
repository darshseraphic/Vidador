import 'package:hive_flutter/hive_flutter.dart';

class LocalDatabaseManager {
  // STRICT BOX IDENTIFIERS MATCHING THE FEATURE ARCHITECTURES
  static const String settingsBoxName = 'vidador_settings_box';
  static const String sleepBoxName = 'vidador_sleep_box';
  static const String waterBoxName = 'vidador_water_box';
  static const String stepsBoxName = 'vidador_steps_box';

  /// INITIALIZES ALL SYSTEM PERSISTENCE BOXES BEFORE RUNTIME ACCESS
  static Future<void> initializeDatabase() async {
    // Initialize Hive for absolute local directory sandbox integration
    await Hive.initFlutter();

    // Asynchronously allocate and open specific box registries
    await Future.wait([
      Hive.openBox(settingsBoxName),
      Hive.openBox(sleepBoxName),
      Hive.openBox(waterBoxName),
      Hive.openBox(stepsBoxName),
    ]);
  }

  /// PURGES ALL PERSISTED HEALTH RECORDS ACROSS THE APPLICATION INSTANTLY
  static Future<void> purgeAllRegistries() async {
    await Hive.box(sleepBoxName).clear();
    await Hive.box(waterBoxName).clear();
    await Hive.box(stepsBoxName).clear();
  }
}
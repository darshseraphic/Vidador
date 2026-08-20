import 'package:hive_flutter/hive_flutter.dart';

class LocalDatabaseManager {
  static const String settingsBoxName = 'vidador_settings_box';
  static const String sleepBoxName = 'vidador_sleep_box';
  static const String waterBoxName = 'vidador_water_box';
  static const String stepsBoxName = 'vidador_steps_box';
  static Future<void> initializeDatabase() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(settingsBoxName),
      Hive.openBox(sleepBoxName),
      Hive.openBox(waterBoxName),
      Hive.openBox(stepsBoxName),
    ]);
  }

  static Future<void> purgeAllRegistries() async {
    await Hive.box(sleepBoxName).clear();
    await Hive.box(waterBoxName).clear();
    await Hive.box(stepsBoxName).clear();
  }
}

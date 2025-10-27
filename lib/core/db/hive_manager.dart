import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('studyFilesBox');
  }

  static Box get studyFilesBox => Hive.box('studyFilesBox');
}

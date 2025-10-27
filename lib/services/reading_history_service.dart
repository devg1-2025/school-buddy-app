import 'package:hive/hive.dart';

class ReadingHistoryService {
  static const String _boxName = 'reading_history';
  static const String _lastReadKey = 'last_read_file';

  /// Initialize Hive box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// Log the last-read file
  static Future<void> logLastRead({
    required String filePath,
    required String fileName,
    String? folderId,
    required String fileType,
    int? currentPage,
  }) async {
    final box = Hive.box(_boxName);

    final data = {
      'filePath': filePath,
      'fileName': fileName,
      'folderId': folderId,
      'fileType': fileType,
      'currentPage': currentPage,
      'lastReadTime': DateTime.now().toIso8601String(),
    };

    await box.put(_lastReadKey, data);
  }

  /// Retrieve the last-read file
  static Map<String, dynamic>? getLastRead() {
    final box = Hive.box(_boxName);
    final data = box.get(_lastReadKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
}

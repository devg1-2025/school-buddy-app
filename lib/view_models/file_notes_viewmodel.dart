import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/file_notes_model.dart';

class FileNotesViewModel extends ChangeNotifier {
  late Box _notesBox;
  String? _fileName;

  Future<void> init() async {
    await Hive.initFlutter();
    _notesBox = await Hive.openBox('file_notes_storage');
  }

  Future<void> loadNotesForFile(String fileName) async {
    _fileName = fileName;
    notifyListeners();
  }

  List<FileNote> get notes {
    if (_fileName == null) return [];
    final rawList = _notesBox.get(_fileName, defaultValue: []);
    if (rawList is! List) return [];

    return rawList.map<FileNote>((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return FileNote.fromMap(map);
    }).toList();
  }

  List<FileNote> get keyPoints => notes.where((n) => n.isKeyPoint).toList();

  Future<void> addNote(String text) async {
    if (_fileName == null) return;
    final newNote = FileNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: _fileName!,
      text: text,
      isKeyPoint: false,
      createdAt: DateTime.now(),
    );
    final updated = [...notes, newNote];
    await _notesBox.put(_fileName, updated.map((n) => n.toMap()).toList());
    notifyListeners();
  }

  Future<void> addKeyPoint(String text) async {
    if (_fileName == null) return;
    final newPoint = FileNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: _fileName!,
      text: text,
      isKeyPoint: true,
      createdAt: DateTime.now(),
    );
    final updated = [...notes, newPoint];
    await _notesBox.put(_fileName, updated.map((n) => n.toMap()).toList());
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    if (_fileName == null) return;
    final updated = notes.where((n) => n.id != id).toList();
    await _notesBox.put(_fileName, updated.map((n) => n.toMap()).toList());
    notifyListeners();
  }
}

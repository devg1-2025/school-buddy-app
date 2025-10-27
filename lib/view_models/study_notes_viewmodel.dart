import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/file_notes_model.dart';

class StudyNotesViewModel extends ChangeNotifier {
  List<FileNote> allNotes = [];
  List<FileNote> filteredNotes = [];
  String searchQuery = '';
  bool showKeyPointsOnly = false;

  Future<void> loadAllNotes() async {
    allNotes.clear();

    final registry = await Hive.openBox('notes_registry');
    final List<String> allBoxNames =
        List<String>.from(registry.get('boxes', defaultValue: []));

    for (final boxName in allBoxNames) {
      if (await Hive.boxExists(boxName)) {
        final box = await Hive.openBox<FileNote>(boxName);
        allNotes.addAll(box.values);
      }
    }

    allNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    filteredNotes = List.from(allNotes);
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void toggleKeyPointFilter(bool value) {
    showKeyPointsOnly = value;
    _applyFilters();
  }

  void _applyFilters() {
    filteredNotes = allNotes.where((note) {
      final matchesSearch = note.text.toLowerCase().contains(searchQuery);
      final matchesType = !showKeyPointsOnly || note.isKeyPoint;
      return matchesSearch && matchesType;
    }).toList();
    notifyListeners();
  }
}

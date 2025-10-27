import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FoldersViewModel extends ChangeNotifier {
  final _box = Hive.box('studyFolders');
  List<Map<String, dynamic>> folders = [];

  Future<void> init() async {
    folders = List<Map<String, dynamic>>.from(_box.get('folders', defaultValue: []));
    notifyListeners();
  }

  void _save() {
    _box.put('folders', folders);
    notifyListeners();
  }

  void addFolder(String name, {int? parentIndex}) {
    final newFolder = {
      'name': name,
      'files': <String>[],
      'subfolders': <Map<String, dynamic>>[],
    };

    if (parentIndex == null) {
      folders.add(newFolder);
    } else {
      folders[parentIndex]['subfolders'].add(newFolder);
    }
    _save();
  }

  void addFileToFolder(int folderIndex, String path, {int? parentIndex}) {
    if (parentIndex == null) {
      folders[folderIndex]['files'].add(path);
    } else {
      folders[parentIndex]['subfolders'][folderIndex]['files'].add(path);
    }
    _save();
  }

  void renameFolder(int index, String newName, {int? parentIndex}) {
    if (parentIndex == null) {
      folders[index]['name'] = newName;
    } else {
      folders[parentIndex]['subfolders'][index]['name'] = newName;
    }
    _save();
  }

  void deleteFolder(int index, {int? parentIndex}) {
    if (parentIndex == null) {
      folders.removeAt(index);
    } else {
      folders[parentIndex]['subfolders'].removeAt(index);
    }
    _save();
  }

  void deleteFile(int folderIndex, int fileIndex, {int? parentIndex}) {
    if (parentIndex == null) {
      folders[folderIndex]['files'].removeAt(fileIndex);
    } else {
      folders[parentIndex]['subfolders'][folderIndex]['files'].removeAt(fileIndex);
    }
    _save();
  }

  /// 🆕 Get the 5 most recent folders (no timestamps, no lag)
  List<Map<String, dynamic>> get recentFolders {
    if (folders.isEmpty) return [];
    return folders.reversed.take(5).toList(); // Just reverse the list
  }
}

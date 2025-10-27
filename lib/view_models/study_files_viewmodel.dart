// lib/view_models/study_files_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter for Box
import '../models/study_file_model.dart';
import '../services/reading_history_service.dart'; // Import ReadingHistoryService

class StudyFilesViewModel extends ChangeNotifier {
  // Use the specific Box type for better type safety
  // Assumes 'studyFilesBox' is opened in main.dart *before* this VM is created
  final Box _box = Hive.box('studyfilesbox');

  List<StudyFileModel> _files = [];
  List<StudyFileModel> get files => List.unmodifiable(_files); // Return unmodifiable list

  StudyFilesViewModel() {
    // Load files immediately when the ViewModel is created
    loadFiles();
  }

  /// Retrieves the data for the last read file using the central service.
  Map<String, dynamic>? getLastReadFileData() {
    // Delegates directly to your ReadingHistoryService
    return ReadingHistoryService.getLastRead();
  }

  /// Loads files from the Hive box.
  Future<void> loadFiles() async {
    // No need to reopen the box, use the _box instance directly
    _files = _box.keys.map((key) { // Keys are now expected to be file IDs (strings)
      try {
        final map = _box.get(key);
        if (map == null) throw Exception("Hive returned null for key $key");

        // Ensure the data is Map<String, dynamic> and add the ID from the key
        final dataMap = Map<String, dynamic>.from(map);
        dataMap['id'] = key as String; // Assign the Hive key as the ID

        return StudyFileModel.fromMap(dataMap);
      } catch (e) {
        debugPrint("Error loading file with key '$key': $e");
        // Return a placeholder or handle corrupted data
        return StudyFileModel(
          id: key as String? ?? 'corrupted_key_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Corrupted File',
          path: '',
          type: '',
          // Ensure default values for lists
          notes: [],
          keyPoints: [],
        );
      }
    }).where((file) => file.id.isNotEmpty && !file.name.contains('Corrupted')).toList(); // Filter out corrupted entries if needed

    // Sort files (e.g., by last opened time, descending)
    _files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

    notifyListeners();
    debugPrint("Loaded ${_files.length} files.");
  }

  /// Adds a new file to the Hive box.
  Future<void> addFile(StudyFileModel file) async {
    // Use the file's unique ID as the Hive key
    await _box.put(file.id, file.toMap());
    // Add to local list and re-sort instead of full reload
    _files.add(file);
    _files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    notifyListeners();
  }

  /// Updates an existing file in the Hive box.
  Future<void> updateFile(StudyFileModel file) async {
    // Use the file's ID directly as the key
    if (_box.containsKey(file.id)) {
      await _box.put(file.id, file.toMap());
      // Update the item in the local list
      final index = _files.indexWhere((f) => f.id == file.id);
      if (index != -1) {
        _files[index] = file;
        // Re-sort if the update affects sorting criteria (like lastOpened)
        _files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
        notifyListeners();
      } else {
        // If not found in memory, reload (edge case)
        await loadFiles();
      }
    } else {
      debugPrint("Error: Tried to update file with ID ${file.id} which doesn't exist in the box.");
      // Optionally add it if it should exist
      // await addFile(file);
    }
  }

  /// Saves the last read page for a specific file ID.
  Future<void> saveLastPage(String id, int page) async {
     int fileIndex = -1;
     try {
       fileIndex = _files.indexWhere((f) => f.id == id);
       if (fileIndex == -1) throw Exception("File not found in memory list _files");
     } catch (e) {
       debugPrint("Error finding file $id in saveLastPage: $e");
       return; // Exit if file isn't found in the current list
     }

     // Get the file model instance from the list
     StudyFileModel fileToUpdate = _files[fileIndex];

     // Update the local model instance's properties
     fileToUpdate.lastPage = page;
     fileToUpdate.lastOpened = DateTime.now(); // Update last opened time

     // 1. Persist the 'last read' info using ReadingHistoryService
     await ReadingHistoryService.logLastRead(
      //  fileId: id, // Pass ID if service needs it
       filePath: fileToUpdate.path,
       fileName: fileToUpdate.name,
       fileType: fileToUpdate.type,
       currentPage: page, // Use 'currentPage' key as expected by Home
     );

     // 2. Update the full file data in the main studyFilesBox
     await _box.put(id, fileToUpdate.toMap()); // Overwrite the existing entry with updated data

     // 3. Re-sort the local list and notify listeners
     _files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
     notifyListeners(); // This updates Home via context.watch

     debugPrint("Saved last page $page for file ID $id, updated history, and notified listeners.");
  }


  /// Deletes a file from the Hive box.
  Future<void> deleteFile(String id) async {
    // Use the file's ID directly as the key
    if (_box.containsKey(id)) {
      await _box.delete(id);
      // Remove from local list and notify
      _files.removeWhere((f) => f.id == id);
      notifyListeners();
    } else {
      debugPrint("Error: Tried to delete file with ID $id which doesn't exist in the box.");
    }
  }

  /// Adds a note to a specific file.
  Future<void> addNote(String id, String text) async {
     int index = _files.indexWhere((f) => f.id == id);
     if (index != -1) {
        StudyFileModel file = _files[index];
        // Ensure notes list exists
        file.notes ??= [];
        file.notes!.add({'text': text, 'date': DateTime.now().toIso8601String()}); // Use ISO string
        await _box.put(id, file.toMap()); // Save updated file back to Hive
        // No need to update _files[index] = file; because lists are reference types
        notifyListeners(); // Notify UI about the change
        debugPrint("Added note to file ID $id");
     } else {
        debugPrint("Error: Could not find file ID $id to add note.");
     }
  }

  /// Adds a key point to a specific file.
  Future<void> addKeyPoint(String id, String point) async {
     int index = _files.indexWhere((f) => f.id == id);
     if (index != -1) {
        StudyFileModel file = _files[index];
        // Ensure keyPoints list exists
        file.keyPoints ??= [];
        file.keyPoints!.add(point);
        await _box.put(id, file.toMap()); // Save updated file back to Hive
        notifyListeners(); // Notify UI
        debugPrint("Added key point to file ID $id");
     } else {
       debugPrint("Error: Could not find file ID $id to add key point.");
     }
  }
}
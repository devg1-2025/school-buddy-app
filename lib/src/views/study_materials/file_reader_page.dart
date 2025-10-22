import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileReaderPage extends StatefulWidget {
  final Map file;
  const FileReaderPage({super.key, required this.file});

  @override
  State<FileReaderPage> createState() => _FileReaderPageState();
}

class _FileReaderPageState extends State<FileReaderPage> {
  final _box = Hive.box('studyFilesBox');
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _keyPointController = TextEditingController();

  late Map file;

  @override
  void initState() {
    super.initState();
    file = Map.from(widget.file);

    // Jump to last page if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastPage = file['lastPage'];
      if (lastPage != null) {
        _pdfViewerController.jumpToPage(lastPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Add Note',
            onPressed: () => _addNoteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            tooltip: 'Add Key Point',
            onPressed: () => _addKeyPointDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'View Notes',
            onPressed: () => _showNotesSheet(context),
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(file['path']),
        controller: _pdfViewerController,
        onPageChanged: (PdfPageChangedDetails details) async {
          await _saveLastPage(details.newPageNumber);
        },
        onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
          if (details.selectedText != null &&
              details.selectedText!.trim().isNotEmpty) {
            _showHighlightBar(details.selectedText!);
          }
        },
      ),
    );
  }

  // 📝 Add Note
  void _addNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Write your note...'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_noteController.text.trim().isEmpty) return;
              await _saveNote(_noteController.text.trim());
              _noteController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 🌟 Add Key Point
  void _addKeyPointDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Key Point'),
        content: TextField(
          controller: _keyPointController,
          decoration: const InputDecoration(hintText: 'Enter key point...'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_keyPointController.text.trim().isEmpty) return;
              await _saveKeyPoint(_keyPointController.text.trim());
              _keyPointController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 📚 View Notes & Key Points
  void _showNotesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final notes = (file['notes'] ?? []) as List;
        final keyPoints = (file['keyPoints'] ?? []) as List;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📝 Notes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (notes.isEmpty)
                  const Text('No notes yet.')
                else
                  ...notes
                      .map((n) => ListTile(
                            leading: const Icon(Icons.edit_note_outlined),
                            title: Text(n['text']),
                            subtitle: Text(n['date']),
                          ))
                      ,
                const Divider(height: 32),
                const Text('⭐ Key Points',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (keyPoints.isEmpty)
                  const Text('No key points yet.')
                else
                  ...keyPoints
                      .map((kp) => ListTile(
                            leading: const Icon(Icons.star, color: Colors.amber),
                            title: Text(kp),
                          ))
                      ,
              ],
            ),
          ),
        );
      },
    );
  }

  // 💾 Save Note
  Future<void> _saveNote(String text) async {
    final updatedNotes = List<Map>.from(file['notes'] ?? []);
    updatedNotes.add({'text': text, 'date': DateTime.now().toString()});
    file['notes'] = updatedNotes;
    await _updateHiveFile();
  }

  // 💾 Save Key Point
  Future<void> _saveKeyPoint(String text) async {
    final updatedKeyPoints = List<String>.from(file['keyPoints'] ?? []);
    updatedKeyPoints.add(text);
    file['keyPoints'] = updatedKeyPoints;
    await _updateHiveFile();
  }

  // 💾 Save Last Page
  Future<void> _saveLastPage(int page) async {
    file['lastPage'] = page;
    file['lastOpened'] = DateTime.now().toString();
    await _updateHiveFile();
  }

  // 📘 Update Hive Record
  Future<void> _updateHiveFile() async {
    final key = _box.keys.firstWhere((k) => _box.get(k)['id'] == file['id']);
    await _box.put(key, file);
    setState(() {});
  }

  // ✨ Highlight Handling
  void _showHighlightBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add highlight as key point?'),
        action: SnackBarAction(
          label: 'Add',
          onPressed: () async {
            await _saveKeyPoint(text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added as key point!')),
            );
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

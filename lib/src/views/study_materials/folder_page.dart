import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';
import '../../models/study_file.dart';


class FolderDetailPage extends StatefulWidget {
  final String folderId;
  final String folderName;

  const FolderDetailPage({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  final box = Hive.box('studyFolders');
  List<Map<String, dynamic>> folders = [];
  List<StudyFile> files = [];
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  void loadFolders() {
    final data = box.get('folders', defaultValue: []) as List;
    folders = List<Map<String, dynamic>>.from(data);

    final folder = folders.firstWhere((f) => f['id'] == widget.folderId,
        orElse: () => {'files': []});
    final fileList = folder['files'] ?? [];

    files = fileList
        .map<StudyFile>((m) => StudyFile.fromMap(Map<String, dynamic>.from(m)))
        .toList();

    setState(() {});
  }

  void saveFolders() {
    final folderIndex =
        folders.indexWhere((f) => f['id'] == widget.folderId);
    if (folderIndex != -1) {
      folders[folderIndex]['files'] = files.map((f) => f.toMap()).toList();
    }
    box.put('folders', folders);
  }

  Future<void> addFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = result.files.first;
    final newFile = StudyFile(
      id: uuid.v4(),
      name: file.name,
      path: file.path ?? '',
      type: file.extension ?? 'unknown',
      addedOn: DateTime.now(),
    );

    setState(() {
      files.add(newFile);
    });
    saveFolders();
  }

  void openFile(StudyFile file) {
    OpenFilex.open(file.path);
  }

  void deleteFile(StudyFile file) {
    setState(() {
      files.removeWhere((f) => f.id == file.id);
    });
    saveFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: files.isEmpty
          ? const Center(
              child: Text(
                'No files yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(
                    file.type.contains('pdf')
                        ? Icons.picture_as_pdf
                        : Icons.insert_drive_file,
                    color: Colors.blue,
                  ),
                  title: Text(file.name),
                  subtitle: Text(
                      'Added on ${file.addedOn.toLocal().toString().split(".").first}'),
                  onTap: () => openFile(file),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => deleteFile(file),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}

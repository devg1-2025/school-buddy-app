import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'file_reader_page.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  final _box = Hive.box('studyFilesBox');

  @override
  Widget build(BuildContext context) {
    final files = _box.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickFile,
          )
        ],
      ),
      body: files.isEmpty
          ? const Center(child: Text('No files added yet'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(file['name']),
                    subtitle: Text(file['path']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FileReaderPage(file: file),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      await _box.add({
        'id': id,
        'name': name,
        'path': path,
        'type': 'pdf',
        'lastPage': 1,
        'notes': [],
        'keyPoints': [],
        'lastOpened': DateTime.now().toString(),
      });

      setState(() {});
    }
  }
}

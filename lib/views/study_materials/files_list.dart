import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/study_file_model.dart';
import '../../services/reading_history_service.dart';
import 'file_reader_page.dart';
import '../../view_models/study_files_viewmodel.dart';

class FileListPage extends StatelessWidget {
  const FileListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudyFilesViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Study Files',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: vm.files.isEmpty
          ? _buildEmptyState(context)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: vm.files.length,
                itemBuilder: (context, index) {
                  final file = vm.files[index];
                  final fileColor = _fileColor(file.type);
                  final icon = _fileIcon(file.type);

                  return GestureDetector(
                    onTap: () async {
                      await ReadingHistoryService.logLastRead(
                        filePath: file.path,
                        fileName: file.name,
                        fileType: file.type,
                        currentPage: file.lastPage,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FileReaderPage(file: file),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: fileColor.withOpacity(0.15),
                          radius: 26,
                          child: Icon(icon, color: fileColor, size: 26),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          file.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert_rounded),
                          onPressed: () => _showFileOptions(context, vm, index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickFile(context, vm),
        label: const Text('Add File'),
        icon: const Icon(Icons.upload_file_rounded),
      ),
    );
  }

  // -------------------------------
  // 🗂 Empty State UI
  // -------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              "No study files yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Start by uploading PDFs, documents, or slides for your courses.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text("Add File"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _pickFile(context, context.read<StudyFilesViewModel>()),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // 🎨 Helper: File Type Styles
  // -------------------------------
  IconData _fileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'docx':
        return Icons.description_rounded;
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'txt':
        return Icons.notes_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _fileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.redAccent;
      case 'docx':
        return Colors.blueAccent;
      case 'pptx':
        return Colors.orangeAccent;
      case 'txt':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // -------------------------------
  // 📁 Add File Function
  // -------------------------------
  Future<void> _pickFile(BuildContext context, StudyFilesViewModel vm) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ['pdf', 'docx', 'pptx', 'txt'],
      type: FileType.custom,
    );

    if (result != null && result.files.isNotEmpty) {
      for (final pickedFile in result.files) {
        if (pickedFile.path != null) {
          final file = StudyFileModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: pickedFile.name,
            path: pickedFile.path!,
            type: pickedFile.extension ?? 'file',
          );
          await vm.addFile(file);
        }
      }
    }
  }

  // -------------------------------
  // ⚙️ File Options Modal
  // -------------------------------
  void _showFileOptions(BuildContext context, StudyFilesViewModel vm, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final file = vm.files[index];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text("Delete File"),
                  onTap: () {
                    // vm.deleteFile(file);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text("Share"),
                  onTap: () {
                    // You can add share functionality here later
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

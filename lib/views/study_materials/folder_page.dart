import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_colors.dart';
import '../../models/study_file_model.dart';
import '../../services/reading_history_service.dart';
import '../../view_models/folders_viewmodel.dart';
import 'file_reader_page.dart';

class FolderPage extends StatefulWidget {
  final int folderIndex;
  final int? parentIndex;

  const FolderPage({super.key, required this.folderIndex, this.parentIndex});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoldersViewModel>();
    final primaryColor = const Color(0xFF073B4C);

    final folder = widget.parentIndex == null
        ? vm.folders[widget.folderIndex]
        : (vm.folders[widget.parentIndex!]['subfolders'] as List)[widget.folderIndex];

    final subfolders = List<Map<String, dynamic>>.from(folder['subfolders'] ?? []);
    final files = List<String>.from(folder['files'] ?? []);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
      foregroundColor: Color(AppColors.homeBgColor),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(folder['name'], style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _renameFolderDialog(context, vm, widget.folderIndex, widget.parentIndex),
          ),
          // IconButton(
          //   icon: const Icon(Icons.delete_outline, color: Colors.white),
          //   onPressed: () {
          //     vm.deleteFolder(widget.folderIndex, parentIndex: widget.parentIndex);
          //     Navigator.pop(context);
          //   },
          // ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (subfolders.isNotEmpty) ...[
              const Text(
                "Subfolders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                itemCount: subfolders.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final sub = subfolders[index];
                  return _buildSubfolderCard(context, sub, index, vm, primaryColor);
                },
              ),
              const SizedBox(height: 24),
            ],
        
            if (files.isNotEmpty) ...[
              const Text(
                "Files",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...files.asMap().entries.map((entry) {
                final index = entry.key;
                final path = entry.value;
                return _buildFileTile(context, vm, path, index, primaryColor);
              }),
            ],
        
            if (subfolders.isEmpty && files.isEmpty)
              _emptyFolderView(primaryColor),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context, vm),
    );
  }

  // ---------------------------
  // Subfolder Card
  // ---------------------------
  Widget _buildSubfolderCard(
      BuildContext context, Map<String, dynamic> sub, int index, FoldersViewModel vm, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FolderPage(folderIndex: index, parentIndex: widget.folderIndex),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.folder_rounded, color: color, size: 40),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'rename') {
                      _renameFolderDialog(context, vm, index, widget.folderIndex);
                    } else if (value == 'delete') {
                      vm.deleteFolder(index, parentIndex: widget.folderIndex);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Rename')]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete_outline, size: 18), SizedBox(width: 8), Text('Delete')]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              sub['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              "${(sub['files'] as List?)?.length ?? 0} files",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // File Tile
  // ---------------------------
  Widget _buildFileTile(BuildContext context, FoldersViewModel vm, String path, int index, Color primaryColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.insert_drive_file_rounded, color: primaryColor, size: 30),
        title: Text(path.split('/').last, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'delete') {
              vm.deleteFile(widget.folderIndex, index, parentIndex: widget.parentIndex);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [Icon(Icons.delete_outline, size: 18), SizedBox(width: 8), Text('Delete')]),
            ),
          ],
        ),
        onTap: () async {
          await ReadingHistoryService.logLastRead(
            fileName: path.split('/').last,
            filePath: path,
            folderId: widget.folderIndex.toString(),
            fileType: path.split('.').last,
          );

          final fileModel = StudyFileModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            path: path,
            name: path.split('/').last,
            type: path.split('.').last,
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FileReaderPage(file: fileModel)),
          );
        },
      ),
    );
  }

  // ---------------------------
  // Empty Folder View
  // ---------------------------
  Widget _emptyFolderView(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, color: primaryColor.withOpacity(0.6), size: 90),
          const SizedBox(height: 16),
          const Text("This folder is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Add subfolders or files using the + button",
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // ---------------------------
  // FAB Menu
  // ---------------------------
  Widget _buildFab(BuildContext context, FoldersViewModel vm) {
    final primaryColor = const Color(0xFF073B4C);

    return FloatingActionButton(
      backgroundColor: primaryColor,
      foregroundColor: Color(AppColors.homeBgColor),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          builder: (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.create_new_folder_rounded, color: primaryColor),
                    title: const Text("New Subfolder"),
                    onTap: () {
                      Navigator.pop(ctx);
                      _createSubfolderDialog(context, vm);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.upload_file_rounded, color: primaryColor),
                    title: const Text("Add File"),
                    onTap: () {
                      Navigator.pop(ctx);
                      _addFileDialog(context, vm, widget.folderIndex, widget.parentIndex);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: const Icon(Icons.add_rounded, color: Colors.white),
    );
  }

  // ---------------------------
  // Dialogs
  // ---------------------------
  void _createSubfolderDialog(BuildContext context, FoldersViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Subfolder'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Subfolder name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF073B4C)),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.addFolder(controller.text, parentIndex: widget.parentIndex ?? widget.folderIndex);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addFileDialog(BuildContext context, FoldersViewModel vm, folderIndex, parentIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'pptx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          if (file.path != null) {
            vm.addFileToFolder(folderIndex, file.path!, parentIndex: parentIndex);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _renameFolderDialog(BuildContext context, FoldersViewModel vm, int index, int? parentIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'New name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF073B4C)),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.renameFolder(index, controller.text, parentIndex: parentIndex);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Color(AppColors.homeBgColor)),),
          ),
        ],
      ),
    );
  }
}

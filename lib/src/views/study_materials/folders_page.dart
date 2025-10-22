import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'folder_page.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class FoldersPage extends FolderPage {
  const FoldersPage({super.key});
}

class _FolderPageState extends State<FolderPage> {
  final box = Hive.box('studyFolders');
  final uuid = const Uuid();

  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  void loadFolders() {
    final data = box.get('folders', defaultValue: []) as List;
    setState(() {
      folders = List<Map<String, dynamic>>.from(data);
    });
  }

  void saveFolders() {
    box.put('folders', folders);
  }

  void addFolder(String name) {
    final newFolder = {
      'id': uuid.v4(),
      'name': name,
    };
    setState(() {
      folders.add(newFolder);
    });
    saveFolders();
  }

  void showCreateFolderDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                addFolder(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
      ),
      body: folders.isEmpty
          ? const Center(
              child: Text(
                'No folders yet.\nTap + to create one.',
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FolderDetailPage(
                          folderId: folder['id'],
                          folderName: folder['name'],
                        ),
                      ),
                    ).then((_) => loadFolders());
                    // Navigate to folder detail page later
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => FolderDetailPage(folderId: folder['id'], folderName: folder['name'])));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder, size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          folder['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateFolderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

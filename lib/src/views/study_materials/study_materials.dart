import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'folders_page.dart';
import 'files_list.dart';

class StudyMaterials extends StatefulWidget {
  const StudyMaterials({super.key});

  @override
  State<StudyMaterials> createState() => _StudyMaterialsState();
}

class _StudyMaterialsState extends State<StudyMaterials> {
  // Sample data
  final List<Map<String, dynamic>> folders = [
    {'name': '200L - First semester', 'color': Colors.blue},
    {'name': '200L - Second semester', 'color': Colors.orange},
    {'name': '100L - First semester', 'color': Colors.green},
    {'name': 'English', 'color': Colors.purple},
  ];

  final List<Map<String, String>> files = [
    {'title': 'Algebra Basics.pdf', 'size': '2.5 MB'},
    {'title': 'Geometry Fundamentals.pdf', 'size': '3.1 MB'},
    {'title': 'Calculus Introduction.pdf', 'size': '4.0 MB'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.homeBgColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Study Materials",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search_rounded, size: 26),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Folders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Folders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoldersPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "View All >",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildFolderSection(),

              const SizedBox(height: 30),

              // Files Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Files",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FileListPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "View All >",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _buildFileSection(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Folder Section Widget
  // -------------------------
  Widget _buildFolderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.create_new_folder_rounded,
                    color: Colors.blue, size: 26),
                const SizedBox(width: 10),
                const Text("Create New Folder",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Horizontal folder list
          SizedBox(
            height: 140,
            child: folders.isEmpty
                ? const Center(
                    child: Text("No folders yet. Create one!"),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: folders.length,
                    separatorBuilder: (context, _) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return _folderItem(folder['name'], folder['color']);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Folder item
  Widget _folderItem(String name, Color color) {
    return GestureDetector(
      onTap: () {
        // handle folder open
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(15),
        width: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_rounded, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // File Section Widget
  // -------------------------
  Widget _buildFileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: files.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No files uploaded yet."),
              ),
            )
          : Column(
              children: files
                  .map(
                    (file) => Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf_rounded,
                              color: Colors.red, size: 30),
                          title: Text(
                            file['title']!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text("Size: ${file['size']}"),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert_rounded),
                          ),
                        ),
                        if (file != files.last)
                          const Divider(
                            color: Colors.grey,
                            indent: 10,
                            endIndent: 10,
                            height: 10,
                          ),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

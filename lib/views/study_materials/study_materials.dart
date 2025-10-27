import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/reading_history_service.dart';
import '../../view_models/folders_viewmodel.dart';
import '../../view_models/study_files_viewmodel.dart';
import '../../view_models/theme_provider.dart';

import 'folders_page.dart';
import 'folder_page.dart';
import 'file_reader_page.dart';
import 'files_list.dart';

class StudyMaterials extends StatefulWidget {
  const StudyMaterials({super.key});

  @override
  State<StudyMaterials> createState() => _StudyMaterialsState();
}

class _StudyMaterialsState extends State<StudyMaterials> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final folderVm = context.watch<FoldersViewModel>();
    final filesVm = context.watch<StudyFilesViewModel>();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppHeader(theme, context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Folders",
                      onViewAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllFoldersPage()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildFolderCarousel(folderVm, theme),
                    const SizedBox(height: 25),
                    _sectionHeader(
                      "Recent Files",
                      onViewAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FileListPage()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRecentFiles(filesVm, theme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(AppColors.primaryColor),
        label: const Text("New Folder", style: TextStyle(color: Color(AppColors.homeBgColor)),),
        icon: const Icon(Icons.create_new_folder_rounded, color: Color(AppColors.homeBgColor),),
        onPressed: () => _createNewFolderDialog(context, folderVm),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildAppHeader(ThemeProvider theme, BuildContext context) {
    return SliverAppBar(
      backgroundColor: theme.bannerStart,
      elevation: 0,
      pinned: true,
      expandedHeight: 140,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          "Study Materials",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.bannerStart, theme.bannerEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: Colors.white,
          ),
          onPressed: () => theme.toggleTheme(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ---------- SECTION HEADER ----------
  Widget _sectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text("View All >", style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  // ---------- FOLDER CAROUSEL ----------
  Widget _buildFolderCarousel(FoldersViewModel vm, ThemeProvider theme) {
    final folders = vm.recentFolders;
final colors = [
  const Color(0xFF25B28C), // calm aqua green
  const Color(0xFFDA8B52), // warm muted orange
  const Color(0xFF2E8FB3), // balanced blue
  const Color(0xFFD65877), // softened red-pink
  const Color(0xFF7B52D9), // elegant medium purple
];

    if (folders.isEmpty) {
      return _emptyCard(theme, "No folders yet", "Tap + to create a new one!");
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: folders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final folder = folders[index];
          final color = colors[index % colors.length];
          return GestureDetector(
            onTap: () {
              final folderIndex = vm.folders.indexOf(folder);
              if (folderIndex != -1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FolderPage(folderIndex: folderIndex)),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.folder_rounded, color: Colors.white, size: 38),
                  const Spacer(),
                  Text(
                    folder['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- RECENT FILES ----------
  Widget _buildRecentFiles(StudyFilesViewModel vm, ThemeProvider theme) {
    final files = vm.files;
    if (files.isEmpty) {
      return _emptyCard(theme, "No files yet", "Upload or open one to begin studying.");
    }

    return Column(
      children: files.take(5).map((file) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF118AB2).withOpacity(0.2),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF118AB2)),
            ),
            title: Text(file.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15)),
            subtitle: Text(
              file.type.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 12, color: theme.subTextColor),
            ),
            // trailing: IconButton(
            //   icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
            //   onPressed: () {},
            // ),
            onTap: () async {
              await ReadingHistoryService.logLastRead(
                filePath: file.path,
                fileName: file.name,
                fileType: file.type,
                currentPage: file.lastPage,
              );

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FileReaderPage(file: file)),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  // ---------- EMPTY STATE ----------
  Widget _emptyCard(ThemeProvider theme, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  // ---------- CREATE FOLDER DIALOG ----------
  void _createNewFolderDialog(BuildContext context, FoldersViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Create New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) vm.addFolder(controller.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

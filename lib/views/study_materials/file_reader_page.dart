// lib/views/study_materials/file_reader_page.dart
// Final revised FileReaderPage — fixes: padded action buttons, working slider,
// last-page persistence (Hive via StudyFilesViewModel), removed Study Hub.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/study_file_model.dart';
import '../../view_models/file_notes_viewmodel.dart';
import '../../view_models/study_files_viewmodel.dart';
import '../../constants/app_colors.dart';

class FileReaderPage extends StatefulWidget {
  final StudyFileModel file;
  const FileReaderPage({super.key, required this.file});

  @override
  State<FileReaderPage> createState() => _FileReaderPageState();
}

class _FileReaderPageState extends State<FileReaderPage> with SingleTickerProviderStateMixin {
  final GlobalKey pdfViewKey = GlobalKey();
  PDFViewController? _pdfController;

  DateTime? _lastSaveTime;


  bool isDarkMode = false;
  String readingTheme = 'day'; // 'day' | 'sepia' | 'night'
  bool isFocusMode = false;

  int currentPage = 0; // zero-based page index
  int totalPages = 0;
  bool pdfReady = false;

  // slider value for UI (1..totalPages)
  double _sliderValue = 1.0;

  late AnimationController _topBarAnim;

  @override
  void initState() {
    super.initState();
    _topBarAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // ================== FIX: INITIALIZE CURRENT PAGE ==================
   // Set the initial state based on the file's last known page
   currentPage = widget.file.lastPage;
   // Initialize slider value accordingly (ensure totalPages is handled later)
   _sliderValue = (currentPage + 1).toDouble();
   // =================================================================


    // load notes / data after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notesVm = context.read<FileNotesViewModel>();
      await notesVm.init();
      await notesVm.loadNotesForFile(widget.file.name);
      // We don't set the page here because PDF controller is provided in onViewCreated.
      // When controller is created we will restore lastPage.
    });

    // simple auto-night heuristic
    final hour = DateTime.now().hour;
    if (hour < 7 || hour >= 20) {
      isDarkMode = true;
      readingTheme = 'night';
    }
  }

  @override
  void dispose() {
    _topBarAnim.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Save the *final* current page on exit
    final studyFilesVm = context.read<StudyFilesViewModel>();
    print('FileReaderPage DISPOSE: Saving final page $currentPage for file ID ${widget.file.id}');
    studyFilesVm.saveLastPage(widget.file.id, currentPage);

    super.dispose();
  }

  // Background gradient colors based on theme
  Color get bgStartColor {
    if (readingTheme == 'sepia') return const Color(0xFFFBF3E7);
    return isDarkMode ? const Color(0xFF071014) : const Color(0xFFF6F8FA);
  }

  Color get bgEndColor {
    if (readingTheme == 'sepia') return const Color(0xFFF0E6D6);
    return isDarkMode ? const Color(0xFF0E2430) : const Color(0xFFEFF3F6);
  }

  Color get surfaceColor => isDarkMode ? Colors.black.withOpacity(0.42) : Colors.white.withOpacity(0.92);

  // Toggle focus/immersive reading
  Future<void> _toggleFocusMode() async {
    setState(() => isFocusMode = !isFocusMode);
    HapticFeedback.mediumImpact();
    if (isFocusMode) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _topBarAnim.reverse();
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _topBarAnim.forward();
    }
  }

  // Cycle color mode (day -> sepia -> night)
  void _cycleColorMode() {
    setState(() {
      if (readingTheme == 'day') {
        readingTheme = 'sepia';
        isDarkMode = false;
      } else if (readingTheme == 'sepia') {
        readingTheme = 'night';
        isDarkMode = true;
      } else {
        readingTheme = 'day';
        isDarkMode = false;
      }
    });
  }

  // Jump dialog used by the Jump button
  Future<void> _jumpToPageDialog() async {
    if (totalPages <= 0) return;
    final controller = TextEditingController(text: (currentPage + 1).toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jump to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter page (1 - $totalPages)', border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0 && val <= totalPages) {
                Navigator.pop(ctx, val - 1); // return zero-based index
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );

    if (result != null && _pdfController != null) {
      await _pdfController!.setPage(result);
      setState(() {
        currentPage = result;
        _sliderValue = (currentPage + 1).toDouble();
      });
      // persist last page to ViewModel / Hive
      context.read<StudyFilesViewModel>().saveLastPage(widget.file.id, currentPage);
    }
  }

  // Programmatic page jump (used by prev/next and slider end)
  Future<void> _goToPage(int pageIndex) async {
    if (_pdfController == null || totalPages == 0 || !pdfReady) return;
    final safeIndex = pageIndex.clamp(0, totalPages - 1);

    try {
      await _pdfController!.setPage(safeIndex);
      
    } catch (e) {
      print('FileReaderPage _goToPage: Error setting page: $e');
    }

    setState(() {
      currentPage = safeIndex;
      _sliderValue = (currentPage + 1).toDouble();
    });
    // persist last page
    context.read<StudyFilesViewModel>().saveLastPage(widget.file.id, currentPage);
  }

  // Notes sheet (unchanged visual, same UX)
  void _showNotesBottomSheet(BuildContext context, FileNotesViewModel vm) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF071418) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 18, right: 18, top: 18),
          child: StatefulBuilder(
            builder: (context, setState) {
              final notes = vm.notes;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  Text('Notes for ${widget.file.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 12),
                  if (notes.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('No notes yet. Add your thoughts below 💭', style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.black54)))
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: notes.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final n = notes[index];
                          return ListTile(
                            title: Text(n.text, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
                            subtitle: Text(DateFormat('MMM d, yyyy • hh:mm a').format(n.createdAt), style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                            trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent), onPressed: () async {
                              await vm.deleteNote(n.id);
                              await vm.loadNotesForFile(widget.file.name);
                              setState(() {});
                            }),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: 'Write a note...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save Note'),
                          onPressed: () async {
                            final text = noteController.text.trim();
                            if (text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write something first.')));
                              return;
                            }
                            await vm.addNote(text); // FileNotesViewModel.addNote(text)
                            await vm.loadNotesForFile(widget.file.name);
                            noteController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Key Points sheet: lists & add key points inline
  void _showKeyPointsBottomSheet(BuildContext context, StudyFilesViewModel vm) {
    final kpController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF071418) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 18, right: 18, top: 18),
          child: StatefulBuilder(
            builder: (context, setState) {
              // keyPointsForFile(fileId) expected to return List<String>
              // final keyPoints = vm.keyPointsForFile(widget.file.id);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  Text('Key Points for ${widget.file.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 12),
                  // if (keyPoints.isEmpty)
                  //   Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('No key points yet. Add important takeaways here.', style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.black54)))
                  // else
                  //   Flexible(
                  //     child: ListView.separated(
                  //       shrinkWrap: true,
                  //       itemCount: keyPoints.length,
                  //       separatorBuilder: (_, __) => const Divider(),
                  //       itemBuilder: (context, index) {
                  //         final kp = keyPoints[index];
                  //         return ListTile(
                  //           title: Text(kp, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
                  //           trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent), onPressed: () async {
                  //             await vm.removeKeyPoint(widget.file.id, kp); // ensure exists in viewmodel
                  //             setState(() {});
                  //           }),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: kpController,
                    maxLines: 2,
                    decoration: InputDecoration(hintText: 'Add key point...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save Key Point'),
                          onPressed: () async {
                            final text = kpController.text.trim();
                            if (text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write something first.')));
                              return;
                            }
                            await vm.addKeyPoint(widget.file.id, text); // StudyFilesViewModel.addKeyPoint
                            kpController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(AppColors.primaryColor);
    final notesVm = context.watch<FileNotesViewModel>();
    final vm = context.watch<StudyFilesViewModel>();

    return Scaffold(
      backgroundColor: bgStartColor,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleFocusMode,
          child: Stack(
            children: [
              // Background gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgStartColor, bgEndColor])),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    children: [
                      // Top title row (attached to top, minimal margins)
                      Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            // Back button on the left
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                                onPressed: () async {
                                    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

                                  // ✅ Save current page instantly before leaving
                                  final studyFilesVm = context.read<StudyFilesViewModel>();
                                  await studyFilesVm.saveLastPage(widget.file.id, currentPage);
                                  debugPrint('📗 Saved last page $currentPage before leaving ${widget.file.name}');

                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            // Title centered
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width /1.3,
                                child: Text(widget.file.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87))),
                            ),
                          ],
                        ),
                      ),
        
                      // PDF view fills remaining area
                     Expanded(
  child: Stack(
    children: [
      Positioned.fill(
        child: PDFView(
  filePath: widget.file.path,
  enableSwipe: true,
  swipeHorizontal: false,
  autoSpacing: false,
  pageFling: true,
  onRender: (pages) async {
    if (!mounted) return;

    setState(() {
      totalPages = pages ?? 0;
      pdfReady = true;
      _sliderValue = (currentPage + 1)
          .toDouble()
          .clamp(1.0, (totalPages == 0 ? 1.0 : totalPages.toDouble()));
    });

    // ✅ Restore last read page once PDF is rendered and controller is ready
    if (_pdfController != null &&
        widget.file.lastPage > 0 &&
        widget.file.lastPage < (pages ?? 0)) {
      await _pdfController!.setPage(widget.file.lastPage);
      setState(() {
        currentPage = widget.file.lastPage;
        _sliderValue = (currentPage + 1).toDouble();
      });
      debugPrint('📖 Restored to last page: ${widget.file.lastPage}');
    }
  },
  onViewCreated: (controller) {
    _pdfController = controller;
  },
  onPageChanged: (page, total) async {
    final newPage = page ?? 0;
    if (newPage != currentPage) {
      setState(() {
        currentPage = newPage;
        _sliderValue = (currentPage + 1).toDouble();
        totalPages = total ?? totalPages;
      });

      // ✅ Instant auto-save with light debounce
      final now = DateTime.now();
      if (_lastSaveTime == null ||
          now.difference(_lastSaveTime!).inSeconds >= 2) {
        _lastSaveTime = now;
        await context
            .read<StudyFilesViewModel>()
            .saveLastPage(widget.file.id, currentPage);
        debugPrint('📘 Auto-saved last page: $currentPage');
      }
    }
  },
  onError: (error) {
    debugPrint('❌ PDF Error: $error');
  },
  onPageError: (page, error) {
    debugPrint('⚠️ Page Error on $page: $error');
  },
),

      ),
      if (!pdfReady)
        const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      Positioned(
        top: 12,
        right: 12,
        child: AnimatedOpacity(
          opacity: pdfReady ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: _PageBubble(
            current: currentPage + 1,
            total: totalPages,
            dark: isDarkMode,
          ),
        ),
      ),
    ],
  ),
),

        
                      // BOTTOM toolbox (attached to edge) with padding for better visibility
                      _BottomToolbox(
                        themeColor: themeColor,
                        isDarkMode: isDarkMode,
                        sliderValue: _sliderValue,
                        totalPages: totalPages,
                        onSliderChange: (val) {
                          // live update while sliding (UI only)
                          setState(() => _sliderValue = val);
                        },
                        onSliderChangeEnd: (val) {
                          // user finished sliding; jump to page (convert to zero-based)
                          final target = (val.round() - 1).clamp(0, (totalPages > 0 ? totalPages - 1 : 0));
                          _goToPage(target);
                        },
                        onNotes: () => _showNotesBottomSheet(context, notesVm),
                        onKeyPoints: () => _showKeyPointsBottomSheet(context, vm),
                        onToggleMode: _cycleColorMode,
                        onJump: _jumpToPageDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// bottom toolbox widget (attached)
class _BottomToolbox extends StatelessWidget {
  final Color themeColor;
  final bool isDarkMode;
  final double sliderValue;
  final int totalPages;
  final ValueChanged<double> onSliderChange;
  final ValueChanged<double> onSliderChangeEnd;
  final VoidCallback onNotes;
  final VoidCallback onKeyPoints;
  final VoidCallback onToggleMode;
  final VoidCallback onJump;

  const _BottomToolbox({
    required this.themeColor,
    required this.isDarkMode,
    required this.sliderValue,
    required this.totalPages,
    required this.onSliderChange,
    required this.onSliderChangeEnd,
    required this.onNotes,
    required this.onKeyPoints,
    required this.onToggleMode,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.95);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar row with active slider that follows pages
        Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: themeColor),
              const SizedBox(width: 10),
              // Slider shows current progress (1..totalPages)
              Expanded(
                child: totalPages > 0
                    ? SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                        ),
                        child: Slider(
                          value: sliderValue.clamp(1.0, (totalPages > 0 ? totalPages.toDouble() : 1.0)),
                          min: 1.0,
                          max: (totalPages > 0 ? totalPages.toDouble() : 1.0),
                          divisions: totalPages > 0 ? totalPages - 1 : 1,
                          label: sliderValue.round().toString(),
                          onChanged: onSliderChange,
                          onChangeEnd: onSliderChangeEnd,
                        ),
                      )
                    : LinearProgressIndicator(
                        backgroundColor: Colors.grey.withOpacity(0.18),
                        color: themeColor,
                        minHeight: 6,
                      ),
              ),
              const SizedBox(width: 10),
              // page indicator
              Text('${sliderValue.round()}/${totalPages == 0 ? 0 : totalPages}', style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white70 : Colors.black87)),
            ],
          ),
        ),

        // Toolbox buttons attached to bottom edge, each with increased padding for visibility
        Container(
          color: bg,
          padding: const EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ToolButton(icon: Icons.notes_rounded, label: 'Notes', onTap: onNotes, themeColor: themeColor),
              _ToolButton(icon: Icons.sticky_note_2_outlined, label: 'Key Points', onTap: onKeyPoints, themeColor: themeColor),
              _ToolButton(icon: Icons.brightness_6_rounded, label: 'Mode', onTap: onToggleMode, themeColor: themeColor),
              _ToolButton(icon: Icons.find_in_page_rounded, label: 'Jump', onTap: onJump, themeColor: themeColor),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color themeColor;
  const _ToolButton({required this.icon, required this.label, required this.onTap, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final color = themeColor;
    // added padding & larger touch area for visibility/usability
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.06)),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _PageBubble extends StatelessWidget {
  final int current;
  final int total;
  final bool dark;
  const _PageBubble({required this.current, required this.total, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? Colors.black54 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Text('$current / $total', style: TextStyle(color: dark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w700)),
    );
  }
}

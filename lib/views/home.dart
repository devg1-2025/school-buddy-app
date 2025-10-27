// lib/views/home.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:school_buddy_app/views/deadlines/deadlines.dart';
import 'package:school_buddy_app/views/study_materials/study_materials.dart';
import '../services/reading_history_service.dart';
import '../../view_models/study_files_viewmodel.dart';
import '../../view_models/theme_provider.dart';
import '../models/study_file_model.dart';
import 'study_materials/file_reader_page.dart';
import '../constants/app_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String date = DateFormat.MMMMEEEEd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudyFilesViewModel>();
    final lastReadData = ReadingHistoryService.getLastRead();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;

  

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF081F24) : const Color(AppColors.homeBgColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            RotationTransition(turns: anim, child: child),
                        child: IconButton(
                          key: ValueKey(isDark),
                          icon: Icon(
                            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                            color: isDark ? Colors.amber[300] : Color(AppColors.primaryColor),
                          ),
                          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color(AppColors.primaryColor).withOpacity(0.15),
                        radius: 22,
                        child: Image.asset('lib/assets/logo/avatar_logo.png', height: 35,),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 25),

              Text(
                "Hi Scholar 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Ready to learn something new today?",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              // Motivational banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF0EA06B), Color(0xFF06604D)]
                        : [Color(AppColors.primaryColor), Color(AppColors.primaryColor).withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.35) : Colors.grey.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keep pushing 💪",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text("Small study steps lead to big wins!", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Upcoming Deadlines
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upcoming Deadline",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Deadlines())),
                    child: Text(
                      "View all",
                      style: TextStyle(color: Color(AppColors.primaryColor), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Upcoming deadline card (dynamic)
              UpcomingDeadlineCard(),

              const SizedBox(height: 25),

              // Continue Reading
              Text(
                "Continue Reading",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.grey[900]),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<Box>(
                valueListenable: Hive.box('reading_history').listenable(), 
                builder: (context, box, _){
                    final Map<String, dynamic>? lastReadData = ReadingHistoryService.getLastRead();
 
                if (lastReadData == null)
                  return _NoReadingCard(isDark: isDark);
                else
                  return _ReadingCard(lastReadData: lastReadData, isDark: isDark);
                  }
                  ),

              const SizedBox(height: 20),

              // Quick Actions
              Text(
                "Quick Actions",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.grey[900]),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: "Study Materials",
                      color: const Color(0xFF9FE2BF),
                      icon: Icons.menu_book_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyMaterials())),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: "Add Deadline",
                      color: const Color(0xFFA3B5F7),
                      icon: Icons.alarm_add_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Deadlines())),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upcoming deadline card (resilient parsing)

/// Upcoming deadline card (resilient parsing)
class UpcomingDeadlineCard extends StatelessWidget {
  const UpcomingDeadlineCard({super.key});

  // ================== FIX: HELPER METHODS MOVED INSIDE CLASS ==================
  
  /// Safely parses a date value (String, int, or DateTime)
  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v); // Handles ISO8601 strings
      } catch (_) {
        try {
          // Fallback: try parsing as milliseconds since epoch (if it's a number string)
          final n = int.parse(v);
          return DateTime.fromMillisecondsSinceEpoch(n);
        } catch (_) {
          return null; // Invalid string format
        }
      }
    }
    if (v is int) {
      // Assume integer is milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    return null; // Unsupported type
  }

  /// Formats the remaining time until the target date
  String _timeLeft(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return '⏰ Deadline passed';
    if (diff.inDays > 0) return 'Due in ${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
    if (diff.inHours > 0) return 'Due in ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
    if (diff.inMinutes > 0) return 'Due in ${diff.inMinutes} min';
    return 'Due very soon';
  }

  /// Builds the card shown when there are no upcoming deadlines
  Widget _emptyCard(ThemeProvider theme) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF0E2A30) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.isDarkMode ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.12)),
          boxShadow: [ // Added subtle shadow for light mode for consistency
            if (!theme.isDarkMode)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.celebration_rounded, color: theme.isDarkMode ? Colors.greenAccent[200] : Color(AppColors.primaryColor), size: 26),
            const SizedBox(width: 10),
            Text("No upcoming deadlines!", style: TextStyle(fontSize: 13, color: theme.isDarkMode ? Colors.grey[400] : Colors.black54)),
          ],
        ),
      );
  }
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Use ValueListenableBuilder to automatically react to Hive changes
    return ValueListenableBuilder(
      valueListenable: Hive.box('deadlinesBox').listenable(),
      builder: (context, box, _) {
        // --- Data Processing Logic ---
        final list = box.values
            .map((e) {
              if (e is Map) return Map<String, dynamic>.from(e);
              return <String, dynamic>{};
            })
            // Use 'dueDate' key and the helper method _parseDate
            .where((d) => _parseDate(d['dueDate']) != null)
            .toList();

        if (list.isEmpty) {
          // Use the helper method _emptyCard
          return _emptyCard(theme);
        }

        // Sort by parsed 'dueDate' ascending
        list.sort((a, b) {
          final at = _parseDate(a['dueDate'])!;
          final bt = _parseDate(b['dueDate'])!;
          return at.compareTo(bt);
        });

        final now = DateTime.now();
        // Find the first deadline whose 'dueDate' is after now
        final upcoming = list.firstWhere(
          (d) => _parseDate(d['dueDate'])!.isAfter(now),
          orElse: () => <String, dynamic>{},
        );

        if (upcoming.isEmpty) {
          // Use the helper method _emptyCard
          return _emptyCard(theme);
        }

        // Extract data safely using the helper methods
        final DateTime due = _parseDate(upcoming['dueDate'])!;
        final String title = (upcoming['title'] ?? 'Untitled Deadline').toString();
        // Use the helper method _timeLeft
        final String timeLeft = _timeLeft(due);
        // --- End of Data Processing ---

        // --- Build the Card UI ---
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.isDarkMode
                  ? const [Color(0xFF0EA06B), Color(0xFF06604D)]
                  : [Color(AppColors.primaryColor), Color(AppColors.primaryColor).withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.isDarkMode ? Colors.black.withOpacity(0.35) : Color(AppColors.primaryColor).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset('lib/assets/icons_3d/alarm_clock_3d.png', width: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(timeLeft, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // Optional: Add a subtle arrow or chevron
              // const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
            ],
          ),
        );
        // --- End of Card UI ---
      },
    );
  }
} // End of UpcomingDeadlineCard class


// Continue reading - no changes to structure
class _NoReadingCard extends StatelessWidget {
  final bool isDark;
  const _NoReadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E2A30) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Text("No recently read files", style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.black54)),
    );
  }
}

class _ReadingCard extends StatelessWidget {
 // Expect a Map<String, dynamic> but Map works
 final Map lastReadData;
 final bool isDark;

 const _ReadingCard({required this.lastReadData, required this.isDark});

 @override
 Widget build(BuildContext context) {
   // Construct the StudyFileModel using the correct keys from the ViewModel/Service
   final file = StudyFileModel(
     id: lastReadData['id']?.toString() ?? 'temp-${DateTime.now().millisecondsSinceEpoch}',
     path: lastReadData['filePath']?.toString() ?? '',
     name: lastReadData['fileName']?.toString() ?? 'Unknown File',
     type: lastReadData['fileType']?.toString() ?? 'pdf',
     // *** ENSURE THIS KEY 'lastPage' IS CORRECT ***
     lastPage: (lastReadData['lastPage'] as int?) ?? 0,
   );

   final String displayFileName = file.name;
   final int displayPage = file.lastPage; // Already 0-based

   return GestureDetector(
     // Pass the fully constructed 'file' object to the reader
     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FileReaderPage(file: file))),
     child: Container(
       padding: const EdgeInsets.all(18),
       decoration: BoxDecoration(
         color: isDark ? const Color(0xFF0E2A30) : Colors.white,
         borderRadius: BorderRadius.circular(14),
         boxShadow: [if (!isDark) BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 4))],
       ),
       child: Row(
         children: [
           // Consider a dynamic icon based on file.type
           Icon(Icons.menu_book, color: Color(AppColors.primaryColor), size: 36),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(displayFileName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                 const SizedBox(height: 4),
                 // Display 1-based page number for users
                 Text("Last page: ${displayPage + 1}", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
               ],
             ),
           ),
           const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
         ],
       ),
     ),
   );
 }
}

// Quick Action Card (keeps behaviour same as before)
class _QuickActionCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionCard({required this.title, required this.color, required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? color.withOpacity(0.16) : color;
    final border = isDark ? Border.all(color: color.withOpacity(0.28), width: 1.0) : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: border,
          boxShadow: [if (!isDark) BoxShadow(color: color.withOpacity(0.36), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: isDark ? Colors.white70 : Color(AppColors.primaryColor), size: 30),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : Color(AppColors.primaryColor), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

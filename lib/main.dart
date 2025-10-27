import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_buddy_app/view_models/file_notes_viewmodel.dart';
import './view_models/study_files_viewmodel.dart';
import './view_models/folders_viewmodel.dart';
import 'services/reading_history_service.dart';
import './view_models/theme_provider.dart';
import './view_models/deadlines_viewmodel.dart';
import 'services/notification_manager.dart';
import 'views/onboarding/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // FIX 1: (REMOVED) Do NOT register an adapter, as you are not using one.

  // Open boxes concurrently
  await Future.wait([
    Hive.openBox('studyFolders'),
    Hive.openBox('studyFilesBox'),
    Hive.openBox('studyNotesBox'),
    // FIX 2: Removed redundant 'deadlines' box (Still correct)
    Hive.openBox('deadlinesBox'), 
  ]);

  // Initialize reading history
  await ReadingHistoryService.init();

  // Initialize notifications
  final notificationManager = NotificationManager();
  await notificationManager.init();

  // Your commented-out code, which is fine to leave as is.
  // final deadlinesBox = Hive.box('deadlinesBox');
  // final deadlines = deadlinesBox.values.cast<DeadlineModel>().toList(); 
  // unawaited(notificationManager.autoSchedule(deadlines));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyFilesViewModel()..loadFiles()),
        ChangeNotifierProvider(create: (_) => FoldersViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // FIX 3: Call loadDeadlines() on init (Still correct)
        // This ensures your VM loads its data AND re-schedules
        // all notifications every time the app starts.
        ChangeNotifierProvider(create: (_) => DeadlinesViewModel()..loadDeadlines()), 

        ChangeNotifierProvider(create: (_) => FileNotesViewModel()..init()),
      ],
      child: const SchoolBuddyApp(),
    ),
  );
}

class SchoolBuddyApp extends StatelessWidget {
  const SchoolBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (rest of your file is perfect) ...
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF073B4C)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF073B4C),
          secondary: Color(0xFF06D6A0),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
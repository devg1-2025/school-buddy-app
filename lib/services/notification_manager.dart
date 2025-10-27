import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  
  // FIX: Flag to ensure init only runs once
  bool _isInitialized = false;

  NotificationManager._internal();

  Future<void> init() async {
    // FIX: Guard clause to make init idempotent
  if (_isInitialized) return;

    // 1. Initialize timezones
    tz.initializeTimeZones();
    
    // 2. THIS IS THE FIX:
    // Tell the library to use the phone's local timezone
    tz.setLocalLocation(tz.local); 

    // 3. The rest of your code is perfect
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // presentAlert: true,
      // presentBadge: true,
      // presentSound: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Request notification permission explicitly for Android 13+
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      debugPrint('🔔 Notification permission: $result');
    } else {
      debugPrint('🔔 Notification permission already granted');
    }
    
    _isInitialized = true; // FIX: Set flag after successful init
    debugPrint('✅ NotificationManager initialized');
  }

  // Show an instant/quick notification
  Future<void> showInstant({
    required String title,
    required String body,
    int id = 9990,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Instant',
          channelDescription: 'Instant feedback or updates',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  // Schedule a single notification at a specific DateTime
  Future<void> scheduleAt({
    required String title,
    required String body,
    required DateTime when,
    int id = 100,
  }) async {
    // ================== FIX IS HERE ==================
    try {
      final tzTime = tz.TZDateTime.from(when, tz.local);

      // Don't schedule if the time is in the past
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('⚠️ Tried to schedule notification (id:$id) in the past. Skipping.');
        return;
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            channelDescription: 'Scheduled reminders and deadlines',
            importance: Importance.max,
            priority: Priority.max,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Reminder scheduled (id:$id) at: $tzTime');
    } catch (e) {
      // "Swallow" the exception. This logs the error for you (the developer)
      // but does NOT crash the app for the user.
      debugPrint('🔥 FAILED TO SCHEDULE NOTIFICATION (id:$id). Error: $e');
      debugPrint('This is likely due to "Exact Alarms" permission being denied. The deadline was still saved.');
    }
    // =================================================
  }

  // Cancel a specific notification by id
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    debugPrint('🗑️ Cancelled notification id: $id');
  }

  // Clear all scheduled notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('🗑️ Cancelled all notifications');
  }

  // Daily reminder (repeating at a time)
  Future<void> scheduleDailyReminder() async {
    const hour = 8; // 8 AM daily
    const minute = 0;

    final now = tz.TZDateTime.now(tz.local);
    var firstTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (firstTime.isBefore(now)) firstTime = firstTime.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      3001,
      '📅 Daily Check-In',
      'Don’t forget to check your upcoming deadlines for today!',
      firstTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminders',
          channelDescription: 'Reminds users to check their deadlines every morning',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('✅ Daily reminder scheduled for $hour:$minute');
  }

  // Sunday evening (weekly)
  Future<void> scheduleSundayReminder() async {
    const sundayHour = 18; // 6 PM
    const sundayMinute = 0;

    final now = tz.TZDateTime.now(tz.local);
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 0) daysUntilSunday += 7;

    // Build next Sunday at 6PM
    final targetDay = now.add(Duration(days: daysUntilSunday));
    
    // FIX: Change to 'var' and add 'isBefore' check
    var nextSunday =
        tz.TZDateTime(tz.local, targetDay.year, targetDay.month, targetDay.day, sundayHour, sundayMinute);

    if (nextSunday.isBefore(now)) {
      nextSunday = nextSunday.add(const Duration(days: 7));
    }

    await _plugin.zonedSchedule(
      3002,
      '🌇 Sunday Reminder',
      'Tomorrow is Monday! Review your deadlines and plan ahead 📘',
      nextSunday,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_channel',
          'Weekly Sunday Reminder',
          channelDescription: 'Reminds users on Sunday evenings to prepare for Monday deadlines',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('✅ Sunday reminder scheduled for ${nextSunday.toLocal()}');
  }

  // Setup recurring reminders (call on app start)
  Future<void> setupRecurringNotifications() async {
    await scheduleDailyReminder();
    await scheduleSundayReminder();
    debugPrint('🔁 Recurring notifications set up.');
  }

  // 🧹 CRITICAL FIX: Clear *delivered* (active in tray) notifications, not *all* notifications
  Future<void> clearPastNotifications() async {
    try {
      // Get all notifications currently in the tray
      final List<ActiveNotification> activeNotifications =
          await _plugin.getActiveNotifications();

      // Loop and cancel each one by its ID
      for (final notification in activeNotifications) {
        if (notification.id != null) {
          await _plugin.cancel(notification.id!);
        }
      }
      debugPrint('🧹 Cleared ${activeNotifications.length} delivered notifications from the tray.');
    } catch (e) {
      debugPrint('⚠️ Error clearing past notifications: $e');
    }
  }
}
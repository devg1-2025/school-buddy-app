// lib/view_models/deadlines_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 Import permission_handler
import 'dart:io'; // 👈 Import for checking platform
import '../../models/deadlines_model.dart';
import '../services/notification_manager.dart';

class DeadlinesViewModel extends ChangeNotifier {
  final _box = Hive.box('deadlinesBox');
  final NotificationManager _notifications = NotificationManager();

  List<DeadlineModel> _deadlines = [];
  List<DeadlineModel> get deadlines => _deadlines;

  // Use unique IDs for instant feedback notifications
  static const int _instantSuccessId = 9999;
  static const int _instantErrorId = 9998;

  DeadlinesViewModel() {
    loadDeadlines();
  }

  /// ✅ Load deadlines from Hive
  Future<void> loadDeadlines() async {
    _deadlines = _box.keys.map((key) {
      final data = Map<String, dynamic>.from(_box.get(key));
      return DeadlineModel.fromMap(data, key.toString());
    }).toList();

    _deadlines.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }


  /// ✅ Add a new deadline (and schedule notifications)
  Future<void> addDeadline(DeadlineModel deadline) async {
    // 1. Save to Hive *first*. This must always succeed.
    final int newKey = await _box.add(deadline.toMap());
    
    // 2. Create a copy with the new ID
    final newDeadlineWithId = DeadlineModel(
      id: newKey.toString(),
      title: deadline.title,
      dueDate: deadline.dueDate,
    );

    // 3. Check permissions, schedule, and show feedback
    await _handleNotificationScheduling(
      deadline: newDeadlineWithId,
      successTitle: "Deadline Added",
      successBody: "${newDeadlineWithId.title} is due ${newDeadlineWithId.remainingTime}.",
    );
    
    // 4. Refresh the list
    await loadDeadlines();
  }

  /// ✅ Update an existing deadline (and reschedule)
  Future<void> updateDeadline(DeadlineModel deadline) async {
    if (deadline.id == null) return;
    final key = int.tryParse(deadline.id!);
    if (key == null) return;

    // 1. Save the updated data *first*.
    await _box.put(key, deadline.toMap());

    // 2. Check permissions, schedule, and show feedback
    await _handleNotificationScheduling(
      deadline: deadline,
      isUpdate: true,
      successTitle: "Deadline Updated",
      successBody: "${deadline.title} is due ${deadline.remainingTime}.",
    );

    // 3. Refresh the list
    await loadDeadlines();
  }

  /// ✅ Delete a deadline (and cancel notifications)
  Future<void> deleteDeadline(String id) async {
    final key = int.tryParse(id);
    if (key == null) return;

    // Try to cancel notifications, but don't stop if it fails
    try {
      await _cancelNotificationsFor(id);
    } catch (e) {
      debugPrint('VM: Failed to cancel notification: $e.');
    }
    
    await _box.delete(key);
    await loadDeadlines();
  }

  // =======================================================================
  // 🔔 NEW HELPER: Handles all scheduling, permission, and feedback logic
  // =======================================================================
  
  /// Checks permissions, schedules notifications, and shows instant feedback.
  Future<void> _handleNotificationScheduling({
    required DeadlineModel deadline,
    required String successTitle,
    required String successBody,
    bool isUpdate = false,
  }) async {
    // 1. Check permissions (and request if missing)
    final bool permissionsGranted = await _checkAndRequestPermissions();

    try {
      if (permissionsGranted) {
        // 2a. If granted, schedule (or reschedule)
        if (isUpdate) {
          await _cancelNotificationsFor(deadline.id);
        }
        await _scheduleNotificationsForDeadline(deadline);

        // Show instant SUCCESS notification
        await _notifications.showInstant(
          id: _instantSuccessId,
          title: successTitle,
          body: successBody,
        );
      } else {
        // 2b. If denied, show the "Warning" notification
        await _notifications.showInstant(
          id: _instantErrorId,
          title: "⚠️ Reminders Off",
          body: "Deadline was saved, but reminders are disabled. Please grant 'Alarms & reminders' permission in your settings.",
        );
      }
    } catch (e) {
      // 3. Failsafe: Catch any other error (like a scheduling bug)
      debugPrint('VM: Failed to schedule/reschedule notification: $e.');
      await _notifications.showInstant(
        id: _instantErrorId,
        title: "⚠️ Notification Error",
        body: "Deadline was saved, but an error occurred while setting the reminder.",
      );
    }
  }

  /// Checks and requests necessary permissions.
  Future<bool> _checkAndRequestPermissions() async {
    if (!Platform.isAndroid) {
      // iOS permissions are handled by flutter_local_notifications init
      return true; 
    }

    // 1. Check for standard notification permission
    var notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      notificationStatus = await Permission.notification.request();
    }

    // 2. Check for exact alarm permission
    var alarmStatus = await Permission.scheduleExactAlarm.status;
    if (alarmStatus.isDenied) {
      alarmStatus = await Permission.scheduleExactAlarm.request();
    }

    // Return true only if *both* are granted
    return notificationStatus.isGranted && alarmStatus.isGranted;
  }

  // =======================================================================
  // 🔔 NOTIFICATION LOGIC (No changes needed below this line)
  // =======================================================================

  int _toIntId(dynamic rawId) {
    if (rawId is int) return rawId;
    if (rawId is String) return int.tryParse(rawId) ?? DateTime.now().millisecondsSinceEpoch % 100000;
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  int _baseIdFor(dynamic rawId) {
    final id = _toIntId(rawId);
    return id * 10;
  }

  Future<void> _cancelNotificationsFor(dynamic rawId) async {
    final baseId = _baseIdFor(rawId);
    for (int i = 0; i < 4; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  Future<void> _scheduleNotificationsForDeadline(DeadlineModel d) async {
    final DateTime due = d.dueDate;
    final now = DateTime.now();
    if (due.isBefore(now)) return;

    final baseId = _baseIdFor(d.id);
    final String title = d.title;

    // 1 day before
    final dayBefore = due.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(now)) {
      await _notifications.scheduleAt(
        id: baseId + 0,
        title: 'Deadline Reminder',
        body: '📅 $title is due tomorrow.',
        when: dayBefore,
      );
    }
    // 1 hour before
    final hourBefore = due.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(now)) {
      await _notifications.scheduleAt(
        id: baseId + 1,
        title: 'Deadline Reminder',
        body: '⏰ $title is in 1 hour.',
        when: hourBefore,
      );
    }
    // 30 minutes before
    final thirtyBefore = due.subtract(const Duration(minutes: 30));
    if (thirtyBefore.isAfter(now)) {
      await _notifications.scheduleAt(
        id: baseId + 2,
        title: 'Deadline Reminder',
        body: '⚠️ $title is in 30 minutes.',
        when: thirtyBefore,
      );
    }
    // At exact due time
    if (due.isAfter(now)) {
      await _notifications.scheduleAt(
        id: baseId + 3,
        title: 'Deadline Reminder',
        body: '🚨 $title is due now!',
        when: due,
      );
    }
  }
}
// lib/views/deadlines/deadlines.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/deadlines_model.dart';
import '../../services/notification_manager.dart'; // 👈 Still needed for init
import '../../view_models/deadlines_viewmodel.dart';
import '../../view_models/theme_provider.dart';
import '../../constants/app_colors.dart';

class Deadlines extends StatefulWidget {
  const Deadlines({super.key});

  @override
  State<Deadlines> createState() => _DeadlinesState();
}

class _DeadlinesState extends State<Deadlines> {
  Timer? _timer;
  bool showCountdown = false;
  // NotificationManager is no longer needed as a state variable

  @override
  void initState() {
    super.initState();

    // Setup recurring notifications (still a good place for this)
    Future.microtask(() async {
      final manager = NotificationManager();
      await manager.init();
      await manager.clearPastNotifications();
      await manager.setupRecurringNotifications();
    });
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatRemaining(Duration diff) {
    if (diff.isNegative) return "Deadline Passed ⏰";
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return "Due in $days d, $hours hr";
    if (hours > 0) return "Due in $hours hr, $minutes min";
    if (minutes > 0) return "Due in $minutes min, $seconds sec";
    return "Due in $seconds sec";
  }
  
  // ALL NOTIFICATION HELPER METHODS HAVE BEEN REMOVED FROM THIS FILE.
  // They now live *exclusively* in the ViewModel.

  @override
  Widget build(BuildContext context) {
    // Use context.watch() in build to listen for changes
    final vm = context.watch<DeadlinesViewModel>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF081F24) : Color(AppColors.homeBgColor),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E2A30),
        foregroundColor: Color(AppColors.homeBgColor),
        elevation: isDark ? 0 : 1,
        title: const Text('Deadlines', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Color(AppColors.homeBgColor),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Add Deadline", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showDeadlineDialog(context),
      ),
      body: vm.deadlines.isEmpty
          ? Center(
              child: Text(
                'No deadlines yet 🎯',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 15,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: vm.deadlines.length,
              itemBuilder: (context, i) {
                final d = vm.deadlines[i];
                final isExpired = d.dueDate.isBefore(DateTime.now());
                final formattedDate =
                    DateFormat('EEE, MMM d • hh:mm a').format(d.dueDate);
                final diff = d.dueDate.difference(DateTime.now());

                return GestureDetector(
                  onTap: () => setState(() {
                    showCountdown = !showCountdown;
                    if (showCountdown) _startTimer();
                    else _stopTimer();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0E2A30) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isExpired
                                ? Colors.redAccent.withOpacity(0.15)
                                : Color(AppColors.primaryColor).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isExpired
                                ? Icons.warning_amber_rounded
                                : Icons.alarm_rounded,
                            color: isExpired
                                ? Colors.redAccent
                                : Color(AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    showCountdown
                                        ? Icons.timer_rounded
                                        : Icons.calendar_today_rounded,
                                    size: 14,
                                    color: isExpired
                                        ? Colors.redAccent
                                        : Color(AppColors.primaryColor),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    showCountdown
                                        ? _formatRemaining(diff)
                                        : formattedDate,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isExpired
                                          ? Colors.redAccent
                                          : Color(AppColors.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          color:
                              isDark ? const Color(0xFF0E2A30) : Colors.white,
                          icon: Icon(Icons.more_vert,
                              color:
                                  isDark ? Colors.white70 : Colors.grey[700]),
                          onSelected: (value) async {
                            // Use context.read() in callbacks
                            final vm = context.read<DeadlinesViewModel>();
                            if (value == 'edit') {
                              _showDeadlineDialog(context, d);
                            }
                            if (value == 'delete') {
                              final deadlineId = d.id;
                              if (deadlineId != null) {
                                // Just tell the ViewModel to delete.
                                // It handles the logic.
                                await vm.deleteDeadline(deadlineId);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeadlineDialog(BuildContext context, [DeadlineModel? existing]) {
    // Use context.read() in a dialog, as it's a one-time operation
    final vm = context.read<DeadlinesViewModel>();
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final titleController = TextEditingController(text: existing?.title ?? '');
    DateTime? selectedDate = existing?.dueDate;
    TimeOfDay? selectedTime =
        existing != null ? TimeOfDay.fromDateTime(existing.dueDate) : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0E2A30) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Add Deadline' : 'Edit Deadline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? "📅 No date selected"
                            : "📅 ${DateFormat('EEE, MMM d, yyyy').format(selectedDate!)}",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      child: const Text("Select Date"),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedTime == null
                            ? "⏰ No time selected"
                            : "⏰ ${selectedTime!.format(context)}",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                      child: const Text("Select Time"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a title and select a date')),
                      );
                      return;
                    }

                    final time = selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
                    final finalDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      time.hour,
                      time.minute,
                    );
                    
                    final newDeadline = DeadlineModel(
                      id: existing?.id, // Pass ID if editing
                      title: titleController.text.trim(),
                      dueDate: finalDateTime,
                    );

                    // ======================================================
                    // BUG FIX:
                    // 1. `await` the async save operation.
                    // 2. Call the correct ViewModel method.
                    // 3. Check `mounted` before popping the navigator.
                    // ======================================================
                    
                    // Show a loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      if (existing == null) {
                        await vm.addDeadline(newDeadline);
                      } else {
                        await vm.updateDeadline(newDeadline);
                      }

                      // Pop loading indicator
                      if (mounted) Navigator.pop(context); 
                      // Pop modal sheet
                      if (mounted) Navigator.pop(context); 

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Deadline saved and reminders scheduled!')),
                      );
                    } catch (e) {
                      // Pop loading indicator
                      if (mounted) Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error saving deadline: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_rounded,
                      color: Color(AppColors.homeBgColor)),
                  label: Text(
                    existing == null ? 'Add Deadline' : 'Update Deadline',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Color(AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class Deadlines extends StatefulWidget {
  const Deadlines({super.key});

  @override
  State<Deadlines> createState() => _DeadlinesState();
}

class _DeadlinesState extends State<Deadlines> {
  int? selectedIndex;
  Timer? _timer;
  late Box deadlinesBox;

  final Color primary = const Color(0xFF073B4C);
  final Color accent = const Color(0xFFF4A261);
  final Color lightBg = const Color(0xFFF7F9FB);
  final Color cardColor = const Color(0xFFE0E7EC);

  @override
  void initState() {
    super.initState();
    deadlinesBox = Hive.box('deadlines');
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get deadlines {
    final data = deadlinesBox.toMap();
    final list = data.entries.map((e) {
      final d = Map<String, dynamic>.from(e.value);
      d['id'] = e.key;
      return d;
    }).toList();

    list.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    return list;
  }

  // --- ADD OR EDIT DEADLINE ---
  Future<void> _openDeadlineDialog({Map<String, dynamic>? existing}) async {
    final titleController = TextEditingController(text: existing?['title']);
    DateTime? selectedDate = existing?['time'];
    TimeOfDay? selectedTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: lightBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            DateTime? combinedDateTime() {
              if (selectedDate == null) return null;
              if (selectedTime == null) {
                return DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, 23, 59);
              }
              return DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existing == null ? "Add Deadline" : "Edit Deadline",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: primary),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primary, foregroundColor: Colors.white),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(selectedDate == null
                              ? "Select Date"
                              : DateFormat.yMMMMd().format(selectedDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: accent, foregroundColor: Colors.white),
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime == null
                              ? "Optional Time"
                              : selectedTime!.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setModalState(() => selectedTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (titleController.text.isNotEmpty && selectedDate != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.preview, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Preview: ${titleController.text} - ${DateFormat.yMMMd().add_jm().format(combinedDateTime()!)}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (titleController.text.isEmpty || selectedDate == null) return;
                      final dateTime = combinedDateTime();

                      if (existing != null) {
                        await deadlinesBox.put(existing['id'], {
                          'title': titleController.text,
                          'time': dateTime,
                        });
                      } else {
                        await deadlinesBox.add({
                          'title': titleController.text,
                          'time': dateTime,
                          'isDone': false,
                        });
                      }

                      if (mounted) setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text(existing == null ? "Save" : "Update",
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- TIME & COUNTDOWN ---
  String timeLeft(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);
    if (diff.isNegative) return 'Deadline passed';
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} to go';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} to go';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} to go';
    return '${diff.inSeconds} sec${diff.inSeconds > 1 ? 's' : ''} to go';
  }

  Map<String, String> detailedCountdown(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final mins = diff.inMinutes % 60;
    return {
      'days': days.toString(),
      'hours': hours.toString(),
      'mins': mins.toString(),
    };
  }

  // --- MAIN UI ---
  @override
  Widget build(BuildContext context) {
    final hasDeadlines = deadlines.isNotEmpty;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Deadlines", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: _openDeadlineDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: hasDeadlines
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deadlines.length,
              itemBuilder: (context, index) {
                final deadline = deadlines[index];
                final isFocused = selectedIndex == index;
                final time = deadline['time'] as DateTime;
                final countdown = detailedCountdown(time);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              deadline['title'],
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: primary),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.black54),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                _openDeadlineDialog(existing: deadline);
                              } else if (value == 'delete') {
                                await deadlinesBox.delete(deadline['id']);
                                setState(() {});
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat.yMMMMd().add_jm().format(time),
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        timeLeft(time),
                        style: TextStyle(
                            color: diffColor(time), fontWeight: FontWeight.w500),
                      ),
                      if (isFocused)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _timeBox(countdown['days']!, "Days"),
                              const SizedBox(width: 8),
                              _timeBox(countdown['hours']!, "Hrs"),
                              const SizedBox(width: 8),
                              _timeBox(countdown['mins']!, "Min"),
                            ],
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = isFocused ? null : index;
                          });
                        },
                        child: Center(
                          child: Icon(
                            isFocused
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: primary,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          : const Center(child: Text("No deadlines yet. Tap + to add one.")),
    );
  }

  Color diffColor(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return Colors.redAccent;
    if (diff.inHours < 24) return accent;
    return primary;
  }

  Widget _timeBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

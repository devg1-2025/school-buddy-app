import 'package:flutter/material.dart';
import 'package:school_buddy_app/constants/app_colors.dart';
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

  final List<Map<String, dynamic>> deadlines = [
    {'title': 'Submit Assignment', 'time': DateTime.now().add(Duration(days: 2))},
    {'title': 'Team Meeting', 'time': DateTime.now().add(Duration(hours: 6))},
    {'title': 'Project Demo', 'time': DateTime.now().add(Duration(minutes: 5))},
  ];

  @override
  void initState() {
    super.initState();

    // Make first deadline always open
    if (deadlines.isNotEmpty) {
      selectedIndex = 0;
    }

    // Rebuild every 30s to refresh time left
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String timeLeft(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);

    if (diff.isNegative) {
      return 'Deadline passed';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} to go';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} to go';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} to go';
    } else {
      return '${diff.inSeconds} sec${diff.inSeconds > 1 ? 's' : ''} to go';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDeadlines = deadlines.isNotEmpty;

    return Scaffold(
      backgroundColor: Color(AppColors.homeBgColor),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed header (won’t scroll)
            Container(
              padding: const EdgeInsets.all(20),
              color: Color(AppColors.homeBgColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Deadlines", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(AppColors.deadlineSummaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: hasDeadlines
                        ? Row(
                            children: [
                              Text(
                                "${deadlines.length}",
                                style: const TextStyle(
                                    fontSize: 45, color: Colors.white, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 15),
                              const VerticalDivider(color: Colors.white, thickness: 1),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: 100,
                                child: const Text("Upcoming Deadlines", style: TextStyle(color: Colors.white))),

                              Expanded(
                                child: Image.asset(
                                  'lib/assets/icons_3d/alarm_clock_3d.png',
                                  fit: BoxFit.contain,
                                  ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              "No upcoming deadlines!",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Add Deadline",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(height: 30, color: Colors.grey[400]),
                ],
              ),
            ),

            // Scrollable list section
            Expanded(
              child: hasDeadlines
                  ? ListView.builder(
                      itemCount: deadlines.length,
                      itemBuilder: (context, index) {
                        final isFocused = selectedIndex == index;
                        final deadline = deadlines[index];

                        return GestureDetector(
                          onTap: () => setState(() {
                            selectedIndex = isFocused ? null : index;
                          
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(AppColors.deadlineListColor1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isFocused
                                ? Column(
                                    children: [
                                      Text(deadline['title'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Color(AppColors.primaryColor))),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _timeBox("10", "Days"),
                                          const SizedBox(width: 10),
                                          const Text(":", style: TextStyle(fontWeight: FontWeight.bold, color: Color(AppColors.primaryColor))),
                                          const SizedBox(width: 10),
                                          _timeBox("10", "Hours"),
                                          const SizedBox(width: 10),
                                          const Text(":", style: TextStyle(fontWeight: FontWeight.bold, color: Color(AppColors.primaryColor))),
                                          const SizedBox(width: 10),
                                          _timeBox("10", "Minutes"),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(deadline['title'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Color(AppColors.primaryColor))),
                                      const SizedBox(height: 10),
                                      Text(DateFormat.yMMMMd().add_jm().format(deadline['time']),
                                          style: const TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 5),
                                      Text(timeLeft(deadline['time']),
                                          style: const TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No upcoming deadlines to display."),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(AppColors.numberBoxColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}
                      
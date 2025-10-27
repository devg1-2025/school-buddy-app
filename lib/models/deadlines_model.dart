// lib/models/deadlines_model.dart

class DeadlineModel {
  final String? id;
  final String title;
  final DateTime dueDate;

  DeadlineModel({
    this.id,
    required this.title,
    required this.dueDate,
  });

  // ==========================================================
  // FIX 1: The factory method *must* be changed to accept
  // the 'id' from the Hive key as a separate argument.
  // ==========================================================
  factory DeadlineModel.fromMap(Map<String, dynamic> map, String? id) {
    final rawDate = map['dueDate'] ?? map['time'];

    return DeadlineModel(
      id: id, // Use the ID from the parameter
      title: map['title'] ?? '',
      dueDate: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate.toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    // ==========================================================
    // FIX 2: Do NOT save the 'id' field in the map.
    // The Hive key *is* the ID.
    // ==========================================================
    return {
      // 'id': id,  <-- THIS LINE MUST BE REMOVED
      'title': title,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  bool get isExpired => dueDate.isBefore(DateTime.now());

  String get remainingTime {
    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return "Expired";
    if (diff.inDays > 0) {
      return "in ${diff.inDays} day${diff.inDays > 1 ? 's' : ''}";
    }
    if (diff.inHours > 0) {
      return "in ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}";
    }
    if (diff.inMinutes > 0) {
      return "in ${diff.inMinutes} min";
    }
    return "soon";
  }
}
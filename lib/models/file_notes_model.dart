
class FileNote {
  final String id;
  final String fileName;
  final String text;
  final bool isKeyPoint;
  final DateTime createdAt;

  FileNote({
    required this.id,
    required this.fileName,
    required this.text,
    required this.isKeyPoint,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fileName': fileName,
        'text': text,
        'isKeyPoint': isKeyPoint,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FileNote.fromMap(Map<String, dynamic> map) {
    return FileNote(
      id: map['id'],
      fileName: map['fileName'],
      text: map['text'],
      isKeyPoint: map['isKeyPoint'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}


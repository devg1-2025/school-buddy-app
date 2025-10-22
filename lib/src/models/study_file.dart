class StudyFile {
  final String id;
  final String name;
  final String path;
  final String type;
  final DateTime addedOn;

  StudyFile({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.addedOn,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'type': type,
        'addedOn': addedOn.toIso8601String(),
      };

  static StudyFile fromMap(Map<String, dynamic> map) => StudyFile(
        id: map['id'],
        name: map['name'],
        path: map['path'],
        type: map['type'],
        addedOn: DateTime.parse(map['addedOn']),
      );
}

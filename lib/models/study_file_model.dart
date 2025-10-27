// class StudyFile {
//   final String id;
//   final String name;
//   final String path;
//   final String type;
//   final DateTime addedOn;

//   StudyFile({
//     required this.id,
//     required this.name,
//     required this.path,
//     required this.type,
//     required this.addedOn,
//   });

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'name': name,
//         'path': path,
//         'type': type,
//         'addedOn': addedOn.toIso8601String(),
//       };

//   static StudyFile fromMap(Map<String, dynamic> map) => StudyFile(
//         id: map['id'],
//         name: map['name'],
//         path: map['path'],
//         type: map['type'],
//         addedOn: DateTime.parse(map['addedOn']),
//       );
// }


// class StudyFileModel {
//   final String id;
//   final String name;
//   final String path;
//   final String type;
//   int lastPage;
//   List<Map<String, dynamic>> notes;
//   List<String> keyPoints;
//   DateTime lastOpened;

//   StudyFileModel({
//     required this.id,
//     required this.name,
//     required this.path,
//     required this.type,
//     this.lastPage = 1,
//     List<Map<String, dynamic>>? notes,
//     List<String>? keyPoints,
//     DateTime? lastOpened,
//   })  : notes = notes ?? [],
//         keyPoints = keyPoints ?? [],
//         lastOpened = lastOpened ?? DateTime.now();

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'name': name,
//         'path': path,
//         'type': type,
//         'lastPage': lastPage,
//         'notes': notes,
//         'keyPoints': keyPoints,
//         'lastOpened': lastOpened.toString(),
//       };

//   factory StudyFileModel.fromMap(Map map) {
//      final data = Map<String, dynamic>.from(map);
//     return StudyFileModel(
//       id: data['id'],
//       name: data['name'],
//       path: data['path'],
//       type: data['type'],
//       lastPage: data['lastPage'] ?? 1,
//       notes: List<Map<String, dynamic>>.from(data['notes'] ?? []),
//       keyPoints: List<String>.from(data['keyPoints'] ?? []),
//       lastOpened: DateTime.tryParse(data['lastOpened'] ?? '') ?? DateTime.now(),
//     );
//   }
// }

class StudyFileModel {
  final String id;
  final String name;
  final String path;
  final String type;
  int lastPage;
  List<Map<String, dynamic>> notes;
  List<String> keyPoints;
  DateTime lastOpened;

  StudyFileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    this.lastPage = 1,
    List<Map<String, dynamic>>? notes,
    List<String>? keyPoints,
    DateTime? lastOpened,
  })  : notes = notes ?? [],
        keyPoints = keyPoints ?? [],
        lastOpened = lastOpened ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'type': type,
        'lastPage': lastPage,
        'notes': notes,
        'keyPoints': keyPoints,
        'lastOpened': lastOpened.toIso8601String(),
      };

  factory StudyFileModel.fromMap(dynamic map) {
    // Convert to Map<String, dynamic> safely, even if Hive returns _Map<dynamic, dynamic>
    final data = Map<String, dynamic>.from(map as Map);

    return StudyFileModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      path: data['path'] ?? '',
      type: data['type'] ?? '',
      lastPage: data['lastPage'] ?? 1,
      notes: (data['notes'] is List)
          ? List<Map<String, dynamic>>.from(
              (data['notes'] as List)
                  .map((e) => Map<String, dynamic>.from(e)))
          : [],
      keyPoints: (data['keyPoints'] is List)
          ? List<String>.from(data['keyPoints'])
          : [],
      lastOpened: DateTime.tryParse(data['lastOpened'] ?? '') ?? DateTime.now(),
    );
  }
}

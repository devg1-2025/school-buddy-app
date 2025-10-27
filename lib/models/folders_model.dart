class StudyFolder {
  final String id;
  final String name;

  StudyFolder({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static StudyFolder fromMap(Map<String, dynamic> map) =>
      StudyFolder(id: map['id'], name: map['name']);
}

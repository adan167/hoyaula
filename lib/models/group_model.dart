class GroupModel {
  GroupModel({
    required this.id,
    required this.name,
    required this.program,
    required this.academicPeriod,
    required this.subject,
    required this.sectionCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String program;
  final String academicPeriod;
  final String subject;
  final String sectionCode;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'program': program,
        'academicPeriod': academicPeriod,
        'subject': subject,
        'sectionCode': sectionCode,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      program: json['program'] as String,
      academicPeriod: json['academicPeriod'] as String,
      subject: json['subject'] as String,
      sectionCode: json['sectionCode'] as String,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? program,
    String? academicPeriod,
    String? subject,
    String? sectionCode,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      program: program ?? this.program,
      academicPeriod: academicPeriod ?? this.academicPeriod,
      subject: subject ?? this.subject,
      sectionCode: sectionCode ?? this.sectionCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

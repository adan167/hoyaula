class StudentModel {
  StudentModel({
    required this.id,
    required this.groupId,
    required this.firstName,
    required this.lastName,
    required this.institutionalCode,
    this.avatar,
  });

  final String id;
  final String groupId;
  final String firstName;
  final String lastName;
  final String institutionalCode;
  final String? avatar;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'firstName': firstName,
        'lastName': lastName,
        'institutionalCode': institutionalCode,
        'avatar': avatar,
      };

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      institutionalCode: json['institutionalCode'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

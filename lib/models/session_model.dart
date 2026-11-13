class SessionModel {
  SessionModel({
    required this.id,
    required this.groupId,
    required this.sessionNumber,
    required this.theme,
    required this.sessionType,
    required this.durationHours,
    required this.observations,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String groupId;
  final int sessionNumber;
  final String theme;
  final String sessionType;
  final double durationHours;
  final String observations;
  final DateTime date;
  final DateTime createdAt;
}

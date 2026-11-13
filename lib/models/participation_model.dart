class ParticipationModel {
  ParticipationModel({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.activityId,
    required this.points,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String sessionId;
  final String activityId;
  final int points;
  final DateTime createdAt;
}

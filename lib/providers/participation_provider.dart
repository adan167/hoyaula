import 'package:flutter/foundation.dart';

import '../models/activity_model.dart';
import '../models/participation_model.dart';
import '../data/mock_data.dart';
import '../services/local_storage_service.dart';

class ParticipationProvider extends ChangeNotifier {
  ParticipationProvider() {
    _records = List.of(LocalStorageService.readParticipationRecordsSync());
    _activityList = buildActivities();
  }

  late List<ParticipationModel> _records;
  late List<ActivityModel> _activityList;
  String _selectedActivityId = 'activity-participation';

  List<ActivityModel> get activities => List.unmodifiable(_activityList);
  String get selectedActivityId => _selectedActivityId;

  void setSelectedActivity(String activityId) {
    _selectedActivityId = activityId;
    notifyListeners();
  }

  List<ParticipationModel> recordsForSession(String sessionId) {
    return _records.where((record) => record.sessionId == sessionId).toList();
  }

  int totalPointsForStudent({
    required String studentId,
    required String sessionId,
  }) {
    return _records
        .where(
          (record) =>
              record.studentId == studentId && record.sessionId == sessionId,
        )
        .fold(0, (sum, record) => sum + record.points);
  }

  Future<void> addPoints({
    required String studentId,
    required String sessionId,
    required int points,
  }) async {
    final record = ParticipationModel(
      id: 'participation-${DateTime.now().microsecondsSinceEpoch}',
      studentId: studentId,
      sessionId: sessionId,
      activityId: _selectedActivityId,
      points: points,
      createdAt: DateTime.now(),
    );
    await LocalStorageService.saveParticipation(record);
    _records.add(record);
    notifyListeners();
  }

  bool hasDuplicateOperation({
    required String studentId,
    required String sessionId,
    required int points,
  }) {
    return _records.any(
      (record) =>
          record.studentId == studentId &&
          record.sessionId == sessionId &&
          record.activityId == _selectedActivityId &&
          record.points == points,
    );
  }
}

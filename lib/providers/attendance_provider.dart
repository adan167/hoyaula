import 'package:flutter/foundation.dart';

import '../models/attendance_model.dart';
import '../services/local_storage_service.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider() {
    _attendanceBySession = LocalStorageService.readAttendanceBySessionSync();
  }

  late Map<String, Map<String, AttendanceStatus>> _attendanceBySession;

  Map<String, AttendanceStatus> attendanceForSession(String sessionId) {
    return Map<String, AttendanceStatus>.from(
      _attendanceBySession[sessionId] ?? const {},
    );
  }

  Future<void> setStatus({
    required String sessionId,
    required String studentId,
    required AttendanceStatus status,
  }) async {
    await LocalStorageService.saveAttendance(
      sessionId: sessionId,
      studentId: studentId,
      status: status,
    );
    final current = Map<String, AttendanceStatus>.from(
      _attendanceBySession[sessionId] ?? const {},
    );
    current[studentId] = status;
    _attendanceBySession[sessionId] = current;
    notifyListeners();
  }

  AttendanceSummary summaryForSession(String sessionId) {
    final statusMap = attendanceForSession(sessionId);
    int present = 0;
    int tardy = 0;
    int absent = 0;
    int justified = 0;

    for (final status in statusMap.values) {
      switch (status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.tardy:
          tardy++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.justified:
          justified++;
          break;
      }
    }

    return AttendanceSummary(
      present: present,
      tardy: tardy,
      absent: absent,
      justified: justified,
    );
  }
}

class AttendanceSummary {
  AttendanceSummary({
    required this.present,
    required this.tardy,
    required this.absent,
    required this.justified,
  });

  final int present;
  final int tardy;
  final int absent;
  final int justified;
}

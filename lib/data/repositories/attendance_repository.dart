import '../../models/attendance_model.dart';
import '../mock_data.dart';

class AttendanceRepository {
  Map<String, Map<String, AttendanceStatus>> getAttendanceBySession() {
    return buildAttendanceBySession();
  }

  Map<String, AttendanceStatus> getAttendanceForSession(String sessionId) {
    return getAttendanceBySession()[sessionId] ?? {};
  }
}

import '../../models/session_model.dart';
import '../mock_data.dart';

class SessionRepository {
  List<SessionModel> getSessionsByGroupId(String groupId) {
    return buildSessionsForGroup(groupId);
  }
}

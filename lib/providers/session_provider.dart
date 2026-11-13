import 'package:flutter/foundation.dart';

import '../models/session_model.dart';
import '../services/local_storage_service.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider() {
    _sessionsByGroup = LocalStorageService.readSessionsByGroupSync();
  }

  late Map<String, List<SessionModel>> _sessionsByGroup;

  List<SessionModel> sessionsForGroup(String groupId) {
    return List.unmodifiable(_sessionsByGroup[groupId] ?? const []);
  }

  Future<void> addSession(SessionModel session) async {
    await LocalStorageService.saveSession(session);
    final current = _sessionsByGroup[session.groupId] ?? <SessionModel>[];
    _sessionsByGroup[session.groupId] = [session, ...current];
    notifyListeners();
  }
}

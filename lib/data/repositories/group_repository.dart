import '../../models/group_model.dart';
import '../mock_data.dart';

class GroupRepository {
  List<GroupModel> getGroups() {
    return buildMockGroups();
  }

  GroupModel? getGroupById(String id) {
    return getGroups().where((group) => group.id == id).firstOrNull;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

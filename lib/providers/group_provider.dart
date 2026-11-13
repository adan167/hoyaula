import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../data/repositories/group_repository.dart';
import '../models/group_model.dart';
import '../models/student_model.dart';
import '../services/local_storage_service.dart';

class GroupProvider extends ChangeNotifier {
  GroupProvider() {
    final savedGroups = LocalStorageService.readGroupsSync();
    _groups = List.of(
      savedGroups.isNotEmpty ? savedGroups : GroupRepository().getGroups(),
    );
    _studentsByGroup = LocalStorageService.readStudentsByGroupSync();
    if (_studentsByGroup.isEmpty) {
      _studentsByGroup = buildStudentsByGroup();
    }

    for (final group in _groups) {
      _studentsByGroup.putIfAbsent(group.id, () => <StudentModel>[]);
    }

    _selectedGroupId = _groups.isNotEmpty ? _groups.first.id : null;
  }

  late List<GroupModel> _groups;
  late Map<String, List<StudentModel>> _studentsByGroup;
  String? _selectedGroupId;

  List<GroupModel> get groups => List.unmodifiable(_groups);

  String? get selectedGroupId => _selectedGroupId;

  GroupModel? get selectedGroup =>
      _groups.where((group) => group.id == _selectedGroupId).firstOrNull;

  void setSelectedGroup(String groupId) {
    if (_groups.any((group) => group.id == groupId)) {
      _selectedGroupId = groupId;
      notifyListeners();
    }
  }

  Future<void> addGroup(
    GroupModel group, {
    List<StudentModel> initialStudents = const [],
  }) async {
    final updatedGroups = [group, ..._groups];
    final updatedStudents = {
      ..._studentsByGroup,
      group.id: List.of(initialStudents),
    };
    await LocalStorageService.saveGroupsAndStudents(
      updatedGroups,
      updatedStudents,
    );
    _groups = updatedGroups;
    _studentsByGroup = updatedStudents;
    _selectedGroupId = group.id;
    notifyListeners();
  }

  List<StudentModel> studentsForGroup(String groupId) {
    return List.unmodifiable(_studentsByGroup[groupId] ?? const []);
  }

  Future<void> addStudentsToGroup(
    String groupId,
    List<StudentModel> students,
  ) async {
    final current = _studentsByGroup[groupId] ?? <StudentModel>[];
    final updatedStudents = {
      ..._studentsByGroup,
      groupId: [...current, ...students],
    };
    await LocalStorageService.saveGroupsAndStudents(_groups, updatedStudents);
    _studentsByGroup = updatedStudents;
    notifyListeners();
  }

  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    final current = _studentsByGroup[groupId] ?? <StudentModel>[];
    final updatedStudents = {
      ..._studentsByGroup,
      groupId: current.where((student) => student.id != studentId).toList(),
    };
    await LocalStorageService.saveGroupsAndStudents(_groups, updatedStudents);
    _studentsByGroup = updatedStudents;
    notifyListeners();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

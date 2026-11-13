import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_aula/main.dart';
import 'package:practica_aula/providers/group_provider.dart';
import 'package:practica_aula/screens/groups/groups_screen.dart';
import 'package:practica_aula/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() async {
    await LocalStorageService.close();
  });

  testWidgets('a new section saves its students with valid codes', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init(inMemory: true);
    await tester.pumpWidget(const AulaPuntosApp());

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sección de prueba');
    await tester.enterText(fields.at(1), 'Desarrollo de software');
    await tester.enterText(fields.at(2), '2026-II');
    await tester.enterText(fields.at(3), 'Programación');
    await tester.enterText(fields.at(4), 'PROG-01');
    await tester.enterText(fields.at(5), 'Ana López');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final groupProvider = tester
        .element(find.byType(GroupsScreen))
        .read<GroupProvider>();
    final group = groupProvider.groups.first;
    final student = groupProvider.studentsForGroup(group.id).single;

    expect(group.name, 'Sección de prueba');
    expect(student.fullName, 'Ana López');
    expect(student.institutionalCode, 'PROG-01-001');
    expect(student.id, contains(group.id));
    expect(
      (await LocalStorageService.readGroups()).first.name,
      'Sección de prueba',
    );
    expect(
      (await LocalStorageService.readStudentsByGroup())[group.id]?.single.id,
      student.id,
    );
    expect(tester.takeException(), isNull);
  });
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practica_aula/core/app_routes.dart';
import 'package:practica_aula/main.dart';
import 'package:practica_aula/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init(inMemory: true);
  });
  tearDown(() async {
    await LocalStorageService.close();
  });

  testWidgets('Aula Puntos app loads the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());

    expect(find.textContaining('AULA PUNTOS'), findsOneWidget);
    expect(find.textContaining('Accesos'), findsOneWidget);
  });

  testWidgets('quick score opens a valid session', (WidgetTester tester) async {
    await tester.pumpWidget(const AulaPuntosApp());

    await tester.tap(find.text('Puntuación'));
    await tester.pumpAndSettle();

    expect(find.text('Selector de actividad actual'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick attendance opens a session attendance screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());

    await tester.tap(find.text('Asistencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Asistencia').first);
    await tester.pumpAndSettle();

    expect(find.text('Asistencia: Sesión 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('attendance route handles missing arguments without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(AppRoutes.attendance);
    await tester.pumpAndSettle();

    expect(find.text('No se encontró el grupo o la sesión.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('attendance route restores group and session from its URL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/attendance?groupId=group-202601&sessionId=session-g1-1');
    await tester.pumpAndSettle();

    expect(find.text('Asistencia: Sesión 1'), findsOneWidget);
    expect(find.text('No se encontró el grupo o la sesión.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sessions back button returns to the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());

    await tester.tap(find.text('Grupos').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cohorte 2026-20'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Accesos Rápidos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups back button returns to the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());

    await tester.tap(find.text('Grupos').first);
    await tester.pumpAndSettle();
    expect(find.text('Cohorte 2026-20'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Accesos Rápidos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports back button returns to the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AulaPuntosApp());
    await tester.tap(find.text('Reportes').last);
    await tester.pumpAndSettle();

    expect(find.text('Reportes y exportación'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Accesos Rápidos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

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
}

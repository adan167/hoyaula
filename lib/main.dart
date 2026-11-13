import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'providers/attendance_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/group_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/participation_provider.dart';
import 'providers/session_provider.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/participation/participation_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/sessions/session_detail_screen.dart';
import 'screens/sessions/sessions_screen.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const AulaPuntosApp());
}

class AulaPuntosApp extends StatelessWidget {
  const AulaPuntosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ParticipationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: MaterialApp(
        title: 'AULA PUNTOS - SENATI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildTheme(),
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.groups: (_) => const GroupsScreen(),
          AppRoutes.sessions: (context) {
            return SessionsScreen(groupId: _stringArgument(context, 'groupId'));
          },
          AppRoutes.sessionDetail: (context) {
            return SessionDetailScreen(
              groupId: _stringArgument(context, 'groupId') ?? '',
              sessionId: _stringArgument(context, 'sessionId') ?? '',
            );
          },
          AppRoutes.attendance: (context) {
            return AttendanceScreen(
              groupId: _stringArgument(context, 'groupId') ?? '',
              sessionId: _stringArgument(context, 'sessionId') ?? '',
            );
          },
          AppRoutes.participation: (context) {
            return ParticipationScreen(
              groupId: _stringArgument(context, 'groupId') ?? '',
              sessionId: _stringArgument(context, 'sessionId') ?? '',
            );
          },
          AppRoutes.reports: (_) => const ReportsScreen(),
        },
      ),
    );
  }
}

String? _stringArgument(BuildContext context, String key) {
  final arguments = ModalRoute.of(context)?.settings.arguments;
  if (arguments is! Map) {
    return null;
  }
  final value = arguments[key];
  return value is String ? value : null;
}

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../providers/group_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/main_navigation.dart';
import '../../widgets/session_card.dart';
import 'session_form_sheet.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key, this.groupId});

  final String? groupId;

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final groups = groupProvider.groups;
    final selectedGroupId = groupId ?? groupProvider.selectedGroupId;
    final selectedGroup = groups
        .where((group) => group.id == selectedGroupId)
        .firstOrNull;
    final sessions = selectedGroup == null
        ? const []
        : context.watch<SessionProvider>().sessionsForGroup(selectedGroup.id);

    return Scaffold(
      appBar: CustomAppBar(
        title: selectedGroup == null
            ? 'Sesiones'
            : 'Sesiones: ${selectedGroup.sectionCode}',
        showBackButton: true,
        onBackPressed: () {
          context.read<NavigationProvider>().setIndex(0);
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
      ),
      bottomNavigationBar: MainNavigation(
        onTap: (index) {
          context.read<NavigationProvider>().setIndex(index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.groups);
              break;
            case 2:
              if (selectedGroup != null) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.sessions,
                  arguments: {'groupId': selectedGroup.id},
                );
              }
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.reports);
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedGroup == null
            ? null
            : () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SessionFormSheet(groupId: selectedGroup.id),
              ),
        child: const Icon(Icons.add),
      ),
      body: selectedGroup == null
          ? const EmptyState(
              title: 'No hay una sección seleccionada.',
              message:
                  'Crea o selecciona una sección antes de registrar sesiones.',
            )
          : sessions.isEmpty
          ? const EmptyState(
              title: 'No hay sesiones registradas.',
              message: 'Crea una sesión para comenzar.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionCard(
                  session: session,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.sessionDetail,
                      arguments: {
                        'groupId': selectedGroup.id,
                        'sessionId': session.id,
                      },
                    );
                  },
                  onAttendance: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.withParameters(AppRoutes.attendance, {
                        'groupId': selectedGroup.id,
                        'sessionId': session.id,
                      }),
                    );
                  },
                  onParticipation: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.participation,
                      arguments: {
                        'groupId': selectedGroup.id,
                        'sessionId': session.id,
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

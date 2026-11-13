import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../providers/group_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/group_card.dart';
import '../../widgets/main_navigation.dart';
import 'group_form_dialog.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Grupos SENATI - AULA PUNTOS', showBackButton: true),
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
              final groupId = context.read<GroupProvider>().selectedGroupId;
              if (groupId != null) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.sessions,
                  arguments: {'groupId': groupId},
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
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const GroupFormDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      body: groups.isEmpty
          ? const EmptyState(
              title: 'No hay grupos registrados.',
              message: 'Crea un grupo para comenzar.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GroupCard(
                    group: group,
                    onTap: () {
                      context.read<GroupProvider>().setSelectedGroup(group.id);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.sessions,
                        arguments: {'groupId': group.id},
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

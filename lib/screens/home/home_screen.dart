import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/connectivity_indicator.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/main_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;
    final online = context.watch<ConnectivityProvider>().isConnected;
    final instructor = buildInstructor();
    final quickActions = [
      {
        'title': 'Grupos',
        'icon': Icons.groups_rounded,
        'route': AppRoutes.groups,
      },
      {
        'title': 'Asistencia',
        'icon': Icons.checklist_rtl_rounded,
        'route': AppRoutes.sessions,
      },
      {
        'title': 'Puntuación',
        'icon': Icons.stars_rounded,
        'route': AppRoutes.participation,
      },
      {
        'title': 'Reportes',
        'icon': Icons.picture_as_pdf_rounded,
        'route': AppRoutes.reports,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ConnectivityIndicator(isOnline: online),
          ),
        ],
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
              final groupId = groups.isNotEmpty ? groups.first.id : null;
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: AppColors.primaryDark,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.white,
                      child: const Text(
                        'DR',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instructor.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            instructor.role,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                color: AppColors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                instructor.academicControl,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Icon(
                                Icons.score_rounded,
                                color: AppColors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                instructor.score,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Mis grupos',
                      value: '${groups.length}',
                      icon: Icons.groups_rounded,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      title: 'Estado del sistema',
                      value: online ? 'Online' : 'Offline',
                      icon: online
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      accentColor: online ? AppColors.green : AppColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Accesos Rápidos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: quickActions.map((item) {
                  return InkWell(
                    onTap: () {
                      final route = item['route'] as String;
                      final groupProvider = context.read<GroupProvider>();
                      final group =
                          groupProvider.selectedGroup ??
                          (groups.isEmpty ? null : groups.first);

                      if (route == AppRoutes.sessions) {
                        if (group == null) {
                          Navigator.pushNamed(context, AppRoutes.groups);
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.sessions,
                            arguments: {'groupId': group.id},
                          );
                        }
                        return;
                      }

                      if (route == AppRoutes.participation) {
                        if (group == null) {
                          Navigator.pushNamed(context, AppRoutes.groups);
                          return;
                        }
                        final sessions = context
                            .read<SessionProvider>()
                            .sessionsForGroup(group.id);
                        if (sessions.isEmpty) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.sessions,
                            arguments: {'groupId': group.id},
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.participation,
                            arguments: {
                              'groupId': group.id,
                              'sessionId': sessions.first.id,
                            },
                          );
                        }
                        return;
                      }

                      Navigator.pushNamed(context, route);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.white,
                        border: Border.all(color: AppColors.grey, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.lightBlue,
                            child: Icon(
                              item['icon'] as IconData,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

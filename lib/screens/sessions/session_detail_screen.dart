import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../providers/session_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({
    super.key,
    required this.groupId,
    required this.sessionId,
  });

  final String groupId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionProvider>().sessionsForGroup(groupId);
    final session = sessions.where((item) => item.id == sessionId).firstOrNull;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Detalle de sesión',
        showBackButton: true,
      ),
      body: session == null
          ? const EmptyState(
              title: 'No se encontró la sesión.',
              message: 'Vuelve a la lista y selecciona una sesión disponible.',
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sesión ${session.sessionNumber}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            session.theme,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Tipo: ${session.sessionType}'),
                          Text('Duración: ${session.durationHours} horas'),
                          Text('Observaciones: ${session.observations}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.attendance,
                              arguments: {
                                'groupId': groupId,
                                'sessionId': sessionId,
                              },
                            ),
                            icon: const Icon(Icons.checklist_rtl_rounded),
                            label: const Text('Asistencia'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.participation,
                              arguments: {
                                'groupId': groupId,
                                'sessionId': sessionId,
                              },
                            ),
                            icon: const Icon(Icons.stars_rounded),
                            label: const Text('Puntuación'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

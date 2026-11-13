import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../providers/group_provider.dart';
import '../../providers/participation_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/points_buttons.dart';
import '../../widgets/student_card.dart';

class ParticipationScreen extends StatelessWidget {
  const ParticipationScreen({
    super.key,
    required this.groupId,
    required this.sessionId,
  });

  final String groupId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final groupExists = groupProvider.groups.any(
      (group) => group.id == groupId,
    );
    final sessionExists = context
        .watch<SessionProvider>()
        .sessionsForGroup(groupId)
        .any((session) => session.id == sessionId);
    final students = groupProvider.studentsForGroup(groupId);
    final participationProvider = context.watch<ParticipationProvider>();
    final activity = participationProvider.activities.firstWhere(
      (item) => item.id == participationProvider.selectedActivityId,
      orElse: () => participationProvider.activities.first,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Puntuación: Sesión ${_sessionNumber(sessionId)}',
        showBackButton: true,
      ),
      body: !groupExists || !sessionExists
          ? const EmptyState(
              title: 'No se encontró el grupo o la sesión.',
              message:
                  'Selecciona una sesión disponible antes de asignar puntos.',
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selector de actividad actual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: activity.id,
                          isExpanded: true,
                          items: participationProvider.activities
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              participationProvider.setSelectedActivity(value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final total = participationProvider
                              .totalPointsForStudent(
                                studentId: student.id,
                                sessionId: sessionId,
                              );

                          return StudentCard(
                            student: student,
                            subtitle: student.institutionalCode,
                            trailing: SizedBox(
                              width: 230,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total: $total',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  PointsButtons(
                                    onPointSelected: (points) async {
                                      try {
                                        await participationProvider.addPoints(
                                          studentId: student.id,
                                          sessionId: sessionId,
                                          points: points,
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Puntos sumados a ${student.fullName}: +$points',
                                            ),
                                          ),
                                        );
                                      } catch (error) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'No se pudieron guardar los puntos. $error',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  static String _sessionNumber(String sessionId) {
    final parts = sessionId.split('-');
    if (parts.length >= 3 && parts.last.contains(RegExp(r'\d'))) {
      return parts.last;
    }
    return '1';
  }
}

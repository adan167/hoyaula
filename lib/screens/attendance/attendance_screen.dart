import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/attendance_selector.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/student_card.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({
    super.key,
    required this.groupId,
    required this.sessionId,
  });

  final String groupId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final group = context
        .watch<GroupProvider>()
        .groups
        .where((item) => item.id == groupId)
        .firstOrNull;
    final sessionExists = context
        .watch<SessionProvider>()
        .sessionsForGroup(groupId)
        .any((session) => session.id == sessionId);
    final students = context.watch<GroupProvider>().studentsForGroup(groupId);
    final attendanceProvider = context.watch<AttendanceProvider>();
    final summary = attendanceProvider.summaryForSession(sessionId);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Asistencia: Sesión ${_sessionNumber(sessionId)}',
        showBackButton: true,
      ),
      body: group == null || !sessionExists
          ? const EmptyState(
              title: 'No se encontró el grupo o la sesión.',
              message: 'Vuelve a la lista y selecciona una sesión disponible.',
            )
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grupo: ${group.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SummaryChip(
                              label: 'Presentes',
                              value: summary.present.toString(),
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 8),
                            _SummaryChip(
                              label: 'Tardanzas',
                              value: summary.tardy.toString(),
                              color: AppColors.orange,
                            ),
                            const SizedBox(width: 8),
                            _SummaryChip(
                              label: 'Faltas',
                              value: summary.absent.toString(),
                              color: AppColors.red,
                            ),
                            const SizedBox(width: 8),
                            _SummaryChip(
                              label: 'Justificados',
                              value: summary.justified.toString(),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final status =
                            attendanceProvider.attendanceForSession(
                              sessionId,
                            )[student.id] ??
                            AttendanceStatus.present;
                        return StudentCard(
                          student: student,
                          subtitle: student.institutionalCode,
                          trailing: SizedBox(
                            width: 210,
                            child: AttendanceSelector(
                              selectedStatus: status,
                              onChanged: (newStatus) async {
                                try {
                                  await attendanceProvider.setStatus(
                                    sessionId: sessionId,
                                    studentId: student.id,
                                    status: newStatus,
                                  );
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No se pudo guardar la asistencia. $error',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.white,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'La asistencia está guardada en SQLite.',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Guardar cambios'),
                    ),
                  ),
                ],
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/participation_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/excel_service.dart';
import '../../services/pdf_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/main_navigation.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedGroupId;
  String? _selectedSessionId;
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;
    final groupProvider = context.read<GroupProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final participationProvider = context.watch<ParticipationProvider>();

    if (_selectedGroupId == null && groups.isNotEmpty) {
      _selectedGroupId = groups.first.id;
    }

    final selectedGroup = groups.firstWhere(
      (group) => group.id == _selectedGroupId,
      orElse: () => groups.first,
    );

    final sessions = sessionProvider.sessionsForGroup(selectedGroup.id);
    if (_selectedSessionId == null && sessions.isNotEmpty) {
      _selectedSessionId = sessions.first.id;
    }

    final students = groupProvider.studentsForGroup(selectedGroup.id);
    if (_selectedStudentId == null && students.isNotEmpty) {
      _selectedStudentId = 'all';
    }

    final filteredStudents =
        _selectedStudentId == null || _selectedStudentId == 'all'
        ? students
        : students
              .where((student) => student.id == _selectedStudentId)
              .toList();

    final reportRows = filteredStudents.map((student) {
      final attendanceMap = attendanceProvider.attendanceForSession(
        _selectedSessionId ?? '',
      );
      final attendanceCount =
          attendanceMap[student.id] == AttendanceStatus.present ? 1 : 0;
      final tardinessCount = attendanceMap[student.id] == AttendanceStatus.tardy
          ? 1
          : 0;
      final absenceCount = attendanceMap[student.id] == AttendanceStatus.absent
          ? 1
          : 0;
      final justifiedCount =
          attendanceMap[student.id] == AttendanceStatus.justified ? 1 : 0;
      final totalPoints = participationProvider.totalPointsForStudent(
        studentId: student.id,
        sessionId: _selectedSessionId ?? '',
      );

      return {
        'studentName': student.fullName,
        'institutionalCode': student.institutionalCode,
        'totalPoints': totalPoints,
        'attendance': attendanceCount,
        'tardiness': tardinessCount,
        'absence': absenceCount,
        'justified': justifiedCount,
      };
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reportes y exportación',
        showBackButton: true,
        onBackPressed: () {
          context.read<NavigationProvider>().setIndex(0);
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.grey),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FilterDropdown(
                            label: 'Grupo',
                            value: _selectedGroupId,
                            items: groups
                                .map(
                                  (group) => DropdownMenuItem(
                                    value: group.id,
                                    child: Text(group.sectionCode),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGroupId = value;
                                _selectedSessionId = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterDropdown(
                            label: 'Sesión',
                            value: _selectedSessionId,
                            items: sessions
                                .map(
                                  (session) => DropdownMenuItem(
                                    value: session.id,
                                    child: Text(
                                      'Sesión ${session.sessionNumber}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSessionId = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FilterDropdown(
                      label: 'Estudiante',
                      value: _selectedStudentId,
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('Todos'),
                        ),
                        ...students.map(
                          (student) => DropdownMenuItem(
                            value: student.id,
                            child: Text(student.fullName),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Puntos')),
                            DataColumn(label: Text('Asistencias')),
                            DataColumn(label: Text('Tardanzas')),
                            DataColumn(label: Text('Faltas')),
                            DataColumn(label: Text('Justificados')),
                          ],
                          rows: reportRows
                              .map(
                                (row) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(row['studentName'] as String),
                                    ),
                                    DataCell(
                                      Text(row['institutionalCode'] as String),
                                    ),
                                    DataCell(Text('${row['totalPoints']}')),
                                    DataCell(Text('${row['attendance']}')),
                                    DataCell(Text('${row['tardiness']}')),
                                    DataCell(Text('${row['absence']}')),
                                    DataCell(Text('${row['justified']}')),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_selectedGroupId != null &&
                            _selectedSessionId != null) {
                          final group = selectedGroup;
                          await PdfService.exportReport(
                            group: group,
                            rows: reportRows,
                            program: group.program,
                            period: group.academicPeriod,
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Exportar PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_selectedGroupId != null &&
                            _selectedSessionId != null) {
                          await ExcelService.exportReport(
                            rows: reportRows,
                            groupName: selectedGroup.sectionCode,
                          );
                        }
                      },
                      icon: const Icon(Icons.table_view_rounded),
                      label: const Text('Excel / WhatsApp'),
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value ?? items.first.value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    );
  }
}

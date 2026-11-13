import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/group_model.dart';
import '../../models/student_model.dart';
import '../../providers/group_provider.dart';
import '../../utils/validators.dart';

class GroupFormDialog extends StatefulWidget {
  const GroupFormDialog({super.key});

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _StudentEntry {
  _StudentEntry() : controller = TextEditingController();

  final TextEditingController controller;
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _programController = TextEditingController();
  final _periodController = TextEditingController();
  final _subjectController = TextEditingController();
  final _sectionController = TextEditingController();
  final List<_StudentEntry> _studentEntries = [_StudentEntry()];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _programController.dispose();
    _periodController.dispose();
    _subjectController.dispose();
    _sectionController.dispose();
    for (final entry in _studentEntries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  void _addStudentRow() {
    setState(() {
      _studentEntries.add(_StudentEntry());
    });
  }

  void _removeStudentRow(int index) {
    if (_studentEntries.length <= 1) {
      return;
    }

    final entry = _studentEntries[index];
    entry.controller.dispose();
    setState(() {
      _studentEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva sección',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                _buildField('Nombre del grupo', _nameController),
                const SizedBox(height: 12),
                _buildField('Programa académico', _programController),
                const SizedBox(height: 12),
                _buildField('Periodo académico', _periodController),
                const SizedBox(height: 12),
                _buildField('Asignatura', _subjectController),
                const SizedBox(height: 12),
                _buildField('Código de sección', _sectionController),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Agregar alumnos a la sección',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addStudentRow,
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 18,
                            ),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_studentEntries.length, (index) {
                        final entry = _studentEntries[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: entry.controller,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: index == 0
                                        ? 'Ej. Ana López'
                                        : 'Ej. Carlos Pérez',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _removeStudentRow(index),
                                icon: const Icon(Icons.delete_outline_rounded),
                                color: AppColors.red,
                                tooltip: 'Eliminar alumno',
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isSaving = true);
                                  final group = GroupModel(
                                    id: 'group-${DateTime.now().microsecondsSinceEpoch}',
                                    name: _nameController.text.trim(),
                                    program: _programController.text.trim(),
                                    academicPeriod: _periodController.text
                                        .trim(),
                                    subject: _subjectController.text.trim(),
                                    sectionCode: _sectionController.text.trim(),
                                  );
                                  final studentEntries = _studentEntries
                                      .map(
                                        (entry) => entry.controller.text.trim(),
                                      )
                                      .where((student) => student.isNotEmpty)
                                      .toList();
                                  final students = <StudentModel>[];
                                  for (
                                    var i = 0;
                                    i < studentEntries.length;
                                    i++
                                  ) {
                                    final raw = studentEntries[i];
                                    final names = raw.split(RegExp(r'\s+'));
                                    final firstName = names.first;
                                    final lastName = names.length > 1
                                        ? names.sublist(1).join(' ')
                                        : 'Estudiante';
                                    final code =
                                        '${group.sectionCode}-${(i + 1).toString().padLeft(3, '0')}';
                                    students.add(
                                      StudentModel(
                                        id: 'student-${group.id}-$code',
                                        groupId: group.id,
                                        firstName: firstName,
                                        lastName: lastName,
                                        institutionalCode: code,
                                      ),
                                    );
                                  }

                                  final provider = context
                                      .read<GroupProvider>();
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  try {
                                    await provider.addGroup(
                                      group,
                                      initialStudents: students,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  } catch (error) {
                                    if (!mounted) return;
                                    setState(() => _isSaving = false);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo guardar la sección. $error',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (value) => requiredField(value, label: label),
      decoration: InputDecoration(labelText: label),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../utils/validators.dart';

class SessionFormSheet extends StatefulWidget {
  const SessionFormSheet({super.key, required this.groupId});

  final String groupId;

  @override
  State<SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends State<SessionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _themeController = TextEditingController();
  final _durationController = TextEditingController();
  final _observationsController = TextEditingController();
  String _sessionType = 'Teoría';
  bool _isSaving = false;

  @override
  void dispose() {
    _numberController.dispose();
    _themeController.dispose();
    _durationController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Crear sesión',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final requiredError = requiredField(
                    value,
                    label: 'Número de sesión',
                  );
                  if (requiredError != null) return requiredError;
                  final number = int.tryParse(value!.trim());
                  return number == null || number < 1
                      ? 'Ingresa un número de sesión válido.'
                      : null;
                },
                decoration: const InputDecoration(
                  labelText: 'Número de sesión',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _themeController,
                validator: (value) =>
                    requiredField(value, label: 'Tema desarrollado'),
                decoration: const InputDecoration(
                  labelText: 'Tema desarrollado',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sessionType,
                decoration: const InputDecoration(labelText: 'Tipo de sesión'),
                items: const [
                  DropdownMenuItem(value: 'Teoría', child: Text('Teoría')),
                  DropdownMenuItem(value: 'Práctica', child: Text('Práctica')),
                  DropdownMenuItem(
                    value: 'Laboratorio',
                    child: Text('Laboratorio'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _sessionType = value ?? 'Teoría'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final requiredError = requiredField(value, label: 'Duración');
                  if (requiredError != null) return requiredError;
                  final duration = _parseDuration(value);
                  return duration == null || duration <= 0
                      ? 'Ingresa una duración válida mayor que cero.'
                      : null;
                },
                decoration: const InputDecoration(
                  labelText: 'Duración en horas',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationsController,
                maxLines: 3,
                validator: (value) =>
                    requiredField(value, label: 'Observaciones'),
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isSaving = true);
                                final number = int.parse(
                                  _numberController.text.trim(),
                                );
                                final duration = _parseDuration(
                                  _durationController.text,
                                )!;
                                final session = SessionModel(
                                  id: 'session-${widget.groupId}-${DateTime.now().microsecondsSinceEpoch}',
                                  groupId: widget.groupId,
                                  sessionNumber: number,
                                  theme: _themeController.text.trim(),
                                  sessionType: _sessionType,
                                  durationHours: duration,
                                  observations: _observationsController.text
                                      .trim(),
                                  date: DateTime.now(),
                                );
                                try {
                                  await context
                                      .read<SessionProvider>()
                                      .addSession(session);
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                } catch (error) {
                                  if (!mounted) return;
                                  setState(() => _isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No se pudo guardar la sesión. $error',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(
                        _isSaving ? 'Guardando...' : 'Guardar y crear sesión',
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

  double? _parseDuration(String? value) {
    if (value == null) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}

import 'package:material_ui/material_ui.dart';

import '../core/app_colors.dart';
import '../models/attendance_model.dart';

class AttendanceSelector extends StatelessWidget {
  const AttendanceSelector({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final AttendanceStatus selectedStatus;
  final ValueChanged<AttendanceStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _AttendanceOption(
        status: AttendanceStatus.present,
        label: 'P',
        color: AppColors.green,
        icon: Icons.check_rounded,
      ),
      _AttendanceOption(
        status: AttendanceStatus.tardy,
        label: 'T',
        color: AppColors.orange,
        icon: Icons.schedule_rounded,
      ),
      _AttendanceOption(
        status: AttendanceStatus.absent,
        label: 'F',
        color: AppColors.red,
        icon: Icons.close_rounded,
      ),
      _AttendanceOption(
        status: AttendanceStatus.justified,
        label: 'J',
        color: AppColors.primary,
        icon: Icons.event_available_rounded,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        final isSelected = item.status == selectedStatus;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: isSelected ? item.color : AppColors.grey,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(item.status),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 14,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AttendanceOption {
  const _AttendanceOption({
    required this.status,
    required this.label,
    required this.color,
    required this.icon,
  });

  final AttendanceStatus status;
  final String label;
  final Color color;
  final IconData icon;
}

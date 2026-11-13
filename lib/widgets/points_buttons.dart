import 'package:material_ui/material_ui.dart';

import '../core/app_colors.dart';

class PointsButtons extends StatelessWidget {
  const PointsButtons({
    super.key,
    required this.onPointSelected,
  });

  final ValueChanged<int> onPointSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(1, AppColors.green),
        const SizedBox(width: 8),
        _buildButton(2, AppColors.orange),
        const SizedBox(width: 8),
        _buildButton(3, AppColors.primary),
      ],
    );
  }

  Widget _buildButton(int value, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => onPointSelected(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text('+$value'),
      ),
    );
  }
}

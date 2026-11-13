import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/navigation_provider.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({
    super.key,
    required this.onTap,
  });

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationProvider>().currentIndex;

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textPrimary.withValues(alpha: 0.65),
      backgroundColor: AppColors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded),
          label: 'Mis grupos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Sesiones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined_rounded),
          label: 'Reportes',
        ),
      ],
    );
  }
}

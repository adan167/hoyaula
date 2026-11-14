import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/app_routes.dart';
import '../core/app_colors.dart';
import '../providers/navigation_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
  });

  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              onPressed:
                  onBackPressed ??
                  () {
                    context.read<NavigationProvider>().setIndex(0);
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                  },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            )
          : null,
      actions: actions,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.white,
    );
  }
}

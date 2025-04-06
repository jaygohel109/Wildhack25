import 'package:flutter/material.dart';
import 'package:frontend_app/theme/theme_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onSettingsPressed;

  const CustomBottomNavBar({
    super.key,
    this.onHomePressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: sandBlush,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: skyAsh, size: 40),
              onPressed: onHomePressed ?? () {},
            ),
            const SizedBox(width: 30), // space for FAB
            IconButton(
              icon: const Icon(Icons.settings, color: skyAsh, size: 40),
              onPressed: onSettingsPressed ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

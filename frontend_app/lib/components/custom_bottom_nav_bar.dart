import 'package:flutter/material.dart';

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
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Color(0xFF13547A)),
              onPressed: onHomePressed ?? () {},
            ),
            const SizedBox(width: 48), // space for FAB
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF13547A)),
              onPressed: onSettingsPressed ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

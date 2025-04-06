import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  void _onMenuSelected(BuildContext context, String value) {
    if (value == 'profile') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile clicked")),
      );
    } else if (value == 'logout') {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Color(0xFF13547A)),
      ),
      onSelected: (value) => _onMenuSelected(context, value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }
}

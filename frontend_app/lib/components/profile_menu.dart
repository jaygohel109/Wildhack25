import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Color(0xFF13547A)),
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }
}

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  void _onProfileTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile clicked")),
    );
  }

  void _onLogoutTap(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFF13547A),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            "Hello, Jay 👋",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
              color: Color(0xFF13547A),
            ),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined,
                size: 30, color: Color(0xFF13547A)),
            title: const Text('Profile',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 20)),
            onTap: () => _onProfileTap(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.logout, color: Color(0xFFCE5E50), size: 30),
            title: const Text('Logout',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 20)),
            onTap: () => _onLogoutTap(context),
          ),
        ],
      ),
    );
  }
}

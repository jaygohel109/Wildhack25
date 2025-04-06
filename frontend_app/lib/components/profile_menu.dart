import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileMenu extends StatelessWidget {
  final String userId;

  const ProfileMenu({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    print("🟡 ProfileMenu userId: $userId");
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

class ProfileDrawer extends StatefulWidget {
  final String userId;
  const ProfileDrawer({super.key, required this.userId});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  String? firstName;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse('http://localhost:8000/profile?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['user_profile'] != null) {
        setState(() {
          firstName = data['user_profile']['first_name'];
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  void _onProfileTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ProfileDetailsDialog(userId: widget.userId),
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
          Text(
            "Hello, ${firstName ?? '👋'}",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
              color: Color(0xFF13547A),
            ),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, size: 30, color: Color(0xFF13547A)),
            title: const Text('Profile', style: TextStyle(fontFamily: 'Nunito', fontSize: 20)),
            onTap: () => _onProfileTap(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFCE5E50), size: 30),
            title: const Text('Logout', style: TextStyle(fontFamily: 'Nunito', fontSize: 20)),
            onTap: () => _onLogoutTap(context),
          ),
        ],
      ),
    );
  }
}

class ProfileDetailsDialog extends StatefulWidget {
  final String userId;

  const ProfileDetailsDialog({super.key, required this.userId});

  @override
  State<ProfileDetailsDialog> createState() => _ProfileDetailsDialogState();
}

class _ProfileDetailsDialogState extends State<ProfileDetailsDialog> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    print("🟢 Fetching profile for userId: ${widget.userId}");

    if (widget.userId.isEmpty) {
      print("❌ userId is empty — cannot fetch profile.");
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('http://localhost:8000/profile?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['user_profile'] != null) {
        setState(() {
          profileData = data['user_profile'];
          isLoading = false;
        });
      } else {
        print('❌ No profile data found.');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Profile Info", style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : profileData == null
                ? const Text("Profile not found.")
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField("First Name", profileData!['first_name']),
                        _buildField("Last Name", profileData!['last_name']),
                        _buildField("Email", profileData!['email']),
                        _buildField("Phone", profileData!['phone']),
                        _buildField("Gender", profileData!['gender']),
                        _buildField("DOB", profileData!['dob']),
                      ],
                    ),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close", style: TextStyle(color: Color(0xFF13547A))),
        )
      ],
    );
  }

  Widget _buildField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        "$label: ${value ?? "-"}",
        style: const TextStyle(fontSize: 16, fontFamily: 'Nunito'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF13547A)),
          ),
          onSelected: (value) => _onMenuSelected(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text('Profile')),
            const PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
        title: const Text(
          "Good Morning 👋",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 28),
            onPressed: () {
              // Navigate to messages
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: const Color(0xFF13547A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "📌 My Current Request",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: const Text(
                  "Set up phone 📱",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text("Status: In Progress"),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Volunteer"),
                    SizedBox(height: 6),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF13547A),
                      child: Icon(Icons.person, size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "📖 Request History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildHistoryCard("🛒 Help with groceries", "Completed"),
            _buildHistoryCard("🏥 Doctor appointment", "Completed"),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Color(0xFF13547A)),
                  Text("Home", style: TextStyle(fontSize: 12)),
                ],
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, color: Color(0xFF13547A)),
                  Text("Settings", style: TextStyle(fontSize: 12)),
                ],
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to new request form
        },
        backgroundColor: const Color(0xFF13547A),
        icon: const Icon(Icons.add),
        label: const Text("New Request"),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            "Status: $status",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

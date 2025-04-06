import 'package:flutter/material.dart';
import 'package:frontend_app/components/custom_bottom_nav_bar.dart';
import 'package:frontend_app/components/custom_fab.dart';
import 'package:frontend_app/components/profile_menu.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      appBar: AppBar(
        leading: const ProfileMenu(),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: ListView(
          children: [
            const Text(
              "📌 My Current Request",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Task Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Set up phone 📱",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Status: In Progress",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Volunteer
                    Column(
                      children: const [
                        Text("Volunteer"),
                        SizedBox(height: 6),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF13547A),
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                      ],
                    )
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
      bottomNavigationBar: const CustomBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const CustomFloatingActionButton(
        onPressed: _onNewRequest,
      ),
    );
  }

  static void _onNewRequest() {
    // TODO: Implement navigation
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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend_app/components/custom_bottom_nav_bar.dart';
import 'package:frontend_app/components/custom_fab.dart';
import 'package:frontend_app/components/profile_menu.dart';

import '../theme/theme_colors.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(), // 👈 NEW!
      extendBody: true,
      backgroundColor: peachCream, // very soft background
      appBar: AppBar(
        leading: const ProfileMenu(),
        title: Text(
          _getGreetingMessage(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
            color: skyAsh,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_outlined, size: 35, color: skyAsh),
            onPressed: () {
              // Navigate to messages
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: sandBlush,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: ListView(
          children: [
            const Text(
              "My Current Request",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                color: skyAsh,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: pastelPeach, // e.g., Color(0xFFF0D7B2)
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Title",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Set up phone 📱",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "In Progress",
                        style: TextStyle(
                          color: Color(0xFFCE5E50), // sunsetCoral
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Volunteer
                    const Text(
                      "Volunteer",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/300?img=5', // Placeholder volunteer avatar
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Emma Williams", // Volunteer Name
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "📖 Request History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                color: skyAsh,
              ),
            ),
            const SizedBox(height: 12),
            _buildHistoryCard(
                "Help with groceries",
                "Completed",
                "David Miller",
                "https://i.pravatar.cc/300?img=20",
                "Apr 4, 2025"),
            _buildHistoryCard("Doctor appointment", "Completed", "David Miller",
                "https://i.pravatar.cc/300?img=20", "Apr 4, 2025"),
            _buildHistoryCard(
                "Help setting up a Zoom call with my grandson",
                "Completed",
                "David Miller",
                "https://i.pravatar.cc/300?img=20",
                "Apr 4, 2025"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const CustomFloatingActionButton(
        onPressed: _onNewRequest,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.transparent,
            child: const CustomBottomNavBar(),
          ),
        ),
      ),
    );
  }

  static void _onNewRequest() {
    // TODO: Implement navigation
  }

  Widget _buildHistoryCard(String title, String status, String volunteerName,
      String avatarUrl, String dateCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        color: lavenderMist, // light, faded background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),

              // Task Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                        color: slateText,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Date and Volunteer name
                    Text(
                      "Completed by $volunteerName on $dateCompleted",
                      style: const TextStyle(
                        fontSize: 13,
                        color: bodyText,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: mutedNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getGreetingMessage() {
  final hour = DateTime.now().hour;
  const name = 'Jay'; // Replace with dynamic name later

  if (hour < 12) {
    return 'Good Morning, $name 👋';
  } else if (hour < 17) {
    return 'Good Afternoon, $name 🌤️';
  } else if (hour < 20) {
    return 'Good Evening, $name 🌇';
  } else {
    return 'Good Night, $name 🌙';
  }
}

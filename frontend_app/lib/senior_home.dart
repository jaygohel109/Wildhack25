import 'package:flutter/material.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: const Text("Good Morning"),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Navigate to messages
            },
          ),
        ],
        backgroundColor: const Color(0xFF13547A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "My Request",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: const Text("Current Task: Set up phone"),
                subtitle: const Text("Status: In Progress"),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Volunteer"),
                    CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildHistoryCard("Help with groceries", "Completed"),
            _buildHistoryCard("Doctor appointment", "Completed"),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            const SizedBox(width: 48), // space for FAB
            IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new request form
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF13547A),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        subtitle: Text("Status: $status"),
      ),
    );
  }
}

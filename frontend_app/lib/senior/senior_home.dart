import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SeniorHomePage extends StatefulWidget {
  final String userId;
  const SeniorHomePage({super.key, required this.userId});

  @override
  State<SeniorHomePage> createState() => _SeniorHomePageState();
}

class _SeniorHomePageState extends State<SeniorHomePage> {
  bool userExists = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserExists();
  }

  Future<void> _checkUserExists() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/user/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          setState(() {
            userExists = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking user: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!userExists) {
      return Scaffold(
        body: Center(
          child: Text(
            "User not found",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }

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

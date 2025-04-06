import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VolunteerHomePage extends StatefulWidget {
  final String userId;
  const VolunteerHomePage({super.key, required this.userId});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
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
      appBar: AppBar(
        title: const Text("Volunteer Home"),
        backgroundColor: const Color(0xFF13547A),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Welcome, Volunteer!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

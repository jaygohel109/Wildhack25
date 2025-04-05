// volunteer_home.dart
import 'package:flutter/material.dart';

class VolunteerHomePage extends StatelessWidget {
  const VolunteerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Home")),
      body: const Center(child: Text("Welcome, Volunteer!", style: TextStyle(fontSize: 24))),
    );
  }
}

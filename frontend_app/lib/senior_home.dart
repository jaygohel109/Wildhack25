// senior_home.dart
import 'package:flutter/material.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Senior Home")),
      body: const Center(child: Text("Welcome, Senior!", style: TextStyle(fontSize: 24))),
    );
  }
}

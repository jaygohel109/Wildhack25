import 'package:flutter/material.dart';
import 'features/auth/ui/get_started_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KindCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1444),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9A7BFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GetStartedScreen(),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'senior_home.dart';
import 'volunteer_home.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String selectedRole = 'Senior';
  bool showPassword = false;
  bool rememberMe = false;
  bool isSignUp = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final String baseUrl = 'http://localhost:8000'; // Use IP if running on emulator/device

  int getRoleInt(String roleLabel) {
    return roleLabel == 'Senior' ? 1 : 2; // Updated to match backend role values
  }

  Future<void> handleSubmit() async {
    final uri = Uri.parse('$baseUrl/${isSignUp ? "signup" : "signin"}');

    final payload = {
      "username": emailController.text,
      "password": passwordController.text,
      if (isSignUp) "role": getRoleInt(selectedRole),
    };

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (isSignUp) {
          setState(() {
            isSignUp = false;
            passwordController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created! Please log in."),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Logged in successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          final role = responseData['role'];
          if (role == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SeniorHomePage()),
            );
          } else if (role == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VolunteerHomePage()),
            );
          } else {
            throw Exception("Unknown role returned.");
          }
        }
      } else {
        final detail = responseData['detail'];
        if (isSignUp && detail != null && detail.toLowerCase().contains("exists")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User already exists"),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          throw Exception(detail ?? "Unknown error");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF80D0C7), Color(0xFF13547A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        isSignUp
                            ? "Create Your KindConnect Account"
                            : "Let's Get You Connected",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 30 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "✨ Who Are You Today?\nChoose whether you’re here to receive help or to lend a hand.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildLabel("Select Role"),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Senior', child: Text('Senior')),
                          DropdownMenuItem(value: 'Volunteer', child: Text('Volunteer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      hintText: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildPasswordField(),

                    if (!isSignUp)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 12),
                        child: Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF13547A),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isSignUp ? "Create Account" : "Continue",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isSignUp = !isSignUp;
                          });
                        },
                        child: Text(
                          isSignUp
                              ? "Already have an account? Sign In"
                              : "Don't have an account? Create one",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              hintText: hintText,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Password"),
          TextField(
            controller: passwordController,
            obscureText: !showPassword,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              hintText: "Enter your password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_app/profile/my-profile.dart';
import 'package:http/http.dart' as http;
import '../senior/senior_home.dart';
import '../volunteer/volunteer_home.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  final String baseUrl = 'http://localhost:8000';

  int getRoleInt(String roleLabel) {
    return roleLabel == 'Senior' ? 1 : 2;
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(
                userData: {
                  "email": payload["username"], // Assuming email == username
                  "role": payload["role"],
                  "id": responseData['id'] ?? "",
                },
              ),
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
              MaterialPageRoute(
                  builder: (_) =>
                      SeniorHomePage(userId: responseData['id'] ?? "")),
            );
          } else if (role == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VolunteerHomePage()),
            );
          }
        }
      } else {
        final detail = responseData['detail'];
        if (isSignUp &&
            detail != null &&
            detail.toLowerCase().contains("exists")) {
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
            colors: [
              Color.fromARGB(255, 255, 196, 156),
              Color.fromARGB(255, 237, 237, 237), // soft white
              // Color(0xFFF3E8FF), // pastel lavender
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/signup.svg',
                      height: 300,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome to KindConnect!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFdf9d72),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Text(
                    //   "How can we help you today?",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontFamily: 'Nunito',
                    //     fontSize: 16,
                    //     color: Colors.white.withOpacity(0.9),
                    //   ),
                    // ),
                    if (isSignUp) ...[
                      _buildLabel("Select Role"),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFdf9d72).withOpacity(1),
                            width: 1,
                          ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.20),
                          //     blurRadius: 5,
                          //     offset: const Offset(0, 3),
                          //   ),
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18), // Equal left/right padding
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              borderRadius: BorderRadius.circular(12),
                              value: selectedRole,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xFFdf9d72)),
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                color: Color(0xFFdf9d72),
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Senior',
                                  child: Text('Senior',
                                      style: TextStyle(fontFamily: 'Nunito')),
                                ),
                                DropdownMenuItem(
                                  value: 'Volunteer',
                                  child: Text('Volunteer',
                                      style: TextStyle(fontFamily: 'Nunito')),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],

                    // const SizedBox(height: 20),
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
                    ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            const Color.fromARGB(255, 255, 174, 74),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isSignUp ? "Create Account" : "Continue",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    // const SizedBox(height: 25),
                    TextButton(
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
                          color: Color(0xFFdf9d72),
                          fontSize: 16,
                          fontFamily: 'Nunito',
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
        style: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 0, 0, 0),
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
        ),
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
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Nunito',
              color: Color(0xFFdf9d72),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFFdf9d72),
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF13547A), // custom icon color
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFdf9d72), // unfocused border
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFdf9d72),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFdf9d72), // 👈 your custom border color
                  width: 2,
                ),
              ),
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
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Nunito',
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              hintText: "Enter your password",
              hintStyle: const TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFFdf9d72),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF13547A), // Custom icon color
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF13547A), // Matching icon color
                ),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFdf9d72),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFdf9d72),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                  color: Color(0xFFdf9d72), // Your custom color when focused
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

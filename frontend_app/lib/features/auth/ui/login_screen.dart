import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Senior';
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1444),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log in',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Role Dropdown
              _buildLabel('Select Role'),
              const SizedBox(height: 8),
              _buildRoleDropdown(),

              const SizedBox(height: 20),
              // Conditional Form Fields
              if (selectedRole == 'Senior') ...[
                _buildLabel('Phone Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  hint: 'Enter phone number',
                  icon: Icons.phone,
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: emailCtrl,
                ),
                const SizedBox(height: 16),
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildTextField(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  controller: passwordCtrl,
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A7BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Log in'),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9A7BFF),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2A2060),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownColor: const Color(0xFF2A2060),
      style: const TextStyle(color: Colors.white),
      items: ['Senior', 'Volunteer', 'Admin']
          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
          .toList(),
      onChanged: (value) => setState(() => selectedRole = value!),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2A2060),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _handleLogin() {
    print('Role: $selectedRole');
    if (selectedRole == 'Senior') {
      print('Phone: ${phoneCtrl.text}');
    } else {
      print('Email: ${emailCtrl.text}');
      print('Password: ${passwordCtrl.text}');
    }
    // TODO: Add backend login logic
  }
}

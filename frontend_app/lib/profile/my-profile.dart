import 'package:flutter/material.dart';
import 'package:frontend_app/senior/senior_home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../theme/theme_colors.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfilePage({super.key, required this.userData});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> profileData = {};
  String selectedGender = 'Male';
  final String baseUrl = "http://localhost:8000";
  // Skills setup
  final List<Map<String, dynamic>> skillOptions = [
    {'label': 'Tech Help', 'value': 1},
    {'label': 'Transportation', 'value': 2},
    {'label': 'Home Repairs', 'value': 3},
    {'label': 'Companionship', 'value': 4},
    {'label': 'Grocery Support', 'value': 5},
    {'label': 'Other', 'value': 6},
  ];
  List<int> selectedSkills = [];
  // Date picker
  DateTime? selectedDOB;
  String? formattedDOB;
  @override
  void initState() {
    super.initState();
    profileData['user_id'] = widget.userData['id'];
    profileData['role'] = widget.userData['role'];
    if (widget.userData['email'] != null) {
      profileData['email'] = widget.userData['email'];
    }
  }

  Widget _buildTextField(String label, String key,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Nunito', color: slateText),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFdf9d72), // unfocused border
            ),
          ),
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            color: Color(0xFFdf9d72),
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
        style: const TextStyle(fontFamily: 'Nunito', color: Colors.black87),
        onSaved: (val) => profileData[key] = val,
      ),
    );
  }

  Widget _buildDisabledField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value ?? '',
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Nunito', color: slateText),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFdf9d72), // unfocused border
            ),
          ),
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            color: Color(0xFFdf9d72),
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
        style: const TextStyle(fontFamily: 'Nunito', color: Colors.black87),
      ),
    );
  }

  Widget _buildSkillMultiSelect() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Skills",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 6,
            children: skillOptions.map((skill) {
              final bool isSelected = selectedSkills.contains(skill['value']);
              return FilterChip(
                label: Text(skill['label']),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedSkills.add(skill['value']);
                    } else {
                      selectedSkills.remove(skill['value']);
                    }
                    profileData['skills'] = selectedSkills;
                  });
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildDOBPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(1950),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFCE5E50), // sunsetCoral - header, buttons
                    onPrimary: Colors.white, // text on top of header
                    onSurface: Color(0xFF3D3D3D), // main text color
                  ),
                  textTheme: const TextTheme(
                    titleMedium: TextStyle(fontFamily: 'Nunito'),
                    bodyLarge: TextStyle(fontFamily: 'Nunito'),
                  ),
                  dialogBackgroundColor: Color(0xFFFFF1E6), // peachCream
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              selectedDOB = picked;
              formattedDOB = DateFormat('yyyy-MM').format(picked);
              profileData['dob'] = formattedDOB;
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Date of Birth",
            labelStyle: const TextStyle(fontFamily: 'Nunito', color: slateText),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFdf9d72), // unfocused border
              ),
            ),
            hintText: "Enter Date of Birth",
            hintStyle: const TextStyle(
              fontFamily: 'Nunito',
              color: Color(0xFFdf9d72),
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
          child: Text(
            formattedDOB ?? "Select DOB",
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
        ),
      ),
    );
  }

  Future<void> _submitProfile() async {
    _formKey.currentState?.save();
    final uri = Uri.parse('$baseUrl/create_profile');
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile submitted successfully"),
              backgroundColor: Colors.green),
        );
        // TODO: Redirect based on role
        if (profileData['role'] == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SeniorHomePage(userId: profileData['user_id']),
            ),
          );
        } else if (profileData['role'] == 2) {
          Navigator.pushReplacementNamed(context, '/volunteerHome');
        }
      } else {
        throw Exception(data['detail'] ?? "Profile submission failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.userData['role'];
    final email = widget.userData['email'];
    return Scaffold(
      backgroundColor: peachCream,
      appBar: AppBar(
        backgroundColor: sunsetCoral,
        title: const Text(
          "Complete Your Profile",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDisabledField("Email", email),
              _buildDisabledField("Role", role == 1 ? "Senior" : "Volunteer"),
              _buildTextField("First Name", "first_name"),
              _buildTextField("Last Name", "last_name"),
              _buildTextField("Phone", "phone", inputType: TextInputType.phone),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(
                            0xFFdf9d72), // matching your highlight color
                        width: 1.2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedGender,
                        hint: const Text(
                          "Select Gender",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Color(0xFF5F7983),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFFdf9d72)),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          color: Color(0xFF3D3D3D),
                          fontWeight: FontWeight.w600,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Male",
                            child: Text("Male"),
                          ),
                          DropdownMenuItem(
                            value: "Female",
                            child: Text("Female"),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedGender = val!;
                            profileData["gender"] = val;
                          });
                        },
                      ),
                    ),
                  )),
              _buildTextField("Street Address", "street_address"),
              _buildTextField("City", "city"),
              _buildTextField(
                  "State & ZIP Code (e.g., Illinois 60616)", "state_zip"),
              if (role == 1) ...[
                _buildDOBPicker(),
              ] else if (role == 2) ...[
                _buildSkillMultiSelect(),
                _buildTextField("Age", "age", inputType: TextInputType.number),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sunsetCoral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _submitProfile,
                child: const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

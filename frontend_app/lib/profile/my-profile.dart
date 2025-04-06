import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> profileData = {};
  final String baseUrl = "http://localhost:8000";

  // Array controllers
  List<String> skills = [];
  final TextEditingController skillController = TextEditingController();

  // Availability structured by day + time
  List<Map<String, String>> availability = [];
  String? selectedDay;
  final TextEditingController timeRangeController = TextEditingController();

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
          border: const OutlineInputBorder(),
        ),
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
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildArrayInput(String label, TextEditingController controller,
      List<String> list, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Enter and press +"),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isNotEmpty) {
                    setState(() {
                      list.add(value);
                      profileData[key] = list;
                      controller.clear();
                    });
                  }
                },
              )
            ],
          ),
          Wrap(
            spacing: 6,
            children: list
                .map((item) => Chip(
                      label: Text(item),
                      onDeleted: () {
                        setState(() {
                          list.remove(item);
                          profileData[key] = list;
                        });
                      },
                    ))
                .toList(),
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
          decoration: const InputDecoration(
            labelText: "Date of Birth",
            border: OutlineInputBorder(),
          ),
          child: Text(formattedDOB ?? "Select DOB"),
        ),
      ),
    );
  }

  Widget _buildAvailabilityPicker() {
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Availability",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: "Day",
                    border: OutlineInputBorder(),
                  ),
                  items: days
                      .map((day) => DropdownMenuItem(
                            value: day,
                            child: Text(day),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedDay = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: timeRangeController,
                  decoration: const InputDecoration(
                    labelText: "Time (e.g., 9 AM - 12 PM)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (selectedDay != null && timeRangeController.text.isNotEmpty) {
                    setState(() {
                      availability.add({
                        'day': selectedDay!,
                        'time': timeRangeController.text.trim()
                      });
                      profileData['availability'] = availability;
                      timeRangeController.clear();
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: availability
                .map((entry) => Chip(
                      label: Text("${entry['day']} - ${entry['time']}"),
                      onDeleted: () {
                        setState(() {
                          availability.remove(entry);
                          profileData['availability'] = availability;
                        });
                      },
                    ))
                .toList(),
          )
        ],
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
      appBar: AppBar(title: const Text("Complete Your Profile")),
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
              _buildTextField("Gender", "gender"),
              _buildTextField("Location", "location"),
              if (role == 1) ...[
                _buildDOBPicker(),
              ] else if (role == 2) ...[
                _buildArrayInput("Skills", skillController, skills, "skills"),
                _buildTextField("Age", "age", inputType: TextInputType.number),
                _buildAvailabilityPicker(),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
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

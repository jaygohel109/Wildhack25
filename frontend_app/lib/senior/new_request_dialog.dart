import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/theme_colors.dart';

class NewRequestDialog extends StatefulWidget {
  final String userId;

  const NewRequestDialog({
    super.key,
    required this.userId,
  });

  @override
  State<NewRequestDialog> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends State<NewRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'issue': '',
    'priority': 'normal',
    'preferable_gender': 'any',
    'description': '',
  };

  bool _isSubmitting = false;

  Future<void> _submitTask() async {
    setState(() => _isSubmitting = true);
    final url = Uri.parse('http://localhost:8000/create_task');
    final body = {
      ..._formData,
      'created_by': widget.userId, // Use correct backend key
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task created successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStyledTextField({
    required String label,
    int maxLines = 1,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Nunito'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontFamily: 'Nunito',
            color: Color(0xFF5F7983),
            fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildStyledDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontFamily: 'Nunito',
            color: Color(0xFF5F7983),
            fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFdf9d72), // 👈 your custom border color
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFdf9d72),
          ),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item[0].toUpperCase() + item.substring(1),
                  style: const TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: peachCream,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Request',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: skyAsh, // skyAsh
                  ),
                ),
                const SizedBox(height: 20),

                // Issue
                _buildStyledTextField(
                  label: 'Issue',
                  onSaved: (value) => _formData['issue'] = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an issue' : null,
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                _buildStyledDropdown(
                  label: 'Priority',
                  value: _formData['priority'],
                  items: const ['normal', 'urgent'],
                  onChanged: (val) =>
                      setState(() => _formData['priority'] = val!),
                ),
                const SizedBox(height: 16),

                // Preferable Gender
                _buildStyledDropdown(
                  label: 'Preferable Gender',
                  value: _formData['preferable_gender'],
                  items: const ['any', 'male', 'female'],
                  onChanged: (val) =>
                      setState(() => _formData['preferable_gender'] = val!),
                ),
                const SizedBox(height: 16),

                // Description
                _buildStyledTextField(
                  label: 'Description',
                  maxLines: 3,
                  onSaved: (value) => _formData['description'] = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sunsetCoral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _submitTask();
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

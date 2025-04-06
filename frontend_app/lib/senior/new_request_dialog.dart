import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 16),

                // Issue
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Issue',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _formData['issue'] = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an issue' : null,
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                DropdownButtonFormField<String>(
                  value: _formData['priority'],
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) =>
                      setState(() => _formData['priority'] = value!),
                ),
                const SizedBox(height: 16),

                // Preferable Gender
                DropdownButtonFormField<String>(
                  value: _formData['preferable_gender'],
                  decoration: const InputDecoration(
                    labelText: 'Preferable Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'any', child: Text('Any')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (value) =>
                      setState(() => _formData['preferable_gender'] = value!),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (value) => _formData['description'] = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 20),

                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _submitTask();
                          }
                        },
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

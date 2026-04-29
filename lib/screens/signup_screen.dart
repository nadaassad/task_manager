import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _gender;
  String? _academicLevel;
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final existingUser = await DatabaseHelper.instance.getUserByEmail(
      _emailController.text.trim(),
    );

    if (existingUser != null) {
      setState(() => _isLoading = false);
      _showError('Email already registered');
      return;
    }

    await DatabaseHelper.instance.insertUser({
      'fullName': _nameController.text.trim(),
      'gender': _gender,
      'email': _emailController.text.trim(),
      'studentId': _studentIdController.text.trim(),
      'academicLevel': _academicLevel,
      'password': _passwordController.text,
      'profilePhoto': null,
    });

    setState(() => _isLoading = false);
    _showSuccess();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final emailRegex = RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');
    if (!emailRegex.hasMatch(value)) {
      return 'Must be: studentID@stud.fci-cu.edu.eg';
    }
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final emailId = _emailController.text.split('@').first;
    if (value != emailId) return 'Student ID must match email ID';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 8) return 'At least 8 characters';
    if (!value.contains(RegExp(r'\d'))) return 'Must contain at least one number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // Gender
              Row(
                children: [
                  const Text('Gender:'),
                  Radio(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const Text('Male'),
                  Radio(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const Text('Female'),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'University Email',
                  hintText: '20201234@stud.fci-cu.edu.eg',
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                validator: _validateStudentId,
              ),
              const SizedBox(height: 12),
              // Academic Level
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Academic Level'),
                initialValue: _academicLevel,
                items: ['1', '2', '3', '4']
                    .map((e) => DropdownMenuItem(value: e, child: Text('Level $e')))
                    .toList(),
                onChanged: (v) => setState(() => _academicLevel = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (v != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signup,
                      child: const Text('Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
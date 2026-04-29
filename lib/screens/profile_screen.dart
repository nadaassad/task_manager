import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  String? _gender;
  String? _academicLevel;
  String? _profilePhoto;
  String? _email;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [widget.userId]);
    if (result.isNotEmpty) {
      final user = result.first;
      setState(() {
        _nameController.text = user['fullName'] as String;
        _studentIdController.text = user['studentId'] as String;
        _gender = user['gender'] as String?;
        _academicLevel = user['academicLevel'] as String?;
        _profilePhoto = user['profilePhoto'] as String?;
        _email = user['email'] as String;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _profilePhoto = picked.path);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    await DatabaseHelper.instance.updateUser(
      {
        'fullName': _nameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'gender': _gender,
        'academicLevel': _academicLevel,
        'profilePhoto': _profilePhoto,
      },
      widget.userId,
    );
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _showImageOptions : null,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profilePhoto != null
                    ? FileImage(File(_profilePhoto!))
                    : null,
                child: _profilePhoto == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            if (_isEditing)
              TextButton.icon(
                onPressed: _showImageOptions,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Change Photo'),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            if (_isEditing)
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
              )
            else
              TextFormField(
                initialValue: _gender ?? 'Not set',
                decoration: const InputDecoration(labelText: 'Gender'),
                enabled: false,
              ),
            const SizedBox(height: 12),
            if (_isEditing)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Academic Level'),
                initialValue: _academicLevel,
                items: ['1', '2', '3', '4']
                    .map((e) => DropdownMenuItem(value: e, child: Text('Level $e')))
                    .toList(),
                onChanged: (v) => setState(() => _academicLevel = v),
              )
            else
              TextFormField(
                initialValue: _academicLevel != null ? 'Level $_academicLevel' : 'Not set',
                decoration: const InputDecoration(labelText: 'Academic Level'),
                enabled: false,
              ),
          ],
        ),
      ),
    );
  }
}
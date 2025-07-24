import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;
  bool _isLoading = true;
  bool _isEditing = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    _emailController.text = user!.email ?? '';

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );

    setState(() => _isEditing = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _deleteAccount() async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/signup', (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            tooltip: _isEditing ? 'Save' : 'Edit',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black12,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.black54)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildField("Email", _emailController, enabled: false, greyed: true),
            const SizedBox(height: 12),
            _buildField("Name", _nameController, enabled: _isEditing),
            const SizedBox(height: 12),
            _buildField("Phone", _phoneController, keyboardType: TextInputType.phone, enabled: _isEditing),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_forever),
              label: const Text("Delete Account"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    required bool enabled,
    bool greyed = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.black54 : Colors.black, // 🔁 Swapped here
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: greyed || !enabled,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

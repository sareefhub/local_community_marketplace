import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_community_marketplace/utils/user_session.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  bool _isLoading = true;
  bool _isSaving = false;

  String? userDocId; // เก็บ id เอกสาร Firestore ของ user
  String? _userIdFromFirestore; // เก็บ userId จากข้อมูลใน Firestore
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    userDocId = UserSession.userId;
    if (userDocId != null) {
      _loadUserProfile();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && userDocId != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // อัปโหลดไปยัง Firebase Storage
      final fileName = 'profile_images/$userDocId.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(_selectedImage!);
      final downloadURL = await ref.getDownloadURL();

      // อัปเดต Firestore
      await _firestore.collection('users').doc(userDocId).update({
        'profileImageUrl': downloadURL,
      });

      // อัปเดต UserSession ด้วย
      UserSession.profileImageUrl = downloadURL;

      setState(() {
        _profileImageUrl = downloadURL;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(userDocId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _usernameController.text = data['username'] ?? '';
        _phoneController.text = data['editPhone'] ?? data['phone'] ?? '';
        _profileImageUrl = data['profileImageUrl'];
        _userIdFromFirestore = data['userId'];

        // อัปเดต UserSession profileImageUrl ด้วย
        UserSession.profileImageUrl = _profileImageUrl;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateInput() {
    String username = _usernameController.text.trim();
    String phone = _phoneController.text.trim();

    if (username.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return false;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone must be exactly 10 digits')),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveProfile() async {
    if (userDocId == null) return;
    if (!_validateInput()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('users').doc(userDocId).update({
        'username': _usernameController.text.trim(),
        'editPhone': _phoneController.text.trim(),
      });

      // อัปเดต UserSession
      UserSession.username = _usernameController.text.trim();
      UserSession.phone = _phoneController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        title: const Text('Edit Profile'),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/angle-small-left.png',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/icons/circle-user.png')
                            as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Text('User ID',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text(_userIdFromFirestore ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9E1E6),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(
                  color: Color(0xFF062252),
                  width: 1,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

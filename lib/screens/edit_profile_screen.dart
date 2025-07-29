import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Username');
  final TextEditingController _phoneController =
      TextEditingController(text: '0XXXXXXXXX');

  @override
  Widget build(BuildContext context) {
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
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/icons/circle-user.png'),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: const [
                Text('User ID', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('12345678'),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // TODO: Save logic
                Navigator.pop(context);
              },
              child: const Text('Save Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC9E1E6),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(
                  color: Color(0xFF062252),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  // เพิ่มความโค้งมุม (ถ้าต้องการ)
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

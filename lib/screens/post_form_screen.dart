import 'package:flutter/material.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _category;
  String? _province;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        leading: const BackButton(color: Colors.black),
        title: const Text('Post', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save logic
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            buildSectionHeader('Product information'),
            buildTextField(label: 'Product name', hint: 'xxxxx'),
            buildSelectField(label: 'Category', value: _category, onTap: () {}),
            buildTextField(
                label: 'Price',
                hint: 'Bath',
                keyboardType: TextInputType.number),
            buildTextField(
              label: 'Product Detail',
              hint: 'Detail',
              maxLines: 3,
              initialValue: '500',
              underlineThickness: 1.5, // เพิ่มความหนาเส้น
            ),
            buildSectionHeader('Location'),
            buildSelectField(label: 'Province', value: _province, onTap: () {}),
            buildSectionHeader('Contact'),
            buildTextField(
                label: 'Phone',
                hint: 'xxxxxxxxxx',
                keyboardType: TextInputType.phone),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Complete all fields to speed up your sale.\nBy tapping "Post" you agree to the listing terms.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            /// ✅ ปุ่มโพสต์พร้อมขอบสีเข้ม
            Center(
              child: OutlinedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit logic
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0F3F7),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFF062252)), // ✅ ขอบเข้ม
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Post'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF0F0F0),
      child: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? initialValue,
    double underlineThickness = 1.0, // 🆕 เพิ่ม parameter ความหนาของเส้น
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: underlineThickness),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 5,
            child: TextFormField(
              initialValue: initialValue,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              textAlign: TextAlign.right,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value ?? 'Select',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

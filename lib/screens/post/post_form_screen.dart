import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../widgets/post_category_selector.dart';
import '../../widgets/post_province_selector.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _productName = '', _price = '', _productDetail = '', _phone = '';
  String? _category, _province;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _selectCategory() async {
    final selected = await showPostCategoryDialog(context);
    if (selected != null) setState(() => _category = selected);
  }

  void _selectProvince() async {
    final selected = await showPostProvinceDialog(context);
    if (selected != null) setState(() => _province = selected);
  }

  // แก้ไขเพิ่ม parameter state เพื่อกำหนดสถานะตอนบันทึก
  Future<void> _saveProduct({String state = 'draft'}) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final counterRef = _firestore.collection('counters').doc('post');
      final counterSnapshot = await counterRef.get();

      int lastPostId = 0;
      if (counterSnapshot.exists && counterSnapshot.data()?['lastPostId'] != null) {
        lastPostId = int.tryParse(counterSnapshot.data()!['lastPostId'].toString()) ?? 0;
      }

      final newPostId = lastPostId + 1;
      final newDocId = 'post$newPostId';
      final postRef = _firestore.collection('posts').doc(newDocId);

      final product = ProductModel(
        id: newDocId,
        name: _productName,
        category: _category ?? '',
        description: _productDetail,
        price: _price,
        location: _province ?? '',
        rating: 0.0,
        image: '',
        sellerName: '',
        sellerImage: '',
        phone: _phone,
        state: state,
      );

      await postRef.set(product.toMap());
      await counterRef.set({'lastPostId': newPostId});

      if (!mounted) return;  // ตรวจสอบก่อนใช้ context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state == 'post' ? 'Product posted successfully' : 'Product saved successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;  // ตรวจสอบก่อนใช้ context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    }
  }

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
              if (_formKey.currentState!.validate()) _saveProduct(state: 'draft');
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionHeader('Product information'),
              _buildTextField('Product name', 'xxxxx', onSaved: (val) => _productName = val ?? ''),
              _buildSelectField('Category', _category, _selectCategory),
              _buildTextField('Price', 'Bath',
                  keyboardType: TextInputType.number, onSaved: (val) => _price = val ?? ''),
              _buildTextField('Product Detail', 'Detail',
                  maxLines: 6, underlineThickness: 1.5, onSaved: (val) => _productDetail = val ?? ''),
              _buildSectionHeader('Location'),
              _buildSelectField('Province', _province, _selectProvince),
              _buildSectionHeader('Contact'),
              _buildTextField('Phone', 'xxxxxxxxxx',
                  keyboardType: TextInputType.phone, onSaved: (val) => _phone = val ?? ''),
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
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) _saveProduct(state: 'post');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0F3F7),
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFF062252)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFFF0F0F0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF062252),
          ),
        ),
      );

  Widget _buildTextField(
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? initialValue,
    double underlineThickness = 1.0,
    required FormFieldSetter<String> onSaved,
  }) =>
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: underlineThickness),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 14))),
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
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onSaved: onSaved,
              ),
            ),
          ],
        ),
      );

  Widget _buildSelectField(String label, String? value, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 14))),
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(value ?? 'Select', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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

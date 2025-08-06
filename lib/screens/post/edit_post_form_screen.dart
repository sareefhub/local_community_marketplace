import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // เพิ่ม import
import '../../widgets/post_category_selector.dart';
import '../../widgets/post_province_selector.dart';

class EditPostFormScreen extends StatefulWidget {
  final String postId;

  const EditPostFormScreen({super.key, required this.postId});

  @override
  State<EditPostFormScreen> createState() => _EditPostFormScreenState();
}

class _EditPostFormScreenState extends State<EditPostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _productName = '',
      _price = '',
      _productDetail = '',
      _phone = '',
      _imageUrl = '';
  String? _category, _province;

  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    try {
      final doc = await _firestore.collection('posts').doc(widget.postId).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (!mounted) return;
        setState(() {
          _productName = data['name'] ?? '';
          _price = data['price'] ?? '';
          _productDetail = data['description'] ?? '';
          _phone = data['phone'] ?? '';
          _category = data['category'];
          _province = data['location'];
          _imageUrl = data['image'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading post: $e', style: GoogleFonts.sarabun()),
        ),
      );
    }
  }

  void _selectCategory() async {
    final selected = await showPostCategoryDialog(context);
    if (selected != null) setState(() => _category = selected);
  }

  void _selectProvince() async {
    final selected = await showPostProvinceDialog(context);
    if (selected != null) setState(() => _province = selected);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageUrl = picked.path;
      });
      // TODO: Upload image to Firebase Storage และอัพเดต _imageUrl เป็น URL จริง
    }
  }

  Future<void> _updateProduct({String? newState}) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final updatedData = {
        'name': _productName,
        'category': _category ?? '',
        'price': _price,
        'description': _productDetail,
        'location': _province ?? '',
        'phone': _phone,
        'image': _imageUrl,
      };

      if (newState != null) {
        updatedData['state'] = newState;
      }

      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState == 'post'
                ? 'Post published successfully'
                : 'Product updated successfully',
            style: GoogleFonts.sarabun(),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Update failed: $e', style: GoogleFonts.sarabun())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        leading: const BackButton(color: Colors.black),
        title:
            Text('Edit Post', style: GoogleFonts.sarabun(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _updateProduct(),
            child:
                Text('Save', style: GoogleFonts.sarabun(color: Colors.black)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionHeader('Product information'),
              _buildTextField('Product name', 'xxxxx',
                  initialValue: _productName,
                  onSaved: (val) => _productName = val ?? ''),
              _buildSelectField('Category', _category, _selectCategory),
              _buildTextField('Price', 'Bath',
                  keyboardType: TextInputType.number,
                  initialValue: _price,
                  onSaved: (val) => _price = val ?? ''),
              _buildTextField('Product Detail', 'Detail',
                  maxLines: 6,
                  underlineThickness: 1.5,
                  initialValue: _productDetail,
                  onSaved: (val) => _productDetail = val ?? ''),
              _buildSectionHeader('Image'),
              _buildImagePicker(),
              _buildSectionHeader('Location'),
              _buildSelectField('Province', _province, _selectProvince),
              _buildSectionHeader('Contact'),
              _buildTextField('Phone', 'xxxxxxxxxx',
                  keyboardType: TextInputType.phone,
                  initialValue: _phone,
                  onSaved: (val) => _phone = val ?? ''),
              const SizedBox(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateProduct(newState: 'post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F3F7),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.sarabun(
                          fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: const Color(0xFF062252)),
          borderRadius: BorderRadius.circular(12),
          image: _imageUrl.isNotEmpty
              ? DecorationImage(image: AssetImage(_imageUrl), fit: BoxFit.cover)
              : null,
        ),
        child: _imageUrl.isEmpty
            ? Center(
                child: Icon(Icons.camera_alt, color: Colors.grey, size: 40))
            : null,
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFFF0F0F0),
        child: Text(
          title,
          style: GoogleFonts.sarabun(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF062252),
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
          crossAxisAlignment: maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: GoogleFonts.sarabun(fontSize: 14),
                )),
            Expanded(
              flex: 5,
              child: TextFormField(
                initialValue: initialValue,
                maxLines: maxLines,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.sarabun(),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.right,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onSaved: onSaved,
                style: GoogleFonts.sarabun(),
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
              Expanded(
                  flex: 3,
                  child: Text(
                    label,
                    style: GoogleFonts.sarabun(fontSize: 14),
                  )),
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      value ?? 'Select',
                      style:
                          GoogleFonts.sarabun(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

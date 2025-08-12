// lib/screens/post/edit_post_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/utils/user_session.dart';
import '../../widgets/post_category_selector.dart';
import '../../widgets/post_province_selector.dart';
import '../../repositories/post_repository.dart'; // <— เพิ่มบรรทัดเดียวนี้

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
      final uid = UserSession.userId;
      if (uid == null || uid.isEmpty) {
        throw Exception('ยังไม่ได้เข้าสู่ระบบ (userId เป็น null)');
      }

      final doc = await _firestore
          .collection('posts')
          .doc(uid)
          .collection('items')
          .doc(widget.postId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        if (!mounted) return;
        setState(() {
          _productName = (data['name'] ?? '').toString();
          _price = (data['price'] ?? '').toString();
          _productDetail = (data['description'] ?? '').toString();
          _phone = (data['phone'] ?? '').toString();
          _category = (data['category'] ?? '').toString();
          _province = (data['location'] ?? '').toString();
          _imageUrl = (data['image'] ?? '').toString();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่พบโพสต์นี้', style: GoogleFonts.sarabun())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ดึงข้อมูลไม่สำเร็จ: $e', style: GoogleFonts.sarabun())),
      );
      Navigator.pop(context);
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
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked != null) {
      setState(() {
        _imageUrl = picked.path; // ไฟล์โลคัล
      });
      // TODO: อัปโหลดขึ้น Firebase Storage แล้วอัปเดต _imageUrl เป็นลิงก์ https
    }
  }

  Future<void> _updateProduct({String? newState}) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final uid = UserSession.userId;
      if (uid == null || uid.isEmpty) {
        throw Exception('ยังไม่ได้เข้าสู่ระบบ (userId เป็น null)');
      }

      final Map<String, dynamic> updatedData = {
        'name': _productName,
        'category': _category ?? '',
        'price': _price,
        'description': _productDetail,
        'location': _province ?? '',
        'phone': _phone,
        'image': _imageUrl,
      };

      if (newState != null) {
        updatedData['state'] = newState; // 'post'
        // ไม่ตั้ง publishedAt ที่นี่ ปล่อยให้ Repository ตั้งตอน sync
      }

      await _firestore
          .collection('posts')
          .doc(uid)
          .collection('items')
          .doc(widget.postId)
          .update(updatedData);

          if (newState == 'post') {
            final productId = await PostRepository()
                .syncIfStateIsPost(uid: uid, postId: widget.postId);
            if (productId == null || productId.isEmpty) {
              throw Exception('sync ไม่สำเร็จ');
            }
          }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState == 'post'
                ? 'เผยแพร่โพสต์เรียบร้อย'
                : 'บันทึกการแก้ไขเรียบร้อย',
            style: GoogleFonts.sarabun(),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('อัปเดตไม่สำเร็จ: $e', style: GoogleFonts.sarabun())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final titleStyle = GoogleFonts.sarabun(color: Colors.black, fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        leading: const BackButton(color: Colors.black),
        title: Text('แก้ไขโพสต์', style: titleStyle),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _updateProduct(),
            child: Text('บันทึก', style: GoogleFonts.sarabun(color: Colors.black)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionHeader('ข้อมูลสินค้า'),
              _buildTextField(
                'ชื่อสินค้า',
                'เช่น มะม่วงน้ำดอกไม้',
                initialValue: _productName,
                onSaved: (val) => _productName = val ?? '',
              ),
              _buildSelectField('หมวดหมู่', _category, _selectCategory),
              _buildTextField(
                'ราคา',
                'เช่น 120',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: _price,
                onSaved: (val) => _price = val ?? '',
                trailingHint: 'บาท',
              ),
              _buildTextField(
                'รายละเอียดสินค้า',
                'บอกรายละเอียด จุดเด่น วิธีเก็บรักษา ฯลฯ',
                maxLines: 6,
                underlineThickness: 1.5,
                initialValue: _productDetail,
                onSaved: (val) => _productDetail = val ?? '',
              ),

              _buildSectionHeader('รูปภาพ'),
              _buildImagePicker(),

              _buildSectionHeader('สถานที่'),
              _buildSelectField('จังหวัด', _province, _selectProvince),

              _buildSectionHeader('ติดต่อ'),
              _buildTextField(
                'เบอร์โทร',
                'เช่น 0812345678',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: _phone,
                onSaved: (val) => _phone = val ?? '',
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateProduct(newState: 'post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F3F7),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('เผยแพร่', style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI helpers ----------------

  Widget _buildImagePicker() {
    final border = Border.all(color: const Color(0xFF062252));
    final radius = BorderRadius.circular(12);

    ImageProvider? provider;
    if (_imageUrl.isNotEmpty) {
      if (_imageUrl.startsWith('http://') || _imageUrl.startsWith('https://')) {
        provider = NetworkImage(_imageUrl);
      } else if (_imageUrl.startsWith('assets/')) {
        provider = AssetImage(_imageUrl);
      } else if (File(_imageUrl).existsSync()) {
        provider = FileImage(File(_imageUrl));
      }
    }

    return InkWell(
      onTap: _pickImage,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: border,
          borderRadius: radius,
          image: provider != null
              ? DecorationImage(image: provider, fit: BoxFit.cover)
              : null,
        ),
        child: provider == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                  const SizedBox(height: 8),
                  Text('แตะเพื่อเลือกรูป', style: GoogleFonts.sarabun(color: Colors.grey[700])),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('เปลี่ยนรูป', style: GoogleFonts.sarabun(color: Colors.white)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    List<TextInputFormatter>? inputFormatters,
    String? initialValue,
    String? trailingHint,
    double underlineThickness = 1.0,
    required FormFieldSetter<String> onSaved,
  }) {
    final labelStyle = GoogleFonts.sarabun(fontSize: 14);
    final inputStyle = GoogleFonts.sarabun();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: underlineThickness),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: Text(label, style: labelStyle)),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: initialValue,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: inputStyle.copyWith(color: Colors.grey[500]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textAlign: TextAlign.right,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'จำเป็นต้องกรอก' : null,
                    onSaved: onSaved,
                    style: inputStyle,
                  ),
                ),
                if (trailingHint != null) ...[
                  const SizedBox(width: 6),
                  Text(trailingHint, style: GoogleFonts.sarabun(color: Colors.black54)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField(String label, String? value, VoidCallback onTap) {
    final labelStyle = GoogleFonts.sarabun(fontSize: 14);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(label, style: labelStyle)),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(value ?? 'เลือก', style: GoogleFonts.sarabun(fontSize: 14, color: Colors.grey[600])),
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

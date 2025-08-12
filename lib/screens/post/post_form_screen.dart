// lib/screens/post_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../widgets/post_category_selector.dart';
import '../../widgets/post_province_selector.dart';
import '../../utils/user_session.dart';
import '../../repositories/post_repository.dart';

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

  Future<void> _saveProduct({String state = 'draft'}) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final uid = UserSession.userId;
      if (uid == null || uid.isEmpty) {
        throw Exception('ยังไม่ได้เข้าสู่ระบบ (userId เป็น null)');
      }

      final counterRef = _firestore.collection('counters').doc('post');
      final counterSnapshot = await counterRef.get();

      int lastPostId = 0;
      if (counterSnapshot.exists &&
          counterSnapshot.data()?['lastPostId'] != null) {
        lastPostId =
            int.tryParse(counterSnapshot.data()!['lastPostId'].toString()) ?? 0;
      }

      final newPostId = lastPostId + 1;
      final newDocId = 'post$newPostId';

      final postRef = _firestore
          .collection('posts')
          .doc(uid)
          .collection('items')
          .doc(newDocId);

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

      final map = product.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['sourceUserId'] = uid;

      await postRef.set(map);
      await counterRef.set({'lastPostId': newPostId});

      if (state == 'post') {
        await PostRepository().syncIfStateIsPost(uid: uid, postId: newDocId);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state == 'post'
                ? 'เผยแพร่โพสต์เรียบร้อย'
                : 'บันทึกแบบร่างเรียบร้อย',
            style: GoogleFonts.sarabun(),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกไม่สำเร็จ: $e', style: GoogleFonts.sarabun()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline = GoogleFonts.sarabun(
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        leading: const BackButton(color: Colors.black),
        title: Text('สร้างโพสต์', style: headline),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _saveProduct(state: 'draft');
              }
            },
            child: Text('บันทึกแบบร่าง', style: GoogleFonts.sarabun(color: Colors.black)),
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
                onSaved: (val) => _productName = val ?? '',
              ),
              _buildSelectField('หมวดหมู่', _category, _selectCategory),
              _buildTextField(
                'ราคา',
                'เช่น 120',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (val) => _price = val ?? '',
                trailingHint: 'บาท',
              ),
              _buildTextField(
                'รายละเอียดสินค้า',
                'บอกรายละเอียด จุดเด่น วิธีเก็บรักษา ฯลฯ',
                maxLines: 6,
                underlineThickness: 1.5,
                onSaved: (val) => _productDetail = val ?? '',
              ),

              _buildSectionHeader('สถานที่'),
              _buildSelectField('จังหวัด', _province, _selectProvince),

              _buildSectionHeader('ติดต่อ'),
              _buildTextField(
                'เบอร์โทร',
                'เช่น 0812345678',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (val) => _phone = val ?? '',
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'กรอกข้อมูลให้ครบถ้วนเพื่อช่วยให้ขายได้ไวขึ้น\nเมื่อกด “เผยแพร่” ถือว่ายอมรับเงื่อนไขการลงประกาศ',
                  style: GoogleFonts.sarabun(fontSize: 12, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // ปุ่มเผยแพร่
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveProduct(state: 'post');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F3F7),
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF062252)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('เผยแพร่', style: GoogleFonts.sarabun(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI helpers ----------------

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

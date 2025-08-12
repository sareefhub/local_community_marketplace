import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> showPostCategoryDialog(BuildContext context) async {
  final firestore = FirebaseFirestore.instance;

  // ดึงข้อมูลหมวดหมู่จาก Firestore
  final snap = await firestore.collection('categories').get();

  // map -> list ที่ปลอดภัยต่อ null
  final List<Map<String, dynamic>> categories = snap.docs.map((doc) {
    final data = doc.data();
    return {
      'label': (data['label'] ?? '').toString(),
      'image': (data['image'] ?? '').toString(), // อาจเป็น url / assets / local file
    };
  }).where((e) => (e['label'] as String).isNotEmpty).toList();

  return showDialog<String>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'เลือกหมวดหมู่',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF001B6E),
              fontFamily: 'Prompt',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF001B6E)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final label = cat['label'] as String;
              final path  = cat['image'] as String;

              return ListTile(
                leading: _categoryThumb(path), // <- ใช้ตัวช่วยเลือกวิธีแสดงรูป
                title: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontFamily: 'Prompt',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF001B6E)),
                onTap: () => Navigator.pop(context, label),
              );
            },
          ),
        ),
      ),
    ),
  );
}

/// แสดงรูปให้ถูกวิธีตามชนิด path:
/// - http/https -> NetworkImage
/// - assets/... -> AssetImage (อย่าลืมประกาศใน pubspec.yaml)
/// - ไฟล์โลคัล (จาก ImagePicker) -> FileImage
Widget _categoryThumb(String path) {
  const double size = 28;
  const fallback = Icon(Icons.image, color: Color(0xFF001B6E), size: size);

  if (path.isEmpty) return fallback;

  ImageProvider? provider;

  if (path.startsWith('http://') || path.startsWith('https://')) {
    provider = NetworkImage(path);
  } else if (path.startsWith('assets/')) {
    provider = AssetImage(path);
  } else if (File(path).existsSync()) {
    provider = FileImage(File(path));
  } else {
    // ถ้าเป็น gs:// หรือพาธ Storage ที่ยังไม่ได้แปลงเป็น downloadURL
    // ให้ fallback ไปก่อน (หรือดึง downloadURL มาก่อนแล้วค่อยใส่ http url)
    return fallback;
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Image(
      image: provider,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}

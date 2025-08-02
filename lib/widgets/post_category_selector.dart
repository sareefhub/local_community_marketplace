import 'package:flutter/material.dart';
import '/dummy_categories.dart';

Future<String?> showPostCategoryDialog(BuildContext context) async {
  final selected = await showDialog<String>(
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
              color: Color(0xFF001B6E), // สีฟ้าเข้ม
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
          color: Colors.white,  // กำหนดพื้นหลังเป็นสีขาว
          child: ListView.builder(
            itemCount: dummyCategories.length,
            itemBuilder: (context, index) {
              final category = dummyCategories[index];
              return ListTile(
                leading: Image.asset(
                  category['image'],
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, color: Color(0xFF001B6E)),
                ),
                title: Text(
                  category['label'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontFamily: 'Prompt',
                  ),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Color(0xFF001B6E)),
                onTap: () => Navigator.pop(context, category['label']),
              );
            },
          ),
        ),
      ),
    ),
  );
  return selected;
}

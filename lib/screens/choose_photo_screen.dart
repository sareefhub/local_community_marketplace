import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChoosePhotoScreen extends StatelessWidget {
  const ChoosePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: const Color(0xFFE0F3F7),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.pop(), // ← ย้อนกลับด้วย go_router
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF062252),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Photo',
                  style: TextStyle(
                    color: Color(0xFF062252),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/icons/arrow-right.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      context.go('/form'); // ← ไปหน้าฟอร์ม
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              'Select photo that are real products,\nwithout any photo editing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

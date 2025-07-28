import 'package:flutter/material.dart';
import 'package:local_community_marketplace/components/navigation.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {'status': 'Post'},
      {'status': 'Wait'},
      {'status': 'Draft'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        title: const Text('Post', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // เปิดหน้าสร้างโพสต์ใหม่
            },
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final status = posts[index]['status'];
            return _buildPostItem(status!);
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildPostItem(String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name of Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Detail............................\n.................................',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _buildStatusButton(status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status) {
    Color? bgColor;
    Color textColor = Colors.black;
    OutlinedBorder shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    ButtonStyle style;

    switch (status) {
      case 'Post':
        style = ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB9E8C9),
          foregroundColor: Colors.black,
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        );
        return ElevatedButton(
            onPressed: () {}, style: style, child: const Text('Post'));

      case 'Wait':
        style = OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFDCEFF3),
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.transparent),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        );
        return OutlinedButton(
            onPressed: () {}, style: style, child: const Text('Wait'));

      case 'Draft':
      default:
        style = OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        );
        return OutlinedButton(
            onPressed: () {}, style: style, child: const Text('Draft'));
    }
  }
}

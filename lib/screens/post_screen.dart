import 'package:flutter/material.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:go_router/go_router.dart';

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
              context.go('/choose_photo'); // ← ใช้ go_router แทน
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
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
                    child: _buildStatusLabel(status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color bgColor;
    Color borderColor = const Color(0xFF062252);

    switch (status) {
      case 'Post':
        bgColor = const Color(0xFFB9E8C9);
        break;
      case 'Wait':
        bgColor = const Color(0xFFDCEFF3);
        break;
      case 'Draft':
      default:
        bgColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }
}

// lib/screens/post_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:local_community_marketplace/utils/user_session.dart';
import 'package:local_community_marketplace/utils/date_utils.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deletePost(String postId) async {
    try {
      final uid = UserSession.userId;
      if (uid == null || uid.isEmpty) {
        throw Exception('User not logged in (userId is null)');
      }

      await _firestore
          .collection('posts')
          .doc(uid)
          .collection('items')
          .doc(postId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบโพสต์สำเร็จ', style: GoogleFonts.sarabun())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบโพสต์ไม่สำเร็จ: $e', style: GoogleFonts.sarabun())),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ยืนยันการลบ', style: GoogleFonts.sarabun(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการลบโพสต์นี้หรือไม่?', style: GoogleFonts.sarabun()),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('ยกเลิก', style: GoogleFonts.sarabun())),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('ลบ', style: GoogleFonts.sarabun(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = UserSession.userId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        title: Text('โพสต์', style: GoogleFonts.sarabun(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => GoRouter.of(context).push('/postform'),
          ),
        ],
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (uid == null || uid.isEmpty) {
            return Center(child: Text('กรุณาเข้าสู่ระบบเพื่อเพิ่มสินค้า', style: GoogleFonts.sarabun()));
          }

          final stream = _firestore
              .collection('posts')
              .doc(uid)
              .collection('items')
              .orderBy('createdAt', descending: true)
              .snapshots();

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}', style: GoogleFonts.sarabun(color: Colors.red)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('ยังไม่มีโพสต์', style: GoogleFonts.sarabun()));
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final doc = posts[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? 'No name').toString();
                    final description = (data['description'] ?? '').toString();
                    final rawState = (data['state'] ?? 'post').toString();
                    final status = rawState.capitalize();
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final postId = doc.id;

                    return GestureDetector(
                      onTap: () {
                        GoRouter.of(context).push('/postedit/$postId');
                      },
                      child: _buildPostItem(context, name, description, status, createdAt, postId),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildPostItem(BuildContext context, String name, String description, String status, DateTime? createdAt, String postId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: GoogleFonts.sarabun(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sarabun(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusLabel(status),
                      if (createdAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          AppDateUtils.formatDateTime(createdAt),
                          style: GoogleFonts.sarabun(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (value) async {
                if (value == 'edit') {                                    // <-- แก้: รองรับเมนู "แก้ไข"
                  GoRouter.of(context).push('/postedit/$postId');          // <-- แก้: ไปหน้าแก้ไข
                } else if (value == 'delete') {                            // <-- แก้: เมนู "ลบ"
                  final confirmed = await _showDeleteConfirmationDialog();
                  if (confirmed == true) {
                    await _deletePost(postId);
                  }
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(                                      // <-- แก้: เพิ่มเมนู "แก้ไข" พร้อมไอคอน
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('แก้ไข', style: GoogleFonts.sarabun()),
                    ],
                  ),
                ),
                PopupMenuItem<String>(                                      // <-- แก้: เพิ่มเมนู "ลบ" พร้อมไอคอน
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('ลบโพสต์', style: GoogleFonts.sarabun(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color bgColor;
    const Color borderColor = Color(0xFF062252);

    switch (status) {
      case 'Post':
      case 'Posted':
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(status, style: GoogleFonts.sarabun(fontSize: 12, color: Colors.black)),
    );
  }
}

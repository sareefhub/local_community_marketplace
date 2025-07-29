import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:local_community_marketplace/utils/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? username;
  String? userId;
  String? phone;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    // สมมติ userId มาจาก UserSession (ถ้ามี)
    final currentUserId = UserSession.userId;

    if (currentUserId != null) {
      try {
        final doc =
            await _firestore.collection('users').doc(currentUserId).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            username = data['username'] ?? UserSession.username;
            userId = currentUserId;
            phone = data['phone'] ?? UserSession.phone;
          });
        }
      } catch (e) {
        // ถ้า error ให้ fallback เป็นข้อมูลเดิมจาก UserSession
        setState(() {
          username = UserSession.username;
          userId = currentUserId;
          phone = UserSession.phone;
        });
      }
    } else {
      setState(() {
        username = UserSession.username;
        userId = UserSession.userId;
        phone = UserSession.phone;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = username != null && userId != null && phone != null;

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFE0F3F7),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey,
                          child: ImageIcon(
                            AssetImage('assets/icons/user.png'),
                            size: 35,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            Text(
                              username ?? 'Guest',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userId != null
                                  ? 'User ID\n$userId'
                                  : 'Not logged in',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // รอผลลัพธ์กลับมาจากหน้า edit_profile
                            await context.push('/edit_profile');
                            // โหลดข้อมูลใหม่หลังแก้ไขเสร็จ
                            await _loadUserData();
                          },
                          icon: const ImageIcon(
                            AssetImage('assets/icons/edit.png'),
                            size: 16,
                          ),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD1E9F2),
                            foregroundColor: Colors.black,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const ImageIcon(
                            AssetImage('assets/icons/seller-store.png'),
                            size: 20,
                          ),
                          title: const Text("Purchase History"),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const ImageIcon(
                            AssetImage('assets/icons/seller.png'),
                            size: 20,
                          ),
                          title: const Text("My Store"),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const ImageIcon(
                            AssetImage('assets/icons/heart.png'),
                            size: 20,
                          ),
                          title: const Text("My favorites"),
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isLoggedIn) {
                                UserSession.clear();
                                context.go('/login');
                              } else {
                                context.go('/login');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD1E9F2),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              child: Text(isLoggedIn ? 'Log Out' : 'Log In'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

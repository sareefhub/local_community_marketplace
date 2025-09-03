import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  const ChatScreen({super.key, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH.mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return DateFormat('d/MM').format(dateTime);
    } else if (dateTime.year < now.year) {
      return DateFormat('d/MM/yyyy').format(dateTime);
    } else {
      return DateFormat('d/MM').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFFE0F3F7),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'ข้อความ',
            style: GoogleFonts.sarabun(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.sarabun(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    searchText = val.trim().toLowerCase();
                  });
                },
              ),
            ),
          ),

          // Chat List
          Expanded(
            child:
                searchText.isEmpty ? _buildChatList() : _buildSearchResults(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: widget.currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!.docs;

        if (chats.isEmpty) {
          return Center(
            child: Text(
              'ยังไม่มีข้อความ',
              style: GoogleFonts.sarabun(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // ✅ sort client-side ตาม timestamp ล่าสุด
        chats.sort((a, b) {
          final t1 =
              (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          final t2 =
              (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          return (t2?.toDate() ?? DateTime(0))
              .compareTo(t1?.toDate() ?? DateTime(0));
        });

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final data = chat.data() as Map<String, dynamic>;

            final users = List<String>.from(data['users'] ?? []);
            final otherUserId = users
                .firstWhere((u) => u != widget.currentUserId, orElse: () => '');

            final lastMessage = data.containsKey('lastMessage')
                ? data['lastMessage'] ?? ''
                : '';
            final timestamp = data.containsKey('timestamp')
                ? data['timestamp'] as Timestamp?
                : null;
            final timeLabel = formatTimestamp(timestamp);

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                String userName = otherUserId;
                String? avatarUrl;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userDoc = userSnapshot.data!;
                  final userData = userDoc.data() as Map<String, dynamic>?;

                  if (userData != null) {
                    userName = userData.containsKey('username')
                        ? userData['username'] ?? otherUserId
                        : otherUserId;
                    avatarUrl = userData.containsKey('avatarUrl')
                        ? userData['avatarUrl'] as String?
                        : null;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    context.push(
                      '/chat_detail/${chat.id}/${widget.currentUserId}/$otherUserId',
                      extra: {
                        'userName': userName,
                        'avatarUrl': avatarUrl,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.shade400,
                          backgroundImage:
                              (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? NetworkImage(avatarUrl)
                                  : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: GoogleFonts.sarabun(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeLabel,
                                    style: GoogleFonts.sarabun(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                lastMessage,
                                style: GoogleFonts.sarabun(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .get(), // ✅ ดึง users ทั้งหมดมาก่อน
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ filter เอา currentUser ออก + ค้นหาตามชื่อ
        final usersFound = userSnapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final username = (data['username'] ?? '').toString().toLowerCase();
          return doc.id != widget.currentUserId &&
              (searchText.isEmpty || username.contains(searchText));
        }).toList();

        if (usersFound.isEmpty) {
          return Center(
            child: Text(
              'ไม่พบผู้ใช้',
              style: GoogleFonts.sarabun(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: widget.currentUserId)
              .get(),
          builder: (context, chatSnapshot) {
            if (!chatSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = chatSnapshot.data!.docs;

            // ✅ map หา chat เดิมถ้ามี
            Map<String, QueryDocumentSnapshot> chatMap = {};
            for (var chat in chats) {
              final data = chat.data() as Map<String, dynamic>;
              final users = List<String>.from(data['users']);
              final otherUserId =
                  users.firstWhere((u) => u != widget.currentUserId);
              chatMap[otherUserId] = chat;
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: usersFound.length,
              itemBuilder: (context, index) {
                final userDoc = usersFound[index];
                final userId = userDoc.id;
                final userData = userDoc.data() as Map<String, dynamic>;
                final userName = userData['username'] ?? userId;
                final avatarUrl = userData.containsKey('avatarUrl')
                    ? userData['avatarUrl'] as String?
                    : null;

                final existingChat = chatMap[userId];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    userName,
                    style: GoogleFonts.sarabun(fontWeight: FontWeight.w600),
                  ),
                  subtitle: existingChat != null
                      ? Text('แชทที่มีอยู่',
                          style: GoogleFonts.sarabun(color: Colors.grey))
                      : Text('เริ่มแชทใหม่',
                          style: GoogleFonts.sarabun(color: Colors.grey)),
                  onTap: () async {
                    if (existingChat != null) {
                      context.push(
                        '/chat_detail/${existingChat.id}/${widget.currentUserId}/$userId',
                        extra: {
                          'userName': userName,
                          'avatarUrl': avatarUrl,
                        },
                      );
                    } else {
                      final newChatDoc =
                          FirebaseFirestore.instance.collection('chats').doc();
                      await newChatDoc.set({
                        'users': [widget.currentUserId, userId],
                        'createdAt': FieldValue.serverTimestamp(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      context.push(
                        '/chat_detail/${newChatDoc.id}/${widget.currentUserId}/$userId',
                        extra: {
                          'userName': userName,
                          'avatarUrl': avatarUrl,
                        },
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

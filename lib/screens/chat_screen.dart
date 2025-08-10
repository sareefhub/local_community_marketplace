import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:local_community_marketplace/components/navigation.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // วันนี้
      return DateFormat('HH.mm').format(dateTime);
    } else if (messageDate == yesterday) {
      // เมื่อวาน
      return DateFormat('d MMM', 'th').format(dateTime); // เช่น 6 ส.ค.
    } else if (dateTime.year < now.year) {
      // ปีก่อนหน้า
      return DateFormat('d MMM yyyy', 'th')
          .format(dateTime); // เช่น 6 ส.ค. 2023
    } else {
      // ภายในปีนี้แต่ไม่ใช่เมื่อวาน/วันนี้
      return DateFormat('d MMM', 'th').format(dateTime); // เช่น 6 ส.ค.
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'ยังไม่มีข้อความ',
                style: GoogleFonts.sarabun(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final data = chatDocs[index].data() as Map<String, dynamic>;
              final userName = data['userName'] ?? 'ไม่ทราบชื่อ';
              final lastMessage = data['lastMessage'] ?? '';
              final avatarUrl = data['avatarUrl'] as String?;
              final timestamp = data['timestamp'] as Timestamp?;
              final timeLabel = formatTimestamp(timestamp);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
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
                                    fontSize: 16,
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
                          const SizedBox(height: 4),
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
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

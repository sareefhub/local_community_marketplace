import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String? avatarUrl;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': 'You', // TODO: ใช้ชื่อผู้ใช้จริง
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    _scrollToBottom();
  }

  String formatDateHeader(DateTime date) {
    return DateFormat('d MMM yyyy', 'th').format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC9E1E6),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/angle-small-left.png',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.userName,
              style: GoogleFonts.sarabun(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF062252)),
        titleTextStyle: GoogleFonts.sarabun(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF062252),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'ยังไม่มีข้อความ',
                      style: GoogleFonts.sarabun(
                          fontSize: 16, color: const Color(0xFF062252)),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                // ฟังก์ชันช่วยเช็ควันที่ต่างกันเพื่อแสดง header วันที่
                DateTime? lastDate;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData =
                        messages[index].data() as Map<String, dynamic>;
                    final text = msgData['text'] ?? '';
                    final senderName = msgData['senderName'] ?? '';
                    final timestamp = msgData['timestamp'] as Timestamp?;
                    final dateTime = timestamp?.toDate();
                    final isMe = senderName == 'You';

                    Widget messageBubble() {
                      return Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFC9E1E6) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 18),
                          ),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.sarabun(
                            fontSize: 16,
                            color: const Color(0xFF062252),
                          ),
                        ),
                      );
                    }

                    Widget timeLabel() {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, right: 4),
                        child: Text(
                          dateTime != null ? formatTime(dateTime) : '',
                          style: GoogleFonts.sarabun(
                            fontSize: 12,
                            color: const Color(0xB3062252),
                          ),
                        ),
                      );
                    }

                    // แสดงวันที่แยกกลางเมื่อวันที่เปลี่ยน
                    Widget dateHeader() {
                      if (dateTime == null) return const SizedBox.shrink();
                      if (lastDate == null ||
                          lastDate!.day != dateTime.day ||
                          lastDate!.month != dateTime.month ||
                          lastDate!.year != dateTime.year) {
                        lastDate = dateTime;
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9E1E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              formatDateHeader(dateTime),
                              style: GoogleFonts.sarabun(
                                  fontSize: 12, color: const Color(0xFF062252)),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        // แสดง header วันที่เมื่อวันเปลี่ยน
                        if (index == 0) dateHeader() else Container(),
                        if (index > 0) dateHeader(),

                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey[400],
                                ),
                                const SizedBox(width: 8),
                              ],
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  messageBubble(),
                                  timeLabel(),
                                ],
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey[400],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9E1E6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'พิมพ์ข้อความ.....',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    child: IconButton(
                      icon: Image.asset(
                        'assets/icons/send.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

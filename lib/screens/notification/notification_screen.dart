import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:local_community_marketplace/components/navigation.dart';
import 'package:local_community_marketplace/screens/product_details_screen.dart';
import 'package:local_community_marketplace/repositories/notification_repository.dart';
import 'package:local_community_marketplace/repositories/product_repository.dart';
import 'package:local_community_marketplace/utils/date_utils.dart';
import 'package:local_community_marketplace/utils/user_session.dart';

final notifStreamByUidProvider = StreamProvider.autoDispose
    .family<QuerySnapshot<Map<String, dynamic>>, String>((ref, uid) {
  return NotificationRepository().stream(uid);
});

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = UserSession.userId ?? '';

    if (uid.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Text('กรุณาเข้าสู่ระบบเพื่อดูการแจ้งเตือน', style: GoogleFonts.sarabun()),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      );
    }

    final notifAsync = ref.watch(notifStreamByUidProvider(uid));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e.toString(), style: GoogleFonts.sarabun())),
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return Center(
              child: Text('ยังไม่มีการแจ้งเตือน', style: GoogleFonts.sarabun()),
            );
          }

          final docs = snapshot.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final title = (data['title'] ?? '') as String;
              final body = (data['body'] ?? '') as String;
              final ts = data['createdAt'];
              final imageUrl = data['imageUrl'] as String?;
              final productId = data['productId'] as String?;
              final createdAt = ts is Timestamp ? ts.toDate() : DateTime.now();

              return _NotificationCard(
                title: title,
                subtitle: body,
                timeText: AppDateUtils.formatDateTime(createdAt),
                imageUrl: imageUrl,
                onTap: () async {
                  final pid = (productId ?? '').trim();
                  if (pid.isEmpty) return;

                  final product = await ProductRepository().getById(pid);
                  if (!mounted) return;
                  if (product == null) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE0F3F7),
      centerTitle: true,
      elevation: 0,
      title: Text(
        'แจ้งเตือน',
        style: GoogleFonts.sarabun(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.notifications_outlined, color: Colors.black),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.timeText,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String timeText;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE6E6E6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagePlaceholder(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: _Texts(
                  title: title,
                  subtitle: subtitle,
                  timeText: timeText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.imageUrl});
  final String? imageUrl;

  bool _isNetwork(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(8);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (_isNetwork(imageUrl)) {
        return ClipRRect(
          borderRadius: border,
          child: Image.network(
            imageUrl!,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackBox(),
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: border,
          child: Image.asset(
            imageUrl!,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return _fallbackBox();
  }

  Widget _fallbackBox() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.black54),
    );
  }
}

class _Texts extends StatelessWidget {
  const _Texts({
    required this.title,
    required this.subtitle,
    required this.timeText,
  });

  final String title;
  final String subtitle;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.sarabun(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.sarabun(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          timeText,
          style: GoogleFonts.sarabun(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

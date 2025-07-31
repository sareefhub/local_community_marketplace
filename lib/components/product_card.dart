// lib/components/product_card.dart

import 'package:flutter/material.dart';
import 'package:local_community_marketplace/screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // ดึง path รูปจาก product
    final image = product['image']?.toString() ?? '';

    // แปลง rating ให้เป็น int เพื่อป้องกัน error
    int rating = 0;
    final ratingRaw = product['rating'];
    if (ratingRaw is int) {
      rating = ratingRaw;
    } else if (ratingRaw is double) {
      rating = ratingRaw.floor();
    }

    // ฟังก์ชันสร้าง Widget รูปภาพ
    Widget buildImage() {
      if (image.isEmpty) {
        // กรณีไม่มีรูป ให้แสดง placeholder
        return Image.asset(
          'assets/images/placeholder.png',
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }

      if (image.startsWith('http')) {
        // กรณีถ้าเป็น URL (ถ้ามีใช้จริง)
        return Image.network(
          image,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/placeholder.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          },
        );
      }

      // กรณีปกติโหลดจาก assets
      return Image.asset(
        image,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ถ้าโหลด asset ผิดพลาด แสดง placeholder แทน
          return Image.asset(
            'assets/images/placeholder.png',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: buildImage(),
                ),
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.favorite_border),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product['category']?.toString() ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              product['name']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              product['location']?.toString() ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.orange,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              product['price']?.toString() ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

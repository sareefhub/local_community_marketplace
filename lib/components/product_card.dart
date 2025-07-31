// lib/components/product_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_marketplace/screens/product_details_screen.dart';
import 'package:local_community_marketplace/providers/favorite_provider.dart';

class ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);
    final isFav = favorites.any((item) => item['id'] == product['id']);

    final image = product['image']?.toString() ?? '';

    int rating = 0;
    final ratingRaw = product['rating'];
    if (ratingRaw is int) {
      rating = ratingRaw;
    } else if (ratingRaw is double) {
      rating = ratingRaw.floor();
    }

    Widget buildImage() {
      if (image.isEmpty) {
        return Image.asset('assets/images/placeholder.png',
            height: 150, width: double.infinity, fit: BoxFit.cover);
      }

      if (image.startsWith('http')) {
        return Image.network(
          image,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/placeholder.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover),
        );
      }

      return Image.asset(
        image,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/placeholder.png',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product)),
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
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      ref
                          .read(favoriteProvider.notifier)
                          .toggleFavorite(product);
                    },
                  ),
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

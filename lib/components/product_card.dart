import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_marketplace/screens/product_details_screen.dart';
import 'package:local_community_marketplace/providers/favorite_provider.dart';

class ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
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

        // กำหนดขนาดตามความกว้างของ container
        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth * 0.9;

        // ปรับขนาดฟอนต์และไอคอนให้เหมาะสม (มีขอบเขต min-max)
        double clampFontSize(double size, double min, double max) =>
            size.clamp(min, max);

        final categoryFontSize = clampFontSize(cardWidth * 0.04, 10, 14);
        final nameFontSize = clampFontSize(cardWidth * 0.05, 13, 18);
        final locationFontSize = clampFontSize(cardWidth * 0.035, 10, 14);
        final starSize = clampFontSize(cardWidth * 0.045, 12, 18);
        final priceFontSize = clampFontSize(cardWidth * 0.055, 16, 20);
        final favoriteIconSize = clampFontSize(cardWidth * 0.07, 20, 30);

        Widget buildImage() {
          if (image.isEmpty) {
            return Image.asset(
              'assets/images/placeholder.png',
              height: imageHeight,
              width: cardWidth,
              fit: BoxFit.cover,
            );
          }

          if (image.startsWith('http')) {
            return Image.network(
              image,
              height: imageHeight,
              width: cardWidth,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/placeholder.png',
                height: imageHeight,
                width: cardWidth,
                fit: BoxFit.cover,
              ),
            );
          }

          return Image.asset(
            image,
            height: imageHeight,
            width: cardWidth,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/placeholder.png',
              height: imageHeight,
              width: cardWidth,
              fit: BoxFit.cover,
            ),
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
            height: 200,
            padding:
                const EdgeInsets.only(top: 2, left: 8, right: 8, bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      child: Container(
                        width: favoriteIconSize + 8,
                        height: favoriteIconSize + 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.all(4),
                          iconSize: favoriteIconSize,
                          icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white),
                          onPressed: () {
                            ref
                                .read(favoriteProvider.notifier)
                                .toggleFavorite(product);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product['category']?.toString() ?? '',
                  style: GoogleFonts.sarabun(
                      fontSize: categoryFontSize, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  product['name']?.toString() ?? '',
                  style: GoogleFonts.sarabun(
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize,
                      color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  product['location']?.toString() ?? '',
                  style: GoogleFonts.sarabun(
                      fontSize: locationFontSize, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: starSize,
                      color: Colors.orange,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']?.toString() ?? '',
                  style: GoogleFonts.sarabun(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: priceFontSize,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

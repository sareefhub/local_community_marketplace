// lib/components/productcard
import 'package:flutter/material.dart';
import 'package:local_community_marketplace/screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset(
                    product['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
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
              product['category'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              product['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              product['location'],
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < product['rating'] ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.orange,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              product['price'],
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

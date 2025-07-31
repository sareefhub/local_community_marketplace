// lib/screens/category_productlist_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/components/product_card.dart';

class CategoryProductListScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductListScreen({super.key, required this.categoryName});

  Future<List<Map<String, dynamic>>> fetchProductsByCategory() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());

      // กำหนดค่า default เผื่อบางฟิลด์ขาด
      return {
        'name': data['name'] ?? 'ไม่มีชื่อ',
        'category': data['category'] ?? '',
        'location': data['location'] ?? '',
        'price': data['price'] ?? '',
        'rating': (data['rating'] is num) ? data['rating'] : 0,
        'image': data['image'] ?? 'assets/images/placeholder.png',
        'description': data['description'] ?? '',
        'sellerName': data['sellerName'] ?? '',
        'sellerImage':
            data['sellerImage'] ?? 'assets/images/placeholder_seller.png',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        categoryName,
                        style: GoogleFonts.sarabun(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Search + Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ค้นหา',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_alt_outlined),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sort),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Product Grid (from Firebase)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchProductsByCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  }

                  final productList = snapshot.data ?? [];

                  if (productList.isEmpty) {
                    return const Center(
                      child: Text('ไม่มีสินค้าสำหรับหมวดนี้'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.60,
                      children: List.generate(productList.length, (index) {
                        final product = productList[index];
                        return ProductCard(product: product);
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

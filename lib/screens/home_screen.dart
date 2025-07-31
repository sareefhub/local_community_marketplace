// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:local_community_marketplace/components/product_card.dart';
import 'package:local_community_marketplace/components/category_list.dart';
import 'package:local_community_marketplace/dummy_products.dart';
import 'package:local_community_marketplace/dummy_categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final categoryList = dummyCategories;
    final List<Map<String, dynamic>> bestSaleProducts =
        dummyProducts.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 20),
                      const SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

            const SizedBox(height: 16),

            // Categories Component
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CategoryList(categories: categoryList),

                    const SizedBox(height: 16),

                    // Product recommend Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.63,
                        children:
                            List.generate(bestSaleProducts.length, (index) {
                          final product = bestSaleProducts[index];
                          return ProductCard(product: product);
                        }),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Product Cards Example
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(2, (index) {
                          return Expanded(
                            child: Container(
                              margin:
                                  EdgeInsets.only(right: index == 0 ? 8 : 0),
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
                                      Container(
                                        height: 80,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image),
                                      ),
                                      const Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Icon(Icons.favorite_border),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'หมวดหมู่',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const Text(
                                    'ชื่อสินค้า',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'สถานที่',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Icon(Icons.star, size: 14),
                                      Icon(Icons.star, size: 14),
                                      Icon(Icons.star, size: 14),
                                      Icon(Icons.star_border, size: 14),
                                      Icon(Icons.star_border, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'ราคา',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

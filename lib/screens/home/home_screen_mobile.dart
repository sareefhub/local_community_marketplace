// lib/screens/home_screen_mobile.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:local_community_marketplace/components/product_card.dart';
import 'package:local_community_marketplace/components/category_list.dart';
import 'package:local_community_marketplace/screens/search_screen.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;

      data['category'] = data['category'] ?? 'ไม่มีหมวดหมู่';
      data['name'] = data['name'] ?? 'ไม่มีชื่อสินค้า';
      data['location'] = data['location'] ?? 'ไม่มีสถานที่';
      data['price'] = data['price'] ?? 'ราคาไม่ระบุ';
      data['rating'] = (data['rating'] is num) ? data['rating'] : 0;
      data['image'] = data['image'] ?? 'assets/images/placeholder.png';
      data['description'] = data['description'] ?? '';
      data['sellerName'] = data['sellerName'] ?? '';
      data['sellerImage'] =
          data['sellerImage'] ?? 'assets/images/placeholder_seller.png';

      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs
        .map((doc) => Map<String, dynamic>.from(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 20),
                  const SizedBox(width: 6),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  );
                },
                child: AbsorbPointer(
                  // ป้องกัน TextField ถูกแก้ไข
                  child: TextField(
                    style: GoogleFonts.sarabun(
                      fontSize: 14,
                    ),
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
              ),
            ),

            const SizedBox(height: 16),

            // Load data from Firestore
            Expanded(
              child: FutureBuilder(
                future: Future.wait([
                  fetchCategories(),
                  fetchProducts(),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  }

                  final categoryList =
                      snapshot.data![0] as List<Map<String, dynamic>>;
                  final productList =
                      snapshot.data![1] as List<Map<String, dynamic>>;
                  final bestSaleProducts = productList.take(4).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        CategoryList(categories: categoryList),
                        const SizedBox(height: 16),

                        // Product Grid
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
                              return ProductCard(
                                  product: bestSaleProducts[index]);
                            }),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

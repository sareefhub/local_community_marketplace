import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_community_marketplace/components/navigation.dart';
import 'package:local_community_marketplace/components/product_card.dart';
import 'package:local_community_marketplace/components/category_list.dart';

class HomeScreenTablet extends StatefulWidget {
  const HomeScreenTablet({super.key});

  @override
  State<HomeScreenTablet> createState() => _HomeScreenTabletState();
}

class _HomeScreenTabletState extends State<HomeScreenTablet> {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();

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
      data['sellerImage'] = data['sellerImage'] ?? 'assets/images/placeholder_seller.png';

      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => Map<String, dynamic>.from(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // กำหนดจำนวนคอลัมน์ตามขนาดหน้าจอ (tablet responsive)
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 5;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header + Search bar
              Row(
                children: [
                  Image.asset('assets/logo.png', height: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Local Community Marketplace',
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหา',
                  prefixIcon: const Icon(Icons.search, size: 28),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),

              // Expanded FutureBuilder
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
                      return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                    }

                    final categoryList = snapshot.data![0] as List<Map<String, dynamic>>;
                    final productList = snapshot.data![1] as List<Map<String, dynamic>>;
                    final bestSaleProducts = productList.take(6).toList();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategoryList(categories: categoryList),
                          const SizedBox(height: 24),
                          GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bestSaleProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: bestSaleProducts[index]);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

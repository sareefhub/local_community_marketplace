// lib/screens/product_details_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_community_marketplace/components/product_card.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Map<String, dynamic> product;
  List<Map<String, dynamic>> similarProducts = [];

  @override
  void initState() {
    super.initState();
    product = widget.product;
    fetchSimilarProducts();
  }

  Future<void> fetchSimilarProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final allProducts = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());

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

      // กรองสินค้าที่อยู่ในหมวดเดียวกัน และไม่ใช่สินค้าที่แสดงอยู่
      similarProducts = allProducts
          .where((p) =>
              p['category'] == product['category'] &&
              p['name'] != product['name'])
          .take(4)
          .toList();

      setState(() {});
    } catch (e) {
      print('เกิดข้อผิดพลาดในการโหลดสินค้าใกล้เคียง: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productDescription =
        product['description']?.toString().isNotEmpty ?? false
            ? product['description']
            : 'ไม่มีรายละเอียดสินค้า';

    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Chat"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call_outlined),
                label: const Text("Call"),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image Header
              Stack(
                children: [
                  Image.asset(
                    product['image'],
                    height: 290,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Positioned(
                    top: 16,
                    right: 8,
                    child: Icon(Icons.favorite_border),
                  ),
                ],
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['price'],
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    Text(product['name'], style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(200, 209, 233, 242),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(product['category']),
                    ),
                    const SizedBox(height: 16),
                    Text(productDescription),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Read more"),
                    ),
                    const SizedBox(height: 18),

                    // Seller Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(product['sellerImage']),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['sellerName'] ?? 'ไม่ทราบชื่อผู้ขาย',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.chat),
                                    label: const Text("Chat"),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.call),
                                    label: const Text("Call"),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Similar Products
                    if (similarProducts.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'สินค้าใกล้เคียง',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.55,
                            ),
                            itemCount: similarProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: similarProducts[index],
                              );
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

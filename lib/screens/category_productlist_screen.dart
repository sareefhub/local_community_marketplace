// lib/screens/category_productlist
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/dummy_products.dart';
import 'package:local_community_marketplace/components/product_card.dart';

class CategoryProductListScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Filter only products that match the category.
    final List<Map<String, dynamic>> productList = dummyProducts
        .where((product) => product['category'] == categoryName)
        .toList();

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
                  const SizedBox(width: 48), // ให้ชื่ออยู่กลางโดยประมาณ
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

            // Product Grid
            Expanded(
              child: productList.isEmpty
                  ? const Center(
                      child: Text(
                        'ไม่มีสินค้าสำหรับหมวดนี้',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Padding(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

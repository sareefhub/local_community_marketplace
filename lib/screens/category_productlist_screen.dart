// lib/screens/category_productlist_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/components/product_card.dart';
import 'package:local_community_marketplace/providers/favorite_provider.dart';
import 'package:local_community_marketplace/components/search_filter_sort_bar.dart';
import 'package:local_community_marketplace/screens/filter_screen.dart';

class CategoryProductListScreen extends ConsumerStatefulWidget {
  final String categoryName;

  const CategoryProductListScreen({super.key, required this.categoryName});

  @override
  ConsumerState<CategoryProductListScreen> createState() =>
      _CategoryProductListScreenState();
}

class _CategoryProductListScreenState
    extends ConsumerState<CategoryProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterPressed() async {
    final filters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          initialCategory: widget.categoryName, // ส่งค่า categoryName ที่เปิดมา
        ),
      ),
    );

    if (filters != null) {
      setState(() {
        _filters = filters;
      });
    }
  }

  void _onSortPressed() {
    // TODO: แสดงตัวเลือกการเรียงลำดับ
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เรียงลำดับ'),
        content: const Text('ใส่ฟังก์ชันเรียงลำดับที่นี่'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด')),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // TODO: ทำการ filter product list ตาม _searchQuery
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync =
        ref.watch(productListProvider(widget.categoryName));

    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar แบบกำหนดเอง
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
                        widget.categoryName,
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

            // นำ SearchFilterSortBar มาใช้
            SearchFilterSortBar(
              searchController: _searchController,
              onFilterPressed: _onFilterPressed,
              onSortPressed: _onSortPressed,
              onSearchChanged: _onSearchChanged,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: productListAsync.when(
                data: (productList) {
                  final filteredList = productList.where((product) {
                    final name =
                        product['name']?.toString().toLowerCase() ?? '';
                    final matchesSearch =
                        name.contains(_searchQuery.toLowerCase());

                    final category = _filters['category']?.toString() ?? '';
                    final province = _filters['province']?.toString() ?? '';

                    String priceStr = product['price']?.toString() ?? '0';
                    priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
                    final price = double.tryParse(priceStr) ?? 0;

                    final minPrice =
                        double.tryParse(_filters['minPrice'] ?? '') ?? 0;
                    final maxPrice =
                        double.tryParse(_filters['maxPrice'] ?? '') ??
                            double.infinity;

                    final matchesCategory =
                        category.isEmpty || product['category'] == category;
                    final matchesProvince =
                        province.isEmpty || product['location'] == province;
                    final matchesPrice = price >= minPrice && price <= maxPrice;

                    return matchesSearch &&
                        matchesCategory &&
                        matchesProvince &&
                        matchesPrice;
                  }).toList();
                  if (filteredList.isEmpty) {
                    return const Center(
                        child: Text('ไม่มีสินค้าสำหรับหมวดนี้'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.60,
                      children: List.generate(filteredList.length, (index) {
                        final product = filteredList[index];
                        return ProductCard(product: product);
                      }),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('เกิดข้อผิดพลาด: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// search_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_community_marketplace/components/product_card.dart';
import 'package:local_community_marketplace/components/search_filter_sort_bar.dart';
import 'package:local_community_marketplace/screens/filter_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      data['price'] = data['price'] ?? '0';
      return data;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onFilterPressed() async {
    final filters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          initialCategory: _filters['category'], // หรือส่ง null ได้ถ้าไม่มีค่า
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
    // สำหรับฟังก์ชันเรียงลำดับ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0, // ชิดซ้าย
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              // ปุ่มย้อนกลับ
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  'assets/icons/angle-small-left.png',
                  width: 24,
                  height: 24,
                ),
              ),

              // ช่องค้นหา (Expanded ให้กินพื้นที่ที่เหลือ)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาสินค้า',
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

              // ปุ่ม Filter
              GestureDetector(
                onTap: _onFilterPressed,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_alt_outlined),
                ),
              ),
              const SizedBox(width: 4),

              // ปุ่ม Sort
              GestureDetector(
                onTap: _onSortPressed,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sort),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  }
                  List<Map<String, dynamic>> products = snapshot.data ?? [];

                  // Filter ตาม searchQuery และ filters
                  final filtered = products.where((product) {
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

                  if (filtered.isEmpty) {
                    return const Center(child: Text('ไม่พบสินค้าตามที่ค้นหา'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.60,
                      children: List.generate(filtered.length, (index) {
                        return ProductCard(product: filtered[index]);
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_community_marketplace/components/filter_components.dart';

class FilterScreen extends StatefulWidget {
  final String? initialCategory;

  const FilterScreen({super.key, this.initialCategory});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedCategory;
  String? selectedProvince;
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  List<String> categories = [];
  List<String> provinces = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final fetchedCategories = categorySnapshot.docs
          .map((doc) => doc.data()['label']?.toString() ?? '')
          .where((label) => label.isNotEmpty)
          .toList();

      final productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final fetchedProvinces = productSnapshot.docs
          .map((doc) => doc.data()['location']?.toString() ?? '')
          .where((location) => location.isNotEmpty)
          .toSet()
          .toList();

      setState(() {
        categories = fetchedCategories;
        provinces = fetchedProvinces;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading filter data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedProvince = null;
      minPriceController.clear();
      maxPriceController.clear();
    });
  }

  void _applyFilters() {
    final filters = {
      'category': selectedCategory,
      'province': selectedProvince,
      'minPrice': minPriceController.text,
      'maxPrice': maxPriceController.text,
    };

    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        centerTitle: true,
        title: const Text(
          'กรองข้อมูล',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/angle-small-left.png',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomDropdown(
              value: selectedCategory,
              items: categories,
              label: 'หมวดหมู่',
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            PriceRangeInput(
              minPriceController: minPriceController,
              maxPriceController: maxPriceController,
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              value: selectedProvince,
              items: provinces,
              label: 'จังหวัด',
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                });
              },
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'ล้าง',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'ตกลง',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

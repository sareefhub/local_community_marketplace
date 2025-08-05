// filter_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    selectedCategory = widget.initialCategory; // กำหนดค่าเริ่มต้น
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      // ดึงหมวดหมู่จาก collection 'categories'
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final fetchedCategories = categorySnapshot.docs
          .map((doc) => doc.data()['label']?.toString() ?? '')
          .where((label) => label.isNotEmpty)
          .toList();

      // ดึงจังหวัดจาก collection 'products' และกรองเอา unique location เท่านั้น
      final productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final fetchedProvinces = productSnapshot.docs
          .map((doc) => doc.data()['location']?.toString() ?? '')
          .where((location) => location.isNotEmpty)
          .toSet() // กรองซ้ำ
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
      appBar: AppBar(title: const Text('กรองข้อมูล')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่',
                border: OutlineInputBorder(),
              ),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: minPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ราคาต่ำสุด',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: maxPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ราคาสูงสุด',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedProvince,
              decoration: const InputDecoration(
                labelText: 'จังหวัด',
                border: OutlineInputBorder(),
              ),
              items: provinces.map((prov) {
                return DropdownMenuItem(value: prov, child: Text(prov));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                });
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('ล้าง'),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('ตกลง'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

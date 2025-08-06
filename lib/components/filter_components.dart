// filter_components.dart
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final void Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Colors.black),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownStyleData: DropdownStyleData(
        maxHeight: 48.0 * 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class PriceRangeInput extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;

  const PriceRangeInput({
    super.key,
    required this.minPriceController,
    required this.maxPriceController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'ราคาต่ำสุด',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '-',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'ราคาสูงสุด',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

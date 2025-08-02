import 'package:flutter/material.dart';

Future<String?> showPostProvinceDialog(BuildContext context) async {
  final provinces = ['Bangkok', 'Chiang Mai', 'Phuket'];
  final selected = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Select Post Province'),
      children: provinces
          .map((e) => SimpleDialogOption(
                child: Text(e),
                onPressed: () => Navigator.pop(context, e),
              ))
          .toList(),
    ),
  );
  return selected;
}

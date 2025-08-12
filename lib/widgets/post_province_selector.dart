import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String?> showPostProvinceDialog(BuildContext context) async {
  final searchCtrl = TextEditingController();

  Future<List<String>> _loadProvinces() async {
    final txt = await rootBundle.loadString('assets/data/th_provinces.json');
    final List data = json.decode(txt);
    return data.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<String?> _currentProvince() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isEmpty) return null;

    final p = placemarks.first;
    final candidates = <String>[
      p.administrativeArea ?? '',
      p.subAdministrativeArea ?? '',
      p.locality ?? '',
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return candidates.isEmpty ? null : candidates.first;
  }

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: SafeArea(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        child: Text('เลือกจังหวัด', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text('ใช้ตำแหน่งปัจจุบัน'),
                      onPressed: () async {
                        try {
                          final prov = await _currentProvince();
                          if (prov != null && prov.isNotEmpty) {
                            Navigator.pop(ctx, prov);
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('ไม่สามารถระบุจังหวัดได้')));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('ตำแหน่งไม่พร้อม: $e')));
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'พิมพ์ชื่อจังหวัด',
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: _loadProvinces(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text('โหลดจังหวัดไม่สำเร็จ: ${snap.error}'));
                      }

                      final all = snap.data ?? const <String>[];

                      return StatefulBuilder(
                        builder: (context, setStateSB) {
                          searchCtrl.addListener(() => setStateSB(() {}));

                          final q = searchCtrl.text.trim().toLowerCase();
                          final filtered = all.where((name) => q.isEmpty || name.toLowerCase().contains(q)).toList();

                          if (filtered.isEmpty) {
                            return const Center(child: Text('ไม่พบจังหวัด'));
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final nameTh = filtered[i];
                              return ListTile(
                                title: Text(nameTh),
                                onTap: () => Navigator.pop(ctx, nameTh),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

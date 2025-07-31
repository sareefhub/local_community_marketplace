// lib/screens/favorite_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_marketplace/providers/favorite_provider.dart';
import 'package:local_community_marketplace/components/product_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0F3F7),
        centerTitle: true,
        title: Text(
          'รายการโปรด',
          style: GoogleFonts.sarabun(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      backgroundColor: Colors.white,
      body: favorites.isEmpty
          ? const Center(child: Text('ยังไม่มีรายการโปรด'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.63,
              ),
              itemCount: favorites.length,
              itemBuilder: (_, index) {
                return ProductCard(product: favorites[index]);
              },
            ),
    );
  }
}

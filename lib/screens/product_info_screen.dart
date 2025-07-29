import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_community_marketplace/dummy_products.dart';

class ProductInfoPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductInfoPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bestSaleProducts = dummyProducts.take(4).toList(); 
  
  // Find product info (description) by checking the product that was sent first.
    String productDescription = '';
    if (product.containsKey('description') && (product['description']?.toString().isNotEmpty ?? false)) {
      productDescription = product['description'];
    } else if (product.containsKey('name')) {
      final matchedProduct = bestSaleProducts.firstWhere(
        (p) => p['name'].toString().toLowerCase().trim() ==
            product['name'].toString().toLowerCase().trim(),
        orElse: () => {},
      );
      if (matchedProduct.isNotEmpty && matchedProduct.containsKey('description')) {
        productDescription = matchedProduct['description'];
      } else {
        productDescription = 'ไม่มีรายละเอียดสินค้า';
      }
    } else {
      productDescription = 'ไม่มีรายละเอียดสินค้า';
    }

    // If the product does not have a seller, add it from bestSaleProducts.
    if (!product.containsKey('sellerName') || !product.containsKey('sellerImage')) {
      final matchedProduct = bestSaleProducts.firstWhere(
        (p) => p['name'].toString().toLowerCase().trim() ==
            product['name'].toString().toLowerCase().trim(),
        orElse: () => {},
      );
      if (matchedProduct.isNotEmpty) {
        product['sellerName'] ??= matchedProduct['sellerName'];
        product['sellerImage'] ??= matchedProduct['sellerImage'];
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.chat_bubble_outline),
                label: Text("Chat"),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.call_outlined),
                label: Text("Call"),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header & image
              Stack(
                children: [
                  Image.asset(
                    product['image'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 8,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 8,
                    child: Icon(Icons.favorite_border),
                  ),
                ],
              ),

              // Product info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['price'],
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    Text(product['name'], style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(product['category']),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 4),
                    Text(productDescription),
                    TextButton(
                      onPressed: () {},
                      child: Text("Read more"),
                    ),
                    SizedBox(height: 16),

                    // Seller
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: product.containsKey('sellerImage')
                              ? AssetImage(product['sellerImage'])
                              : null,
                          child: product.containsKey('sellerImage') ? null : Icon(Icons.person),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['sellerName'] ?? 'ไม่ทราบชื่อผู้ขาย',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.chat),
                                  label: Text("Chat"),
                                ),
                                SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.call),
                                  label: Text("Call"),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Similar Products Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'สินค้าที่คล้ายกัน',
                          style: GoogleFonts.sarabun(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.55,
                        children: List.generate(bestSaleProducts.length, (index) {
                          final p = bestSaleProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductInfoPage(product: p),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          p['image'],
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Icon(Icons.favorite_border),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p['category'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    p['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    p['location'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < p['rating']
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 14,
                                        color: Colors.orange,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p['price'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 80),
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
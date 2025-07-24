import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categoryList = [
      {'label': 'Fresh Food', 'image': 'assets/category-image/fresh_food.jpg'},
      {'label': 'Household', 'image': 'assets/category-image/household.jpg'},
      {'label': 'Clothing', 'image': 'assets/category-image/clothing.jpg'},
      {'label': 'Handicrafts', 'image': 'assets/category-image/handicrafts.jpg'},
      {'label': 'Beauty & Health', 'image': 'assets/category-image/beauty.jpg'},
      {'label': 'Ready to Eat Food', 'image': 'assets/category-image/ready_to_eat.jpg'},
      {'label': 'Home & Garden', 'image': 'assets/category-image/home_garden.jpg'},
      {'label': 'Mom & Baby', 'image': 'assets/category-image/mom_baby.jpg'},
      {'label': 'Electronics', 'image': 'assets/category-image/electronics.jpg'},
      {'label': 'Tools', 'image': 'assets/category-image/tools.jpg'},
    ];

    final List<Map<String, dynamic>> bestSaleProducts = [
      {
        'category': 'Fresh Food',
        'name': 'Organic Mango',
        'location': 'Chiang Mai',
        'price': '฿120',
        'rating': 4,
        'image': 'assets/products-image/mango.jpg',
      },
      {
        'category': 'Handicrafts',
        'name': 'Bamboo Basket',
        'location': 'Lampang',
        'price': '฿250',
        'rating': 5,
        'image': 'assets/products-image/basket.jpg',
      },
      {
        'category': 'Mom & Baby',
        'name': 'Baby milk bottle',
        'location': 'Songkhla',
        'price': '฿320',
        'rating': 3.5,
        'image': 'assets/products-image/milk.jpg',
      },
      {
        'category': 'Tools',
        'name': 'Drill',
        'location': 'Bangkok',
        'price': '฿1,450',
        'rating': 4,
        'image': 'assets/products-image/drill.jpg',
      },
    ];


    return Scaffold(
      backgroundColor: const Color(0xFFE0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 20),
                      const SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
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

            const SizedBox(height: 16),

            // Categories
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Category Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: GoogleFonts.sarabun(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Horizontal Category Scroll
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 100,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(categoryList.length, (index) {
                              final category = categoryList[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          category['image']!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        category['label']!,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                   // Best Sale Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recommend for you',
                        style: GoogleFonts.sarabun(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Grid of Products
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), 
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.65, 
                      children: List.generate(bestSaleProducts.length, (index) {
                        final product = bestSaleProducts[index];
                        return Container(
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
                                      product['image'],
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
                                product['category'],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                product['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                product['location'],
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < product['rating']
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 14,
                                    color: Colors.orange,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['price'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                    const SizedBox(height: 8),

                    // Product Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(2, (index) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
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
                                      Container(
                                        height: 80,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image),
                                      ),
                                      const Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Icon(Icons.favorite_border),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Category',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const Text(
                                    'Product\'s name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'Location',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Icon(Icons.star, size: 14),
                                      Icon(Icons.star, size: 14),
                                      Icon(Icons.star, size: 14),
                                      Icon(Icons.star_border, size: 14),
                                      Icon(Icons.star_border, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Price',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 80), // for spacing above nav bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

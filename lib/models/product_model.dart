class ProductModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String price;
  final String location;
  final double rating;
  final String image;
  final String sellerName;
  final String sellerImage;
  final String phone;
  final String state;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.location,
    required this.rating,
    required this.image,
    required this.sellerName,
    required this.sellerImage,
    required this.phone,
    required this.state,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String docId) {
    return ProductModel(
      id: data['id']?.toString() ?? docId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] is double)
              ? data['rating']
              : 0.0,
      image: data['image'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerImage: data['sellerImage'] ?? '',
      phone: data['phone'] ?? '',
      state: data['state'] ?? 'draft',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'location': location,
      'rating': rating,
      'image': image,
      'sellerName': sellerName,
      'sellerImage': sellerImage,
      'phone': phone,
      'state': state,
    };
  }
}

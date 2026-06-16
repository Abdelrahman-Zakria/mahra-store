import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.imagePath,
    required super.category,
    super.rating,
    super.reviewCount,
    super.isFeatured,
    super.isNew,
    super.stockQuantity,
    super.tags,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      imagePath: (json['image_url'] ?? json['image_path']) as String? ?? 'assets/products/product1.jpeg',
      category: (json['category_id'] ?? json['category']) as String? ?? 'all',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      stockQuantity: (json['stock_quantity'] ?? json['stock']) as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.isEmpty ? null : id,
    'name': name,
    'description': description,
    'price': price,
    'original_price': originalPrice,
    'image_url': imagePath,
    'category_id': category,
    'rating': rating,
    'review_count': reviewCount,
    'is_featured': isFeatured,
    'is_new': isNew,
    'stock_quantity': stockQuantity,
    'tags': tags,
  };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imagePath,
    String? category,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isNew,
    int? stockQuantity,
    List<String>? tags,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      tags: tags ?? this.tags,
    );
  }
}
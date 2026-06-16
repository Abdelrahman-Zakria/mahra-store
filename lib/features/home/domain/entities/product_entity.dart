import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imagePath;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isNew;
  final int stockQuantity;
  final List<String> tags;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imagePath,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isNew = false,
    this.stockQuantity = 0,
    this.tags = const [],
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercent =>
      hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    originalPrice,
    imagePath,
    category,
    rating,
    reviewCount,
    isFeatured,
    isNew,
    stockQuantity,
    tags,
  ];
}
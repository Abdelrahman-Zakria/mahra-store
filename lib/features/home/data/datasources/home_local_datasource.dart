import 'package:flutter/material.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../models/product_model.dart';

abstract class HomeLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<CategoryEntity>> getCategories();
  Future<List<BannerEntity>> getBanners();
  Future<ProductModel> getProductById(String id);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  // ─── Refactored Mock Products Based on MAHRA Branding ──────────────────────
  static final List<ProductModel> _products = [
    const ProductModel(
      id: 'p1',
      name: 'MAHRA Commuter Backpack',
      description:
      'A premium tech-ready backpack featuring the signature MAHRA orange logo. '
          'Includes a dedicated laptop compartment, external USB charging port, '
          'and a water bottle side pocket. Built for the modern CEO on the move.',
      price: 120.00,
      originalPrice: 150.00,
      imagePath: 'assets/products/product1.jpeg',
      category: 'bags',
      rating: 4.9,
      reviewCount: 320,
      isFeatured: true,
      tags: ['backpack', 'tech', 'travel'],
    ),
    const ProductModel(
      id: 'p2',
      name: 'MAHRA Signature Tech Pack',
      description:
      'The classic MAHRA backpack in a stealth-grey variant. Features ultra-durable '
          'weather-resistant fabric and ergonomic straps. Professional aesthetics '
          'combined with maximum utility for daily commutes.',
      price: 115.00,
      originalPrice: null,
      imagePath: 'assets/products/product2.jpeg',
      category: 'bags',
      rating: 4.8,
      reviewCount: 150,
      isFeatured: true,
      isNew: true,
      tags: ['backpack', 'office', 'minimalist'],
    ),
    const ProductModel(
      id: 'p3',
      name: 'Executive Laptop Sleeve',
      description:
      'Sleek, slim, and sophisticated. This protective sleeve features the MAHRA '
          'monochrome logo and a front zipper pocket for chargers and accessories. '
          'Crafted with shock-absorbent lining to keep your device secure.',
      price: 45.00,
      originalPrice: 55.00,
      imagePath: 'assets/products/product3.jpeg',
      category: 'accessories',
      rating: 4.7,
      reviewCount: 85,
      isFeatured: false,
      tags: ['laptop', 'sleeve', 'protection'],
    ),
    const ProductModel(
      id: 'p4',
      name: 'MAHRA Leather Bi-fold Wallet',
      description:
      'Genuine black leather wallet featuring a precision-engraved silver MAHRA logo. '
          'RFID blocking technology with 6 card slots and a dedicated cash compartment. '
          'A statement piece for the minimalist professional.',
      price: 65.00,
      originalPrice: null,
      imagePath: 'assets/products/product4.jpeg',
      category: 'accessories',
      rating: 4.9,
      reviewCount: 210,
      isFeatured: true,
      isNew: true,
      tags: ['wallet', 'leather', 'luxury'],
    ),
    const ProductModel(
      id: 'p5',
      name: 'Premium CEO Notebook',
      description:
      'Structured black leather notebook with the MAHRA emblem. Features an '
          'elastic closure band, ribbon bookmark, and premium 100gsm cream paper. '
          'Ideal for high-level meetings and strategic brainstorming.',
      price: 35.00,
      originalPrice: null,
      imagePath: 'assets/products/product5.jpeg',
      category: 'stationery',
      rating: 5.0,
      reviewCount: 45,
      isFeatured: false,
      isNew: true,
      tags: ['notebook', 'office', 'writing'],
    ),
  ];

  // ─── Refactored Categories ──────────────────────────────────────────────────
  static final List<CategoryEntity> _categories = [
    const CategoryEntity(
      id: 'all',
      name: 'All',
      icon: Icons.grid_view_rounded,
      color: Color(0xFF1A1A1A),
    ),
    const CategoryEntity(
      id: 'bags',
      name: 'Bags',
      icon: Icons.backpack_rounded,
      color: Color(0xFFE65100), // Matching the orange in the logo
    ),
    const CategoryEntity(
      id: 'accessories',
      name: 'Accessories',
      icon: Icons.watch_rounded,
      color: Color(0xFF1A1A1A),
    ),
    const CategoryEntity(
      id: 'stationery',
      name: 'Stationery',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF1A1A1A),
    ),
  ];

  // ─── Refactored Banners ──────────────────────────────────────────────────────
  static final List<BannerEntity> _banners = [
    const BannerEntity(
      id: 'b1',
      title: 'MAHRA Collection',
      subtitle: 'Premium gear for the modern leader',
      badgeText: 'NEW BRAND',
      backgroundColor: Color(0xFF1A1A1A),
      textColor: Colors.white,
      imagePath: 'assets/coming_soon_banner.jpg',
    ),
  ];

  // ─── Implementation Methods ────────────────────────────────────────────────

  @override
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _products;
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _products.where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (categoryId == 'all') return _products;
    return _products.where((p) => p.category == categoryId).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories;
  }

  @override
  Future<List<BannerEntity>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _banners;
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.firstWhere(
          (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
    );
  }
}
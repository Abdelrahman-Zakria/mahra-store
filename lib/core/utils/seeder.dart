import 'dart:io';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/home/data/models/category_model.dart';
import '../../features/home/domain/entities/category_entity.dart';

class Seeder {
  static Future<void> seed() async {
    final supabase = Supabase.instance.client;
    final localDataSource = HomeLocalDataSourceImpl();

    print('🚀 Starting Seeder...');

    // 0. Ensure app_settings for free_shipping exists
    print('⚙️ Setting up App Settings...');
    await supabase.from('app_settings').upsert({
      'setting_key': 'free_shipping',
      'value': false,
    }, onConflict: 'setting_key');

    // 1. Seed Categories
    print('📦 Seeding Categories...');
    final categories = await localDataSource.getCategories();
    for (var category in categories) {
      if (category.id == 'all') continue; // Skip 'all' category for DB

      await supabase.from('categories').upsert({
        'name': category.name,
        'icon_name': _getIconName(category.icon),
        'color_hex': '#${category.color.value.toRadixString(16).substring(2)}',
      }, onConflict: 'name');
    }

    // Fetch categories back to map IDs
    final remoteCategories = await supabase.from('categories').select();
    final categoryMap = {for (var c in remoteCategories) c['name'] as String: c['id'] as String};

    // 2. Seed Products
    print('🛍️ Seeding Products...');
    final products = await localDataSource.getProducts();
    for (var product in products) {
      final categoryName = _getCategoryName(product.category);
      final categoryId = categoryMap[categoryName];
      
      String imageUrl = product.imagePath;
      
      // Upload to storage if it's an asset
      if (product.imagePath.startsWith('assets/')) {
        try {
          final byteData = await rootBundle.load(product.imagePath);
          final bytes = byteData.buffer.asUint8List();
          final fileName = product.imagePath.split('/').last;
          
          await supabase.storage.from('products').uploadBinary(
            fileName, 
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
          
          imageUrl = supabase.storage.from('products').getPublicUrl(fileName);
        } catch (e) {
          print('Failed to upload ${product.imagePath}: $e');
        }
      }

      await supabase.from('products').upsert({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'original_price': product.originalPrice,
        'image_url': imageUrl,
        'category_id': categoryId,
        'stock_quantity': 50, // Default stock
        'is_featured': product.isFeatured,
        'is_new': product.isNew,
        'rating': product.rating,
        'review_count': product.reviewCount,
        'tags': product.tags,
      }, onConflict: 'name');
    }

    // 3. Seed Banners
    print('🚩 Seeding Banners...');
    final banners = await localDataSource.getBanners();
    for (var banner in banners) {
      String? imageUrl = banner.imagePath;

      if (banner.imagePath!.startsWith('assets/')) {
        try {
          final byteData = await rootBundle.load(banner.imagePath!);
          final bytes = byteData.buffer.asUint8List();
          final fileName = banner.imagePath!.split('/').last;

          await supabase.storage.from('banners').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

          imageUrl = supabase.storage.from('banners').getPublicUrl(fileName);
        } catch (e) {
          print('Failed to upload ${banner.imagePath}: $e');
        }
      }

      await supabase.from('banners').upsert({
        'title': banner.title,
        'subtitle': banner.subtitle,
        'badge_text': banner.badgeText,
        'image_url': imageUrl,
        'background_color_hex': '#${banner.backgroundColor.value.toRadixString(16).substring(2)}',
        'text_color_hex': '#${banner.textColor.value.toRadixString(16).substring(2)}',
      }, onConflict: 'title');
    }

    print('✅ Seeding Complete!');
  }

  static String _getIconName(dynamic icon) {
    // Mapping back icon data to names
    if (icon.toString().contains('backpack')) return 'backpack_rounded';
    if (icon.toString().contains('watch')) return 'watch_rounded';
    if (icon.toString().contains('menu_book')) return 'menu_book_rounded';
    return 'grid_view_rounded';
  }

  static String _getCategoryName(String id) {
    switch (id) {
      case 'bags': return 'Bags';
      case 'accessories': return 'Accessories';
      case 'stationery': return 'Stationery';
      default: return 'All';
    }
  }
}

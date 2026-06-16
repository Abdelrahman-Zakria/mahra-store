import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../home/data/models/category_model.dart';
import '../../../home/domain/entities/category_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/data/models/product_model.dart';
import '../models/order_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient supabase;

  AdminRepositoryImpl(this.supabase);

  @override
  Future<Either<String, List<OrderEntity>>> getAllOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select('*, order_items(*, products(name))')
          .order('created_at', ascending: false);
      return Right((response as List).map((json) => OrderModel.fromJson(json)).toList());
    } catch (e) {
      return Left('Failed to fetch orders: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateOrderStatus(String orderId, String status) async {
    try {
      if (status == 'confirmed') {
        // Use RPC to decrement stock atomically
        await supabase.rpc('confirm_order_and_decrement_stock', params: {'p_order_id': orderId});
      } else {
        await supabase.from('orders').update({'status': status}).eq('id', orderId);
      }
      return const Right(null);
    } catch (e) {
      return Left('Failed to update order status: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteOrder(String orderId) async {
    try {
      await supabase.from('orders').delete().eq('id', orderId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete order: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> getAllInventory() async {
    try {
      final response = await supabase.from('products').select().order('name');
      return Right((response as List).map((json) => ProductModel.fromJson(json)).toList());
    } catch (e) {
      return Left('Failed to fetch inventory: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateProduct(ProductEntity product, {Uint8List? imageBytes, String? imageExt}) async {
    try {
      String imageUrl = product.imagePath;

      if (imageBytes != null) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.${imageExt ?? "png"}';
        await supabase.storage.from('products').uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(upsert: true),
        );
        imageUrl = supabase.storage.from('products').getPublicUrl(fileName);
      }

      final model = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        originalPrice: product.originalPrice,
        imagePath: imageUrl,
        category: product.category,
        rating: product.rating,
        reviewCount: product.reviewCount,
        isFeatured: product.isFeatured,
        isNew: product.isNew,
        stockQuantity: product.stockQuantity,
        tags: product.tags,
      );
      final data = model.toJson();
      
      await supabase.from('products').update(data).eq('id', product.id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<CategoryEntity>>> getAllCategories() async {
    try {
      final response = await supabase.from('categories').select().order('name');
      return Right((response as List).map((json) => CategoryModel.fromJson(json)).toList());
    } catch (e) {
      return Left('Failed to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addCategory(String name, String iconName, String colorHex) async {
    try {
      await supabase.from('categories').insert({
        'name': name,
        'icon_name': iconName,
        'color_hex': colorHex,
      });
      return const Right(null);
    } catch (e) {
      return Left('Failed to add category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateCategory(String id, String name, String iconName, String colorHex) async {
    try {
      await supabase.from('categories').update({
        'name': name,
        'icon_name': iconName,
        'color_hex': colorHex,
      }).eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteCategory(String id) async {
    try {
      await supabase.from('categories').delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addProduct(ProductEntity product, {Uint8List? imageBytes, String? imageExt}) async {
    try {
      String imageUrl = product.imagePath;

      if (imageBytes != null) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.${imageExt ?? "png"}';
        await supabase.storage.from('products').uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(upsert: true),
        );
        imageUrl = supabase.storage.from('products').getPublicUrl(fileName);
      }

      final model = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        originalPrice: product.originalPrice,
        imagePath: imageUrl,
        category: product.category,
        rating: product.rating,
        reviewCount: product.reviewCount,
        isFeatured: product.isFeatured,
        isNew: product.isNew,
        stockQuantity: product.stockQuantity,
        tags: product.tags,
      );
      
      final data = model.toJson();
      if (product.id.isEmpty) {
        data.remove('id'); // Let Supabase generate UUID
      }
      
      await supabase.from('products').insert(data);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add product: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteProduct(String productId) async {
    try {
      await supabase.from('products').delete().eq('id', productId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getRevenueStats() async {
    try {
      final response = await supabase.from('orders').select('total_amount, created_at');
      final orders = response as List;
      
      double totalRevenue = 0;
      Map<String, double> dailyRevenue = {};

      for (var order in orders) {
        final amount = (order['total_amount'] as num).toDouble();
        totalRevenue += amount;
        
        final date = DateTime.parse(order['created_at']).toIso8601String().split('T')[0];
        dailyRevenue[date] = (dailyRevenue[date] ?? 0) + amount;
      }

      final shippingResponse = await getShippingSettings();
      bool isFreeShipping = false;
      shippingResponse.fold((_) => null, (val) => isFreeShipping = val);

      return Right({
        'totalRevenue': totalRevenue,
        'dailyRevenue': dailyRevenue,
        'orderCount': orders.length,
        'isFreeShipping': isFreeShipping,
      });
    } catch (e) {
      return Left('Failed to fetch stats: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> getShippingSettings() async {
    try {
      final response = await supabase
          .from('app_settings')
          .select('value')
          .eq('setting_key', 'free_shipping')
          .maybeSingle();
      return Right(response?['value'] ?? false);
    } catch (e) {
      return Left('Failed to fetch shipping settings: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateShippingSettings(bool isFree) async {
    try {
      await supabase.from('app_settings').upsert({
        'setting_key': 'free_shipping',
        'value': isFree,
      }, onConflict: 'setting_key');
      return const Right(null);
    } catch (e) {
      return Left('Failed to update shipping settings: ${e.toString()}');
    }
  }
}

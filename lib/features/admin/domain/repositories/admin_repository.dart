import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../domain/entities/order_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/entities/category_entity.dart';

abstract class AdminRepository {
  Future<Either<String, List<OrderEntity>>> getAllOrders();
  Future<Either<String, void>> updateOrderStatus(String orderId, String status);
  Future<Either<String, void>> deleteOrder(String orderId);
  Future<Either<String, List<ProductEntity>>> getAllInventory();
  Future<Either<String, void>> updateProduct(ProductEntity product, {Uint8List? imageBytes, String? imageExt});
  Future<Either<String, void>> addProduct(ProductEntity product, {Uint8List? imageBytes, String? imageExt});
  Future<Either<String, void>> deleteProduct(String productId);
  Future<Either<String, List<CategoryEntity>>> getAllCategories();
  Future<Either<String, void>> addCategory(String name, String iconName, String colorHex);
  Future<Either<String, void>> updateCategory(String id, String name, String iconName, String colorHex);
  Future<Either<String, void>> deleteCategory(String id);
  Future<Either<String, Map<String, dynamic>>> getRevenueStats();
  Future<Either<String, bool>> getShippingSettings();
  Future<Either<String, void>> updateShippingSettings(bool isFree);
}

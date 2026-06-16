import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/order_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/entities/category_entity.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(AdminInitial());

  Future<void> loadDashboardData() async {
    emit(AdminLoading());
    final statsResult = await _repository.getRevenueStats();
    final ordersResult = await _repository.getAllOrders();
    final inventoryResult = await _repository.getAllInventory();
    final categoriesResult = await _repository.getAllCategories();

    statsResult.fold(
      (error) => emit(AdminError(error)),
      (stats) {
        ordersResult.fold(
          (error) => emit(AdminError(error)),
          (orders) {
            inventoryResult.fold(
              (error) => emit(AdminError(error)),
              (inventory) {
                categoriesResult.fold(
                  (error) => emit(AdminError(error)),
                  (categories) => emit(AdminLoaded(
                    stats: stats,
                    recentOrders: orders,
                    inventory: inventory,
                    categories: categories,
                  )),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> saveProduct(ProductEntity product, {bool isNew = false, Uint8List? imageBytes, String? imageExt}) async {
    final result = isNew 
        ? await _repository.addProduct(product, imageBytes: imageBytes, imageExt: imageExt)
        : await _repository.updateProduct(product, imageBytes: imageBytes, imageExt: imageExt);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }

  Future<void> updateShipping(bool isFree) async {
    final result = await _repository.updateShippingSettings(isFree);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }

  Future<void> deleteProduct(String id) async {
    final result = await _repository.deleteProduct(id);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }

  Future<void> saveCategory(String name, String icon, String color, {String? id}) async {
    final result = id == null
        ? await _repository.addCategory(name, icon, color)
        : await _repository.updateCategory(id, name, icon, color);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }

  Future<void> deleteCategory(String id) async {
    final result = await _repository.deleteCategory(id);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }

  Future<void> updateStatus(String orderId, String status) async {
    final result = await _repository.updateOrderStatus(orderId, status);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }

  Future<void> deleteOrder(String id) async {
    final result = await _repository.deleteOrder(id);
    result.fold(
      (error) => emit(AdminError(error)),
      (_) => loadDashboardData(),
    );
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/entities/category_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final Map<String, dynamic> stats;
  final List<OrderEntity> recentOrders;
  final List<ProductEntity> inventory;
  final List<CategoryEntity> categories;

  const AdminLoaded({
    required this.stats,
    required this.recentOrders,
    required this.inventory,
    required this.categories,
  });

  @override
  List<Object?> get props => [stats, recentOrders, inventory, categories];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';
import '../entities/category_entity.dart';
import '../entities/banner_entity.dart';

abstract class HomeRepository {
  Future<Either<String, List<ProductEntity>>> getProducts();
  Future<Either<String, List<ProductEntity>>> getFeaturedProducts();
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(String categoryId);
  Future<Either<String, List<CategoryEntity>>> getCategories();
  Future<Either<String, List<BannerEntity>>> getBanners();
  Future<Either<String, ProductEntity>> getProductById(String id);
}
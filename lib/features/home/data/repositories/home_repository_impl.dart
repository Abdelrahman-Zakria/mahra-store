import 'package:dartz/dartz.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _localDataSource;
  final HomeRemoteDataSource _remoteDataSource;
  final bool _useRemote;

  HomeRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource, {
    bool useRemote = true,
  }) : _useRemote = useRemote;

  @override
  Future<Either<String, List<ProductEntity>>> getProducts() async {
    try {
      final products = _useRemote
          ? await _remoteDataSource.getProducts()
          : await _localDataSource.getProducts();
      return Right(products);
    } catch (e) {
      if (_useRemote) {
        try {
          final products = await _localDataSource.getProducts();
          return Right(products);
        } catch (_) {}
      }
      return Left('Failed to load products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> getFeaturedProducts() async {
    try {
      final products = _useRemote
          ? await _remoteDataSource.getFeaturedProducts()
          : await _localDataSource.getFeaturedProducts();
      return Right(products);
    } catch (e) {
      if (_useRemote) {
        try {
          final products = await _localDataSource.getFeaturedProducts();
          return Right(products);
        } catch (_) {}
      }
      return Left('Failed to load featured products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(
      String categoryId) async {
    try {
      final products = _useRemote
          ? await _remoteDataSource.getProductsByCategory(categoryId)
          : await _localDataSource.getProductsByCategory(categoryId);
      return Right(products);
    } catch (e) {
      if (_useRemote) {
        try {
          final products =
              await _localDataSource.getProductsByCategory(categoryId);
          return Right(products);
        } catch (_) {}
      }
      return Left('Failed to load products by category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = _useRemote
          ? await _remoteDataSource.getCategories()
          : await _localDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      if (_useRemote) {
        try {
          final categories = await _localDataSource.getCategories();
          return Right(categories);
        } catch (_) {}
      }
      return Left('Failed to load categories: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<BannerEntity>>> getBanners() async {
    try {
      final banners = _useRemote
          ? await _remoteDataSource.getBanners()
          : await _localDataSource.getBanners();
      return Right(banners);
    } catch (e) {
      if (_useRemote) {
        try {
          final banners = await _localDataSource.getBanners();
          return Right(banners);
        } catch (_) {}
      }
      return Left('Failed to load banners: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductEntity>> getProductById(String id) async {
    try {
      final product = _useRemote
          ? await _remoteDataSource.getProductById(id)
          : await _localDataSource.getProductById(id);
      return Right(product);
    } catch (e) {
      if (_useRemote) {
        try {
          final product = await _localDataSource.getProductById(id);
          return Right(product);
        } catch (_) {}
      }
      return Left('Product not found: ${e.toString()}');
    }
  }
}

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  Timer? _debounce;

  HomeCubit(this._homeRepository) : super(const HomeInitial());

  // Helper to create the static "All" category
  static const CategoryEntity _allCategory = CategoryEntity(
    id: 'all',
    name: 'All',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF1A1A1A),
  );

  /// Loads all home page data in parallel
  Future<void> loadHomeData() async {
    emit(const HomeLoading());

    // Fetch all data sources concurrently
    final results = await Future.wait([
      _homeRepository.getProducts(),
      _homeRepository.getFeaturedProducts(),
      _homeRepository.getCategories(),
      _homeRepository.getBanners(),
    ]);

    // Explicitly cast each result to restore the specific type information lost in Future.wait
    final productsResult = results[0] as Either<String, List<ProductEntity>>;
    final featuredResult = results[1] as Either<String, List<ProductEntity>>;
    final categoriesResult = results[2] as Either<String, List<CategoryEntity>>;
    final bannersResult = results[3] as Either<String, List<BannerEntity>>;

    // Check for any failures
    String? errorMessage;

    // Check main products result for errors
    productsResult.fold((l) => errorMessage = l, (_) {});
    // Optionally check others if they are critical
    if (errorMessage == null) {
      categoriesResult.fold((l) => errorMessage = l, (_) {});
    }

    if (errorMessage != null) {
      emit(HomeLoadFailure(errorMessage!));
      return;
    }

    // Add "All" category at the beginning of the list
    final remoteCategories = categoriesResult.getOrElse(() => []);
    final categories = [_allCategory, ...remoteCategories];

    emit(HomeLoadSuccess(
      allProducts: productsResult.getOrElse(() => []),
      featuredProducts: featuredResult.getOrElse(() => []),
      filteredProducts: productsResult.getOrElse(() => []),
      categories: categories,
      banners: bannersResult.getOrElse(() => []),
      selectedCategoryId: 'all',
    ));
  }

  /// Filters products by category
  Future<void> filterByCategory(String categoryId) async {
    final currentState = state;
    if (currentState is! HomeLoadSuccess) return;

    emit(HomeCategoryFilterLoading(currentState));

    final result = await _homeRepository.getProductsByCategory(categoryId);

    result.fold(
          (failure) => emit(HomeLoadFailure(failure)),
          (products) => emit(currentState.copyWith(
        filteredProducts: products,
        selectedCategoryId: categoryId,
        searchQuery: '',
      )),
    );
  }

  /// Searches products by name/description with debounce
  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final currentState = state;
    if (currentState is! HomeLoadSuccess) return;

    if (query.isEmpty) {
      emit(currentState.copyWith(
        filteredProducts: currentState.allProducts,
        searchQuery: '',
        selectedCategoryId: 'all',
      ));
      return;
    }

    final filtered = currentState.allProducts.where((product) {
      final lowerQuery = query.toLowerCase();
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();

    emit(currentState.copyWith(
      filteredProducts: filtered,
      searchQuery: query,
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  /// Refreshes the home page data
  Future<void> refresh() => loadHomeData();
}
import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data has been loaded
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state when fetching home page data
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Success state with all home page data populated
class HomeLoadSuccess extends HomeState {
  final List<ProductEntity> allProducts;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> filteredProducts;
  final List<CategoryEntity> categories;
  final List<BannerEntity> banners;
  final String selectedCategoryId;
  final String searchQuery;

  const HomeLoadSuccess({
    required this.allProducts,
    required this.featuredProducts,
    required this.filteredProducts,
    required this.categories,
    required this.banners,
    required this.selectedCategoryId,
    this.searchQuery = '',
  });

  HomeLoadSuccess copyWith({
    List<ProductEntity>? allProducts,
    List<ProductEntity>? featuredProducts,
    List<ProductEntity>? filteredProducts,
    List<CategoryEntity>? categories,
    List<BannerEntity>? banners,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return HomeLoadSuccess(
      allProducts: allProducts ?? this.allProducts,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      banners: banners ?? this.banners,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allProducts,
    featuredProducts,
    filteredProducts,
    categories,
    banners,
    selectedCategoryId,
    searchQuery,
  ];
}

/// Error state when loading fails
class HomeLoadFailure extends HomeState {
  final String message;

  const HomeLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when filtering products by category
class HomeCategoryFilterLoading extends HomeState {
  final HomeLoadSuccess previousState;

  const HomeCategoryFilterLoading(this.previousState);

  @override
  List<Object?> get props => [previousState];
}
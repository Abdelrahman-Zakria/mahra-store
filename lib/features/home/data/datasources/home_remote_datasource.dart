import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<CategoryModel>> getCategories();
  Future<List<BannerModel>> getBanners();
  Future<ProductModel> getProductById(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabase;

  HomeRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await supabase.from('products').select();
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await supabase.from('products').select().eq('is_featured', true);
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    // If categoryId is 'all', it might be a special UUID or we just fetch all
    if (categoryId == 'all' || categoryId == '00000000-0000-0000-0000-000000000000') return getProducts();
    final response = await supabase.from('products').select().eq('category_id', categoryId);
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabase.from('categories').select();
    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    final response = await supabase.from('banners').select();
    return (response as List).map((json) => BannerModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await supabase.from('products').select().eq('id', id).single();
    return ProductModel.fromJson(response);
  }
}

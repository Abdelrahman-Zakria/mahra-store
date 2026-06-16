import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: _getIconData(json['icon_name'] as String?),
      color: _getColor(json['color_hex'] as String?),
    );
  }

  static IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'backpack_rounded':
        return Icons.backpack_rounded;
      case 'watch_rounded':
        return Icons.watch_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  static Color _getColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF1A1A1A);
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

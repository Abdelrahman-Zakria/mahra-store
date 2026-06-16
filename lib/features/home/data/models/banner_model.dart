import 'package:flutter/material.dart';
import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.badgeText,
    required super.backgroundColor,
    super.textColor,
    super.imagePath,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      subtitle: json['subtitle'] as String? ?? '',
      badgeText: json['badge_text'] as String? ?? '',
      backgroundColor: _getColor(json['background_color_hex'] as String?),
      textColor: _getColor(json['text_color_hex'] as String?, defaultColor: Colors.white),
      imagePath: json['image_url'] as String?,
    );
  }

  static Color _getColor(String? hex, {Color defaultColor = const Color(0xFF1A1A1A)}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

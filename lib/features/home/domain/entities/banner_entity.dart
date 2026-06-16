import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BannerEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color backgroundColor;
  final Color textColor;
  final String? imagePath;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, title];
}
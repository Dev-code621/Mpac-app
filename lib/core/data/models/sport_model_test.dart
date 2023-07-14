import 'package:flutter/material.dart';

class SportModelTest {
  final int id;
  final String title;
  final String imagePath;
  final String subImagePath;
  final String backgroundPath;
  final Color color;
  final List<String>? positions;

  bool isExpanded = false;

  SportModelTest(
      {required this.subImagePath,
      required this.id,
      required this.title,
      required this.color,
      this.positions,
      required this.backgroundPath,
      required this.imagePath,});

  factory SportModelTest.fromJson(Map<String, dynamic> json) {
    return SportModelTest(
        color: json['color'],
        backgroundPath: json['backgroundPath'],
        id: json['id'],
        title: json['title'],
        imagePath: json['image'],
        subImagePath: json['subImagePath'],);
  }
}






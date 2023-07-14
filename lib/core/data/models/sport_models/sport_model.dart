import 'package:flutter/material.dart';

import 'package:mpac_app/core/data/models/sport_models/attribute_model.dart';

class SportModel {
  final String id;
  final String name;
  final String type;
  final AttributeModel attributeModel;

  List<String>? selectedPositions = [];

  bool isExpanded = false;
  String skillType = "Outdoor";
  String skillTypeRoadRacing = "Running Events";

  Color color = Colors.white;
  String backgroundPath = "";
  String subImagePath = "";

  bool isAddingToServer = false;
  bool errorAddingToServer = false;
  bool addedToServer = false;

  SportModel({
    required this.id,
    required this.name,
    this.subImagePath = "",
    this.backgroundPath = "",
    this.color = Colors.transparent,
    required this.type,
    required this.attributeModel,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'],
      backgroundPath: json['backgroundPath'] ?? "",
      subImagePath: json['subImagePath'] ?? "",
      color: json['color'] == null ? Colors.transparent : Color(json['color']),
      name: json['name'],
      type: json['type'],
      attributeModel: AttributeModel.fromJson(json['attributes']),
    );
  }

  Map<String, dynamic> toMap(SportModel s) {
    return {
      'id': s.id,
      'type': s.type,
      'name': s.name,
      'backgroundPath': s.backgroundPath,
      'subImagePath': s.subImagePath,
      'color': s.color.value,
      'attributes': {}
    };
  }
}

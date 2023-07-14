import 'dart:convert';

import 'package:mpac_app/core/data/models/sport_models/sport_model.dart';

class SelectedSportModel {
  final String id;
  final String sportPath2;
  final String value;
  final SportModel? sport;

  SelectedSportModel({
    required this.id,
    required this.sportPath2,
    required this.value,
    this.sport,
  });

  factory SelectedSportModel.fromJson(
    Map<String, dynamic> json,
    bool withSport,
  ) {
    return SelectedSportModel(
      id: json['id'],
      sportPath2: json['sport_path'],
      value: json['value'],
      sport: withSport ? SportModel.fromJson(json['sport']) : null,
    );
  }

  static String encode(List<SelectedSportModel> sports) => json.encode(
        sports
            .map<Map<String, dynamic>>(
                (sport) => SelectedSportModel.toMap(sport),)
            .toList(),
      );

  static List<SelectedSportModel> decode(String sports) =>
      (json.decode(sports) as List<dynamic>)
          .map<SelectedSportModel>(
              (item) => SelectedSportModel.fromJson(item, true),)
          .toList();

  static Map<String, dynamic> toMap(SelectedSportModel s) {
    return {
      'id': s.id,
      'sport_path': s.sportPath2,
      'value': s.value,
      'sport': s.sport!.toMap(s.sport!)
    };
  }
}

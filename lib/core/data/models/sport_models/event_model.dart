import 'package:mpac_app/core/data/models/sport_models/variation_model.dart';

class EventModel {
  final String id;
  final String name;
  final String type;
  final List<VariationModel>? variations;
  // for sub events
  final String? category;
  final List<EventModel>? subEvents;

  bool isExpanded = false;

  EventModel(
      {required this.id,
      required this.name,
      required this.type,
      required this.category,
      required this.subEvents,
      required this.variations,});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        type: json['type'],
        subEvents: json['events'] == null ? [] : getSubEvents(json['events']),
        variations: json['variations'] == null
            ? []
            : getVariations(json['variations']),);
  }

  static List<VariationModel> getVariations(json) {
    List<VariationModel> variations = [];
    for (var item in json) {
      variations.add(VariationModel.fromJson(item));
    }
    return variations;
  }

  static List<EventModel> getSubEvents(json) {
    List<EventModel> subEvents = [];
    for (var item in json) {
      subEvents.add(EventModel.fromJson(item));
    }
    return subEvents;
  }
}

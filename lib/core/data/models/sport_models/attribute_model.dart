import 'package:mpac_app/core/data/models/sport_models/event_model.dart';

class AttributeModel {
  final List<String>? positions;
  final List<EventModel>? events;

  AttributeModel({this.positions, this.events});

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
        positions:
            json['positions'] == null ? [] : getPositions(json['positions']),
        events: json['events'] == null ? [] : getEvents(json['events']),);
  }

  static List<String> getPositions(json) {
    List<String> positions = [];
    for (var item in json) {
      positions.add(item.toString());
    }
    return positions;
  }

  static List<EventModel> getEvents(json){
    List<EventModel> events = [];
    for(var item in json){
      events.add(EventModel.fromJson(item));
    }
    return events;
  }
}

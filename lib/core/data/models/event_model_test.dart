import 'package:flutter/material.dart';

class EventModelTest {
  final String title;
  final List<String> points;
  final Color color;
  final Widget? icon;
  final String? trailingMessage;

  // For athletics
  List<SubEventModel>? subEvents;

  bool isExpanded = false;

  EventModelTest(
      {required this.title,
      required this.points,
      required this.color,
      this.subEvents,
      this.icon,
      this.isExpanded = false,
      this.trailingMessage,});
}

class SubEventModel {
  final String title;
  final List<String> points;
  final Color color;

  SubEventModel(
      {required this.title, required this.points, required this.color,});
}

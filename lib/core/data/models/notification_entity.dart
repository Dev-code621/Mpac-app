import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  bool isNew;
  final String createdAt;
  final PostModel? postModel;
  final UserModel? userModel;

  NotificationModel(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body,
      required this.type,
      required this.isNew,
      this.postModel,
      this.userModel,
      required this.createdAt,});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        id: json['id'],
        type: json['type'],
        userId: json['user_id'],
        title: json['title'],
        createdAt: json['created_at'],
        isNew: json['is_new'],
        body: json['body'],
        postModel: json['type'] == "comment_notification" || json['type'] == "react_notification"
            ? PostModel.fromJson(json['post'])
            : null,
        userModel: json['type'] == "follow_notification" || json['type'] == "comment_notification" || json['type'] == "react_notification"
            ? UserModel.fromJson(json['user'])
            : null,

    );
  }
}

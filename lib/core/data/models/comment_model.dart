import 'package:mpac_app/core/data/models/user_model.dart';

class CommentModel {
  final String id;
  final String userId;
  final String comment;
  final UserModel owner;
  final String createdAt;

  CommentModel(
      {required this.id,
      required this.userId,
      required this.comment,
      required this.createdAt,
      required this.owner,});

  factory CommentModel.fromJson(Map<String, dynamic> json, {UserModel? owner}) {
    return CommentModel(
        id: json['id'],
        userId: json['user_id'],
        comment: json['comment'],
        createdAt: json['created_at'],
        owner: owner ??  UserModel.fromJson(json['user']),);
  }
}

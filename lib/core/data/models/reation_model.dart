import 'package:mpac_app/core/data/models/user_model.dart';

class ReactionModel {
  final String id;
  final String userId;
  final String type;
  final UserModel? user;

  ReactionModel(
      {required this.id,
      required this.userId,
      required this.user,
      required this.type,});

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
        user: json['user'] == null ? null : UserModel.fromJson(json['user']),
        id: json['id'],
        userId: json['user_id'],
        type: json['type'],);
  }
}

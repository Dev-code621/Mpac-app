import 'package:mpac_app/core/data/models/user_model.dart';

class FollowerModel {
  final UserModel userModel;

  FollowerModel(this.userModel);

  factory FollowerModel.fromJson(Map<String, dynamic> json){
    return FollowerModel(UserModel.fromJson(json));
  }
}
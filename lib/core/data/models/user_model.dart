import 'dart:convert';

import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';

class UserModel {
  final String id;

  // final String name;
  final String? email;
  final bool? isEmailVerified;
  final String? username;
  final String? gender;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? dob;
  final int? onBoardingStep;
  final String? mobileNumber;
  final String? mobileCountryCode;
  final bool? isMobileVerified;
  final String? originCountry;
  final String? originCity;
  final String? originState;
  final String? originAddress;
  final String? currentCountry;
  final String? currentCity;
  final String? currentState;
  final String? currentAddress;
  final num? height;
  final num? weight;
  final String? type;
  final String? onboardBy;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final String? followers;
  final String? followings;
  final bool? isSuperUser;

  final List<SelectedSportModel>? sports;
  final List<String>? interestedSports;

  bool? isFollowed;

  String? token;
  int? notificationsCount;
  String? measureSystem;

  UserModel({
    required this.id,
    this.email,
    this.mobileCountryCode,
    this.isEmailVerified,
    this.username,
    this.gender,
    this.firstName,
    this.lastName,
    this.bio,
    this.dob,
    this.onBoardingStep,
    this.mobileNumber,
    this.isMobileVerified,
    this.originCountry,
    this.originCity,
    this.originState,
    this.originAddress,
    this.currentCountry,
    this.currentCity,
    this.currentState,
    this.currentAddress,
    this.height,
    this.weight,
    this.type,
    this.onboardBy,
    this.image,
    this.sports,
    this.interestedSports,
    this.createdAt,
    this.updatedAt,
    this.followers,
    this.followings,
    this.isFollowed,
    this.notificationsCount,
    this.measureSystem,
    this.isSuperUser,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    List<Map<String, dynamic>> sports = [];
    if (json['sports'] != null) {
      for (int i = 0; i < json["sports"].length; i++) {
        if (!sports.contains(json["sports"][i])) {
          if (!sports.any((element) => element['sport_path']
              .startsWith(json["sports"][i]['sport_path'].split('/')[0]))) {
            sports.add(json['sports'][i]);
          }
        }
      }
    }

    if (json['token'] == null) {
      return UserModel(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        isEmailVerified: json['is_email_verified'],
        gender: json['gender'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        bio: json['bio'],
        dob: json['dob'],
        onBoardingStep: json['onboarding_step'],
        mobileNumber: json['mobile_number'],
        mobileCountryCode: json['mobile_country_code'],
        // isMobileVerified: json['is_mobile_verified'],
        isMobileVerified: false,
        originCountry: json['origin_country'],
        originCity: json['origin_city'],
        originState: json['origin_state'],
        originAddress: json['origin_address'],
        currentCountry: json['current_country'],
        currentCity: json['current_city'],
        currentState: json['current_state'],
        currentAddress: json['current_address'],
        height: json['height'],
        weight: json['weight'],
        type: json['type'],
        onboardBy: json['onboard_by'],
        image: json['image'],
        sports: getSports(sports),
        interestedSports: json['interestedSports'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        followings: json['followings_count'],
        followers: json['followers_count'],
        isFollowed: json['is_followed'],
        measureSystem: json['measure_system'],
        isSuperUser: json['is_super_user'],
        notificationsCount: json['notifications_count'] == null
            ? 0
            : int.tryParse(json['notifications_count'].toString()),
        token: token,
      );
    } else {
      String token = json['token'];
      json = json['user'];
      return UserModel(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        isEmailVerified: json['is_email_verified'],
        gender: json['gender'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        bio: json['bio'],
        dob: json['dob'],
        onBoardingStep: json['onboarding_step'],
        mobileNumber: json['mobile_number'],
        mobileCountryCode: json['mobile_country_code'],
        // isMobileVerified: json['is_mobile_verified'],
        isMobileVerified: false,
        originCountry: json['origin_country'],
        originCity: json['origin_city'],
        originState: json['origin_state'],
        originAddress: json['origin_address'],
        currentCountry: json['current_country'],
        currentCity: json['current_city'],
        currentState: json['current_state'],
        currentAddress: json['current_address'],
        height: json['height'],
        weight: json['weight'],
        type: json['type'],
        onboardBy: json['onboard_by'],
        image: json['image'],
        createdAt: json['created_at'],
        sports: getSports(sports),
        interestedSports: json['interestedSports'],
        updatedAt: json['updated_at'],
        followings: json['followings_count'],
        followers: json['followers_count'],
        isFollowed: json['is_followed'],
        measureSystem: json['measure_system'],
        isSuperUser: json['is_super_user'],
        notificationsCount: json['notifications_count'] == null
            ? 0
            : int.tryParse(json['notifications_count'].toString()),
        token: token,
      );
    }
  }

  static List<SelectedSportModel> getSports(json) {
    int index = 0;

    if (json == null) {
      return [];
    } else {
      List<SelectedSportModel> sports = [];
      for (var item in json) {
        var s = Sport.all.where(
          (element) =>
              element.title.toLowerCase() ==
              item['sport']['name'].toString().toLowerCase(),
        );
        sports.add(SelectedSportModel.fromJson(
          item,
          true,
        ));
        if (s.isNotEmpty) {
          sports[index].sport!.backgroundPath = s.first.backgroundPath;
          sports[index].sport!.subImagePath = s.first.subImagePath;
          sports[index].sport!.color = s.first.color;
        }
        index++;
      }
      return sports;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "user": {
        "id": id,
        "username": username,
        "email": email,
        "is_email_verified": isEmailVerified,
        "gender": gender,
        "first_name": firstName,
        "last_name": lastName,
        "dob": dob,
        "bio": bio,
        "onboarding_step": onBoardingStep,
        "mobile_number": mobileNumber,
        "mobile_country_code": mobileCountryCode,
        "is_mobile_verified": isMobileVerified,
        "origin_country": originCountry,
        "origin_city": originCity,
        "origin_state": originState,
        "origin_address": originAddress,
        "current_country": currentCountry,
        "current_city": currentCity,
        "current_state": currentState,
        "current_address": currentAddress,
        "height": height,
        "weight": weight,
        "type": type,
        "onboard_by": onboardBy,
        "image": image,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_super_user": isSuperUser,
        "measure_system": measureSystem
      },
      "token": token,
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, isEmailVerified: $isEmailVerified, username: $username, gender: $gender, firstName: $firstName, lastName: $lastName, dob: $dob, onBoardingStep: $onBoardingStep, mobileNumber: $mobileNumber, isMobileVerified: $isMobileVerified, originCountry: $originCountry, originCity: $originCity, originState: $originState, originAddress: $originAddress, currentCountry: $currentCountry, currentCity: $currentCity, currentState: $currentState, currentAddress: $currentAddress, height: $height, weight: $weight, type: $type, onboardBy: $onboardBy, image: $image, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, followings: $followings, token: $token}';
  }
}

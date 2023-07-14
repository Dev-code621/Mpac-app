import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart';
import 'package:mpac_app/core/utils/constants/converters.dart';

class ProfileParams {
  String username = "";
  String gender = "male";
  String firstName = "";
  String lastName = "";
  String? bio;
  DateTime? dob;
  int mobileNumber = 0;
  int codePhoneNumber = 971;
  CountryModel? originCountry;
  String? originCity = "";
  State? originState;
  String originAddress = "";

  File? profileImage;
  Uint8List? profileImageWeb;
  XFile? xFile;
  CroppedFile? croppedProfileImage;
  CountryModel? currentCountry;
  String? currentCity;
  State? currentState;
  String currentAddress = "";
  num? height;
  int footHeight = 0;
  int inchHeight = 0;
  String heightSymbol = "Cm";
  num? weight;
  String weightSymbol = "Kg";
  String type = "";

  int onBoardingStep = 1;

  String firebaseToken = "";

  ProfileParams({
    this.username = "",
    this.gender = "",
    this.firstName = "",
    this.lastName = "",
    this.bio,
    this.dob,
    this.mobileNumber = 0,
    this.codePhoneNumber = 971,
    this.originCity = "",
    this.originAddress = "",
    this.profileImage,
    this.currentAddress = "",
    this.heightSymbol = "",
    this.onBoardingStep = 1,
    this.weightSymbol = "",
    this.type = "player",
  });

  Future<Map<String, dynamic>> toMap() async {
    String? contentType;
    if (profileImage != null || croppedProfileImage != null) {
      if (profileImage != null) {
        contentType = lookupMimeType(profileImage!.path);
      } else {
        contentType = lookupMimeType(croppedProfileImage!.path);
      }
    }

    return {
      "profile_image": profileImage == null &&
              profileImageWeb == null &&
              croppedProfileImage == null
          ? null
          : profileImage == null && croppedProfileImage == null
              ? MultipartFile.fromBytes(
                  profileImageWeb!,
                  filename: "${DateTime.now()}",
                  contentType: MediaType(
                    xFile!.mimeType!.split("/").first,
                    xFile!.mimeType!.split("/")[1],
                    {'Content-Type': xFile!.mimeType!.toString()},
                  ),
                )
              : croppedProfileImage != null
                  ? await MultipartFile.fromFile(
                      croppedProfileImage!.path,
                      contentType: contentType == null
                          ? null
                          : MediaType(
                              contentType.split("/").first,
                              contentType.split("/")[1],
                              {'Content-Type': contentType},
                            ),
                    )
                  : await MultipartFile.fromFile(
                      profileImage!.path,
                      contentType: contentType == null
                          ? null
                          : MediaType(
                              contentType.split("/").first,
                              contentType.split("/")[1],
                              {'Content-Type': contentType},
                            ),
                    ),
      /*await MultipartFile.fromFile(
          profileImage == null
              ? File.fromRawPath(profileImageWeb!).path
              : profileImage!.path
      ),*/
      "username": username,
      "gender": gender,
      "first_name": firstName,
      "last_name": lastName,
      "bio": bio,
      "dob": dob ?? dob.toString(),
      "mobile_number": mobileNumber.toString(),
      "mobile_country_code": codePhoneNumber.toString(),
      "origin_country": originCountry != null ? originCountry!.name : null,
      "origin_city": originCity,
      "origin_state": originState != null ? originState!.name : null,
      "origin_address": originAddress,
      "current_country": currentCountry == null ? null : currentCountry!.name,
      "current_city": currentCity,
      "current_state": currentState == null ? null : currentState!.name,
      "current_address": currentAddress,
      "height": height == 0 && (footHeight == 0 && inchHeight == 0)
          ? null
          : heightSymbol == "Cm"
              ? height
              : Converters.ftToCm(
                  footHeight +
                      (inchHeight / pow(10, (inchHeight.toString().length))),
                ),
      "weight": weight == 0
          ? null
          : weightSymbol == "Kg"
              ? weight
              : Converters.poundToKg(weight!),
      "onboarding_step": onBoardingStep,
      // "type": type,
      "measure_system": weightSymbol == "Kg" ? "metric" : "imperial",
      "fcm_token": firebaseToken
    };
  }
}

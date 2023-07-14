import 'dart:convert';

import 'package:mpac_app/core/data/models/settings_model.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/data/models/user_model.dart';

@LazySingleton()
class PrefsHelper {
  final SharedPreferences prefs;

  PrefsHelper(this.prefs);

  bool get getIsLoggedIn =>
      prefs.getBool(SharedPreferencesKeys.isLoggedBefore) ?? false;

  String get getUserToken => prefs.getString(SharedPreferencesKeys.token) ?? '';

  String get getUserId => prefs.getString(SharedPreferencesKeys.userId) ?? '';

  String get getSelectedFilter =>
      prefs.getString(SharedPreferencesKeys.selectedFilter) ?? '';

  String userFullName() {
    return prefs.getString(SharedPreferencesKeys.name) ?? '';
  }

  Future<void> saveUserInfo(UserModel user) async {
    /// save user info...
    if (user.token == null) {
      user.token = getUserToken;
      await prefs.setString(SharedPreferencesKeys.token, user.token!);
    }
    if (user.token != null) {
      await prefs.setString(SharedPreferencesKeys.token, user.token!);
    }
    await prefs.setString(SharedPreferencesKeys.userId, user.id);
    await prefs.setString(SharedPreferencesKeys.email, user.email!);
    if (user.username != null) {
      await prefs.setString(SharedPreferencesKeys.username, user.username!);
    }
    if (user.image != null) {
      await prefs.setString(
        SharedPreferencesKeys.userProfilePicture,
        user.image!,
      );
    }

    await prefs.setString(SharedPreferencesKeys.user, jsonEncode(user.toMap()));
    await prefs.setBool(SharedPreferencesKeys.isLoggedBefore, true);
    return Future.value();
  }

  Future<void> saveSelectedSports(List<SelectedSportModel> sSports) async {
    await prefs.setString(
      SharedPreferencesKeys.selectedSports,
      SelectedSportModel.encode(sSports),
    );
  }

  Future<void> savePostFilter(String val) async {
    await prefs.setString(SharedPreferencesKeys.selectedFilter, val);
  }

  Future<List<SelectedSportModel>> getSelectedSports() async {
    final String? sportsString =
        prefs.getString(SharedPreferencesKeys.selectedSports);

    final List<SelectedSportModel> sports =
        sportsString == null ? [] : SelectedSportModel.decode(sportsString);
    return sports;
  }

  Future<void> saveUserSettings(List<SettingsModel> settings) async {
    await prefs.setString(
      SharedPreferencesKeys.settings,
      SettingsModel.encode(settings),
    );
  }

  List<SettingsModel> getUserSettings() {
    final String? settingsStr = prefs.getString(SharedPreferencesKeys.settings);

    final List<SettingsModel> settings =
        settingsStr == null ? [] : SettingsModel.decode(settingsStr);
    return settings;
  }

  Future<void> clearUserInfo() async {
    prefs.clear();
    return Future.value();
  }

  UserModel userInfo() {
    String? userPref = prefs.getString(SharedPreferencesKeys.user);
    Map<String, dynamic> userMap =
        jsonDecode(userPref!) as Map<String, dynamic>;

    return UserModel.fromJson(userMap);
  }

  bool needRefreshToken() {
    int? timestamp = prefs.getInt(SharedPreferencesKeys.storedTokenTime);
    if (timestamp != null) {
      DateTime tokenDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      DateTime now = DateTime.now();
      final int difference = tokenDate.difference(now).inDays;
      if (difference >= 6) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}

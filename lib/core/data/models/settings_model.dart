import 'dart:convert';

class SettingsModel {
  final String key;
  final String value;

  SettingsModel({required this.key, required this.value});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(key: json['key'], value: json['value']);
  }

  static String encode(List<SettingsModel> settings) => json.encode(
        settings
            .map<Map<String, dynamic>>(
              (setting) => SettingsModel.toMap(setting),
            )
            .toList(),
      );

  static List<SettingsModel> decode(String sports) =>
      (json.decode(sports) as List<dynamic>)
          .map<SettingsModel>(
            (item) => SettingsModel.fromJson(item),
          )
          .toList();

  static Map<String, dynamic> toMap(SettingsModel setting) {
    return {'key': setting.key, 'value': setting.value};
  }
}

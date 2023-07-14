class CountryModel {
  static String className = "CountryModel";

  final String name;
  final String emoji;
  final String emojiU;


  CountryModel({required this.name, required this.emoji, required this.emojiU});

  factory CountryModel.fromJson(Map<String, dynamic> json){
    return CountryModel(name: json['name'], emoji: json['emoji'], emojiU: json['emojiU']);
  }
}
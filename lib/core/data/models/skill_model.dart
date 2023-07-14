class SkillModel {
  final String title;
  final String description;
  final String image;

  bool isExpanded = false;

  SkillModel(
      {required this.title, required this.description, required this.image,});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
        title: json['title'], description: json['desc'], image: json['image'],);
  }
}

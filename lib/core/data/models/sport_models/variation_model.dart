class VariationModel {
  final String id;
  final String name;

  VariationModel({required this.id, required this.name});

  factory VariationModel.fromJson(Map<String, dynamic> json){
    return VariationModel(id: json['id'], name: json['name']);
  }
}
class MetaModel {
  final int height, width;
  final String? aspectRatio, codecName;
  final double? duration;

  const MetaModel({
    required this.height,
    required this.width,
    this.aspectRatio,
    this.duration,
    this.codecName,
  });

  static MetaModel? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    return MetaModel(
      height: int.parse(json['height'].toString()),
      width: int.parse(json['width'].toString()),
      duration: double.tryParse(json['duration']?.toString() ?? ''),
      aspectRatio: json['display_aspect_ratio'],
      codecName: json['codec_name'],
    );
  }

  MetaModel copyWith({
    int? height,
    int? width,
    String? aspectRatio,
  }) {
    return MetaModel(
      height: height ?? this.height,
      width: width ?? this.width,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      codecName: codecName,
      duration: duration,
    );
  }
}

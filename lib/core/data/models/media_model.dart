import 'package:mpac_app/core/data/models/meta_model.dart';
import 'package:pod_player/pod_player.dart';

class MediaModel {
  final String id;
  final String url;
  final String? type;
  final String? thumbnailURL;
  final MetaModel? meta;
  final String? postId;

  MediaModel({
    required this.id,
    this.type,
    this.meta,
    required this.url,
    required this.postId,
    required this.thumbnailURL,
  });

  VideoPlayerController? videoPlayerController;
  Duration? currentPosition;
  PodPlayerController? playerController;
  bool isLoading = false;
  bool showVideoSettings = false;
  bool isVideoPaused = false;
  bool showSettings = false;

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      type: json['type'],
      postId: json['post_id'],
      url: json['url'],
      thumbnailURL: json['thumbnail'],
      meta: MetaModel.fromJson(json['meta']),
      // uint8list: json['type'] == "video" ? await getThumbnailData(json['url']) : null
    );
  }

  MediaModel copyWith({
    MetaModel? meta,
  }) {
    return MediaModel(
      id: id,
      url: url,
      type: type,
      thumbnailURL: thumbnailURL,
      meta: meta ?? this.meta,
      postId: postId,
    );
  }
}

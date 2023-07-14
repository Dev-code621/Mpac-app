import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/pages/edit_post_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

abstract class EditPostEvent {}

class InitializeEditPost extends EditPostEvent {
  final PostModel postModel;

  InitializeEditPost(this.postModel);
}

class ChangingPostDescription extends EditPostEvent {
  final String val;

  ChangingPostDescription(this.val);
}

class EditPost extends EditPostEvent {
  final String id;

  EditPost(this.id);
}

class ChangingAssetEntities extends EditPostEvent {
  final List<AssetEntity> assets;

  ChangingAssetEntities(this.assets);
}

class ChangingAssetEntitiesWeb extends EditPostEvent {
  List<XFile> list;

  ChangingAssetEntitiesWeb(this.list);
}

class DeleteOldMedia extends EditPostEvent {
  final String mediaId;
  final CustomMediaAsset customMediaAsset;

  DeleteOldMedia(this.mediaId, this.customMediaAsset);
}

class DeleteNewMedia extends EditPostEvent {
  final CustomMediaAsset customMediaAsset;

  DeleteNewMedia(this.customMediaAsset);
}

class CropImage extends EditPostEvent {
  CroppedFile croppedFile;
  int index;
  String assetId;

  CropImage(
      {required this.croppedFile, required this.index, required this.assetId});
}

class ChangingPostSport extends EditPostEvent {
  final String val;

  ChangingPostSport(this.val);
}

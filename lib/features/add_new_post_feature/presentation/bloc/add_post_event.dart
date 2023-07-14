import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/pick_images_page.dart';

abstract class AddPostEvent {}

class ClearFailures extends AddPostEvent {}

class ClearState extends AddPostEvent {}

class ChangeFocusedMediaIndex extends AddPostEvent {
  final int index;

  ChangeFocusedMediaIndex(this.index);
}

class MediaClicked extends AddPostEvent {
  final MediaSource mediaSource;

  MediaClicked(this.mediaSource);
}

class ChangePostDescription extends AddPostEvent {
  final String val;

  ChangePostDescription(this.val);
}

class GetMoreComments extends AddPostEvent {
  final String val;

  GetMoreComments(this.val);
}

class GetMoreLikes extends AddPostEvent {
  final String val;

  GetMoreLikes(this.val);
}

class ChangingPostSport extends AddPostEvent {
  final String val;

  ChangingPostSport(this.val);
}

class SubmitPost extends AddPostEvent {
  final ProgressCallback? webOnSendProgress;

  SubmitPost({
    this.webOnSendProgress,
  });
}

class GetSports extends AddPostEvent {}

class ClearFailure extends AddPostEvent {}

class SubmitComment extends AddPostEvent {
  final String postId;
  final String? commentId;
  final bool isEdit;

  SubmitComment({required this.postId, this.commentId, required this.isEdit});
}

class GetPostComments extends AddPostEvent {
  final String id;

  GetPostComments(this.id);
}

class GetPostLikes extends AddPostEvent {
  final String id;

  GetPostLikes(this.id);
}

class ChangeCommentStr extends AddPostEvent {
  final String val;

  ChangeCommentStr(this.val);
}

class AddNewPost extends AddPostEvent {}

class CancelCommentFocus extends AddPostEvent {}

class DeleteComment extends AddPostEvent {
  final String postId;
  final String commentId;

  DeleteComment({required this.postId, required this.commentId});
}

class FocusOnComment extends AddPostEvent {
  final CommentModel commentModel;

  FocusOnComment(this.commentModel);
}

class ChangingPostImages extends AddPostEvent {
  List<Uint8List> list;

  ChangingPostImages(this.list);
}

class AddVideoOnWeb extends AddPostEvent {
  XFile video;

  AddVideoOnWeb(this.video);
}

class CropImage extends AddPostEvent {
  final CroppedFile croppedFile;
  final int index;
  final String assetId;

  CropImage(this.croppedFile, this.index, this.assetId);
}

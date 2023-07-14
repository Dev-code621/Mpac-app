import 'dart:typed_data';

import 'package:built_value/built_value.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/models/reation_model.dart';
import 'package:mpac_app/core/data/models/sport_models/selected_sport_model.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/presentation/controllers/pagination_controller.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/classes/post_params.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/pick_images_page.dart';

part 'add_post_state.g.dart';

abstract class AddPostState
    implements Built<AddPostState, AddPostStateBuilder> {
  AddPostState._();

  factory AddPostState([Function(AddPostStateBuilder b) updates]) =
      _$AddPostState;

  List<MediaSource> get selectedMedias;

  PostParams get postParams;

  bool get isSubmittingPost;
  bool get errorSubmittingPost;
  bool get postSubmitted;

  List<Uint8List> get selectedMediasWeb;

  Failure? get failure;

  PostModel? get postedPost;

  bool get isGettingComments;
  bool get errorGettingComments;
  bool get commentsLoaded;
  List<CommentModel> get comments;

  bool get isPostingComment;
  bool get errorPostingComment;
  bool get commentPosted;

  bool get isDeletingComment;
  bool get errorDeletingComment;
  bool get commentDeleted;

  bool get errorValidationCommentStr;

  String get commentStr;

  CommentModel? get focusedCommentForEdit;

  Map<String, dynamic> get croppedFilesMap;

  PaginationController get paginationController;

  bool get isLoadingMoreComments;
  bool get errorLoadingMoreComments;
  bool get loadedMore;
  bool get canLoadMore;

  bool get isLoadingLikes;
  bool get errorLoadingLikes;
  bool get likesLoaded;

  List<ReactionModel> get reactions;

  bool get isLoadingMoreLikes;
  bool get errorLoadingMoreLikes;
  bool get loadedMoreLikes;
  bool get canLoadMoreLikes;

  bool get errorValidationDesc;

  List<XFile> get selectedVideos;

  int get currentFocusedIndex;

  List<SelectedSportModel> get sports;

  factory AddPostState.initial() {
    return AddPostState(
      (b) => b
        ..currentFocusedIndex = 0
        ..reactions = []
        ..sports = []
        ..selectedVideos = []
        ..croppedFilesMap = {}
        ..paginationController = PaginationController()
        ..isLoadingMoreLikes = false
        ..errorLoadingMoreLikes = false
        ..loadedMoreLikes = false
        ..canLoadMoreLikes = false
        ..errorValidationDesc = false
        ..isLoadingLikes = false
        ..errorLoadingLikes = true
        ..likesLoaded = false
        ..canLoadMore = true
        ..loadedMore = false
        ..errorLoadingMoreComments = false
        ..isLoadingMoreComments = false
        ..isDeletingComment = false
        ..errorDeletingComment = false
        ..commentDeleted = false
        ..comments = []
        ..selectedMediasWeb = []
        ..commentStr = ""
        ..commentPosted = false
        ..errorPostingComment = false
        ..isPostingComment = false
        ..isGettingComments = false
        ..errorGettingComments = false
        ..commentsLoaded = false
        ..selectedMedias = []
        ..postParams = PostParams('', sport: "general")
        ..isSubmittingPost = false
        ..errorSubmittingPost = false
        ..errorValidationCommentStr = false
        ..postSubmitted = false,
    );
  }
}

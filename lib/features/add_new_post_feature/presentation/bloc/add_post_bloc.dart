import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/data/repository/repos/post_repository.dart';
import 'package:mpac_app/core/data/repository/repos/settings_repository.dart';
import 'package:mpac_app/core/data/repository/repos/sports_repository.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_event.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_state.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/classes/post_params.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/pick_images_page.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';

@Injectable()
class AddPostBloc extends Bloc<AddPostEvent, AddPostState> {
  final PostRepository postRepository;
  final SportsRepository sportsRepository;
  final SettingsRepository settingsRepository;
  final HomeBloc homeBloc;

  AddPostBloc(
    this.postRepository,
    this.sportsRepository,
    this.settingsRepository,
    this.homeBloc,
  ) : super(AddPostState.initial());

  void onMediaClicked(MediaSource mediaSource) {
    add(MediaClicked(mediaSource));
  }

  void onChangePostDescription(String value) {
    add(ChangePostDescription(value));
  }

  void onAddNewPost({
    ProgressCallback? webOnSendProgress,
  }) {
    add(SubmitPost(
      webOnSendProgress: webOnSendProgress,
    ));
  }

  void onGetPostComments(String id) {
    add(GetPostComments(id));
  }

  void onGetPostLikes(String id) {
    add(GetPostLikes(id));
  }

  void onGetMoreComments(String postId) {
    add(GetMoreComments(postId));
  }

  void onGetMoreLikes(String id) {
    add(GetMoreLikes(id));
  }

  void onSubmitNewComment({
    required String postId,
    required bool isEdit,
    String? commentId,
  }) {
    add(SubmitComment(postId: postId, isEdit: isEdit, commentId: commentId));
  }

  void onChangeCommentStr(String val) {
    add(ChangeCommentStr(val));
  }

  void onClearFailures() {
    add(ClearFailures());
  }

  void onClearState() {
    add(ClearState());
  }

  void onFocusOnComment(CommentModel comment) {
    add(FocusOnComment(comment));
  }

  void onCancelCommentFocus() {
    add(CancelCommentFocus());
  }

  void onDeleteComment({required String postId, required String commentId}) {
    add(DeleteComment(postId: postId, commentId: commentId));
  }

  void onCropImage(CroppedFile croppedFile, int index, String assetId) {
    add(CropImage(croppedFile, index, assetId));
  }

  @override
  Stream<AddPostState> mapEventToState(AddPostEvent event) async* {
    if (event is MediaClicked) {
      if (!state.selectedMedias.contains(event.mediaSource)) {
        yield state.rebuild((p0) => p0..selectedMedias!.add(event.mediaSource));
      } else {
        yield state.rebuild(
          (p0) => p0
            ..selectedMedias!.remove(event.mediaSource)
            ..croppedFilesMap!.remove(event.mediaSource.assetEntity.id),
        );
      }
    } else if (event is ChangePostDescription) {
      yield state.rebuild(
        (p0) => p0
          ..postParams!.description = event.val
          ..errorValidationDesc = false,
      );
    } else if (event is SubmitPost) {
      yield* mapToSubmitPost(webOnSendProgress: event.webOnSendProgress);
    } else if (event is GetPostComments) {
      yield* mapToGetPostComments(event.id, true);
    } else if (event is ChangeCommentStr) {
      yield state.rebuild(
        (p0) => p0
          ..commentStr = event.val
          ..errorValidationCommentStr = false,
      );
    } else if (event is SubmitComment) {
      yield* mapToSubmitNewComment(
        event.postId,
        event.isEdit,
        commentId: event.commentId,
      );
    } else if (event is ClearFailures) {
      yield state.rebuild(
        (p0) => p0
          ..commentPosted = false
          ..failure = null,
      );
    } else if (event is FocusOnComment) {
      yield state
          .rebuild((p0) => p0..focusedCommentForEdit = event.commentModel);
    } else if (event is CancelCommentFocus) {
      yield state.rebuild((p0) => p0..focusedCommentForEdit = null);
    } else if (event is DeleteComment) {
      yield* mapToDeleteComment(event);
    } else if (event is ChangingPostImages) {
      yield state.rebuild(
        (p0) => p0
          ..selectedVideos = []
          ..selectedMediasWeb = event.list
          ..croppedFilesMap = {},
      );
    } else if (event is CropImage) {
      yield state.rebuild(
        (p0) => p0
          ..croppedFilesMap![event.assetId.toString()] = {
            'file': event.croppedFile,
            'index': event.index,
            'assetId': event.assetId
          },
      );
    } else if (event is ClearState) {
      yield state.rebuild(
        (p0) => p0
          ..croppedFilesMap = {}
          ..isDeletingComment = true
          ..errorDeletingComment = false
          ..commentDeleted = false
          ..comments = []
          ..selectedMediasWeb = []
          ..selectedVideos = []
          ..commentStr = ""
          ..commentPosted = false
          ..errorPostingComment = false
          ..isPostingComment = false
          ..isGettingComments = false
          ..errorGettingComments = false
          ..commentsLoaded = false
          ..selectedMedias = []
          ..postParams = PostParams('')
          ..isSubmittingPost = false
          ..errorSubmittingPost = false
          ..errorValidationCommentStr = false
          ..postSubmitted = false,
      );
    } else if (event is GetMoreComments) {
      yield* mapToGetMoreComments(event.val);
    } else if (event is GetPostLikes) {
      yield* mapToGetUsersLikes(event.id);
    } else if (event is GetMoreLikes) {
      yield* mapToGetMoreLikes(event.val);
    } else if (event is AddVideoOnWeb) {
      yield state.rebuild(
        (p0) => p0
          ..selectedVideos!.add(event.video)
          ..selectedMediasWeb = [],
      );
    } else if (event is ChangeFocusedMediaIndex) {
      yield state.rebuild((p0) => p0..currentFocusedIndex = event.index);
    } else if (event is GetSports) {
      yield* mapToGetSports();
    } else if (event is ChangingPostSport) {
      yield state.rebuild((p0) => p0..postParams!.sport = event.val);
    }
  }

  Stream<AddPostState> mapToGetSports() async* {
    // List<SelectedSportModel> sports = await getIt<PrefsHelper>().getSelectedSports();

    final result = await sportsRepository.getProfileSports(true);
    yield* result.fold((l) async* {}, (r) async* {
      // List<String> sports = ["General"];
      // for (int i = 0; i < r.length; i++) {
      //   if(r[i].sport != null) {
      //     sports.add(r[i].sport!.name);
      //   }
      // }
      String selectedFilter = (getIt<PrefsHelper>().getSelectedFilter == null ||
              getIt<PrefsHelper>().getSelectedFilter.isEmpty)
          ? "general"
          : getIt<PrefsHelper>().getSelectedFilter;
      yield state.rebuild((p0) => p0
        ..sports = r
        ..postParams!.sport = selectedFilter);
    });

    // yield state.rebuild((p0) => p0..sports = sports);
  }

  Stream<AddPostState> mapToGetMoreLikes(String postId) async* {
    if (state.canLoadMoreLikes && state.reactions.length > 14) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingMoreLikes = true
          ..errorLoadingMoreLikes = false
          ..loadedMoreLikes = false,
      );
      final result = await postRepository.getPostReactions(
        postId,
        offset: state.paginationController.offset + 15,
        limit: state.paginationController.limit,
      );
      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..isLoadingMoreLikes = false
            ..errorLoadingMoreLikes = true
            ..loadedMoreLikes = false,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..canLoadMoreLikes = r.length > state.paginationController.limit - 1
            ..paginationController!.offset =
                state.paginationController.offset + 15
            ..reactions!.addAll(r)
            ..isLoadingMoreLikes = false
            ..errorLoadingMoreLikes = false
            ..loadedMoreLikes = true,
        );
      });
    } else {}
  }

  Stream<AddPostState> mapToGetUsersLikes(String postId) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingLikes = true
        ..errorLoadingLikes = false
        ..likesLoaded = false,
    );
    final result = await postRepository.getPostReactions(postId);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingLikes = false
          ..errorLoadingLikes = true
          ..likesLoaded = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..reactions = r
          ..canLoadMoreLikes = r.length > 14
          ..isLoadingLikes = false
          ..errorLoadingLikes = false
          ..likesLoaded = true,
      );
    });
  }

  Stream<AddPostState> mapToGetMoreComments(String postId) async* {
    if (state.canLoadMore && state.comments.length > 14) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingMoreComments = true
          ..errorLoadingMoreComments = false
          ..loadedMore = false,
      );
      final result = await postRepository.getPostComments(
        postId,
        offset: state.paginationController.offset + 15,
        limit: state.paginationController.limit,
      );
      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..isLoadingMoreComments = false
            ..errorLoadingMoreComments = true
            ..loadedMore = false,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..canLoadMore = r.length > state.paginationController.limit - 1
            ..paginationController!.offset =
                state.paginationController.offset + 15
            ..comments!.addAll(r)
            ..isLoadingMoreComments = false
            ..errorLoadingMoreComments = false,
        );
      });
    } else {}
  }

  Stream<AddPostState> mapToDeleteComment(DeleteComment event) async* {
    yield state.rebuild(
      (p0) => p0
        ..isDeletingComment = true
        ..errorDeletingComment = false
        ..commentDeleted = false,
    );
    final result = await postRepository.deleteComment(
      postId: event.postId,
      commentId: event.commentId,
    );
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isDeletingComment = false
          ..errorDeletingComment = true
          ..commentDeleted = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isDeletingComment = false
          ..errorDeletingComment = false
          ..commentDeleted = true,
      );
      yield* mapToGetPostComments(event.postId, false);
    });
  }

  Stream<AddPostState> mapToSubmitNewComment(
    String postId,
    bool isEdit, {
    String? commentId,
  }) async* {
    if (state.commentStr.isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationCommentStr = true);
    } else {
      yield state.rebuild(
        (p0) => p0
          ..isPostingComment = true
          ..errorPostingComment = false
          ..commentPosted = false,
      );
      dynamic result;
      if (isEdit) {
        result = await postRepository.editComment(
          commentId: commentId!,
          postId: postId,
          comment: state.commentStr,
        );
      } else {
        result = await postRepository.addNewComment(
          postId: postId,
          comment: state.commentStr,
        );
      }
      yield state.rebuild(
        (p0) => p0
          ..focusedCommentForEdit = null
          ..isPostingComment = false
          ..errorPostingComment = false
          ..commentPosted = true,
      );
      yield* mapToGetPostComments(postId, false);

      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..isPostingComment = false
            ..errorPostingComment = true
            ..commentPosted = false
            ..failure = l,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            // ..comments!.insert(0, r)
            ..isPostingComment = false
            ..errorPostingComment = false
            ..commentPosted = true,
        );
      });
    }
  }

  Stream<AddPostState> mapToGetPostComments(
    String id,
    bool withLoading,
  ) async* {
    yield state.rebuild(
      (p0) => p0
        ..isGettingComments = withLoading
        ..errorGettingComments = false
        ..commentsLoaded = false,
    );
    final result = await postRepository.getPostComments(id);
    final settingsResult = await settingsRepository.settings();
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isGettingComments = false
          ..errorGettingComments = true
          ..commentsLoaded = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..comments = r
          ..canLoadMore = r.length > 14
          ..isGettingComments = false
          ..errorGettingComments = false
          ..commentsLoaded = true
          ..commentStr = "",
      );
    });
  }

  Stream<AddPostState> mapToSubmitPost({
    ProgressCallback? webOnSendProgress,
  }) async* {
    if (state.postParams.description.trim().isEmpty) {
      yield state.rebuild((p0) => p0..errorValidationDesc = true);
    }
    else {
      yield state.rebuild(
        (p0) => p0
          ..isSubmittingPost = true
          ..errorSubmittingPost = false
          ..postSubmitted = false,
      );
      final result = await postRepository.create(
        params: PostParams(
          state.postParams.description,
          medias: state.selectedMedias.isEmpty ? null : state.selectedMedias,
          mediasWeb:
              state.selectedMediasWeb.isEmpty ? null : state.selectedMediasWeb,
          webVideos: state.selectedVideos,
          croppedFiles: state.croppedFilesMap,
          sport: state.postParams.sport,
        ),
        webOnSendProgress: webOnSendProgress,
        homeBloc: homeBloc,
      );

      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..isSubmittingPost = false
            ..errorSubmittingPost = true
            ..postSubmitted = false
            ..failure = l,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..isSubmittingPost = false
            ..errorSubmittingPost = false
            ..postSubmitted = true,
        );
      });
    }
  }
}

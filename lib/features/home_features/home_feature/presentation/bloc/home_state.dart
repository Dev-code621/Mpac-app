import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/presentation/controllers/pagination_controller.dart';
import 'package:video_player/video_player.dart';

part 'home_state.g.dart';

abstract class HomeState implements Built<HomeState, HomeStateBuilder> {
  HomeState._();

  factory HomeState([Function(HomeStateBuilder b) updates]) = _$HomeState;

  int get currentPageIndex;

  bool get isLoadingPosts;
  bool get errorLoadingPosts;
  bool get postsLoaded;

  List<PostModel> get posts;

  Failure? get failure;

  bool get liking;
  bool get errorLiking;
  bool get liked;

  Duration? get currentFocusedDuration;
  bool get isChangingVideoStuff;
  VideoPlayerController? get videoPlayerController;
  bool get isLoadingVideo;

  bool get isDeletingPost;
  bool get errorDeleting;
  bool get postDeleted;

  bool get canLoadMore;

  PaginationController get paginationController;

  factory HomeState.initial() {
    return HomeState((b) => b
      ..canLoadMore = true
      ..paginationController = PaginationController()
      ..isLoadingVideo = false
      ..isChangingVideoStuff = false
      ..isLoadingPosts = false
      ..errorLoadingPosts = false
      ..postsLoaded = false
      ..liking = false
      ..errorLiking = false
      ..liked = false
      ..isDeletingPost = false
      ..errorDeleting = true
      ..postDeleted = false
      ..posts = []
      ..currentPageIndex = 0,);
  }
}

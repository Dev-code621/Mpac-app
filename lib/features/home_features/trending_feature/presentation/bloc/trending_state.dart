import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/presentation/controllers/pagination_controller.dart';

part 'trending_state.g.dart';

abstract class TrendingState
    implements Built<TrendingState, TrendingStateBuilder> {
  TrendingState._();

  factory TrendingState([Function(TrendingStateBuilder b) updates]) =
      _$TrendingState;

  int get currentPageIndex;

  bool get isLoadingPosts;
  bool get errorLoadingPosts;
  bool get postsLoaded;

  List<PostModel> get posts;

  Failure? get failure;

  bool get liking;
  bool get errorLiking;
  bool get liked;

  bool get isDeletingPost;
  bool get errorDeleting;
  bool get postDeleted;

  bool get canLoadMore;

  PaginationController get paginationController;

  factory TrendingState.initial() {
    return TrendingState((b) => b..currentPageIndex = 0
      ..isLoadingPosts = false
      ..canLoadMore = true
      ..paginationController = PaginationController()
      ..errorLoadingPosts = false
      ..postsLoaded = false
      ..liking = false
      ..errorLiking = false
      ..liked = false
      ..isDeletingPost = false
      ..errorDeleting = true
      ..postDeleted = false
      ..posts = [],
    );
  }
}

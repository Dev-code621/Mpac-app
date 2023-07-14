import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/post_repository.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_event.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_state.dart';

@Injectable()
class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  final PostRepository postRepository;

  TrendingBloc(this.postRepository) : super(TrendingState.initial());

  void onGetTrendingPosts({bool? withLoading = true}) {
    add(GetTrendingPosts(withLoading));
  }

  void onLikingPost(String postId, String type, int index) {
    add(LikingPost(postId, type, index));
  }

  void onDisLikingPost(String postId, String type, int index) {
    add(DisLikingPost(postId, type, index));
  }

  void onUpdatePostCommentsNum(int index, int val) {
    add(UpdatePostCommentsNum(index, val));
  }

  void onGetMorePosts(   ) {
    add(GetMorePosts( ));
  }

  @override
  Stream<TrendingState> mapEventToState(TrendingEvent event) async* {
    if (event is GetTrendingPosts) {
      yield* mapToGetTrendingPosts(event.withLoading);
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0
        ..postsLoaded = false
        ..failure = null
        ..errorLoadingPosts = false,);
    } else if (event is LikingPost) {
      yield* mapToLikePost(event.id, event.type, event.index);
    } else if (event is DisLikingPost) {
      yield* mapToDisLikePost(event.id, event.type, event.index);
    } else if (event is DeletePost) {
      yield* mapToDeletePost(event.id);
    } else if (event is GetMorePosts) {
      yield* mapToGetMoreTrendingPosts(false);
    }
  }

  Stream<TrendingState> mapToDeletePost(String id) async* {
    yield state.rebuild((p0) => p0
      ..isDeletingPost = true
      ..errorDeleting = false
      ..postDeleted = false,);
    final result = await postRepository.deletePost(id);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..isDeletingPost = false
        ..errorDeleting = true
        ..postDeleted = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..isDeletingPost = false
        ..errorDeleting = false
        ..postDeleted = true
        ..posts!.removeWhere((element) => element.id == id),);
    });
  }

  Stream<TrendingState> mapToDisLikePost(
      String postId, String type, int index,) async* {
    yield state.rebuild((p0) => p0
      ..liking = true
      ..errorLiking = false
      ..liked = false,);
    final result = await postRepository.deleteReaction(postId);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..liking = false
        ..errorLiking = true
        ..liked = false
        ..failure = l,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..posts![index].userReaction = null
        ..posts![index].reactionsCount = state.posts[index].reactionsCount - 1
        ..liking = false
        ..errorLiking = false
        ..liked = true,);
    });
  }

  Stream<TrendingState> mapToLikePost(
      String postId, String type, int index,) async* {
    yield state.rebuild((p0) => p0
      ..liking = true
      ..errorLiking = false
      ..liked = false,);
    final result = await postRepository.addReaction(postId, type);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..liking = false
        ..errorLiking = true
        ..liked = false
        ..failure = l,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..posts![index].reactionsCount = state.posts[index].userReaction == null
            ? state.posts[index].reactionsCount =
                state.posts[index].reactionsCount + 1
            : state.posts[index].reactionsCount
        ..posts![index].userReaction = r
        ..liking = false
        ..errorLiking = false
        ..liked = true,);
    });
  }

  Stream<TrendingState> mapToGetTrendingPosts(bool? withLoading) async* {
    yield state.rebuild((p0) => p0
      ..isLoadingPosts = withLoading
      ..errorLoadingPosts = false
      ..postsLoaded = false,);
    final result = await postRepository.getPostsFeed("featured");
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..isLoadingPosts = false
        ..errorLoadingPosts = true
        ..postsLoaded = false
        ..failure = l,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..paginationController!.offset = 0
        ..canLoadMore = r.length > 14
        ..isLoadingPosts = false
        ..errorLoadingPosts = false
        ..postsLoaded = true
        ..posts = r,);
    });
  }

  Stream<TrendingState> mapToGetMoreTrendingPosts(bool? withLoading) async* {
    if (state.canLoadMore && state.posts.length > 14) {
      yield state.rebuild((p0) => p0
        ..isLoadingPosts = withLoading
        ..errorLoadingPosts = false
        ..postsLoaded = false,);
      final result = await postRepository.getPostsFeed("featured",
          offset: state.paginationController.offset + 15,
          limit: state.paginationController.limit,);
      yield* result.fold((l) async* {
        yield state.rebuild((p0) => p0
          ..isLoadingPosts = false
          ..errorLoadingPosts = true
          ..postsLoaded = false
          ..failure = l,);
      }, (r) async* {
        yield state.rebuild((p0) => p0
          ..canLoadMore = r.length > state.paginationController.limit - 1
          ..paginationController!.offset = state.paginationController.offset + 15
          ..isLoadingPosts = false
          ..errorLoadingPosts = false
          ..postsLoaded = true
          // ..posts!.addAll(oldPosts)
          ..posts!.addAll(r),
        );
      });
    } else {}
  }
}

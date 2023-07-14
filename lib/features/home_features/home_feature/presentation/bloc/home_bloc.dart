import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/repository/repos/post_repository.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_event.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_state.dart';
import 'package:video_player/video_player.dart';

@Injectable()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PostRepository postRepository;

  HomeBloc({required this.postRepository}) : super(HomeState.initial());

  void onGetFeedPosts({bool withLoading = true}) {
    add(GetFeedPosts(withLoading));
  }

  void onClearFailures() {
    add(ClearFailures());
  }

  void onGetMorePosts() {
    add(GetMorePosts());
  }

  void onEditPost(PostModel post, int index) {
    add(EditPost(post, index));
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is GetFeedPosts) {
      yield* mapToGetPostsFeed(event.withLoading);
    } else if (event is ClearFailures) {
      yield state.rebuild(
        (p0) => p0
          ..postsLoaded = false
          ..failure = null
          ..errorLoadingPosts = false
          ..isChangingVideoStuff = false,
      );
    } else if (event is LikingPost) {
      yield* mapToLikePost(event.id, event.type, event.index);
    } else if (event is DisLikingPost) {
      yield* mapToDisLikePost(event.id, event.type, event.index);
    } else if (event is ChangingPosition) {
      yield state.rebuild(
        (p0) => p0
          ..currentFocusedDuration = event.duration
          ..posts![event.index].medias[event.mediaIndex].currentPosition =
              event.duration
          ..isChangingVideoStuff = true,
      );
    } else if (event is LoadingVideo) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingVideo = event.status
          ..posts![event.index].medias[event.mediaIndex].isLoading =
              event.status
          ..isChangingVideoStuff = true,
      );
    } else if (event is LoadVideo) {
      yield state.rebuild((p0) => p0..isLoadingVideo = true);
      if (state.videoPlayerController != null) {
        state.videoPlayerController!.dispose();
      }
      yield state.rebuild((p0) => p0..videoPlayerController = null);
      VideoPlayerController videoPlayerController =
          VideoPlayerController.network(event.url);
      videoPlayerController
        ..initialize()
        ..play().then((value) async* {
          yield state.rebuild(
            (p0) => p0
              ..videoPlayerController = videoPlayerController
              ..isLoadingVideo = false,
          );
        });

      // yield state.rebuild((p0) => p0
      //   ..videoPlayerController = videoPlayerController
      //   ..isLoadingVideo = false);
    } else if (event is DeletePost) {
      yield* mapToDeletePost(event.id, event.index);
    } else if (event is GetMorePosts) {
      yield* mapToLoadMorePosts();
    } else if (event is EditPost) {
      yield state.rebuild((p0) => p0..posts![event.index] = event.post);
    }
  }

  Stream<HomeState> mapToLoadMorePosts() async* {
    if (state.canLoadMore && state.posts.length > 14) {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingPosts = false
          ..errorLoadingPosts = false
          ..postsLoaded = false,
      );
      final result = await postRepository.getPostsFeed(
        "feed",
        offset: state.paginationController.offset + 15,
        limit: state.paginationController.limit,
      );
      yield* result.fold((l) async* {
        yield state.rebuild(
          (p0) => p0
            ..isLoadingPosts = false
            ..errorLoadingPosts = true
            ..postsLoaded = false
            ..failure = l,
        );
      }, (r) async* {
        yield state.rebuild(
          (p0) => p0
            ..canLoadMore = r.length > state.paginationController.limit - 1
            ..paginationController!.offset =
                state.paginationController.offset + 15
            ..isLoadingPosts = false
            ..errorLoadingPosts = false
            ..postsLoaded = true
            ..posts!.addAll(r),
        );
      });
    }
  }

  Stream<HomeState> mapToDeletePost(String id, int index) async* {
    yield state.rebuild(
      (p0) => p0
        ..isDeletingPost = true
        ..posts!.where((element) => element.id == id).first.isDeleting = true
        ..errorDeleting = false
        ..postDeleted = false,
    );
    final result = await postRepository.deletePost(id);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isDeletingPost = false
          ..posts!.where((element) => element.id == id).first.isDeleting = false
          ..errorDeleting = true
          ..postDeleted = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isDeletingPost = false
          ..posts!.where((element) => element.id == id).first.isDeleting = false
          ..posts!.removeAt(index)
          ..errorDeleting = false
          ..postDeleted = true,
      );
    });

    yield* mapToGetPostsFeed(true);
  }

  Stream<HomeState> mapToLikePost(
    String postId,
    String type,
    int index,
  ) async* {
    yield state.rebuild(
      (p0) => p0
        ..liking = true
        ..errorLiking = false
        ..liked = false,
    );
    final result = await postRepository.addReaction(postId, type);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..liking = false
          ..errorLiking = true
          ..liked = false
          ..failure = l,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..posts![index].userReaction = r
          ..liking = false
          ..errorLiking = false
          ..liked = true,
      );
    });
  }

  Stream<HomeState> mapToDisLikePost(
    String postId,
    String type,
    int index,
  ) async* {
    yield state.rebuild(
      (p0) => p0
        ..liking = true
        ..errorLiking = false
        ..liked = false,
    );
    final result = await postRepository.deleteReaction(postId);
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..liking = false
          ..errorLiking = true
          ..liked = false
          ..failure = l,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..posts![index].userReaction = null
          ..liking = false
          ..errorLiking = false
          ..liked = true,
      );
    });
  }

  Stream<HomeState> mapToGetPostsFeed(bool withLoading) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoadingPosts = withLoading
        ..errorLoadingPosts = false
        ..postsLoaded = false,
    );
    final result = await postRepository.getPostsFeed("feed");
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingPosts = false
          ..errorLoadingPosts = true
          ..postsLoaded = false
          ..failure = l,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..isLoadingPosts = false
          ..errorLoadingPosts = false
          ..postsLoaded = true
          ..posts = r
          ..canLoadMore = r.length > 14,
      );
    });
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/error/error_view.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_event.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_state.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/media_full_screen.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/post_widget.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:pod_player/pod_player.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  final HolderBloc holderBloc;

  const HomePage({
    required this.holderBloc,
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AppLocalizations localizations;
  ScrollPhysics _physics = const AlwaysScrollableScrollPhysics();
  int currentInViewIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: BlocListener(
        bloc: BlocProvider.of<HomeBloc>(context),
        listener: (BuildContext context, HomeState state) {
          if (state.postDeleted) {}
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: BlocBuilder(
            bloc: BlocProvider.of<HomeBloc>(context),
            builder: (BuildContext context, HomeState state) {
              /// isLoadingPosts
              if (state.isLoadingPosts) {
                return Center(
                  child: SizedBox(
                    height: context.w * 0.35,
                    width: context.w * 0.35,
                    child: CircularProgressIndicator(
                      color: AppColors.logoColor,
                      strokeWidth: 1.5,
                    ),
                  ),
                );
              }

              /// errorLoadingPosts
              else if (state.errorLoadingPosts) {
                return RefreshIndicator(
                  onRefresh: () async {
                    BlocProvider.of<HomeBloc>(context).onGetFeedPosts();
                  },
                  child: Stack(
                    children: [
                      ListView(),
                      Center(
                        child: ErrorView(
                          color: AppColors.primaryColor.withOpacity(0.8),
                          onReload: () {
                            BlocProvider.of<HomeBloc>(context).onGetFeedPosts();
                          },
                          message: "Error loading posts!",
                          btnContent: localizations.retry,
                          withRefreshBtn: false,
                        ),
                      ),
                    ],
                  ),
                );
              }

              /// posts.isEmpty
              else if (state.posts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    BlocProvider.of<HomeBloc>(context).onGetFeedPosts();
                  },
                  child: Stack(
                    children: [
                      ListView(),
                      Center(
                        child: ErrorView(
                          color: AppColors.primaryColor.withOpacity(0.8),
                          onReload: () {
                            BlocProvider.of<HomeBloc>(context).onGetFeedPosts();
                          },
                          message: "Follow your friends to see their posts",
                          btnContent: localizations.retry,
                          withRefreshBtn: false,
                        ),
                      ),
                    ],
                  ),
                );
              }

              /// else
              else {
                // if (state.posts[0].medias[0].type == 'video') {
                //   state.posts[0].medias[0].videoPlayerController =
                //       VideoPlayerController.network(
                //     state.posts[0].medias[0].url,
                //     videoPlayerOptions: VideoPlayerOptions(
                //       allowBackgroundPlayback: false,
                //       mixWithOthers: true,
                //     ),
                //   )
                //         ..initialize().then((v) {
                //           state.posts[0].streamer.add({
                //             'ratio': state.posts[0].medias[0]
                //                 .videoPlayerController!.value.aspectRatio,
                //             'currentDurationInSeconds': 0
                //           });
                //           state.posts[0].medias[0].isLoading = false;
                //           state.posts[0].medias[0].videoPlayerController!
                //               .addListener(() {
                //             state.posts[0].streamer.add({
                //               'ratio': state.posts[0].medias[0]
                //                   .videoPlayerController!.value.aspectRatio,
                //               'currentDurationInSeconds': state
                //                   .posts[0]
                //                   .medias[0]
                //                   .videoPlayerController!
                //                   .value
                //                   .position
                //                   .inSeconds
                //             });
                //           });
                //         })
                //         ..setVolume(0.0);
                // }

                return NotificationListener(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      if (currentInViewIndex != -1) {
                        state.posts[currentInViewIndex].medias[0].isLoading =
                            false;
                      }
                    }

                    return true;
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<HomeBloc>(context).onGetFeedPosts();
                    },
                    child: InViewNotifierList(
                      physics: const BouncingScrollPhysics(),
                      isInViewPortCondition:
                          (deltaTop, deltaBottom, viewPortDimension) {
                        return deltaTop < (0.5 * viewPortDimension) &&
                            deltaBottom > (0.5 * viewPortDimension);
                      },
                      itemCount: state.posts.length,
                      shrinkWrap: true,
                      builder: (context, index) {
                        if (index == state.posts.length - 1 &&
                            state.posts.length > 14 &&
                            state.canLoadMore) {
                          BlocProvider.of<HomeBloc>(context).onGetMorePosts();
                        }

                        return InViewNotifierWidget(
                          id: "$index",
                          builder: (context, isInView, child) {
                            return _buildPostWidget(
                              state,
                              index,
                              context,
                              isInView,
                            );
                          },
                        );
                      },
                    ),

                    /*
                    PreloadPageView.builder(
                      preloadPagesCount: 5,
                      scrollDirection: Axis.vertical,
                      physics: const ClampingScrollPhysics(),
                      pageSnapping: false,
                      itemCount: state.posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == state.posts.length - 1 &&
                            state.posts.length > 14 &&
                            state.canLoadMore) {
                          BlocProvider.of<HomeBloc>(context).onGetMorePosts();
                        }

                        return PostWidget(_buildPostWidget(state, index, context);
                      },
                      controller: PreloadPageController(initialPage: 0),
                      onPageChanged: (int i) async {
                        if (i > 0) {
                          final int prevIndex = i - 1;

                          for (var element in state.posts[prevIndex].medias) {
                            await element.videoPlayerController?.pause();
                          }
                        }
                      },
                    ),*/
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  PostWidget _buildPostWidget(
    HomeState state,
    int index,
    BuildContext context,
    bool isInView,
  ) {
    return PostWidget(
      holderBloc: widget.holderBloc,
      isInView: isInView,
      goToFullScreen: (value) => _goToFullScreen(
        state,
        index,
      ),
      disableScrolling: () {
        setState(() {
          _physics = const NeverScrollableScrollPhysics();
        });
      },
      enableScrolling: () {
        setState(() {
          _physics = const ClampingScrollPhysics();
        });
      },
      key: ValueKey(state.posts[index].id),
      parentStream: state.posts[index].streamer.stream,
      onDisposeHorizontalList: (Map map) {
        disposeAll(state);
        if (state.posts[index].medias.isNotEmpty &&
            state.posts[index].medias[map['mediaIndex']].type == "video") {
          state.posts[index].medias[map['mediaIndex']].isLoading = true;

          state.posts[index].medias[map['mediaIndex']].isLoading = true;
          state.posts[index].medias[map['mediaIndex']].videoPlayerController =
              VideoPlayerController.network(
            state.posts[index].medias[map['mediaIndex']].url,
            videoPlayerOptions: VideoPlayerOptions(
              allowBackgroundPlayback: false,
              mixWithOthers: true,
            ),
          )
                ..initialize().then((v) {
                  state.posts[index].streamer.add({
                    'ratio': state.posts[index].medias[map['mediaIndex']]
                        .videoPlayerController!.value.aspectRatio,
                    'currentDurationInSeconds': 0
                  });

                  state.posts[index].medias[map['mediaIndex']]
                      .videoPlayerController!
                      .addListener(() {
                    state.posts[index].streamer.add({
                      'ratio': state.posts[index].medias[map['mediaIndex']]
                          .videoPlayerController!.value.aspectRatio,
                      'currentDurationInSeconds': state
                          .posts[index]
                          .medias[map['mediaIndex']]
                          .videoPlayerController!
                          .value
                          .position
                          .inSeconds
                    });
                  });
                })
                ..setVolume(0.0)
                ..play();

          state.posts[index].medias[map['mediaIndex']].isLoading = false;
        }
      },
      onLikesClicked: () {
        Navigator.pushNamed(
          context,
          AppScreens.likesPage,
          arguments: {'post': state.posts[index]},
        );
      },
      onBackFromComments: (val) {
        BlocProvider.of<HomeBloc>(context).onGetFeedPosts(withLoading: false);
      },
      postModel: state.posts[index],
      onAddLike: (type) {
        if (!state.liking) {
          BlocProvider.of<HomeBloc>(context).add(
            LikingPost(
              state.posts[index].id,
              type,
              index,
            ),
          );
        }
      },
      onDisLike: () {
        BlocProvider.of<HomeBloc>(context).add(
          DisLikingPost(
            state.posts[index].id,
            "love",
            index,
          ),
        );
      },
      onEditPost: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          AppScreens.editPostPage,
          arguments: {'post': state.posts[index]},
        ).then((value) {
          if (value != null && (value as Map)['updatedPost'] != null) {
            BlocProvider.of<HomeBloc>(context).onEditPost(
              (value)['updatedPost'] as PostModel,
              index,
            );
            setState(() {});
          }
        });
      },
      onDeletePost: () {
        BlocProvider.of<HomeBloc>(context).add(
          DeletePost(state.posts[index].id, index),
        );
      },
      isDeleting: state.posts[index].isDeleting,
    );
  }

  void _goToFullScreen(HomeState state, int initialPostIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaFullScreenView(
          holderBloc: widget.holderBloc,
          initialPostIndex: initialPostIndex,
          homeBloc: BlocProvider.of<HomeBloc>(context),
          trendingBloc: BlocProvider.of<TrendingBloc>(context),
          posts: state.posts,
        ),
      ),
    );
  }

  void disposeAll(HomeState state) {
    for (int i = 0; i < state.posts.length; i++) {
      for (int j = 0; j < state.posts[i].medias.length; j++) {
        if (state.posts[i].medias[j].videoPlayerController != null) {
          state.posts[i].medias[j].videoPlayerController!.dispose();
          state.posts[i].medias[j].videoPlayerController = null;
          state.posts[i].medias[j].isVideoPaused = false;
          state.posts[i].medias[j].isLoading = false;
          state.posts[i].medias[j].showSettings = false;
        }
      }
    }
  }

  void loadVideo(HomeState state, int index) async {
    state.posts[index].medias[0].isLoading = true;
    state.posts[index].medias[0].videoPlayerController =
        VideoPlayerController.network(
      state.posts[index].medias[0].url,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: true,
      ),
    )
          ..initialize().then((v) {
            // state.posts[index].medias[0].isLoading = false;
            state.posts[index].streamer.add({
              'ratio': state.posts[index].medias[0].videoPlayerController!.value
                  .aspectRatio,
              'currentDurationInSeconds': 0
            });
            state.posts[index].medias[0].isLoading = false;
            state.posts[index].medias[0].videoPlayerController!.addListener(() {
              state.posts[index].streamer.add({
                'ratio': state.posts[index].medias[0].videoPlayerController!
                    .value.aspectRatio,
                'currentDurationInSeconds': state.posts[index].medias[0]
                    .videoPlayerController!.value.position.inSeconds
              });
            });
          })
          ..setVolume(0.0)
          ..play();

    currentInViewIndex = index;
  }
}

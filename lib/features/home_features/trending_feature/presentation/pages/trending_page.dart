import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/error/error_view.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/media_full_screen.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/post_widget.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_bloc.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_state.dart';
import 'package:video_player/video_player.dart';

class TrendingPage extends StatefulWidget {
  final HolderBloc holderBloc;

  const TrendingPage({
    required this.holderBloc,
    Key? key,
  }) : super(key: key);

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage>
    with SingleTickerProviderStateMixin {
  final _bloc = getIt<TrendingBloc>();
  late AppLocalizations localizations;
  double aspectRatio = 1.0;
  ScrollPhysics _physics = const AlwaysScrollableScrollPhysics();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: BlocBuilder(
          bloc: BlocProvider.of<TrendingBloc>(context),
          builder: (BuildContext context, TrendingState state) {
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
                onRefresh: () {
                  BlocProvider.of<TrendingBloc>(context).onGetTrendingPosts();
                  return Future.value(true);
                },
                child: Stack(
                  children: [
                    ListView(),
                    Center(
                      child: ErrorView(
                        color: AppColors.primaryColor.withOpacity(0.8),
                        onReload: () {},
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
                onRefresh: () {
                  BlocProvider.of<TrendingBloc>(context).onGetTrendingPosts();
                  return Future.value(true);
                },
                child: Stack(
                  children: [
                    ListView(),
                    Center(
                      child: ErrorView(
                        color: AppColors.primaryColor.withOpacity(0.8),
                        onReload: () {},
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
              return RefreshIndicator(
                  onRefresh: () async {
                    BlocProvider.of<TrendingBloc>(context).onGetTrendingPosts();
                  },
                  child: InViewNotifierList(
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
                        BlocProvider.of<TrendingBloc>(context).onGetMorePosts();
                      }
                      if (state.posts[index].medias[0].type == "video") {
                        Future.delayed(
                          const Duration(milliseconds: 10),
                              () {
                            loadVideo(state, index);
                          },
                        );
                      }

                      return InViewNotifierWidget(
                        id: "$index",
                        builder: (context, isInView, child) {
                          return _buildPostWidget(
                              context, index, state, isInView);
                        },
                      );
                    },
                  )

                  /*PreloadPageView.builder(
                  preloadPagesCount: 5,
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(),
                  pageSnapping: false,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == state.posts.length - 1 &&
                        state.posts.length > 14 &&
                        state.canLoadMore) {
                      BlocProvider.of<TrendingBloc>(context).onGetMorePosts();
                    }

                    return _buildPostWidget(context, index, state);
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
                  /*
                InViewNotifierList(
                  isInViewPortCondition:
                      (double deltaTop, double deltaBottom, double vpHeight) {
                    return deltaTop < (0.5 * vpHeight) &&
                        deltaBottom > (0.5 * vpHeight);
                  },
                  itemCount: state.posts.length,
                  physics: _physics,
                  builder: (BuildContext context, int index) {
                    (index == state.posts.length - 1 &&
                            state.posts.length > 14 &&
                            state.canLoadMore)
                        ? BlocProvider.of<TrendingBloc>(context)
                            .onGetMorePosts()
                        : print('');
                    return InViewNotifierWidget(
                      id: '$index',
                      builder:
                          (BuildContext context, bool isInView, Widget? child) {
                        if (isInView) {
                          disposeAll(state);
                          if (state.posts[index].medias.isNotEmpty &&
                              state.posts[index].medias[0].type == "video") {
                            loadVideo(state, index);
                          }
                        }
                        return Column(
                          children: [
                            PostWidget(
                              goToFullScreen: (initialMediaIndex) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MediaFullScreenView(
                                      holderBloc: widget.holderBloc,
                                      initialPostIndex: index,
                                      posts: state.posts,
                                    ),
                                  ),
                                );
                              },
                              parentStream: state.posts[index].streamer.stream,
                              holderBloc: widget.holderBloc,
                              isInView: isInView,
                              disableScrolling: () {
                                setState(() {
                                  _physics =
                                      const NeverScrollableScrollPhysics();
                                });
                              },
                              enableScrolling: () {
                                setState(() {
                                  _physics =
                                      const AlwaysScrollableScrollPhysics();
                                });
                              },
                              onDisposeHorizontalList: (Map map) {
                                disposeAll(state);
                                if (state.posts[index].medias.isNotEmpty &&
                                    state.posts[index].medias[map['mediaIndex']]
                                            .type ==
                                        "video") {
                                  state.posts[index].medias[map['mediaIndex']]
                                      .isLoading = true;

                                  state.posts[index].medias[map['mediaIndex']]
                                          .videoPlayerController =
                                      VideoPlayerController.network(
                                    state.posts[index].medias[map['mediaIndex']]
                                        .url,
                                  )
                                        ..initialize().then((v) {
                                          state.posts[index].streamer.add({
                                            'ratio': state
                                                .posts[index]
                                                .medias[map['mediaIndex']]
                                                .videoPlayerController!
                                                .value
                                                .aspectRatio,
                                            'currentDurationInSeconds': 0
                                          });

                                          state
                                              .posts[index]
                                              .medias[map['mediaIndex']]
                                              .videoPlayerController!
                                              .addListener(() {
                                            state.posts[index].streamer.add({
                                              'ratio': state
                                                  .posts[index]
                                                  .medias[map['mediaIndex']]
                                                  .videoPlayerController!
                                                  .value
                                                  .aspectRatio,
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

                                  state.posts[index].medias[map['mediaIndex']]
                                      .isLoading = false;
                                }

                                // if(state.posts[i].id == map['postId']){
                                //   if(state.posts[i].medias[j].id != map['mediaId']) {
                                //     if (state.posts[i].medias[j].videoPlayerController != null) {
                                //       state.posts[i].medias[j].videoPlayerController!.dispose();
                                //     }
                                //   }
                                // } else {
                                //   if(state.posts[i].medias[j].videoPlayerController != null){
                                //     state.posts[i].medias[j].videoPlayerController!.dispose();
                                //   }
                                // }

                                // setState(() {});
                              },
                              onLikesClicked: () {
                                Navigator.pushNamed(
                                  context,
                                  AppScreens.likesPage,
                                  arguments: {'post': state.posts[index]},
                                );
                              },
                              onBackFromComments: (val) {
                                BlocProvider.of<TrendingBloc>(context)
                                    .onGetTrendingPosts(withLoading: false);
                              },
                              postModel: state.posts[index],
                              onAddLike: (type) {
                                if (!state.liking) {
                                  BlocProvider.of<TrendingBloc>(context)
                                      .onLikingPost(
                                    state.posts[index].id,
                                    type,
                                    index,
                                  );
                                }
                              },
                              onDisLike: () {
                                if (!state.liking) {
                                  BlocProvider.of<TrendingBloc>(context)
                                      .onDisLikingPost(
                                    state.posts[index].id,
                                    "love",
                                    index,
                                  );
                                }
                              },
                              onEditPost: () {},
                              onDeletePost: () {},
                              isDeleting: state.isDeletingPost,
                            ),
                            index == state.posts.length - 1
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                  )
                                : Container()
                          ],
                        );
                      },
                    );
                  },
                ),*/
                  );
            }
          },
        ),
      ),
    );
  }

  PostWidget _buildPostWidget(
    BuildContext context,
    int index,
    TrendingState state,
    bool isInView,
  ) {
    return PostWidget(
      goToFullScreen: (initialMediaIndex) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaFullScreenView(
              holderBloc: widget.holderBloc,
              homeBloc: BlocProvider.of<HomeBloc>(context),
              trendingBloc: BlocProvider.of<TrendingBloc>(context),
              fromTrending: true,
              initialPostIndex: index,
              posts: state.posts,
            ),
          ),
        );
      },
      isInView: isInView,
      parentStream: state.posts[index].streamer.stream,
      holderBloc: widget.holderBloc,
      disableScrolling: () {
        setState(() {
          _physics = const NeverScrollableScrollPhysics();
        });
      },
      enableScrolling: () {
        setState(() {
          _physics = const AlwaysScrollableScrollPhysics();
        });
      },
      onDisposeHorizontalList: (Map map) {
        disposeAll(state);
        if (state.posts[index].medias.isNotEmpty &&
            state.posts[index].medias[map['mediaIndex']].type == "video") {
          state.posts[index].medias[map['mediaIndex']].isLoading = true;

          state.posts[index].medias[map['mediaIndex']].videoPlayerController =
              VideoPlayerController.network(
            state.posts[index].medias[map['mediaIndex']].url,
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

        // if(state.posts[i].id == map['postId']){
        //   if(state.posts[i].medias[j].id != map['mediaId']) {
        //     if (state.posts[i].medias[j].videoPlayerController != null) {
        //       state.posts[i].medias[j].videoPlayerController!.dispose();
        //     }
        //   }
        // } else {
        //   if(state.posts[i].medias[j].videoPlayerController != null){
        //     state.posts[i].medias[j].videoPlayerController!.dispose();
        //   }
        // }

        // setState(() {});
      },
      onLikesClicked: () {
        Navigator.pushNamed(
          context,
          AppScreens.likesPage,
          arguments: {'post': state.posts[index]},
        );
      },
      onBackFromComments: (val) {
        BlocProvider.of<TrendingBloc>(context)
            .onGetTrendingPosts(withLoading: false);
      },
      postModel: state.posts[index],
      onAddLike: (type) {
        if (!state.liking) {
          BlocProvider.of<TrendingBloc>(context).onLikingPost(
            state.posts[index].id,
            type,
            index,
          );
        }
      },
      onDisLike: () {
        if (!state.liking) {
          BlocProvider.of<TrendingBloc>(context).onDisLikingPost(
            state.posts[index].id,
            "love",
            index,
          );
        }
      },
      onEditPost: () {},
      onDeletePost: () {},
      isDeleting: state.isDeletingPost,
    );
  }

  void disposeAll(TrendingState state) {
    for (int i = 0; i < state.posts.length; i++) {
      for (int j = 0; j < state.posts[i].medias.length; j++) {
        if (state.posts[i].medias[j].videoPlayerController != null) {
          state.posts[i].medias[j].videoPlayerController!.dispose();
        }
        state.posts[i].medias[j].videoPlayerController = null;
        state.posts[i].medias[j].isVideoPaused = false;
        state.posts[i].medias[j].isLoading = false;
        state.posts[i].medias[j].showSettings = false;
      }
    }
  }

  void loadVideo(TrendingState state, int index) async {
    state.posts[index].medias[0].isLoading = true;
    state.posts[index].medias[0].videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(state.posts[index].medias[0].url))
          ..initialize().then((v) {
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
    // state.posts[index].medias[0].videoPlayerController!
    //   ..play();
    /*.then((value) {
        print(
            'state.posts[index].medias[0].videoPlayerController = ${state.posts[index].medias[0].videoPlayerController!.value.size.aspectRatio}');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          aspectRatio = state.posts[index].medias[0].videoPlayerController!
              .value.size.aspectRatio;
          state.posts[index].medias[0].isLoading = false;
        });
      });*/
    // setState(() {
    //   aspectRatio = state.posts[index].medias[0].videoPlayerController!.value.size.aspectRatio;
    // });

    // state.posts[index].medias[0].isLoading = true;
    //
    // BlocProvider.of<HomeBloc>(context)
    //     .add(LoadingVideo(mediaIndex: 0, index: index, status: true));
    //
    // state.posts[index].medias[0].videoPlayerController =
    //     await VideoPlayerController.network(state.posts[index].medias[0].url)
    //       ..initialize().then((value) => {
    //             state.posts[index].medias[0].videoPlayerController!
    //                 .addListener(() {
    //               if (state.posts[index].medias[0].videoPlayerController!.value
    //                   .isInitialized) {
    //                 //checking the duration and position every time
    //                 // state.posts[index].medias[0].currentPosition = state.posts[index].medias[0].videoPlayerController!.value.position;
    //                 // BlocProvider.of<HomeBloc>(context).add(ChangingPosition(
    //                 //     mediaIndex: 0,
    //                 //     index: index,
    //                 //     duration: state.posts[index].medias[0]
    //                 //         .videoPlayerController!.value.position));
    //
    //                 BlocProvider.of<HomeBloc>(context)
    //                     .add(LoadingVideo(mediaIndex: 0, index: index, status: false));
    //
    //                 if ((state.posts[index].medias[0].videoPlayerController!
    //                         .value.duration ==
    //                     state.posts[index].medias[0].videoPlayerController!
    //                         .value.position)) {
    //                   // The video is end
    //                 }
    //               }
    //             })
    //           })
    //       ..play();

    // state.posts[index].medias[0].isLoading = false;

    // SchedulerBinding.instance
    //     .addPostFrameCallback((_) => setState(() {
    //
    // }));
  }
}

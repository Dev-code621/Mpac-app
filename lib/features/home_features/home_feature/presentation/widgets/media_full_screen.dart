import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_event.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/full_screen_post.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class FullScreenPostParams {
  final PostModel post;
  final int initialMediaIndex;
  final String heroId;
  final Function(String) onAddLike;
  final Function onDisLike;
  final Function(Map) onDisposeHorizontalList;
  final bool withClickOnProfile;
  final Function(int) onBackFromComments;
  final Function onLikesClicked;
  final Function onEditPost;
  final Function onDeletePost;

  const FullScreenPostParams({
    required this.post,
    required this.initialMediaIndex,
    required this.heroId,
    required this.onAddLike,
    required this.onDisLike,
    required this.onDisposeHorizontalList,
    required this.withClickOnProfile,
    required this.onBackFromComments,
    required this.onLikesClicked,
    required this.onEditPost,
    required this.onDeletePost,
  });
}

class MediaFullScreenView extends StatefulWidget {
  final List<PostModel> posts;
  final int initialPostIndex;
  final HolderBloc holderBloc;
  final TrendingBloc trendingBloc;
  final HomeBloc homeBloc;
  final bool fromTrending;

  const MediaFullScreenView({
    required this.posts,
    required this.initialPostIndex,
    required this.trendingBloc,
    required this.homeBloc,
    required this.holderBloc,
    this.fromTrending = false,
    Key? key,
  }) : super(key: key);

  @override
  State<MediaFullScreenView> createState() => _MediaFullScreenViewState();
}

class _MediaFullScreenViewState extends State<MediaFullScreenView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AppLocalizations localizations;
  late final TransformationController controller;
  late final AnimationController animationController;
  late final PreloadPageController _controller;
  bool _firstTime = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      localizations = AppLocalizations.of(context)!;

      _controller = PreloadPageController(initialPage: widget.initialPostIndex);

      // Future.delayed(const Duration(milliseconds: 0), () {
      //   _pageController.animateToPage(
      //     widget.initialPostIndex,
      //     duration: const Duration(
      //       microseconds: 1,
      //     ),
      //     curve: Curves.ease,
      //   );
      // });

      _firstTime = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HolderBloc, HolderState>(
      bloc: widget.holderBloc,
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(),
          ),
          bottomNavigationBar: _bottomNavigationBar(state),
          body: Stack(
            fit: StackFit.expand,
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: PreloadPageView.builder(
                  itemCount: widget.posts.length,
                  preloadPagesCount: 1,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return FullScreenPost(
                      holderBloc: widget.holderBloc,
                      trendingBloc: widget.trendingBloc,
                      homeBloc: widget.homeBloc,
                      fromTrending: widget.fromTrending,
                      heroId: widget.posts[index].id,
                      initialMediaIndex: 0,
                      post: widget.posts[index],
                      withClickOnProfile: true,
                      onDisposeHorizontalList: (Map map) {
                        if (widget.posts[index].medias.isNotEmpty &&
                            widget.posts[index].medias[map['mediaIndex']]
                                    .type ==
                                "video") {
                          widget.posts[index].medias[map['mediaIndex']]
                              .isLoading = true;

                          widget.posts[index].medias[map['mediaIndex']]
                              .isLoading = true;
                          widget.posts[index].medias[map['mediaIndex']]
                                  .videoPlayerController =
                              VideoPlayerController.network(
                            widget.posts[index].medias[map['mediaIndex']].url,
                            videoPlayerOptions: VideoPlayerOptions(
                              allowBackgroundPlayback: false,
                              mixWithOthers: true,
                            ),
                          )
                                ..initialize().then((v) {
                                  widget.posts[index].streamer.add({
                                    'ratio': widget
                                        .posts[index]
                                        .medias[map['mediaIndex']]
                                        .videoPlayerController!
                                        .value
                                        .aspectRatio,
                                    'currentDurationInSeconds': 0
                                  });

                                  widget.posts[index].medias[map['mediaIndex']]
                                      .videoPlayerController!
                                      .addListener(() {
                                    widget.posts[index].streamer.add({
                                      'ratio': widget
                                          .posts[index]
                                          .medias[map['mediaIndex']]
                                          .videoPlayerController!
                                          .value
                                          .aspectRatio,
                                      'currentDurationInSeconds': widget
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

                          widget.posts[index].medias[map['mediaIndex']]
                              .isLoading = false;
                        }
                      },
                      onLikesClicked: () {
                        Navigator.pushNamed(
                          context,
                          AppScreens.likesPage,
                          arguments: {'post': widget.posts[index]},
                        );
                      },
                      onBackFromComments: (val) {
                        BlocProvider.of<HomeBloc>(context)
                            .onGetFeedPosts(withLoading: false);
                      },
                      onAddLike: (type) {
                        if (widget.fromTrending) {
                          BlocProvider.of<TrendingBloc>(context).onLikingPost(
                            widget.posts[index].id,
                            type,
                            index,
                          );
                        } else {
                          BlocProvider.of<HomeBloc>(context).add(
                            LikingPost(
                              widget.posts[index].id,
                              type,
                              index,
                            ),
                          );
                        }
                      },
                      onDisLike: () {
                        if (widget.fromTrending) {
                          BlocProvider.of<TrendingBloc>(context)
                              .onDisLikingPost(
                            widget.posts[index].id,
                            "love",
                            index,
                          );
                        } else {
                          BlocProvider.of<HomeBloc>(context).add(
                            DisLikingPost(
                              widget.posts[index].id,
                              "love",
                              index,
                            ),
                          );
                        }
                      },
                      onEditPost: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppScreens.editPostPage,
                          arguments: {'post': widget.posts[index]},
                        ).then((value) {
                          if (value != null &&
                              (value as Map)['updatedPost'] != null) {
                            BlocProvider.of<HomeBloc>(context).onEditPost(
                                (value)['updatedPost'] as PostModel, index);
                            setState(() {});
                          }
                        });
                      },
                      onDeletePost: () {
                        BlocProvider.of<HomeBloc>(context).add(
                          DeletePost(widget.posts[index].id, index),
                        );
                      },
                    );
                  },
                  controller: _controller,
                  onPageChanged: (int i) async {
                    if (i > 0) {
                      final int prevIndex = i - 1;

                      for (var element in widget.posts[prevIndex].medias) {
                        if(element.type == "video") {
                          await element.videoPlayerController?.pause();
                        }
                      }
                    }
                  },
                ),

                /* PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemBuilder: (context, index) => FullScreenPost(
                    holderBloc: widget.holderBloc,
                    heroId: widget.posts[index].id,
                    initialMediaIndex: 0,
                    post: widget.posts[index],
                    withClickOnProfile: true,
                    onDisposeHorizontalList: (Map map) {
                      if (widget.posts[index].medias.isNotEmpty &&
                          widget.posts[index].medias[map['mediaIndex']].type ==
                              "video") {
                        widget.posts[index].medias[map['mediaIndex']]
                            .isLoading = true;

                        widget.posts[index].medias[map['mediaIndex']]
                            .isLoading = true;
                        widget.posts[index].medias[map['mediaIndex']]
                                .videoPlayerController =
                            VideoPlayerController.network(
                          widget.posts[index].medias[map['mediaIndex']].url,
                          videoPlayerOptions: VideoPlayerOptions(
                            allowBackgroundPlayback: false,
                            mixWithOthers: true,
                          ),
                        )
                              ..initialize().then((v) {
                                widget.posts[index].streamer.add({
                                  'ratio': widget
                                      .posts[index]
                                      .medias[map['mediaIndex']]
                                      .videoPlayerController!
                                      .value
                                      .aspectRatio,
                                  'currentDurationInSeconds': 0
                                });

                                widget.posts[index].medias[map['mediaIndex']]
                                    .videoPlayerController!
                                    .addListener(() {
                                  widget.posts[index].streamer.add({
                                    'ratio': widget
                                        .posts[index]
                                        .medias[map['mediaIndex']]
                                        .videoPlayerController!
                                        .value
                                        .aspectRatio,
                                    'currentDurationInSeconds': widget
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

                        widget.posts[index].medias[map['mediaIndex']]
                            .isLoading = false;
                      }
                    },
                    onLikesClicked: () {
                      Navigator.pushNamed(
                        context,
                        AppScreens.likesPage,
                        arguments: {'post': widget.posts[index]},
                      );
                    },
                    onBackFromComments: (val) {
                      BlocProvider.of<HomeBloc>(context)
                          .onGetFeedPosts(withLoading: false);
                    },
                    onAddLike: (type) {
                      BlocProvider.of<HomeBloc>(context).add(
                        LikingPost(
                          widget.posts[index].id,
                          type,
                          index,
                        ),
                      );
                    },
                    onDisLike: () {
                      BlocProvider.of<HomeBloc>(context).add(
                        DisLikingPost(
                          widget.posts[index].id,
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
                        arguments: {'post': widget.posts[index]},
                      ).then((value) {
                        if (value != null &&
                            (value as Map)['updatedPost'] != null) {
                          BlocProvider.of<HomeBloc>(context).onEditPost(
                              (value)['updatedPost'] as PostModel, index);
                          setState(() {});
                        }
                      });
                    },
                    onDeletePost: () {
                      BlocProvider.of<HomeBloc>(context).add(
                        DeletePost(widget.posts[index].id, index),
                      );
                    },
                  ),
                  itemCount: widget.posts.length,
                ),*/
              ),
              _buildBackButton(context),
            ],
          ),
        );
      },
    );
  }

  Positioned _buildBackButton(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Align(
        alignment: localizations.localeName == "ar"
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: CustomBackButton(
          localeName: localizations.localeName,
          backgroundColor: Colors.transparent,
          onBackClicked: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _bottomNavigationBar(HolderState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.11 +
          MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/home.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/home.svg',
                  tabIndex: homeTab,
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/trending.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/trending.svg',
                  tabIndex: trendingTab,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.085,
                  width: MediaQuery.of(context).size.height * 0.085,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.logoColor,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppScreens.addNewPostPage,
                      );
                    },
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/inbox.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/inbox.svg',
                  tabIndex: inboxTab,
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/profile.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/profile.svg',
                  tabIndex: profileTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tabWidget({
    required HolderState state,
    required svgPath,
    required inActiveSvgPath,
    required int tabIndex,
  }) {
    return InkWell(
      onTap: () => _navigateTo(tabIndex),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 6.h,
            height: 6.h,
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    state.currentPageIndex == tabIndex
                        ? svgPath
                        : inActiveSvgPath,
                    height: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.03
                        : context.h * 0.027,
                  ),
                ),
              ],
            ),
          ),
          Text(
            getTitleBasedOnIndex(tabIndex),
            style: TextStyle(
              fontSize:
                  Dimensions.checkKIsWeb(context) ? context.h * 0.026 : 11.sp,
              color: state.currentPageIndex == tabIndex
                  ? Colors.white
                  : AppColors.unSelectedWidgetColor,
            ),
          )
        ],
      ),
    );
  }

  String getTitleBasedOnIndex(int index) {
    switch (index) {
      case 0:
        return localizations.home;
      case 1:
        return localizations.trending;
      case 2:
        return localizations.inbox;
      default:
        return localizations.profile;
    }
  }

  void _navigateTo(int index) {
    Navigator.of(context).pop();
    widget.holderBloc.onChangePageIndex(index);
  }
}

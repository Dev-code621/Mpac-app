import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/image_viewer_page_2.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/video_viewer_page_2.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FullScreenPost extends StatefulWidget {
  final PostModel post;
  final int initialMediaIndex;
  final String heroId;
  final HolderBloc holderBloc;
  final TrendingBloc trendingBloc;
  final HomeBloc homeBloc;
  final Function(String) onAddLike;
  final Function onDisLike;
  final Function(Map) onDisposeHorizontalList;
  final bool withClickOnProfile;
  final Function(int) onBackFromComments;
  final Function onLikesClicked;
  final Function onEditPost;
  final Function onDeletePost;
  final bool fromTrending;

  const FullScreenPost({
    required this.post,
    required this.initialMediaIndex,
    required this.holderBloc,
    required this.trendingBloc,
    required this.homeBloc,
    required this.heroId,
    required this.onAddLike,
    required this.onBackFromComments,
    required this.onLikesClicked,
    required this.onDisLike,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onDisposeHorizontalList,
    this.withClickOnProfile = true,
    this.fromTrending = false,
    Key? key,
  }) : super(key: key);

  @override
  State<FullScreenPost> createState() => _FullScreenPostState();
}

class _FullScreenPostState extends State<FullScreenPost>
    with SingleTickerProviderStateMixin {
  late final List<Widget> _pages;
  final PageController _pageController = PageController();
  late final AppLocalizations localizations;
  late final TransformationController controller;
  late final AnimationController animationController;
  ScrollPhysics _physics = const ClampingScrollPhysics();
  bool _firstTime = true;
  int mediaIndex = -1, _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      localizations = AppLocalizations.of(context)!;

      _pages = widget.post.medias.map((e) {
        mediaIndex += 1;

        if (e.type == "video") {
          return VideoViewerPage2(
            post: widget.post,
            mediaIndex: mediaIndex,
            holderBloc: widget.holderBloc,
            heroId: widget.heroId,
            onAddLike: widget.onAddLike,
            onBackFromComments: widget.onBackFromComments,
            onLikesClicked: widget.onLikesClicked,
            onDisLike: widget.onDisLike,
            onEditPost: widget.onEditPost,
            onDeletePost: widget.onDeletePost,
            onDisposeHorizontalList: widget.onDisposeHorizontalList,
          );
        }

        return ImageViewerPage2(
          post: widget.post,
          mediaIndex: mediaIndex,
          holderBloc: widget.holderBloc,
          heroId: widget.heroId,
          onAddLike: widget.onAddLike,
          onBackFromComments: widget.onBackFromComments,
          onLikesClicked: widget.onLikesClicked,
          onDisLike: widget.onDisLike,
          onEditPost: widget.onEditPost,
          onDeletePost: widget.onDeletePost,
          onDisposeHorizontalList: widget.onDisposeHorizontalList,
          disableScrolling: _disableScrolling,
          enableScrolling: _enableScrolling,
        );
      }).toList();

      Future.delayed(const Duration(milliseconds: 0), () {
        _pageController.animateToPage(
          widget.initialMediaIndex,
          duration: const Duration(
            microseconds: 1,
          ),
          curve: Curves.ease,
        );
      });

      _firstTime = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HolderBloc, HolderState>(
      bloc: widget.holderBloc,
      builder: (context, state) {
        return Stack(
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
              child: PageView(
                physics: _physics,
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                children: _pages,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            _pages.length == 1
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: _pages.length * 18,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                          color: Colors.grey.withOpacity(0.65),
                        ),
                        child: SizedBox(
                          height: 18,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == index
                                        ? AppColors.primaryColor
                                        : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            _buildPostInfo(context),
          ],
        );
      },
    );
  }

  Positioned _buildPostInfo(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 5,
      left: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAuthorAndDescription(context),
            _buildCommentsAndLikes(context)
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsAndLikes(BuildContext context) {
    if (widget.fromTrending) {
      return BlocBuilder(
        bloc: widget.trendingBloc,
        builder: (context, state) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppScreens.commentsPage,
                    arguments: {
                      'postId': widget.post.id,
                      'commentsCount': widget.post.commentsCount.toString()
                    },
                  ).then((value) {
                    widget.onBackFromComments(
                      (value as Map)['comments_length'],
                    );
                  });
                },
                child: SvgPicture.asset(
                  'assets/images/icons/comments.svg',
                  color: Colors.white,
                  width: !Dimensions.checkKIsWebMobile(context)
                      ? context.w * 0.03
                      : context.w * 0.08,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                widget.post.commentsCount.toString(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: Dimensions.checkKIsWeb(context)
                      ? context.h * 0.025
                      : 10.sp,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  widget.post.showReactions = false;
                  (context as Element).markNeedsBuild();
                  if (widget.post.userReaction != null) {
                    widget.onDisLike();
                  } else {
                    widget.onAddLike("love");
                  }
                },
                onLongPress: () {
                  widget.post.showReactions = !widget.post.showReactions;
                  (context as Element).markNeedsBuild();
                },
                child: getReactionWidget(context),
              ),
              const SizedBox(
                width: 8,
              ),
              InkWell(
                onTap: () {
                  widget.onLikesClicked();
                },
                child: Text(
                  "${widget.post.reactionsCount}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.025
                        : 10.sp,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return BlocBuilder(
        bloc: widget.homeBloc,
        builder: (context, state) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppScreens.commentsPage,
                    arguments: {
                      'postId': widget.post.id,
                      'commentsCount': widget.post.commentsCount.toString()
                    },
                  ).then((value) {
                    widget.onBackFromComments(
                      (value as Map)['comments_length'],
                    );
                  });
                },
                child: SvgPicture.asset(
                  'assets/images/icons/comments.svg',
                  color: Colors.white,
                  width: !Dimensions.checkKIsWebMobile(context)
                      ? context.w * 0.03
                      : context.w * 0.08,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                widget.post.commentsCount.toString(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: Dimensions.checkKIsWeb(context)
                      ? context.h * 0.025
                      : 10.sp,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  widget.post.showReactions = false;
                  (context as Element).markNeedsBuild();
                  if (widget.post.userReaction != null) {
                    widget.onDisLike();
                  } else {
                    widget.onAddLike("love");
                  }
                },
                onLongPress: () {
                  widget.post.showReactions = !widget.post.showReactions;
                  (context as Element).markNeedsBuild();
                },
                child: getReactionWidget(context),
              ),
              const SizedBox(
                width: 8,
              ),
              InkWell(
                onTap: () {
                  widget.onLikesClicked();
                },
                child: Text(
                  "${widget.post.reactionsCount}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.025
                        : 10.sp,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Column _buildAuthorAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: Dimensions.checkKIsWeb(context)
                  ? context.w * 0.05
                  : context.w * 0.08,
              width: Dimensions.checkKIsWeb(context)
                  ? context.w * 0.05
                  : context.w * 0.08,
              decoration: widget.post.owner.image == null
                  ? BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      shape: BoxShape.circle,
                    )
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.post.owner.image!,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
              child: widget.post.owner.image == null
                  ? Icon(
                      Icons.person,
                      color: Colors.grey.withOpacity(0.5),
                    )
                  : Container(),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.post.owner.username == null
                  ? "-"
                  : widget.post.owner.username!,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.025 : 10.sp,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.post.description,
          style: TextStyle(
            color: Colors.white,
            fontSize:
                Dimensions.checkKIsWeb(context) ? context.h * 0.025 : 10.sp,
          ),
        ),
      ],
    );
  }

  void _enableScrolling() {
    setState(() {
      _physics = const ClampingScrollPhysics();
    });
  }

  void _disableScrolling() {
    setState(() {
      _physics = const NeverScrollableScrollPhysics();
    });
  }

  Widget getReactionWidget(BuildContext context) {
    if (widget.post.userReaction == null) {
      return Icon(
        Icons.favorite_border,
        color: Colors.white,
        size: !Dimensions.checkKIsWebMobile(context)
            ? context.w * 0.032
            : context.w * 0.09,
      );
    } else {
      switch (widget.post.userReaction!.type) {
        case "like":
          return Image.asset(
            'assets/images/reactions/ic_like_fill.png',
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.032
                : context.w * 0.065,
          );
        case "love":
          return Icon(
            Icons.favorite,
            color: Colors.red,
            size: !Dimensions.checkKIsWebMobile(context)
                ? context.w * 0.032
                : context.w * 0.09,
          );
        case "sad":
          return Image.asset(
            'assets/images/reactions/sad2.png',
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.032
                : context.w * 0.065,
          );
        case "angry":
          return Image.asset(
            'assets/images/reactions/angry2.png',
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.032
                : context.w * 0.065,
          );
        case "laugh":
          return Image.asset(
            'assets/images/reactions/haha2.png',
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.032
                : context.w * 0.065,
          );
        default:
          return Image.asset(
            'assets/images/reactions/wow2.png',
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.032
                : context.w * 0.065,
          );
      }
    }
  }
}

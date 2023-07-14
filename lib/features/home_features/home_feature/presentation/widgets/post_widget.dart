import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/octicon.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/custom_date_time.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/dialogs/custom_dialog.dart';
import 'package:mpac_app/core/utils/widgets/sheets/edit_delete_bottom_sheet.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_event.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_state.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/recent_comment_widget.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/video_viewer_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:ui' as ui;
// import 'dart:html';

class PostWidget extends StatefulWidget {
  final PostModel postModel;
  final HolderBloc holderBloc;
  final Function(String) onAddLike;
  final Function onDisLike;
  final Function(Map) onDisposeHorizontalList;
  final bool withClickOnProfile;
  final Function(int) onBackFromComments;
  final Function onLikesClicked;
  final Function onEditPost;
  final Function onDeletePost;
  final bool isDeleting;
  final Stream<Map<String, dynamic>>? parentStream;
  final ui.VoidCallback disableScrolling, enableScrolling;
  final ValueChanged<int> goToFullScreen;
  final bool isInView;

  const PostWidget({
    required this.postModel,
    required this.onAddLike,
    required this.holderBloc,
    required this.onBackFromComments,
    required this.onLikesClicked,
    required this.onDisLike,
    required this.onEditPost,
    required this.onDeletePost,
    required this.isDeleting,
    required this.onDisposeHorizontalList,
    required this.enableScrolling,
    required this.disableScrolling,
    required this.goToFullScreen,
    required this.isInView,
    this.withClickOnProfile = true,
    this.parentStream,
    Key? key,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  late TransformationController controller;
  late AnimationController animationController;
  late final double maxPostHeight, minPostHeight;
  ScrollPhysics _physics = const ClampingScrollPhysics();
  Animation<Matrix4?>? animation;
  // OverlayEntry? entry;
  double ratios = -1;
  int currentDurationInSeconds = -1;
  late double _currentMediaWidth, _currentMediaHeight;
  bool _firstTime = true;
  BoxFit _boxFit = BoxFit.fitWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      controller = TransformationController();
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      )..addListener(() => controller.value = animation!.value!);

      minPostHeight = 100.sp;
      maxPostHeight = context.h * 0.55;

      _calculateMediaWidgetWidthAndHeight(0, context, false);

      // if (widget.postModel.medias[0].type == "video") {
      //   Future.delayed(
      //     const Duration(milliseconds: 10),
      //     () {
      //       loadVideo(0);
      //     },
      //   );
      // }

      _firstTime = false;
    }
  }

  @override
  void initState() {
    super.initState();
    listenToStream();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.postModel.showReactions = false;
        (context as Element).markNeedsBuild();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    left: kIsWeb ? 5 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.withClickOnProfile &&
                          getIt<PrefsHelper>().userInfo().id !=
                              widget.postModel.ownerId) {
                        Navigator.pushNamed(
                          context,
                          AppScreens.profilePage,
                          arguments: {
                            'profile_id': widget.postModel.owner.id,
                            'withAppBar': true,
                            'flowCalled': "outside"
                          },
                        );
                      } else if (getIt<PrefsHelper>().userInfo().id ==
                          widget.postModel.ownerId) {
                        widget.holderBloc.add(ChangePageIndex(3));
                        // Navigator.pushNamed(
                        //   context,
                        //   AppScreens.profilePage,
                        //   arguments: {
                        //     'profile_id': widget.postModel.ownerId,
                        //     'withAppBar': true,
                        //     'flowCalled': "outside"
                        //   },
                        // );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: Dimensions.checkKIsWeb(context)
                                  ? context.w * 0.05
                                  : context.w * 0.1,
                              width: Dimensions.checkKIsWeb(context)
                                  ? context.w * 0.05
                                  : context.w * 0.1,
                              decoration: widget.postModel.owner.image == null
                                  ? BoxDecoration(
                                      color: Colors.grey.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    )
                                  : BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          widget.postModel.owner.image!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              child: widget.postModel.owner.image == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey.withOpacity(0.5),
                                    )
                                  : Container(),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.postModel.owner.firstName == null
                                        ? "-"
                                        : "${widget.postModel.owner.firstName!} ${widget.postModel.owner.lastName!}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Dimensions.checkKIsWeb(context)
                                          ? context.h * 0.025
                                          : 10.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CustomDateTime.readableDate(
                                      widget.postModel.createdAt,
                                      full: false,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            widget.isDeleting
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      right: 6.0,
                                      left: 6.0,
                                    ),
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                  )
                                : widget.postModel.ownerId ==
                                        getIt<PrefsHelper>().userInfo().id
                                    ? GestureDetector(
                                        onTap: () {
                                          _onClickOnMoreIcon(
                                            context,
                                            widget.postModel.ownerId,
                                          );
                                        },
                                        child: const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Icon(
                                            Icons.more_horiz,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Container()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    minHeight: minPostHeight,
                    maxHeight: maxPostHeight,
                  ),
                  height: _currentMediaHeight,
                  width: double.infinity,
                  child: _getMediasWidget(context),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.postModel.owner.username == null
                                    ? "-"
                                    : widget.postModel.owner.username!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Dimensions.checkKIsWeb(context)
                                      ? context.h * 0.025
                                      : 10.sp,
                                ),
                              ),
                              // Text(
                              //   "Football Player",
                              //   style: TextStyle(
                              //       color: AppColors.secondaryFontColor,
                              //       fontSize: 9.sp),
                              // ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppScreens.commentsPage,
                                    arguments: {
                                      'postId': widget.postModel.id,
                                      'commentsCount': widget
                                          .postModel.commentsCount
                                          .toString()
                                    },
                                  ).then((value) {
                                    widget.onBackFromComments(
                                      (value as Map)['comments_length'],
                                    );
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/images/icons/comments.svg',
                                  color: Colors.white.withOpacity(0.7),
                                  width: Dimensions.checkKIsWeb(context)
                                      ? context.w * 0.03
                                      : context.w * 0.06,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                widget.postModel.commentsCount.toString(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: Dimensions.checkKIsWeb(context)
                                      ? context.h * 0.025
                                      : 10.sp,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              InkWell(
                                onTap: () {
                                  widget.onLikesClicked();
                                },
                                child: Text(
                                  "${widget.postModel.reactionsCount} Likes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Dimensions.checkKIsWeb(context)
                                        ? context.h * 0.025
                                        : 10.sp,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.postModel.showReactions = false;
                                  (context as Element).markNeedsBuild();
                                  if (widget.postModel.userReaction != null) {
                                    widget.onDisLike();
                                  } else {
                                    widget.onAddLike("love");
                                  }
                                },
                                onLongPress: () {
                                  widget.postModel.showReactions =
                                      !widget.postModel.showReactions;
                                  (context as Element).markNeedsBuild();
                                },
                                child: _getReactionWidget(context),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.postModel.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.checkKIsWeb(context)
                              ? context.h * 0.025
                              : 10.sp,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      ListView.builder(
                        itemCount: widget.postModel.recentComments.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return RecentCommentWidget(
                            commentModel:
                                widget.postModel.recentComments[index],
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getMediasWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.zero,
      child: widget.postModel.medias.isEmpty
          ? Container()
          : Hero(
              tag: widget.postModel.id,
              child: SizedBox(
                height: _currentMediaHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          ui.PointerDeviceKind.touch,
                          ui.PointerDeviceKind.mouse,
                          ui.PointerDeviceKind.trackpad,
                        },
                      ),
                      child: PageView(
                        physics: _physics,
                        onPageChanged: (index) async {
                          widget.postModel.currentFocusedIndex = index;
                          currentDurationInSeconds = 0;

                          _calculateMediaWidgetWidthAndHeight(
                            index,
                            context,
                            true,
                          );

                          (context as Element).markNeedsBuild();
                          if (!kIsWeb) {
                            widget.onDisposeHorizontalList({
                              'postId': widget.postModel.id,
                              'mediaId': widget.postModel.medias[index].id,
                              'mediaIndex': index
                            });
                          }

                          if (widget.postModel.medias[index].type == "video") {
                            loadVideo(index);
                          }
                        },
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                          widget.postModel.medias.length,
                          (index) {
                            // ignore: undefined_prefixed_name
                            // ui.platformViewRegistry.registerViewFactory(
                            //     '$index',
                            //         (int viewId) => IFrameElement()
                            //       // ..style.width = '50'
                            //         ..height = "100%"
                            //           ..width = "100%"
                            //       // ..style.height = '50'
                            //       ..src = widget
                            //           .postModel.medias[index].url
                            //       ..style.border = 'none',
                            // );

                            return widget.postModel.medias[index].type ==
                                    "video"
                                ? GestureDetector(
                                    onTap: () {
                                      _goFullScreen(context, index);
                                    },
                                    child: _getThumbnailVideoWidget(
                                      context,
                                      widget.postModel.medias[index].url,
                                      index,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      _goFullScreen(context, index);
                                    },
                                    child: kIsWeb
                                        ? SizedBox(
                                            height: _currentMediaHeight,
                                            width: double.infinity,
                                            child: Image.network(
                                              widget.postModel.medias[index].url,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress){
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    color: AppColors.primaryColor,
                                                    value: loadingProgress.expectedTotalBytes != null ?
                                                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              // viewType: '$index',
                                            ),
                                          )
                                        : _getZoomableImageWidget(index),
                                  );
                          },
                        ),
                      ),
                    ),
                    widget.postModel.medias.length == 1
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: widget.postModel.medias.length * 18,
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
                                      widget.postModel.medias.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: 5,
                                          width: 5,
                                          decoration: BoxDecoration(
                                            color: widget.postModel
                                                        .currentFocusedIndex ==
                                                    index
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
                    widget.postModel.showReactions
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: _renderIcons(context),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
    );
  }

  void _goFullScreen(BuildContext context, int index) {
    widget.goToFullScreen(
      // FullScreenPostParams(
      //   post: widget.postModel,
      //   initialMediaIndex: index,
      //   heroId: widget.postModel.medias[index].id,
      //   onAddLike: widget.onAddLike,
      //   onBackFromComments: widget.onBackFromComments,
      //   onDeletePost: widget.onDeletePost,
      //   onDisLike: widget.onDisLike,
      //   onDisposeHorizontalList: widget.onDisposeHorizontalList,
      //   onEditPost: widget.onEditPost,
      //   onLikesClicked: widget.onLikesClicked,
      //   withClickOnProfile: widget.withClickOnProfile,
      // ),
      index,
    );
  }

  Widget _getZoomableImageWidget(int index) {
    return Listener(
      onPointerPanZoomStart: (_) {
        _disableScrolling();
      },
      onPointerPanZoomEnd: (_) {
        _enableScrolling();
      },
      child: InteractiveViewer(
        panEnabled: false,
        transformationController: controller,
        clipBehavior: Clip.none,
        child: SizedBox(
          height: _currentMediaHeight + 50,
          width: double.infinity,
          child: Image.network(
            widget.postModel.medias[index].url,
            fit: _boxFit,
          ),
        ),
        onInteractionEnd: (details) {
          _resetInteraction(details);
        },
      ),
    );
  }

  Widget _getReactionWidget(BuildContext context) {
    if (widget.postModel.userReaction == null) {
      return Icon(
        Icons.favorite_border,
        color: Colors.white,
        size: Dimensions.checkKIsWeb(context)
            ? context.w * 0.032
            : context.w * 0.065,
      );
    } else {
      switch (widget.postModel.userReaction!.type) {
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
            size: Dimensions.checkKIsWeb(context)
                ? context.w * 0.032
                : context.w * 0.065,
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

  Widget _renderIcons(BuildContext context) {
    return Container(
      height: 150.0,
      color: Colors.black,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: 300.0,
              margin: const EdgeInsets.only(left: 10, top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // icon like
                  Transform.scale(
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: () {
                        widget.postModel.showReactions = false;
                        (context as Element).markNeedsBuild();
                        widget.onAddLike("like");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        width: 40.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: const Text(
                                'Like',
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/reactions/like.gif',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // icon love
                  Transform.scale(
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: () {
                        widget.postModel.showReactions = false;
                        (context as Element).markNeedsBuild();
                        widget.onAddLike("love");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        width: 40.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: const Text(
                                'Love',
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/reactions/love.gif',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // icon haha
                  Transform.scale(
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: () {
                        widget.postModel.showReactions = false;
                        (context as Element).markNeedsBuild();
                        widget.onAddLike("laugh");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        width: 40.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: const Text(
                                'Haha',
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/reactions/haha.gif',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // icon wow
                  Transform.scale(
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: () {
                        widget.postModel.showReactions = false;
                        (context as Element).markNeedsBuild();
                        widget.onAddLike("wow");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        width: 40.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: const Text(
                                'Wow',
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/reactions/wow.gif',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // icon sad
                  Transform.scale(
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: () {
                        widget.postModel.showReactions = false;
                        (context as Element).markNeedsBuild();
                        widget.onAddLike("sad");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        width: 40.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: const Text(
                                'Sad',
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/reactions/sad.gif',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // icon angry
                  Transform.scale(
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: () {
                        widget.postModel.showReactions = false;
                        (context as Element).markNeedsBuild();
                        widget.onAddLike("angry");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        width: 40.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.only(
                                left: 7.0,
                                right: 7.0,
                                top: 2.0,
                                bottom: 2.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: const Text(
                                'Angry',
                                style: TextStyle(
                                  fontSize: 8.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/reactions/angry.gif',
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                // crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BlocBuilder<HomeBloc, HomeState> _getThumbnailVideoWidget(
    BuildContext context,
    String url,
    int mediaIndex,
  ) {
    return BlocBuilder(
      bloc: BlocProvider.of<HomeBloc>(context),
      builder: (BuildContext context, HomeState state) {
        /// Loading
        if (widget.postModel.medias[mediaIndex].isLoading) {
          return Stack(
            children: [
              if (widget.postModel.medias[mediaIndex].thumbnailURL != null)
                SizedBox(
                  height: _currentMediaHeight,
                  width: double.infinity,
                  child: Image.network(
                    widget.postModel.medias[mediaIndex].thumbnailURL!,
                    fit: BoxFit.cover,
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 1.5,
                ),
              ),
            ],
          );
        }

        /// Playing
        else if (widget.postModel.medias[mediaIndex].videoPlayerController !=
            null) {
          double maxHeight = MediaQuery.of(context).size.height,
              maxWidth = MediaQuery.of(context).size.width;

          if (widget.postModel.medias[mediaIndex].meta != null) {
            if (widget.postModel.medias[mediaIndex].meta!.width >
                widget.postModel.medias[mediaIndex].meta!.height) {
              maxHeight =
                  widget.postModel.medias[mediaIndex].meta!.height.toDouble();
              maxWidth =
                  widget.postModel.medias[mediaIndex].meta!.width.toDouble();
            } else {
              maxHeight =
                  widget.postModel.medias[mediaIndex].meta!.height.toDouble() *
                      2;
              maxWidth =
                  widget.postModel.medias[mediaIndex].meta!.width.toDouble() *
                      2;
            }
          }

          return AspectRatio(
            aspectRatio:
            widget.postModel.medias[mediaIndex].videoPlayerController!.value.aspectRatio,
            child: VisibilityDetector(
              onVisibilityChanged: (info) {
                Future.delayed(const Duration(milliseconds: 10), () {
                  if (info.visibleFraction < 1) {
                    if (widget.postModel.medias[mediaIndex].videoPlayerController!
                        .value.isInitialized) {
                      widget.postModel.medias[mediaIndex].videoPlayerController!
                          .pause();
                    }
                  } else {
                      widget.postModel.medias[mediaIndex].videoPlayerController!
                      ..play()
                      ..setLooping(false);
                  }
                });
              },
              key: ValueKey(
                widget.postModel.medias[mediaIndex].url,
              ),
              child: Stack(
                children: [
                  Center(
                    child: OverflowBox(
                      maxHeight: maxHeight,
                      maxWidth: maxWidth,
                      child: VideoPlayer(
                        widget.postModel.medias[mediaIndex]
                            .videoPlayerController!,
                      ),
                    ),
                  ),
                  if (widget.postModel.medias[mediaIndex].currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          widget.postModel.medias[mediaIndex].currentPosition!
                              .toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 1.0,
                      width: context.w,
                      color: AppColors.unSelectedWidgetColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 1.0,
                      width: (currentDurationInSeconds == -1 ||
                          currentDurationInSeconds == 0)
                          ? 0.1
                          : (currentDurationInSeconds /
                          widget
                              .postModel
                              .medias[mediaIndex]
                              .videoPlayerController!
                              .value
                              .duration
                              .inSeconds) *
                          context.w,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _goFullScreen(context, mediaIndex);
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: _currentMediaHeight,
                      width: double.infinity,
                    ),
                  ),
                  if (widget.postModel.medias[mediaIndex].type == "video")
                    _buildMuteButton(context, mediaIndex),
                ],
              ),
            ),
          );
        }

        /// else
        else {
          return Stack(
            children: [
              if (widget.postModel.medias[mediaIndex].thumbnailURL != null)
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: _currentMediaHeight,
                    width: double.infinity,
                    child: Image.network(
                      widget.postModel.medias[mediaIndex].thumbnailURL!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  Align _buildMuteButton(
    BuildContext context,
    int mediaIndex,
  ) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if (widget.postModel.medias[mediaIndex].videoPlayerController!.value
                    .volume ==
                0.0) {
              widget.postModel.medias[mediaIndex].videoPlayerController!
                  .setVolume(1.0);
              (context as Element).markNeedsBuild();
            } else {
              widget.postModel.medias[mediaIndex].videoPlayerController!
                  .setVolume(0.0);
              (context as Element).markNeedsBuild();
            }
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(500)),
            ),
            child: Center(
              child: Iconify(
                widget.postModel.medias[mediaIndex].videoPlayerController!.value
                            .volume ==
                        0.0
                    ? Octicon.mute_24
                    : Octicon.unmute,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loadVideo(int index) async {
    widget.postModel.medias[index].isLoading = true;

    if (!(widget.postModel.medias[index].videoPlayerController?.value
            .isInitialized ??
        false)) {
      widget.postModel.medias[index]
          .videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.postModel.medias[index].url),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      )
        ..initialize().then((v) {
          // state.posts[index].medias[0].isLoading = false;
          widget.postModel.streamer
              .add({'ratio': 1, 'currentDurationInSeconds': 0});
          widget.postModel.medias[index].isLoading = false;
          widget.postModel.medias[index].videoPlayerController!.addListener(() {
            // widget.postModel.streamer.add({
            //   'ratio': 1,
            //   'currentDurationInSeconds': widget.postModel.medias[index]
            //       .videoPlayerController!.value.position.inSeconds
            // });
          });
          setState(() {});
        })
        ..setVolume(0.0);
    }

    if (widget.isInView) {
      widget.postModel.medias[index].videoPlayerController?.play();
    }
  }

  void _calculateMediaWidgetWidthAndHeight(
    int index,
    BuildContext context,
    bool useSetState,
  ) {
    if (widget.postModel.medias[index].meta != null) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      double mediaWidth = widget.postModel.medias[index].meta!.width.toDouble();
      double mediaHeight =
          widget.postModel.medias[index].meta!.height.toDouble();

      double widthRatio = screenWidth / mediaWidth;
      double heightRatio = screenHeight / mediaHeight;

      double scaleFactor = widthRatio < heightRatio ? widthRatio : heightRatio;

      _currentMediaHeight = mediaHeight * scaleFactor;
      _currentMediaWidth = mediaWidth * scaleFactor;

      if (_currentMediaHeight > maxPostHeight) {
        _currentMediaHeight = maxPostHeight;
      }

      if (useSetState) {
        setState(() {});
      }
    }

    if (widget.postModel.medias[index].meta != null) {
      if (widget.postModel.medias[index].meta!.width >
          widget.postModel.medias[index].meta!.height) {
        _boxFit = BoxFit.fitHeight;
      } else {
        _boxFit = BoxFit.fitWidth;
      }
    }

    if (useSetState) {
      setState(() {});
    }
  }

  void getBrowserInfo(BuildContext context, String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoViewerPage(
          url: url,
          heroId: widget.postModel.id,
        ),
      ),
    );
  }

  void _enableScrolling() {
    widget.enableScrolling();

    setState(() {
      _physics = const ClampingScrollPhysics();
    });
  }

  void _disableScrolling() {
    widget.disableScrolling();

    setState(() {
      _physics = const NeverScrollableScrollPhysics();
    });
  }

  void _resetInteraction(details) {
    animation =
        Matrix4Tween(begin: controller.value, end: Matrix4.identity()).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    animationController.forward(from: 0);
  }

  void _onClickOnMoreIcon(BuildContext context, String ownerId) {
    if (ownerId == getIt<PrefsHelper>().userInfo().id) {
      Sheet.editDeleteSheet(
        context,
        onEdit: () {
          widget.onEditPost();
        },
        onDelete: () {
          Navigator.pop(context);
          CustomDialogs.deleteDialog(context, () {
            widget.onDeletePost();
            Navigator.pop(context, widget.postModel.id);
          });
        },
      );
    }
  }

  void listenToStream() async {
    if (widget.parentStream != null) {
      if (widget.parentStream != null) {
        widget.parentStream!.listen((Map<String, dynamic> map) {
          if (mounted) {
            setState(() {
              ratios = map['ratio'].toDouble();
              currentDurationInSeconds = map['currentDurationInSeconds'];
            });
          }
        });
      }
    }
  }
}

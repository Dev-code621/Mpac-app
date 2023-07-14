import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/media_model.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/error/error_view.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/widgets/custom_appbar_widget.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/image_viewer_page.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/widgets/video_viewer_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_bloc.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_event.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/bloc/profile_state.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/widgets/profile_information_widget.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/widgets/user_sports_widget.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  String? profileId;
  final bool withAppBar;
  final String flowCalled;
  final HolderBloc holderBloc;

  ProfilePage({
    required this.withAppBar,
    required this.flowCalled,
    required this.holderBloc,
    this.profileId,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _bloc = getIt<ProfileBloc>();
  late AppLocalizations localizations;
  late final UserModel _currentUser;
  GlobalKey informationWidgetKey = GlobalKey();
  GlobalKey appBarKey = GlobalKey();
  GlobalKey sportWidgetKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = AppLocalizations.of(context)!;
    _currentUser = getIt<PrefsHelper>().userInfo();
  }

  @override
  void initState() {
    super.initState();
    if (widget.profileId != null) {
      _bloc.onGetProfileInformation(widget.profileId!);
      _bloc.onGetProfilePosts(widget.profileId!);
      _bloc.add(GetVideoMedias(widget.profileId!));
      _bloc.add(GetImagesMedias(widget.profileId!));
    } else {
      String userId = getIt<PrefsHelper>().userInfo().id;
      widget.profileId = userId;
      _bloc.onGetProfileInformation(userId);
      _bloc.onGetProfilePosts(userId);
      _bloc.add(GetVideoMedias(userId));
      _bloc.add(GetImagesMedias(userId));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  double getTabBarViewHeight(BuildContext context) {
    RenderBox? box =
        informationWidgetKey.currentContext!.findRenderObject() as RenderBox?;
    if (box != null) {
      return context.h - (box.size.height + context.h * 0.118 + 6);
    } else {
      return context.h * 0.67;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, ProfileState state) {
        if (state.thumbnailLoaded) {
          setState(() {});
          _bloc.onClearFailure();
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ProfileState state) {
          return Scaffold(
            appBar: widget.profileId != null && widget.withAppBar
                ? AppBar(
                    key: appBarKey,
                    backgroundColor: AppColors.backgroundColor,
                    leading: CustomBackButton(
                      onBackClicked: () {
                        Navigator.pop(context);
                      },
                      localeName: localizations.localeName,
                    ),
                    title: Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.032
                            : 14.sp,
                      ),
                    ),
                  )
                : null,
            backgroundColor: Colors.black,
            body: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  if (widget.profileId != null) {
                    _bloc.onGetProfileInformation(widget.profileId!);
                    _bloc.onGetProfilePosts(widget.profileId!);
                  } else {
                    String userId = getIt<PrefsHelper>().userInfo().id;
                    widget.profileId = userId;
                    _bloc.onGetProfileInformation(userId);
                    _bloc.onGetProfilePosts(userId);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.profileId != null && !widget.withAppBar
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: CustomAppBarWidget(
                                key: appBarKey,
                                localeName: localizations.localeName,
                                backgroundColor: state.currentPageIndex == 3
                                    ? const Color(0xff111111)
                                    : Colors.black,
                                onBack: () {
                                  String userId =
                                      getIt<PrefsHelper>().userInfo().id;
                                  widget.profileId = userId;
                                  _bloc.onGetProfileInformation(userId);
                                  _bloc.onGetProfilePosts(userId);
                                },
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: context.h * 0.01,
                      ),
                      ProfileInformationWidget(
                        flowCalled: widget.flowCalled,
                        localizations: localizations,
                        isLoadingProfile: state.isLoadingProfile,
                        profileModelLoaded: state.profileModelLoaded,
                        onEditInformation: () {
                          String userId = getIt<PrefsHelper>().userInfo().id;
                          widget.profileId = userId;
                          _bloc.onGetProfileInformation(userId);
                        },
                        onFollow: () {
                          if (state.profileModelLoaded!.isFollowed!) {
                            _bloc.onUnFollowUser();
                          } else {
                            _bloc.onFollowUser();
                          }
                        },
                      ),
                      SizedBox(
                        height: context.h * 0.02,
                      ),
                      state.profileModelLoaded != null
                          ? state.profileModelLoaded!.sports!.isEmpty
                              ? Container()
                              : Center(
                                  child: UserSportsWidget(
                                    key: sportWidgetKey,
                                    flowCalled: widget.flowCalled,
                                    localizations: localizations,
                                    isLoadingProfile: state.isLoadingProfile,
                                    sports: state.profileModelLoaded == null ||
                                            state.profileModelLoaded!.sports ==
                                                null
                                        ? []
                                        : state.profileModelLoaded!.sports!,
                                    selectedSport:
                                        state.currentSelectedFilterSportType,
                                    onFilter: (val) {
                                      _bloc.onChangeFilterSportType(
                                          val, widget.profileId!);
                                    },
                                    withEdit: _currentUser.id ==
                                        state.profileModelLoaded?.id,
                                    onEditSports: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppScreens.sportSelectionPage,
                                        arguments: {
                                          'viewType': ViewType.profile
                                        },
                                      ).then((v) {
                                        if (v != null &&
                                            (v as Map)['withReloading'] !=
                                                null) {
                                          _bloc.onGetProfileInformation(
                                              widget.profileId!);
                                          _bloc.onGetProfilePosts(
                                              widget.profileId!);
                                          _bloc.add(GetVideoMedias(
                                              widget.profileId!));
                                          _bloc.add(GetImagesMedias(
                                              widget.profileId!));
                                        }
                                      });
                                    },
                                  ),
                                )
                          : Center(
                              child: UserSportsWidget(
                                key: sportWidgetKey,
                                flowCalled: widget.flowCalled,
                                localizations: localizations,
                                isLoadingProfile: state.isLoadingProfile,
                                sports: state.profileModelLoaded == null ||
                                        state.profileModelLoaded!.sports == null
                                    ? []
                                    : state.profileModelLoaded!.sports!,
                                selectedSport:
                                    state.currentSelectedFilterSportType,
                                onFilter: (val) {
                                  _bloc.onChangeFilterSportType(
                                      val, widget.profileId!);
                                },
                                withEdit: _currentUser.id ==
                                    state.profileModelLoaded?.id,
                                onEditSports: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppScreens.sportSelectionPage,
                                    arguments: {'viewType': ViewType.profile},
                                  ).then((v) {
                                    if (v != null &&
                                        (v as Map)['withReloading'] != null) {
                                      _bloc.onGetProfileInformation(
                                          widget.profileId!);
                                      _bloc
                                          .onGetProfilePosts(widget.profileId!);
                                      _bloc.add(
                                          GetVideoMedias(widget.profileId!));
                                      _bloc.add(
                                          GetImagesMedias(widget.profileId!));
                                    }
                                  });
                                },
                              ),
                            ),
                      SizedBox(
                        height: context.h * 0.028,
                      ),
                      getMultiTabBarViewWidget(state),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getMultiTabBarViewWidget(ProfileState state) {
    return state.profileModelLoaded == null
        ? Container()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: DefaultTabController(
              length: 3,
              initialIndex: 0,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppColors.primaryColor,
                    isScrollable: false,
                    tabs: const [
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Icon(Icons.camera),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Icon(Icons.video_camera_back_outlined),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Icon(Icons.image_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: context.h * 0.67,
                    child: TabBarView(
                      children: [
                        getProfilePosts(state),
                        getProfileVideos(state),
                        getProfileImages(state),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget getProfileVideos(ProfileState state) {
    if (state.isLoadingVideosMedias || state.isLoadingUserPosts) {
      return Center(
        child: SizedBox(
          height: Dimensions.checkKIsWeb(context)
              ? context.w * 0.2
              : context.w * 0.35,
          width: Dimensions.checkKIsWeb(context)
              ? context.w * 0.2
              : context.w * 0.35,
          child: CircularProgressIndicator(
            color: AppColors.logoColor,
            strokeWidth: 1.5,
          ),
        ),
      );
    } else if (state.errorLoadingVideosMedias) {
      return Center(
        child: ErrorView(
          color: Colors.grey.withOpacity(0.3),
          onReload: () {
            if (widget.profileId != null) {
              _bloc.add(GetVideoMedias(widget.profileId!));
            }
          },
          message: "No videos found!",
          btnContent: localizations.retry,
        ),
      );
    } else if (state.videosMedias.isEmpty) {
      return Center(
        child: Text(
          "No videos found!",
          style: TextStyle(color: AppColors.primaryColor, fontSize: 14.sp),
        ),
      );
    } else {
      return GridView.builder(
        itemCount: state.videosMedias.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (BuildContext context, int index) {
          return getMediaWidget(state.videosMedias[index]);
        },
      );
    }
  }

  Widget getProfileImages(ProfileState state) {
    if (state.isLoadingImagesMedias ||
        state.isLoadingUserPosts ||
        state.isLoadingVideosMedias) {
      return Center(
        child: SizedBox(
          height: Dimensions.checkKIsWeb(context)
              ? context.w * 0.2
              : context.w * 0.35,
          width: Dimensions.checkKIsWeb(context)
              ? context.w * 0.2
              : context.w * 0.35,
          child: CircularProgressIndicator(
            color: AppColors.logoColor,
            strokeWidth: 1.5,
          ),
        ),
      );
    } else if (state.errorLoadingImagesMedias) {
      return Center(
        child: ErrorView(
          color: Colors.grey.withOpacity(0.3),
          onReload: () {
            if (widget.profileId != null) {
              _bloc.add(GetImagesMedias(widget.profileId!));
            }
          },
          message: "No images found!",
          btnContent: localizations.retry,
        ),
      );
    } else if (state.imagesMedias.isEmpty) {
      return Center(
        child: Text(
          "No images found!",
          style: TextStyle(color: AppColors.primaryColor, fontSize: 14.sp),
        ),
      );
    } else {
      return GridView.builder(
        itemCount: state.imagesMedias.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (BuildContext context, int index) {
          return getMediaWidget(state.imagesMedias[index]);
        },
      );
    }
  }

  Widget getProfilePosts(ProfileState state) {
    if (state.isLoadingUserPosts) {
      return Center(
        child: SizedBox(
          height: Dimensions.checkKIsWeb(context)
              ? context.w * 0.2
              : context.w * 0.35,
          width: Dimensions.checkKIsWeb(context)
              ? context.w * 0.2
              : context.w * 0.35,
          child: CircularProgressIndicator(
            color: AppColors.logoColor,
            strokeWidth: 1.5,
          ),
        ),
      );
    } else if (state.errorLoadingUserPosts) {
      return Center(
        child: ErrorView(
          color: Colors.grey.withOpacity(0.3),
          onReload: () {
            if (widget.profileId != null) {
              _bloc.onGetProfilePosts(widget.profileId!);
            }
          },
          message: "No posts found!",
          btnContent: localizations.retry,
        ),
      );
    } else if (widget.profileId != null) {
      if (state.userPosts.isEmpty) {
        return Center(
          child: Text(
            "No posts found!",
            style: TextStyle(color: AppColors.primaryColor, fontSize: 14.sp),
          ),
        );
      } else {
        // return Align(
        //   alignment: Alignment.centerLeft,
        //   child: Wrap(
        //       alignment: WrapAlignment.start,
        //       children: List.generate(
        //           state.userPosts.length,
        //           (index) => Padding(
        //                 padding: const EdgeInsets.only(
        //                     right: 2.0, left: 2.0, bottom: 8.0, top: 4.0),
        //                 child: state.userPosts[index].medias.isEmpty
        //                     ? Container()
        //                     : getPostWidget(state, index),
        //               ))),
        // );

        return GridView.builder(
          itemCount: state.userPosts.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (BuildContext context, int index) {
            return state.userPosts[index].medias.isEmpty
                ? Container()
                : getPostWidget(state, index);
          },
        );
      }
    } else {
      return Wrap(
        children: List.generate(
          12,
          (index) => Padding(
            padding: const EdgeInsets.only(
              right: 4.0,
              left: 4.0,
              bottom: 8.0,
              top: 4.0,
            ),
            child: Container(
              width: context.w * 0.2,
              height: context.w * 0.2,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                image: DecorationImage(
                  image: AssetImage(
                    index % 2 == 0
                        ? index % 3 == 0
                            ? 'assets/images/general/profile_image.png'
                            : 'assets/images/general/profile_image1.png'
                        : 'assets/images/general/profile_image2.png',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget getPostWidget(ProfileState state, int index) {
    // if(state.userPosts[index].medias)
    return SizedBox(
      width:
          Dimensions.checkKIsWeb(context) ? context.w * 0.15 : context.w * 0.31,
      height:
          Dimensions.checkKIsWeb(context) ? context.w * 0.25 : context.w * 0.55,
      child: Stack(
        children: [
          PageView(
            onPageChanged: (pageIndex) async {
              state.userPosts[index].currentFocusedIndex = pageIndex;
              (context as Element).markNeedsBuild();
            },
            scrollDirection: Axis.horizontal,
            children: List.generate(
              state.userPosts[index].medias.length,
              (mediaIndex) => GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppScreens.postInformationPage,
                    arguments: {'postId': state.userPosts[index].id},
                  ).then((v) {
                    if (v != null) {
                      _bloc.onDeletePost(v as String, widget.profileId!);
                    }
                  });
                },
                child: getMediaTypeWidget(state, index, mediaIndex),
              ),
            ),
          ),
          state.userPosts[index].medias.length == 1
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: state.userPosts[index].medias.length * 18,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      child: SizedBox(
                        height: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            state.userPosts[index].medias.length,
                            (mmIndex) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 3.5,
                                width: 3.5,
                                decoration: BoxDecoration(
                                  color: state.userPosts[index]
                                              .currentFocusedIndex ==
                                          mmIndex
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
        ],
      ),
    );
  }

  Widget getMediaTypeWidget(ProfileState state, int index, int mediaIndex) {
    if (state.userPosts[index].medias[mediaIndex].type == "image") {
      return Container(
        width: Dimensions.checkKIsWeb(context)
            ? context.w * 0.15
            : context.w * 0.31,
        height: Dimensions.checkKIsWeb(context)
            ? context.w * 0.25
            : context.w * 0.55,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image:
                state.userPosts[index].medias[mediaIndex].thumbnailURL == null
                    ? NetworkImage(
                        state.userPosts[index].medias[mediaIndex].url,
                      )
                    : NetworkImage(
                        state.userPosts[index].medias[mediaIndex].thumbnailURL!,
                      ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // goToVideo(state.userPosts[index].medias[mediaIndex].url,
          //     state.userPosts[index]);

          Navigator.pushNamed(
            context,
            AppScreens.postInformationPage,
            arguments: {'postId': state.userPosts[index].id},
          ).then((v) {
            if (v != null) {
              _bloc.onDeletePost(v as String, widget.profileId!);
            }
          });
        },
        child: Container(
          width: Dimensions.checkKIsWeb(context)
              ? context.w * 0.15
              : context.w * 0.31,
          height: Dimensions.checkKIsWeb(context)
              ? context.w * 0.25
              : context.w * 0.55,
          color: Colors.grey.withOpacity(0.1),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: state.userPosts[index].medias[mediaIndex].thumbnailURL ==
                        null
                    ? Container()
                    : Image.network(
                        state.userPosts[index].medias[mediaIndex].thumbnailURL!,
                        width: Dimensions.checkKIsWeb(context)
                            ? context.w * 0.15
                            : context.w * 0.31,
                        height: Dimensions.checkKIsWeb(context)
                            ? context.w * 0.25
                            : context.w * 0.55,
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0, top: 5.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Icon(
                        size: 20,
                        Icons.videocam_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget getMediaWidget(MediaModel media) {
    if (media.type == "image") {
      return GestureDetector(
        onTap: () {
          goToMedia(media);
        },
        child: Hero(
          tag: media.id,
          child: Container(
            width: Dimensions.checkKIsWeb(context)
                ? context.w * 0.15
                : context.w * 0.31,
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.25
                : context.w * 0.55,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: media.thumbnailURL == null
                    ? NetworkImage(media.url)
                    : NetworkImage(media.thumbnailURL!),
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          goToMedia(media);
        },
        child: Hero(
          tag: media.id,
          child: Container(
            width: Dimensions.checkKIsWeb(context)
                ? context.w * 0.15
                : context.w * 0.31,
            height: Dimensions.checkKIsWeb(context)
                ? context.w * 0.25
                : context.w * 0.55,
            color: Colors.grey.withOpacity(0.1),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: media.thumbnailURL == null
                      ? Container()
                      : Image.network(
                          media.thumbnailURL!,
                          width: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.15
                              : context.w * 0.31,
                          height: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.25
                              : context.w * 0.55,
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0, top: 5.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          size: 20,
                          Icons.videocam_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void goToMedia(MediaModel media) {
    if (media.postId == null) {
      if (media.type == "video") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoViewerPage(
              url: media.url,
              heroId: media.id,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerPage(
              urlStr: media.url,
              heroId: media.id,
              holderBloc: widget.holderBloc,
            ),
          ),
        );
      }
    } else {
      Navigator.pushNamed(
        context,
        AppScreens.postInformationPage,
        arguments: {'postId': media.postId!},
      ).then((v) {
        if (v != null) {
          _bloc.onDeletePost(v as String, widget.profileId!);
        }
      });
    }
  }
}

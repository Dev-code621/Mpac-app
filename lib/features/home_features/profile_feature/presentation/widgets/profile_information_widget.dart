import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/general/custom_image_picker.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_bloc.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_state.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_event.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';

class ProfileInformationWidget extends StatefulWidget {
  final AppLocalizations localizations;
  final UserModel? profileModelLoaded;
  final bool isLoadingProfile;
  final String flowCalled;
  final Function onEditInformation;
  final Function onFollow;

  const ProfileInformationWidget(
      {Key? key,
      required this.localizations,
      this.profileModelLoaded,
      required this.isLoadingProfile,
      required this.flowCalled,
      required this.onEditInformation,
      required this.onFollow})
      : super(key: key);

  @override
  State<ProfileInformationWidget> createState() =>
      _ProfileInformationWidgetState();
}

class _ProfileInformationWidgetState extends State<ProfileInformationWidget>
    with FlushBarMixin {
  final _bloc = getIt<MyAccountBloc>();

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoadingProfile && widget.profileModelLoaded != null) {
      return BlocListener(
        bloc: _bloc,
        listener: (BuildContext context, MyAccountState state) {
          if (state.errorUploadingPicture && state.failure != null) {
            _bloc.add(ClearFailures());
            exceptionFlushBar(
              context: context,
              duration: const Duration(milliseconds: 1500),
              message: (state.failure as ServerFailure).errorMessage ??
                  "Server error!",
              onHidden: () {
                _bloc.add(ClearFailures());
              },
              onChangeStatus: (s) {},
            );
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
          builder: (context, MyAccountState state) {
            return SizedBox(
              width: context.w,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: widget.profileModelLoaded!.id !=
                              getIt<PrefsHelper>().userInfo().id
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            widget.profileModelLoaded!.id !=
                                    getIt<PrefsHelper>().userInfo().id
                                ? SizedBox(
                                    width: kIsWeb
                                        ? MediaQuery.of(context).size.width <
                                                760
                                            ? 15.sp
                                            : 5.sp
                                        : 00.sp,
                                  )
                                : SizedBox(
                                    width: kIsWeb
                                        ? MediaQuery.of(context).size.width <
                                                760
                                            ? 15.sp
                                            : 5.sp
                                        : 00.sp,
                                  ),
                            SizedBox(
                              width:
                                  kIsWeb ? context.w * 0.18 : context.w * 0.25,
                              height:
                                  kIsWeb ? context.w * 0.18 : context.w * 0.25,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      width: context.w * 0.25,
                                      height: context.w * 0.25,
                                      decoration: BoxDecoration(
                                        color:
                                            widget.profileModelLoaded != null &&
                                                    widget.profileModelLoaded!
                                                            .image ==
                                                        null
                                                ? Colors.grey.withOpacity(0.15)
                                                : Colors.grey.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        image: widget.profileModelLoaded !=
                                                    null &&
                                                widget.profileModelLoaded!
                                                        .image ==
                                                    null
                                            ? null
                                            : widget.profileModelLoaded != null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                      widget.profileModelLoaded!
                                                          .image!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                      ),
                                      child: widget.profileModelLoaded !=
                                                  null &&
                                              widget.profileModelLoaded!
                                                      .image ==
                                                  null
                                          ? Icon(
                                              Icons.person,
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              size: kIsWeb
                                                  ? context.w * 0.1
                                                  : context.w * 0.1,
                                            )
                                          : null,
                                    ),
                                  ),
                                  (widget.flowCalled != "profile")
                                      ? Container()
                                      : Align(
                                          alignment: Alignment.bottomRight,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfilePage(),
                                                ),
                                              ).then((value) {
                                                widget.onEditInformation();
                                              });
                                            },
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .unSelectedWidgetColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            widget.profileModelLoaded!.id !=
                                    getIt<PrefsHelper>().userInfo().id
                                ? SizedBox(
                                    width: kIsWeb ? 10.sp : 25.sp,
                                  )
                                : SizedBox(
                                    width: kIsWeb ? 20.sp : 70.sp,
                                  ),
                            widget.profileModelLoaded!.id !=
                                    getIt<PrefsHelper>().userInfo().id
                                ? Column(
                                    children: [
                                      Text(
                                        "",
                                        style: TextStyle(
                                          color: AppColors.secondaryFontColor,
                                          fontSize: kIsWeb
                                              ? context.h * 0.025
                                              : 10.sp,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          widget.onFollow();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.unSelectedWidgetColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(4)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 3.0,
                                              right: 10,
                                              left: 10,
                                              top: 3,
                                            ),
                                            child: Text(
                                              widget.profileModelLoaded !=
                                                          null &&
                                                      widget.profileModelLoaded!
                                                          .isFollowed!
                                                  ? "Unfollow"
                                                  : "Follow",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        760
                                                    ? context.h * 0.015
                                                    : 9.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppScreens.followingsPage,
                                  arguments: {
                                    'userId': widget.profileModelLoaded!.id,
                                    'type': "followers"
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    widget.profileModelLoaded != null
                                        ? widget.profileModelLoaded!.followers!
                                        : "-",
                                    style: TextStyle(
                                      color: AppColors.secondaryFontColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  760
                                              ? context.h * 0.023
                                              : 13.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.localizations.followers,
                                    style: TextStyle(
                                      color: AppColors.secondaryFontColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  760
                                              ? context.h * 0.023
                                              : 10.sp,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10.sp,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppScreens.followingsPage,
                                  arguments: {
                                    'userId': widget.profileModelLoaded!.id,
                                    'type': "followings"
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    widget.profileModelLoaded != null
                                        ? widget.profileModelLoaded!.followings!
                                        : "-",
                                    style: TextStyle(
                                      color: AppColors.secondaryFontColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  760
                                              ? context.h * 0.023
                                              : 13.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.localizations.following,
                                    style: TextStyle(
                                      color: AppColors.secondaryFontColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  760
                                              ? context.h * 0.023
                                              : 10.sp,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.profileModelLoaded!.id !=
                                  getIt<PrefsHelper>().userInfo().id
                              ? 0.sp
                              : 7.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profileModelLoaded != null
                                ? "${widget.profileModelLoaded!.firstName!} ${widget.profileModelLoaded!.lastName!}"
                                : "-",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              color: Colors.white,
                              fontSize: Dimensions.checkKIsWeb(context)
                                  ? context.h * 0.03
                                  : 13.sp,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          SizedBox(
                            width: context.w,
                            child: Text(
                              widget.profileModelLoaded != null
                                  ? widget.profileModelLoaded!.bio ?? ""
                                  : "-",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                color: Colors.white,
                                fontSize: Dimensions.checkKIsWeb(context)
                                    ? context.h * 0.02
                                    : 9.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        width: context.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: kIsWeb ? context.w * 0.18 : context.w * 0.25,
                    height: kIsWeb ? context.w * 0.18 : context.w * 0.25,
                    child: Shimmer.fromColors(
                      baseColor:
                          AppColors.unSelectedWidgetColor.withOpacity(0.8),
                      highlightColor: Colors.black,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              AppColors.unSelectedWidgetColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    width: 50,
                    height: 20,
                    child: Shimmer.fromColors(
                      baseColor:
                          AppColors.unSelectedWidgetColor.withOpacity(0.8),
                      highlightColor: Colors.black,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              AppColors.unSelectedWidgetColor.withOpacity(0.8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 30,
                    child: Shimmer.fromColors(
                      baseColor:
                          AppColors.unSelectedWidgetColor.withOpacity(0.8),
                      highlightColor: Colors.black,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              AppColors.unSelectedWidgetColor.withOpacity(0.8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 30,
                    child: Shimmer.fromColors(
                      baseColor:
                          AppColors.unSelectedWidgetColor.withOpacity(0.8),
                      highlightColor: Colors.black,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              AppColors.unSelectedWidgetColor.withOpacity(0.8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
}

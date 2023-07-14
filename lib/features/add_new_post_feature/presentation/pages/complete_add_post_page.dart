import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_bloc.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_event.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_state.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/pick_images_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/widgets/user_sports_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class CompleteAddPostPage extends StatefulWidget {
  final AddPostBloc bloc;
  final Map<String, dynamic> controllers;

  const CompleteAddPostPage({
    required this.bloc,
    required this.controllers,
    Key? key,
  }) : super(key: key);

  @override
  State<CompleteAddPostPage> createState() => _CompleteAddPostPageState();
}

class _CompleteAddPostPageState extends State<CompleteAddPostPage>
    with FlushBarMixin {
  late AppLocalizations localizations;
  final TextEditingController _descController = TextEditingController();
  final StreamController<String> _streamController = StreamController<String>();
  bool _isUploading = false;
  String _uploadPercentage = "0%";

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: widget.bloc,
      listener: (BuildContext context, AddPostState state) {
        if (state.postSubmitted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppScreens.holderPage,
            (route) => false,
          );
        }
        if (state.failure != null) {
          widget.bloc.onClearFailures();
          exceptionFlushBar(
            onChangeStatus: (s) {},
            onHidden: () {
              widget.bloc.onClearFailures();
            },
            duration: const Duration(milliseconds: 2000),
            message: (state.failure as ServerFailure).errorMessage ?? "Error!",
            context: context,
          );
        }
      },
      child: BlocBuilder(
        bloc: widget.bloc,
        builder: (BuildContext context, AddPostState state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              height: context.h * 0.05,
                              width: Dimensions.checkKIsWeb(context)
                                  ? context.w * 0.075
                                  : context.w * 0.15,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: const Color(0xffB7B7B7),
                                  size: context.h * 0.025,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isUploading)
                  StreamBuilder<String>(
                    stream: _streamController.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        _uploadPercentage = snapshot.data!;
                      }
                      return Center(
                        child: Text(
                          "Uploading $_uploadPercentage...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                context.w > 550 ? context.h * 0.028 : 13.sp,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: context.w * 0.08,
                                  height: context.h * 0.08,
                                  decoration: getIt<SharedPreferences>()
                                              .getString(
                                            SharedPreferencesKeys
                                                .userProfilePicture,
                                          ) ==
                                          null
                                      ? BoxDecoration(
                                          color: Colors.grey.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        )
                                      : BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              getIt<SharedPreferences>()
                                                  .getString(
                                                SharedPreferencesKeys
                                                    .userProfilePicture,
                                              )!,
                                            ),
                                            fit: kIsWeb
                                                ? BoxFit.cover
                                                : BoxFit.contain,
                                          ),
                                        ),
                                  child: getIt<SharedPreferences>().getString(
                                            SharedPreferencesKeys
                                                .userProfilePicture,
                                          ) ==
                                          null
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.grey.withOpacity(0.5),
                                          size: context.w * 0.05,
                                        )
                                      : Container(),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${getIt<PrefsHelper>().userInfo().firstName!} ${getIt<PrefsHelper>().userInfo().lastName!}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Dimensions.checkKIsWeb(context)
                                        ? context.h * 0.025
                                        : 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          getImagesWidget(state),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextFieldWidget(
                            onChanged: (value) {
                              widget.bloc.onChangePostDescription(value);
                            },
                            hintText: localizations.post_desc,
                            controller: _descController,
                            maxLines: 3,
                            showError: state.errorValidationDesc,
                            errorText: 'invalid input!',
                            inputType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          state.sports.isEmpty
                              ? Container()
                              : UserSportsWidget(
                                  flowCalled: "add_post",
                                  localizations: localizations,
                                  isLoadingProfile: false,
                                  sports: state.sports,
                                  selectedSport: state.postParams.sport,
                                  onFilter: (val) {
                                    widget.bloc.add(ChangingPostSport(val));
                                    setState(() {});
                                  },
                                ),
                          const SizedBox(
                            height: 16,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.h),
                            child: CustomSubmitButton(
                              buttonText: localizations.publish.toUpperCase(),
                              backgroundColor: AppColors.primaryColor,
                              onPressed: () {
                                widget.bloc.onAddNewPost(
                                  webOnSendProgress: kIsWeb
                                      ? (count, total) {
                                          final percentage =
                                              ((count / total) * 100).toInt();

                                          _streamController.add("$percentage%");
                                        }
                                      : null,
                                );

                                if (_descController.text.isEmpty) {
                                  return;
                                }

                                if (!kIsWeb) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppScreens.holderPage,
                                    (route) => false,
                                  );
                                } else {
                                  setState(() {
                                    _isUploading = true;
                                  });
                                }
                              },
                              hoverColor: Colors.grey.withOpacity(0.5),
                              textColor: Colors.white,
                              isLoading: state.isSubmittingPost,
                              disable: state.isSubmittingPost,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getVideoWidget(String mediaKey) {
    double maxHeight = widget.controllers[mediaKey]['video'].value.size.height,
        maxWidth = context.w * 0.8;

    // if (widget.controllers[mediaKey]['video'].value.size.width >
    //     widget.controllers[mediaKey]['video'].value.size.height) {
    //   maxWidth = widget.controllers[mediaKey]['video'].value.size.width;
    // }

    if (widget.controllers[mediaKey] != null) {
      return GestureDetector(
        key: Key(mediaKey),
        onTap: () {
          widget.controllers[mediaKey]['isPaused']
              ? widget.controllers[mediaKey]['video']!.play()
              : widget.controllers[mediaKey]['video']!.pause();
          setState(() {
            widget.controllers[mediaKey]['isPaused'] =
                !widget.controllers[mediaKey]['isPaused'];
          });
        },
        child: SizedBox(
          height: context.h * 0.45,
          width: context.w * 0.8,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    maxWidth: maxWidth,
                  ),
                  child: VideoPlayer(widget.controllers[mediaKey]['video']!),
                ),
              ),
              widget.controllers[mediaKey]['isPaused']
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 35,
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getImagesWidget(AddPostState state) {
    return Container(
      height: context.h * 0.45,
      width: context.w,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColors.primaryColor.withOpacity(0.5),
              shadowColor: Colors.transparent,
            ),
            child: kIsWeb
                ? ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: List.generate(
                        kIsWeb
                            ? state.selectedVideos.isEmpty
                                ? state.selectedMediasWeb.length
                                : state.selectedVideos.length
                            : state.selectedMedias.length,
                        (index) => kIsWeb
                            ? state.selectedVideos.isNotEmpty
                                ? SizedBox(
                                    height: context.h * 0.40,
                                    width: context.w,
                                    child: VideoPlayer(
                                      VideoPlayerController.network(
                                        state.selectedVideos[0].path,
                                      )
                                        ..initialize()
                                        ..play(),
                                    ),
                                  )
                                : SizedBox(
                                    height: context.h * 0.40,
                                    width: context.w,
                                    child: state.croppedFilesMap.isNotEmpty &&
                                            state.croppedFilesMap
                                                .containsKey(index.toString())
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: FutureBuilder<Uint8List>(
                                              future: state.croppedFilesMap[
                                                      index.toString()]['file']
                                                  .readAsBytes(),
                                              builder: (context, snapshot) {
                                                return Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.fitHeight,
                                                );
                                              },
                                            ),
                                          )
                                        : Image.memory(
                                            state.selectedMediasWeb[index],
                                            fit: BoxFit.cover,
                                          ),
                                  )
                            : getMobileMediaWidget(state, index),
                      ),
                    ),
                  )
                : ReorderableListView(
                    clipBehavior: Clip.antiAlias,
                    scrollDirection: Axis.horizontal,
                    onReorder: (int start, int current) {
                      // dragging from top to bottom
                      if (start < current) {
                        int end = current - 1;
                        MediaSource startItem = state.selectedMedias[start];
                        int i = 0;
                        int local = start;
                        do {
                          state.selectedMedias[local] =
                              state.selectedMedias[++local];
                          i++;
                        } while (i < end - start);
                        state.selectedMedias[end] = startItem;
                      }
                      // dragging from bottom to top
                      else if (start > current) {
                        MediaSource startItem = state.selectedMedias[start];
                        for (int i = start; i > current; i--) {
                          state.selectedMedias[i] = state.selectedMedias[i - 1];
                        }
                        state.selectedMedias[current] = startItem;
                      }
                      setState(() {});
                    },
                    children: List.generate(
                      kIsWeb
                          ? state.selectedVideos.isEmpty
                              ? state.selectedMediasWeb.length
                              : state.selectedVideos.length
                          : state.selectedMedias.length,
                      (index) => kIsWeb
                          ? state.selectedVideos.isNotEmpty
                              ? VideoPlayer(
                                  VideoPlayerController.network(
                                    state.selectedVideos[0].path,
                                  )
                                    ..initialize()
                                    ..play(),
                                )
                              : SizedBox(
                                  height: context.h * 0.40,
                                  width: context.w,
                                  child: state.croppedFilesMap.isNotEmpty &&
                                          state.croppedFilesMap
                                              .containsKey(index.toString())
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: FutureBuilder<Uint8List>(
                                            future: state.croppedFilesMap[
                                                    index.toString()]['file']
                                                .readAsBytes(),
                                            builder: (context, snapshot) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.fitHeight,
                                              );
                                            },
                                          ),
                                        )
                                      : Image.memory(
                                          state.selectedMediasWeb[index],
                                          fit: BoxFit.cover,
                                        ),
                                )
                          : getMobileMediaWidget(state, index),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget getMobileMediaWidget(AddPostState state, int index) {
    if (state.selectedMedias[index].file == null) {
      return FutureBuilder<File?>(
        key: Key('complete_orr$index'),
        future: state.selectedMedias[index].assetEntity.file,
        builder: (context, snapshot) {
          return snapshot.data == null
              ? Container()
              : state.selectedMedias[index].assetEntity.type == AssetType.video
                  ? getVideoWidget(
                      state.selectedMedias[index].assetEntity.id,
                    )
                  : state.croppedFilesMap.isNotEmpty &&
                          state.croppedFilesMap.containsKey(
                            state.selectedMedias[index].assetEntity.id,
                          )
                      ? Align(
                          alignment: Alignment.center,
                          child: Image.file(
                            key: Key('complete_orr$index'),
                            File(
                              state
                                  .croppedFilesMap[state.selectedMedias[index]
                                      .assetEntity.id]['file']
                                  .path,
                            ),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: Image.file(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            height: context.h * 0.45,
                            width: context.w * 0.8,
                          ),
                        );
        },
      );
    } else {
      return state.selectedMedias[index].assetEntity.type == AssetType.video
          ? getVideoWidget(
              state.selectedMedias[index].assetEntity.id,
            )
          : state.croppedFilesMap.isNotEmpty &&
                  state.croppedFilesMap.containsKey(
                    state.selectedMedias[index].assetEntity.id,
                  )
              ? Align(
                  key: Key('complete_orr$index'),
                  alignment: Alignment.center,
                  child: Image.file(
                    File(
                      state
                          .croppedFilesMap[state
                              .selectedMedias[index].assetEntity.id]['file']
                          .path,
                    ),
                    fit: BoxFit.cover,
                  ),
                )
              : Align(
                  key: Key('complete_orr$index'),
                  alignment: Alignment.center,
                  child: Image.file(
                    state.selectedMedias[index].file!,
                    fit: BoxFit.cover,
                    height: context.h * 0.45,
                    width: context.w * 0.8,
                  ),
                );
    }
  }
}

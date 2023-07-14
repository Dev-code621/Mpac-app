import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/data/models/media_model.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/bloc/edit_post_bloc.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/bloc/edit_post_event.dart';
import 'package:mpac_app/features/edit_post_feature/presentation/bloc/edit_post_state.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/widgets/user_sports_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({required this.post, Key? key}) : super(key: key);

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late AppLocalizations localizations;
  final _bloc = getIt<EditPostBloc>();
  TextEditingController _descController = TextEditingController();
  PageController pg = PageController();
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.post.description);
    _bloc.add(ChangingPostDescription(widget.post.description));
    _bloc.add(InitializeEditPost(widget.post));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, EditPostState state) {
        if (state.postUpdated) {
          Navigator.pop(context, {'updatedPost': state.updatedPost});
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(),
        ),
        body: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, EditPostState state) {
            return Column(
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
                          Text(
                            localizations.edit_post,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Dimensions.checkKIsWeb(context)
                                  ? context.h * 0.03
                                  : 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                          onTap: () async {
                            if (kIsWeb) {
                              List<XFile> list = [];
                              _picker.pickMultiImage().then((value) async {
                                for (int i = 0; i < value.length; i++) {
                                  list.add(
                                    value[i],
                                  );
                                }
                                _bloc.add(ChangingAssetEntitiesWeb(list));
                                pg.nextPage(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeIn);
                              });
                            } else {
                              final List<AssetEntity>? result =
                                  await AssetPicker.pickAssets(
                                context,
                                pickerConfig: AssetPickerConfig(
                                  themeColor: AppColors.primaryColor,
                                  selectedAssets: state.newAssets,
                                ),
                              );

                              result == null || result.isEmpty
                                  ? ''
                                  : _bloc.add(ChangingAssetEntities(result));
                            }
                          },
                          child: SizedBox(
                            height: context.h * 0.05,
                            width: Dimensions.checkKIsWeb(context)
                                ? context.w * 0.075
                                : context.w * 0.15,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: const Color(0xffB7B7B7),
                                size: context.h * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            left: 16.0,
                            right: 16.0,
                          ),
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
                                          fit: BoxFit.cover,
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
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 12.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            height: context.h * 0.45, // 0.45
                            width: context.w,
                            child: state.loadingAssets == false
                                ? state.allAssets.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "No media selected!",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : PageView(
                                        controller: pg,
                                        children: List.generate(
                                          state.allAssets.length,
                                          (index) =>
                                              getMediasWidget(state, index),
                                        ),
                                      )
                                : const CircularProgressIndicator(),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: CustomTextFieldWidget(
                            onChanged: (value) {
                              _bloc.add(ChangingPostDescription(value));
                            },
                            hintText: localizations.post_desc,
                            controller: _descController,
                            maxLines: 3,
                            showError: state.errorValidationDesc,
                            errorText: 'invalid input!',
                            inputType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        UserSportsWidget(
                          flowCalled: "add_post",
                          localizations: localizations,
                          isLoadingProfile: false,
                          sports: state.userSports,
                          selectedSport: state.postSport,
                          onFilter: (val) {
                            _bloc.add(ChangingPostSport(val));
                            setState(() {});
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 5.h,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: CustomSubmitButton(
                            buttonText: localizations.publish.toUpperCase(),
                            backgroundColor: AppColors.primaryColor,
                            onPressed: () {
                              if (state.allAssets.isNotEmpty) {
                                _bloc.add(EditPost(widget.post.id));
                              }
                            },
                            hoverColor: Colors.grey.withOpacity(0.5),
                            textColor: Colors.white,
                            isLoading: state.isUpdatingPost,
                            disable:
                                state.isUpdatingPost || state.allAssets.isEmpty,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getMediasWidget(EditPostState state, int index) {
    if (state.allAssets[index].mediaModelForOldAsset != null &&
        state.allAssets[index].mediaModelForOldAsset!.type == "image") {
      return SizedBox(
        height: context.h * 0.45,
        width: context.w,
        child: Stack(
          children: [
            Image.network(
              state.allAssets[index].mediaModelForOldAsset!.url,
              fit: BoxFit.contain,
              height: context.h * 0.45,
              width: context.w,
            ),
            deleteIconWidget(
              onClicked: () {
                _bloc.add(
                  DeleteOldMedia(
                    state.allAssets[index].mediaModelForOldAsset!.id,
                    state.allAssets[index],
                  ),
                );
              },
            )
          ],
        ),
      );
    } else if (state.allAssets[index].mediaModelForOldAsset != null &&
        state.allAssets[index].mediaModelForOldAsset!.type == "video") {
      return getVideoWidget(
        state,
        index,
      );
    } else {
      if (state.allAssets[index].file == null) {
        if (state.allAssets[index].webUrl != null) {
          return Align(
            key: Key('complete_orr$index'),
            alignment: Alignment.center,
            child: Stack(
              children: [
                Image.network(
                  state.allAssets[index].webUrl!,
                  fit: BoxFit.contain,
                  height: context.h * 0.45,
                  width: context.w,
                ),
                deleteIconWidget(onClicked: () {
                  _bloc.add(
                    DeleteNewMedia(
                      state.allAssets[index],
                    ),
                  );
                }),
              ],
            ),
          );
        }
        return FutureBuilder<File?>(
          key: Key('complete_orr$index'),
          future: state.allAssets[index].assetEntity!.file,
          builder: (context, snapshot) {
            return snapshot.data == null
                ? Container()
                : state.allAssets[index].assetEntity!.type == AssetType.video
                    ? getVideoWidget(
                        state,
                        index,
                      )
                    : state.croppedFilesMap.isNotEmpty &&
                            state.croppedFilesMap.containsKey(
                              state.allAssets[index].assetEntity!.id,
                            )
                        ? Align(
                            alignment: Alignment.center,
                            child: Image.file(
                              key: Key('complete_orr$index'),
                              File(
                                state
                                    .croppedFilesMap[state.allAssets[index]
                                        .assetEntity!.id]['file']
                                    .path,
                              ),
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              height: context.h * 0.45, // 0.45
                              width: context.w * 0.5,
                            ),
                          );
          },
        );
      } else {
        return state.allAssets[index].assetEntity!.type == AssetType.video
            ? getVideoWidget(
                state,
                index,
              )
            : state.croppedFilesMap.isNotEmpty &&
                    state.croppedFilesMap.containsKey(
                      state.allAssets[index].assetEntity!.id,
                    )
                ? Stack(
                    children: [
                      Align(
                        key: Key('complete_orr$index'),
                        alignment: Alignment.center,
                        child: Image.file(
                          File(
                            state
                                .croppedFilesMap[state
                                    .allAssets[index].assetEntity!.id]['file']
                                .path,
                          ),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      deleteAndCroppingRowWidget(state, index)
                    ],
                  )
                : Align(
                    key: Key('complete_orr$index'),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Image.file(
                          state.allAssets[index].file!,
                          fit: BoxFit.contain,
                          height: context.h * 0.45,
                          width: context.w,
                        ),
                        deleteAndCroppingRowWidget(state, index)
                      ],
                    ),
                  );
      }
    }
  }

  Widget getVideoWidget(EditPostState state, int index) {
    if (state.allAssets[index].videoPlayerController != null) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              !state.allAssets[index].videoPlayerController!.value.isPlaying
                  ? state.allAssets[index].videoPlayerController!.play()
                  : state.allAssets[index].videoPlayerController!.pause();
              setState(() {});
              // setState(() {
              //   controllers[mediaKey]['isPaused'] =
              //       !controllers[mediaKey]['isPaused'];
              // });
            },
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: state.allAssets[index].videoPlayerController!
                        .value.aspectRatio,
                    child: VideoPlayer(
                      state.allAssets[index].videoPlayerController!,
                    ),
                  ),
                ),
                !state.allAssets[index].videoPlayerController!.value.isPlaying
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
          deleteIconWidget(
            onClicked: () {
              _bloc.add(
                DeleteNewMedia(
                  state.allAssets[index],
                ),
              );
            },
          )
        ],
      );
    } else {
      return Stack(
        children: [
          state.allAssets[index].mediaModelForOldAsset!.thumbnailURL == null
              ? Container()
              : Align(
                  alignment: Alignment.center,
                  child: Image.network(
                    state.allAssets[index].mediaModelForOldAsset!.thumbnailURL!,
                    fit: BoxFit.fill,
                  ),
                ),
          Align(
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
          ),
          deleteIconWidget(
            onClicked: () {
              _bloc.add(
                DeleteOldMedia(
                  state.allAssets[index].mediaModelForOldAsset!.id,
                  state.allAssets[index],
                ),
              );
            },
          )
        ],
      );
    }
  }

  Widget croppingFileWidget({required Function onClicked}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            onClicked();
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.crop,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteIconWidget({required Function onClicked}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            onClicked();
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.delete_outline,
                color: Color(0xffB7B7B7),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteAndCroppingRowWidget(EditPostState state, index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        croppingFileWidget(
          onClicked: () async {
            CroppedFile? file = await _cropImage(
              state.allAssets[index].file!,
            );
            setState(() {
              _bloc.onCropImage(
                file!,
                index,
                state.allAssets[index].assetEntity!.id.toString(),
              );
            });
          },
        ),
        deleteIconWidget(
          onClicked: () {
            _bloc.add(
              DeleteNewMedia(
                state.allAssets[index],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<CroppedFile?> _cropImage(File pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: CroppieBoundary(
            width: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.w * 0.6).toInt(),
            height: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.h * 0.6).toInt(), // 520
          ),
          viewPort: CroppieViewPort(
            width: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.w * 0.6).toInt(),
            height: Dimensions.checkKIsWeb(context)
                ? (context.w * 0.5).toInt()
                : (context.h * 0.6).toInt(), // 520
            type: 'square',
          ),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      return croppedFile;
    }
    return null;
  }
}

class CustomMediaAsset {
  final String? assetId;
  final AssetEntity? assetEntity;
  final File? file;
  final String? webUrl;
  final MediaModel? mediaModelForOldAsset;
  VideoPlayerController? videoPlayerController;

  CustomMediaAsset({
    this.assetId,
    this.assetEntity,
    this.webUrl,
    this.file,
    this.mediaModelForOldAsset,
    this.videoPlayerController,
  });
}

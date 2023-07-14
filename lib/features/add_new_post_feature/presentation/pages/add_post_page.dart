import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_bloc.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_event.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/bloc/add_post_state.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/pick_images_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_io/io.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

bool shouldBuildMediaGrid = true;

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> with FlushBarMixin {
  late AppLocalizations localizations;
  final ImagePicker _picker = ImagePicker();
  final _bloc = getIt<AddPostBloc>();
  final List<MediaSource> _selectedMedia = [];
  FlushbarStatus fStatus = FlushbarStatus.DISMISSED;
  Map<String, dynamic> controllers = {};
  Map<String, dynamic> controllersWeb = {};
  bool _firstTime = true;
  PageController pageCont = PageController(viewportFraction: 1);

  int chosenIndex = -1;

  Subscription? _subscription;

  @override
  void initState() {
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      shouldBuildMediaGrid = true;
      localizations = AppLocalizations.of(context)!;
      _bloc.add(GetSports());

      _firstTime = false;
    }
  }

  @override
  void dispose() {
    for (var item in controllers.keys) {
      controllers[item]['video']?.dispose();
    }

    for (var item in controllersWeb.keys) {
      controllersWeb[item]['video']?.dispose();
    }

    _subscription!.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext ctx, AddPostState state) {
        return Scaffold(
          appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                      },
                      child: SizedBox(
                        width: Dimensions.checkKIsWeb(ctx)
                            ? ctx.w * 0.08
                            : ctx.w * 0.15,
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: const Color(0xffB7B7B7),
                            size: Dimensions.checkKIsWeb(ctx)
                                ? ctx.w * 0.04
                                : ctx.w * 0.08,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      localizations.new_post,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Dimensions.checkKIsWeb(ctx) ? ctx.h * 0.032 : 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          state.selectedMedias.addAll(_selectedMedia);
                        });

                        if (_selectedMedia.isEmpty &&
                            state.selectedMediasWeb.isEmpty &&
                            state.selectedVideos.isEmpty) {
                          if (fStatus != FlushbarStatus.IS_APPEARING &&
                              fStatus != FlushbarStatus.IS_HIDING &&
                              fStatus != FlushbarStatus.SHOWING) {
                            exceptionFlushBar(
                              onChangeStatus: (s) {
                                fStatus = s;
                              },
                              onHidden: () {},
                              duration: const Duration(milliseconds: 1500),
                              message: "Select at least one media!",
                              context: ctx,
                            );
                          }
                        } else {
                          Navigator.pushNamed(
                            ctx,
                            AppScreens.completeAddPostPage,
                            arguments: {
                              'bloc': _bloc,
                              'controllers': controllers
                            },
                          );
                        }
                      },
                      child: Text(
                        localizations.next,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: Dimensions.checkKIsWeb(ctx)
                              ? ctx.h * 0.032
                              : 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: ctx.w,
                height:
                    Dimensions.checkKIsWeb(ctx) ? ctx.h * 0.65 : ctx.h * 0.45,
                child: _getImagesWidget(state),
              ),
              Expanded(
                child: Stack(
                  children: [
                    (!kIsWeb)
                        ? MediaGrid(
                            key: GlobalKey(),
                            onSelectNewMedia: () {
                              if (mounted) {
                                if (defaultTargetPlatform ==
                                    TargetPlatform.iOS) {
                                  setState(() {});
                                  setState(() {
                                    shouldBuildMediaGrid = false;
                                  });
                                }
                              }
                            },
                            goAndEnablePermissions: (msg) {
                              exceptionFlushBar(
                                onChangeStatus: (s) {
                                  fStatus = s;
                                },
                                onHidden: () {
                                  Navigator.pop(ctx);
                                  openAppSettings();
                                },
                                duration: const Duration(milliseconds: 2500),
                                message: msg,
                                context: ctx,
                              );
                            },
                            selectedMedias: _selectedMedia,
                            onMediaClicked: _onMediaClicked,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: ctx.h * 0.2,
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      List<Uint8List> list = [];
                                      _picker
                                          .pickMultiImage()
                                          .then((value) async {
                                        for (int i = 0; i < value.length; i++) {
                                          list.add(
                                            await value[i].readAsBytes(),
                                          );
                                        }
                                        _bloc.add(ChangingPostImages(list));
                                        setState(() {
                                          chosenIndex = 0;
                                        });
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_sharp,
                                          color: AppColors.primaryColor,
                                        ),
                                        Text(
                                          "Upload Images",
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ctx.h * 0.2,
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      _picker
                                          .pickVideo(
                                        source: ImageSource.gallery,
                                      )
                                          .then((value) async {
                                        if (value != null) {
                                          // if (!(value.mimeType
                                          //         ?.contains("mp4") ??
                                          //     false)) {
                                          //   // MediaInfo? mediaInfo =
                                          //   // await VideoCompress.compressVideo(value.path,
                                          //   //   quality: VideoQuality
                                          //   //       .DefaultQuality,
                                          //   //   deleteOrigin: false,
                                          //   //   includeAudio: true,
                                          //   // );
                                          //   // XFile mp4Vid =
                                          //   // XFile(mediaInfo!.path!);
                                          //   // _bloc.add(AddVideoOnWeb(mp4Vid));
                                          //   exceptionFlushBar(
                                          //     onChangeStatus: (s) {
                                          //       fStatus = s;
                                          //     },
                                          //     onHidden: () {},
                                          //     duration: const Duration(
                                          //       milliseconds: 1500,
                                          //     ),
                                          //     message:
                                          //         "Only MP4 Videos Allowed",
                                          //     context: ctx,
                                          //   );
                                          //
                                          //   return;
                                          // }

                                          _bloc.add(AddVideoOnWeb(value));
                                          setState(() {});
                                        }
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_sharp,
                                          color: AppColors.primaryColor,
                                        ),
                                        Text(
                                          "Upload Video",
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getImagesWidget(AddPostState state) {
    if (kIsWeb) {
      if (state.selectedVideos.isNotEmpty) {
        return VideoPlayer(
          VideoPlayerController.network(
              state.selectedVideos[state.selectedVideos.length - 1].path)
            ..initialize()
            ..play(),
        );
      } else if (state.selectedMediasWeb.isEmpty) {
        return Center(
          child: Text(
            "No items",
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        );
      } else {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: Column(
            children: [
              SizedBox(
                width: context.w,
                height: context.h * 0.45 - 20.sp,
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      chosenIndex = index;
                    });
                  },
                  controller: PageController(viewportFraction: 1),
                  children: List.generate(
                    state.selectedMediasWeb.length,
                    (index) => SizedBox(
                      height: context.h * 0.70,
                      width: context.w,
                      child: Stack(
                        children: [
                          state.croppedFilesMap.isNotEmpty &&
                                  state.croppedFilesMap
                                      .containsKey(index.toString())
                              ? Align(
                                  alignment: Alignment.center,
                                  child: FutureBuilder<Uint8List>(
                                    future: state
                                        .croppedFilesMap[index.toString()]
                                            ['file']
                                        .readAsBytes(),
                                    builder: (context, snapshot) {
                                      return SizedBox(
                                        height: context.h * 0.70,
                                        width: context.w,
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : SizedBox(
                                  height: context.h * 0.70,
                                  width: context.w,
                                  child: Image.memory(
                                    state.selectedMediasWeb[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () async {
                                  CroppedFile? file = await _cropImage(
                                    XFile.fromData(
                                      state.selectedMediasWeb[index],
                                    ),
                                  );
                                  setState(() {
                                    _bloc.onCropImage(
                                      file!,
                                      index,
                                      index.toString(),
                                    );
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBackgroundColor,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.crop,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 12.sp,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: state.selectedMediasWeb.length,
                    itemBuilder: (_, i) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Container(
                            width: 10.sp,
                            height: 10.sp,
                            decoration: BoxDecoration(
                              color: chosenIndex == i
                                  ? AppColors.primaryColor
                                  : Colors.grey.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        );
      }
    } else {
      if (_selectedMedia.isEmpty) {
        return Center(
          child: Text(
            localizations.noSelectedItems,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        );
      } else {
        return Stack(
          children: [
            PageView(
              onPageChanged: (index) {
                _bloc.add(ChangeFocusedMediaIndex(index));
                for (var c in controllers.keys) {
                  if (controllers[c]['video'] != null) {
                    controllers[c]['video'].pause();
                    controllers[c]['isPaused'] = true;
                  }
                }
              },
              scrollDirection: Axis.horizontal,
              controller: pageCont,
              children: List.generate(
                _selectedMedia.length,
                (index) => FutureBuilder(
                  future:
                      _selectedMedia[index].assetEntity.thumbnailDataWithSize(
                            const ThumbnailSize(1024, 1024),
                          ),
                  builder: (BuildContext context, snapshot) {
                    return SizedBox(
                      height: context.h * 0.40,
                      width: context.w,
                      child: snapshot.data == null
                          ? Container()
                          : _selectedMedia[index].assetEntity.type ==
                                  AssetType.video
                              ? _getVideoWidget(
                                  _selectedMedia[index].assetEntity.id,
                                )
                              : Stack(
                                  children: [
                                    state.croppedFilesMap.isNotEmpty &&
                                            state.croppedFilesMap.containsKey(
                                              _selectedMedia[index]
                                                  .assetEntity
                                                  .id,
                                            )
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: Image.file(
                                              File(
                                                state
                                                    .croppedFilesMap[state
                                                        .selectedMedias[index]
                                                        .assetEntity
                                                        .id]['file']
                                                    .path,
                                              ),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          )
                                        : Align(
                                            alignment: Alignment.center,
                                            child: Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _selectedMedia[index]
                                                .assetEntity
                                                .file
                                                .then((value) async {
                                              CroppedFile? file =
                                                  await _cropImage(
                                                XFile(value!.path),
                                              );
                                              setState(() {
                                                _bloc.onCropImage(
                                                  file!,
                                                  index,
                                                  _selectedMedia[index]
                                                      .assetEntity
                                                      .id,
                                                );
                                              });
                                            });
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .secondaryBackgroundColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(
                                                  10,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.crop,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                    );
                  },
                ),
              ),
            ),
            if (_selectedMedia.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: _selectedMedia.length * 18,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: Colors.grey.withOpacity(0.65),
                    ),
                    child: SizedBox(
                      height: 18,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _selectedMedia.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              height: 5,
                              width: 5,
                              decoration: BoxDecoration(
                                color: state.currentFocusedIndex == index
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
        );
      }
    }
  }

  Widget _getVideoWidget(String mediaKey) {
    if (controllers[mediaKey] != null) {
      return GestureDetector(
        onTap: () {
          controllers[mediaKey]['isPaused']
              ? controllers[mediaKey]['video']!.play()
              : controllers[mediaKey]['video']!.pause();
          setState(() {
            controllers[mediaKey]['isPaused'] =
                !controllers[mediaKey]['isPaused'];
          });
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: controllers[mediaKey]['video'].value.aspectRatio,
                child: VideoPlayer(controllers[mediaKey]['video']!),
              ),
            ),
            controllers[mediaKey]['isPaused']
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
      );
    } else {
      return Container();
    }
  }

  Future<CroppedFile?> _cropImage(XFile pickedFile) async {
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
            width: (context.w * 0.5).toInt(),
            height: (context.h * 0.5).toInt(),
          ),
          viewPort: CroppieViewPort(
            width: (context.w * 0.5).toInt(),
            height: (context.h * 0.5).toInt(),
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

  void _onMediaClicked(MediaSource media) async {
    if (_selectedMedia.any(
      (element) => element.assetEntity.id == media.assetEntity.id,
    )) {
      setState(() {
        _selectedMedia.removeWhere(
          (element) => element.assetEntity.id == media.assetEntity.id,
        );

        if (media.assetEntity.type == AssetType.video) {
          controllers[media.assetEntity.id]['video']!.dispose();
          controllers.remove(media.assetEntity.id);
        }
      });
    } else {
      if (media.assetEntity.type == AssetType.video) {
        File? file = await media.assetEntity.file;
        VideoPlayerController videoPlayerController =
            VideoPlayerController.file(file!)
              ..initialize().then((v) {
                setState(() {});
              });

        controllers[media.assetEntity.id] = {
          'video': videoPlayerController,
          'isPaused': true
        };

        pageCont.nextPage(
            duration: Duration(milliseconds: 250), curve: Curves.bounceIn);
        setState(() {
          _selectedMedia.add(media);
        });
      } else {
        if (_selectedMedia.isNotEmpty) {
          pageCont.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.bounceIn);
        }
        setState(() {
          _selectedMedia.add(media);
        });
      }
    }
  }
}

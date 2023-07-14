import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/add_new_post_feature/presentation/pages/add_post_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaGrid extends StatefulWidget {
  final List<MediaSource> selectedMedias;
  final Function(MediaSource) onMediaClicked;
  final Function(String) goAndEnablePermissions;
  final VoidCallback onSelectNewMedia;

  const MediaGrid({
    required this.selectedMedias,
    required this.onMediaClicked,
    required this.goAndEnablePermissions,
    required this.onSelectNewMedia,
    super.key,
  });

  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  final List<MediaSource> _mediaList = [];
  late PermissionState permissionState;
  List<MediaSource> filteredMediaList = [];
  int currentPage = 0;
  int? lastPage;
  List<String> postTypes = ["Recent", "Photos", "Videos"];
  String postTypeValue = "Recent";
  ImagePicker imagePicker = ImagePicker();
  bool reAsk = true;
  bool _hasSelectedPhotos = false;
  bool _firstTime = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      _loadSelectedPhotosFlag();

      _firstTime = false;
    }
  }

  void _handleScrollEvent(ScrollNotification scroll) async {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        await _fetchNewMedia();
      }
    }
  }

  RequestType getType() {
    switch (postTypeValue) {
      case "Recent":
        return RequestType.common;
      case "Photos":
        return RequestType.image;
      case "Videos":
        return RequestType.video;
      default:
        return RequestType.common;
    }
  }

  Future<List<MediaSource>> _fetchNewMedia({RequestType? type}) async {
    lastPage = currentPage;

    if (permissionState.hasAccess) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: type ?? getType(),
      );

      List<AssetEntity> media = albums.isEmpty
          ? []
          : await albums[0].getAssetListPaged(page: currentPage, size: 200);

      List<MediaSource> temp = [];

      for (var asset in media) {
        temp.add(
          MediaSource(
            widget: FutureBuilder(
              future:
                  asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (asset.type == AssetType.video)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                return Container();
              },
            ),
            assetEntity: asset,
          ),
        );
      }

      setState(() {
        for (final tmpMedia in temp) {
          if (!_mediaList.any(
            (element) => element.assetEntity.id == tmpMedia.assetEntity.id,
          )) {
            _mediaList.add(tmpMedia);
          }
        }

        if (temp.isNotEmpty) {
          _updateSelectedPhotosFlag(permissionState);
          currentPage++;
        }
      });

      if ((type != null && type == RequestType.video) ||
          getType() == RequestType.video) {
        filteredMediaList = _mediaList
            .where((element) => element.assetEntity.type == AssetType.video)
            .toList();
        setState(() {});
      } else if ((type != null && type == RequestType.image) ||
          getType() == RequestType.image) {
        filteredMediaList.addAll(temp);
        setState(() {});
      } else if ((type != null && type == RequestType.common) ||
          getType() == RequestType.common) {
        _mediaList.sort(
          (a, b) => b.assetEntity.createDateSecond!
              .compareTo(a.assetEntity.createDateSecond!),
        );
        setState(() {});
      }

      if (shouldBuildMediaGrid) {
        widget.onSelectNewMedia();
      }

      return _mediaList;
    } else {
      await Permission.storage.isPermanentlyDenied.then((v) {
        if (v) {
          Permission.notification.request();
        } else {
          Permission.notification.request();
        }
      });

      await Permission.storage.isDenied.then((v) {
        if (v) {
          Permission.storage.request().then((vv) async {
            if (vv.isGranted) {
              if (reAsk) {
                await _fetchNewMedia();

                reAsk = false;
              }
            }
          });
        } else {
          Permission.storage.request().then((vv) async {
            if (vv.isGranted) {
              if (reAsk) {
                await _fetchNewMedia();

                reAsk = false;
              }
            }
          });
        }
      });
      Permission.storage.request().then((vv) async {
        if (vv.isGranted) {
          if (reAsk) {
            await _fetchNewMedia();

            reAsk = false;
          }
        }
      });

      if (shouldBuildMediaGrid) {
        widget.onSelectNewMedia();
      }

      return _mediaList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: UniqueKey(),
      children: [
        getPostOptionsWidget(),
        Expanded(
          key: UniqueKey(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scroll) {
              _handleScrollEvent(scroll);
              return false;
            },
            child: GridView.builder(
              key: UniqueKey(),
              itemCount: filteredMediaList.isEmpty
                  ? _mediaList.length
                  : filteredMediaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (BuildContext context, int index) {
                MediaSource currentMedia = filteredMediaList.isEmpty
                    ? _mediaList[index]
                    : filteredMediaList[index];
                return InkWell(
                  onTap: () async {
                    currentMedia.file = await currentMedia.assetEntity.file;
                    _mediaList.add(_mediaList[0]);
                    widget.onMediaClicked(currentMedia);
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: currentMedia.widget,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5, top: 5),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: widget.selectedMedias
                                  .contains(currentMedia)
                                  ? AppColors.primaryColor
                                  : Colors.grey.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: widget.selectedMedias
                                  .contains(currentMedia)
                                  ? null
                                  : Border.all(color: Colors.white),
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
      ],
    );
  }

  Future<int> getSelectedItemNumbered(
    List<MediaSource> big,
    List<MediaSource> small,
  ) async {
    for (int i = 0; i < big.length; i++) {
      String bigPath = "";
      await big[i].assetEntity.file.then((value) {
        bigPath = value!.path;
      });
      for (int j = 0; j < small.length; j++) {
        String smallPath = "";
        await small[j].assetEntity.file.then((value) {
          smallPath = value!.path;
        });
        if (bigPath == smallPath) {
          return i + 1;
        }
      }
    }
    return -1;
  }

  Widget getPostOptionsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          kIsWeb
              ? Container()
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: postTypeValue,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.white,
                    ),
                    items: postTypes.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: value == postTypeValue
                                ? Colors.grey
                                : Colors.grey,
                            fontWeight:
                                value == postTypeValue ? FontWeight.bold : null,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == "Recent") {
                        _mediaList.sort(
                          (a, b) => b.assetEntity.createDateSecond!
                              .compareTo(a.assetEntity.createDateSecond!),
                        );
                        filteredMediaList = [];
                        setState(() {
                          postTypeValue = value!;
                        });
                      } else if (value == "Photos") {
                        filteredMediaList = _mediaList
                            .where(
                              (element) =>
                                  element.assetEntity.type == AssetType.image,
                            )
                            .toList();
                        setState(() {
                          postTypeValue = value!;
                        });
                      } else if (value == "Videos") {
                        filteredMediaList = _mediaList
                            .where(
                              (element) =>
                                  element.assetEntity.type == AssetType.video,
                            )
                            .toList();
                        setState(() {
                          postTypeValue = value!;
                        });

                        if (filteredMediaList.isEmpty) {
                          filteredMediaList =
                              await _fetchNewMedia(type: RequestType.video)
                                  .then(
                            (value) => value
                                .where(
                                  (element) =>
                                      element.assetEntity.type ==
                                      AssetType.video,
                                )
                                .toList(),
                          );

                          setState(() {});
                        }
                      }
                    },
                  ),
                ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: Dimensions.checkKIsWeb(context)
                          ? context.w * 0.0225
                          : context.w * 0.055,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (defaultTargetPlatform == TargetPlatform.iOS)
                GestureDetector(
                  onTap: () async {
                    permissionState =
                        await PhotoManager.requestPermissionExtend();

                    if (permissionState == PermissionState.limited) {
                      await PhotoManager.presentLimited();
                    }

                    await _fetchNewMedia();

                    setState(() {});

                    widget.onSelectNewMedia();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.0225
                              : context.w * 0.055,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  void _updateSelectedPhotosFlag(PermissionState permissionState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSelectedPhotos', true);
    prefs.setInt('permissionState', permissionState.index);
    setState(() {
      _hasSelectedPhotos = true;
    });
  }

  Future<void> _loadSelectedPhotosFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    void changeNotify(MethodCall call) {
      widget.onSelectNewMedia();

      setState(() {});
    }

    PhotoManager.addChangeCallback(changeNotify);

    _hasSelectedPhotos = prefs.getBool('hasSelectedPhotos') ?? false;
    permissionState =
        PermissionState.values[prefs.getInt('permissionState') ?? 0];

    permissionState = await PhotoManager.requestPermissionExtend();

    await _fetchNewMedia();

    Future.delayed(Duration(seconds: 1), () {
      PhotoManager.startChangeNotify();
    });
  }
}

class MediaSource {
  final Widget widget;
  final AssetEntity assetEntity;
  File? file;

  MediaSource({required this.widget, required this.assetEntity, this.file});
}

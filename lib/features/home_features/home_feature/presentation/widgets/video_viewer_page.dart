import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class VideoViewerPage extends StatefulWidget {
  final String url;
  final String heroId;

  const VideoViewerPage({required this.url, required this.heroId, Key? key})
      : super(key: key);

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late VideoPlayerController _controller;

  late AppLocalizations localizations;

  bool isPaused = false;
  late final Future<void> initVideo;

  bool isLoading = true;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((v) {
        setState(() {
          isLoading = false;
        });
      })
      ..play()
      ..setLooping(false);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroId,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(),
        ),
        body: GestureDetector(
          onTap: () {
            if (isPaused) {
              _controller.play();
              setState(() {
                isPaused = !isPaused;
              });
            } else {
              _controller.pause();
              setState(() {
                isPaused = !isPaused;
              });
            }
          },
          onPanUpdate: (details) {
            if (details.delta.dy < -5) {
              Navigator.pop(context);
            }
          },
          child: SizedBox(
            width: context.w,
            height: context.h,
            child: Stack(
              children: [
                !_controller.value.isInitialized ? Container() :  Align(
                  alignment: Alignment.center,
                  child: InkWell(
                      onTap: () {
                        if (isPaused) {
                          _controller.play();
                          setState(() {
                            isPaused = !isPaused;
                          });
                        } else {
                          _controller.pause();
                          setState(() {
                            isPaused = !isPaused;
                          });
                        }
                      },
                      child: SizedBox(
                        width: context.w,
                        height: context.h,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio * 0.85,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(
                                    _controller,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: context.w,
                                height: context.h,
                                child: GestureDetector(
                                  onTap: () {
                                    if (isPaused) {
                                      _controller.play();
                                      setState(() {
                                        isPaused = !isPaused;
                                      });
                                    } else {
                                      _controller.pause();
                                      setState(() {
                                        isPaused = !isPaused;
                                      });
                                    }
                                  },
                                ),
                              ),
                              isPaused
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _controller.value.position !=
                                                  _controller.value.duration
                                              ? GestureDetector(
                                                  onTap: () {
                                                    _controller.play();
                                                    setState(() {
                                                      isPaused = !isPaused;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey
                                                            .withOpacity(0.5),),
                                                    child: const Center(
                                                      child: Icon(
                                                          Icons.play_arrow,
                                                          size: 30,
                                                          color: Colors.black,),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          _controller.value.position ==
                                                  _controller.value.duration
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    _controller.seekTo(
                                                        const Duration(seconds: 0),);
                                                    _controller.play();
                                                    setState(() {
                                                      isLoading = false;
                                                      isPaused = !isPaused;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey
                                                            .withOpacity(0.5),),
                                                    child: const Center(
                                                      child: Icon(Icons.refresh,
                                                          color: Colors.black,
                                                          size: 30,),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 6.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomBackButton(
                      arrowColor: AppColors.primaryColor,
                      backgroundColor: Colors.transparent,
                      onBackClicked: () {
                        Navigator.pop(context);
                      },
                      localeName: localizations.localeName,
                    ),
                  ),
                ),
                isLoading ||  !_controller.value.isInitialized
                    ? Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppColors.primaryColor,),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';
import 'package:pod_player/pod_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoViewerPage2 extends StatefulWidget {
  final PostModel post;
  final int mediaIndex;
  final String heroId;
  final HolderBloc holderBloc;
  final Function(String) onAddLike;
  final Function onDisLike;
  final Function(Map) onDisposeHorizontalList;
  final bool withClickOnProfile;
  final Function(int) onBackFromComments;
  final Function onLikesClicked;
  final Function onEditPost;
  final Function onDeletePost;

  const VideoViewerPage2({
    required this.post,
    required this.mediaIndex,
    required this.holderBloc,
    required this.heroId,
    required this.onAddLike,
    required this.onBackFromComments,
    required this.onLikesClicked,
    required this.onDisLike,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onDisposeHorizontalList,
    this.withClickOnProfile = true,
    super.key,
  });

  @override
  State<VideoViewerPage2> createState() => _VideoViewerPage2State();
}

class _VideoViewerPage2State extends State<VideoViewerPage2> {

  late AppLocalizations localizations;

  bool isPaused = false;
  late final Future<void> initVideo;


  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (!(widget.post.medias[widget.mediaIndex].videoPlayerController?.value
        .isInitialized ??
        false)) {
      widget.post.medias[widget.mediaIndex]
          .videoPlayerController = VideoPlayerController.network(
        widget.post.medias[widget.mediaIndex].url,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      )
        ..initialize().then((v) {
          // state.posts[index].medias[0].isLoading = false;
          widget.post.streamer
              .add({'ratio': 1, 'currentDurationInSeconds': 0});
          widget.post.medias[widget.mediaIndex].isLoading = false;
          widget.post.medias[widget.mediaIndex].videoPlayerController!.addListener(() {
            widget.post.streamer.add({
              'ratio': 1,
              'currentDurationInSeconds': widget.post.medias[widget.mediaIndex]
                  .videoPlayerController!.value.position.inSeconds
            });
          });
          widget.post.medias[widget.mediaIndex].videoPlayerController?.play();
          setState(() {});
        })
        ..setVolume(1.0);
    }
    else{
      setState(() {
        widget.post.medias[widget.mediaIndex].videoPlayerController?.setVolume(1.0);
        widget.post.medias[widget.mediaIndex].isLoading = false;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();
    widget.post.medias[widget.mediaIndex]
        .videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.post.medias[widget.mediaIndex].url),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: true,
      ),
    )
      ..initialize().then((v) {
        // state.posts[index].medias[0].isLoading = false;
        widget.post.streamer
            .add({'ratio': 1, 'currentDurationInSeconds': 0});
        widget.post.medias[widget.mediaIndex].isLoading = false;
        widget.post.medias[widget.mediaIndex].videoPlayerController!.addListener(() {
          widget.post.streamer.add({
            'ratio': 1,
            'currentDurationInSeconds': widget.post.medias[widget.mediaIndex]
                .videoPlayerController!.value.position.inSeconds
          });
        });
        widget.post.medias[widget.mediaIndex].videoPlayerController?.play();
        // setState(() {});
      })
      ..setVolume(0.0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HolderBloc, HolderState>(
      bloc: widget.holderBloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(),
          ),
          body: GestureDetector(
            onTap: () {
              if (isPaused) {
                widget.post.medias[widget.mediaIndex].videoPlayerController!.play();
                setState(() {
                  isPaused = !isPaused;
                });
              } else {
                widget.post.medias[widget.mediaIndex].videoPlayerController!.pause();
                setState(() {
                  isPaused = !isPaused;
                });
              }
            },
            onPanUpdate: (details) {
              if (details.delta.dy < -5) {
                // Navigator.pop(context);
              }
            },
            child: SizedBox(
              width: context.w,
              height: context.h,
              child: Stack(
                children: [
                  !widget.post.medias[widget.mediaIndex].videoPlayerController!.value.isInitialized
                      ? Container()
                      : Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              if (isPaused) {
                                widget.post.medias[widget.mediaIndex].videoPlayerController!.play();
                                setState(() {
                                  isPaused = !isPaused;
                                });
                              } else {
                                widget.post.medias[widget.mediaIndex].videoPlayerController!.pause();
                                setState(() {
                                  isPaused = !isPaused;
                                });
                              }
                            },
                            child: SizedBox(
                              width: context.w,
                              height: context.h,
                              child: AspectRatio(
                                aspectRatio:
                                widget.post.medias[widget.mediaIndex].videoPlayerController!.value.aspectRatio,
                                child: Stack(
                                  children: [
                                    VisibilityDetector(
                                      onVisibilityChanged: (info) {
                                        if (info.visibleFraction < 1) {
                                          if (widget.post.medias[widget.mediaIndex].videoPlayerController!.value.isInitialized) {
                                            widget.post.medias[widget.mediaIndex].videoPlayerController!.pause();
                                          }
                                        } else {
                                          widget.post.medias[widget.mediaIndex].videoPlayerController!
                                            ..play()
                                            ..setLooping(false);
                                        }
                                      },
                                      key: ValueKey(
                                        widget
                                            .post.medias[widget.mediaIndex].url,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: VideoPlayer(
                                          widget.post.medias[widget.mediaIndex].videoPlayerController!,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.w,
                                      height: context.h,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (isPaused) {
                                            widget.post.medias[widget.mediaIndex].videoPlayerController!.play();
                                            setState(() {
                                              isPaused = !isPaused;
                                            });
                                          } else {
                                            widget.post.medias[widget.mediaIndex].videoPlayerController!.pause();
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
                                                widget.post.medias[widget.mediaIndex].videoPlayerController!.value.position !=
                                                    widget.post.medias[widget.mediaIndex].videoPlayerController!
                                                            .value.duration
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          widget.post.medias[widget.mediaIndex].videoPlayerController!.play();
                                                          setState(() {
                                                            isPaused =
                                                                !isPaused;
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                              0.5,
                                                            ),
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.play_arrow,
                                                              size: 30,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                widget.post.medias[widget.mediaIndex].videoPlayerController!.value.position ==
                                                    widget.post.medias[widget.mediaIndex].videoPlayerController!
                                                            .value.duration
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            widget.post.medias[widget.mediaIndex].isLoading = true;
                                                          });
                                                          widget.post.medias[widget.mediaIndex].videoPlayerController!.seekTo(
                                                            const Duration(
                                                              seconds: 0,
                                                            ),
                                                          );
                                                          widget.post.medias[widget.mediaIndex].videoPlayerController!.play();
                                                          setState(() {
                                                            widget.post.medias[widget.mediaIndex].isLoading = false;
                                                            isPaused =
                                                                !isPaused;
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                              0.5,
                                                            ),
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.refresh,
                                                              color:
                                                                  Colors.black,
                                                              size: 30,
                                                            ),
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
                            ),
                          ),
                        ),
                  widget.post.medias[widget.mediaIndex].isLoading
                      ? Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.primaryColor,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

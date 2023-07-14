import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/data/models/post_model.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';

class ImageViewerPage2 extends StatefulWidget {
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
  final VoidCallback enableScrolling, disableScrolling;

  const ImageViewerPage2({
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
    required this.disableScrolling,
    required this.enableScrolling,
    this.withClickOnProfile = true,
    Key? key,
  }) : super(key: key);

  @override
  State<ImageViewerPage2> createState() => _ImageViewerPage2State();
}

class _ImageViewerPage2State extends State<ImageViewerPage2>
    with SingleTickerProviderStateMixin {
  late AppLocalizations localizations;
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4?>? animation;
  BoxFit _boxFit = BoxFit.fitWidth;
  bool _firstTime = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      localizations = AppLocalizations.of(context)!;
      controller = TransformationController();
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      )..addListener(() => controller.value = animation!.value!);

      if (widget.post.medias[widget.mediaIndex].meta != null) {
        if (widget.post.medias[widget.mediaIndex].meta!.width >
            widget.post.medias[widget.mediaIndex].meta!.height) {
          _boxFit = BoxFit.contain;
        } else {
          _boxFit = BoxFit.contain;
        }
      }

      _firstTime = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HolderBloc, HolderState>(
      bloc: widget.holderBloc,
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(),
          ),
          body: SizedBox(
            height: context.h,
            width: context.w,
            child: getZoomableImageWidget(),
          ),
        );
      },
    );
  }

  Widget getZoomableImageWidget() {
    return Listener(
      onPointerPanZoomStart: (_) {
        widget.disableScrolling();
      },
      onPointerPanZoomEnd: (_) {
        widget.enableScrolling();
      },
      child: InteractiveViewer(
        panEnabled: true,
        transformationController: controller,
        clipBehavior: Clip.none,
        child: Image.network(
          widget.post.medias[widget.mediaIndex].url,
          fit: _boxFit,
          width: context.w,
          height: context.h,
        ),
        onInteractionEnd: (details) {
          resetInteraction(details);
        },
        onInteractionStart: (details) {
          if (details.pointerCount < 2) return;
        },
        onInteractionUpdate: (details) {
          if (details.pointerCount < 2) {
            if (details.focalPointDelta.dy < -5) {
              // Navigator.of(context).pop();
            }
          }
        },
      ),
    );
  }

  void resetInteraction(details) {
    animation =
        Matrix4Tween(begin: controller.value, end: Matrix4.identity()).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    animationController.forward(from: 0);
  }
}

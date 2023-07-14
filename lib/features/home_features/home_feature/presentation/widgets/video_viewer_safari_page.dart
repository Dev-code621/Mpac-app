import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VideoViewerSafariPage extends StatefulWidget {
  final String url;

  const VideoViewerSafariPage({required this.url, Key? key}) : super(key: key);

  @override
  State<VideoViewerSafariPage> createState() => _VideoViewerSafariPageState();
}

class _VideoViewerSafariPageState extends State<VideoViewerSafariPage> {
  late PodPlayerController controller;
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        widget.url,
      ),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: CustomBackButton(
          arrowColor: AppColors.primaryColor,
          onBackClicked: () {
            Navigator.pop(context);
          },
          localeName: localizations.localeName,
        ),
      ),
      body: PodVideoPlayer(
          controller: controller,
          frameAspectRatio: controller.videoPlayerValue == null
              ? (16/9)
              : controller.videoPlayerValue!.aspectRatio,),
    );
  }
}

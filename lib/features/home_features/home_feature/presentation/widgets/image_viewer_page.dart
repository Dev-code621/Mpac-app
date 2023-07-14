import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';
import 'package:sizer/sizer.dart';

class ImageViewerPage extends StatefulWidget {
  final String urlStr;
  final String heroId;
  final HolderBloc holderBloc;

  const ImageViewerPage({
    required this.urlStr,
    required this.holderBloc,
    required this.heroId,
    Key? key,
  }) : super(key: key);

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  late AppLocalizations localizations;
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4?>? animation;

  @override
  void initState() {
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => controller.value = animation!.value!);
  }

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HolderBloc, HolderState>(
      bloc: widget.holderBloc,
      builder: (context, state) {
        return Hero(
          tag: widget.heroId,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            bottomNavigationBar: _bottomNavigationBar(state),
            body: SizedBox(
              height: context.h,
              width: context.w,
              child: Column(
                children: [
                  Align(
                    alignment: localizations.localeName == "ar"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: CustomBackButton(
                      localeName: localizations.localeName,
                      onBackClicked: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: context.h,
                      width: context.w,
                      child: getZoomableImageWidget(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomNavigationBar(HolderState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.11 +
          MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/home.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/home.svg',
                  tabIndex: homeTab,
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/trending.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/trending.svg',
                  tabIndex: trendingTab,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.085,
                  width: MediaQuery.of(context).size.height * 0.085,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.logoColor,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppScreens.addNewPostPage,
                      );
                    },
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/inbox.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/inbox.svg',
                  tabIndex: inboxTab,
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/profile.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/profile.svg',
                  tabIndex: profileTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tabWidget({
    required HolderState state,
    required svgPath,
    required inActiveSvgPath,
    required int tabIndex,
  }) {
    return InkWell(
      onTap: () => _navigateTo(tabIndex),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 6.h,
            height: 6.h,
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    state.currentPageIndex == tabIndex
                        ? svgPath
                        : inActiveSvgPath,
                    height: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.03
                        : context.h * 0.027,
                  ),
                ),
              ],
            ),
          ),
          // Expanded(child: SizedBox())
          Text(
            getTitleBasedOnIndex(tabIndex),
            style: TextStyle(
              fontSize:
                  Dimensions.checkKIsWeb(context) ? context.h * 0.026 : 11.sp,
              color: state.currentPageIndex == tabIndex
                  ? Colors.white
                  : AppColors.unSelectedWidgetColor,
            ),
          )
        ],
      ),
    );
  }

  String getTitleBasedOnIndex(int index) {
    switch (index) {
      case 0:
        return localizations.home;
      case 1:
        return localizations.trending;
      case 2:
        return localizations.inbox;
      default:
        return localizations.profile;
    }
  }

  void _navigateTo(int index) {
    Navigator.of(context).pop();
    widget.holderBloc.onChangePageIndex(index);
  }

  Widget getZoomableImageWidget() {
    return Builder(
      builder: (context) {
        return InteractiveViewer(
          panEnabled: true,
          transformationController: controller,
          clipBehavior: Clip.none,
          child: Image.network(
            widget.urlStr,
            fit: BoxFit.contain,
            width: context.w,
          ),
          onInteractionEnd: (details) {
            resetInteraction(details);
          },
          onInteractionStart: (details) {
            if (details.pointerCount < 2) return;
            // if(entry == null) {
            //   showOverlay(context, index);
            // }
          },
          onInteractionUpdate: (details) {
            if (details.pointerCount < 2) {
              if (details.focalPointDelta.dy < -5) {
                Navigator.of(context).pop();
              }
            }
          },
        );
      },
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

import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_app_logo.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/widgets/custom_background_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnBoardingStepsPage extends StatefulWidget {
  const OnBoardingStepsPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingStepsPage> createState() => _OnBoardingStepsPageState();
}

class _OnBoardingStepsPageState extends State<OnBoardingStepsPage> {
  late AppLocalizations localizations;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(),
      ),
      body: SizedBox(
        width: context.w,
        height: context.h,
        child: Stack(
          children: [
            const CustomBackgroundWidget(),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(height: context.h * 0.07),
                  Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomAppLogo(),
                        SizedBox(
                          height: context.h * 0.1,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0,),
                    child: Container(
                      width: context.w,
                      height: context.h * 0.4, // 0.325
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: Column(
                          children: [
                            Expanded(child: getPageViewWidget()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppScreens.signInPage,
                                          (route) => false,);
                                    },
                                    child: Text(
                                      localizations.skip,
                                      style: TextStyle(
                                        color: AppColors.secondaryFontColor,
                                        fontSize: Dimensions.checkKIsWeb(context)  ? context.h * 0.025 : 10.sp,
                                      ),
                                    ),),
                                Row(
                                  children: [
                                    Text(
                                      "${_currentPage + 1}/3",
                                      style: TextStyle(
                                        color: AppColors.secondaryFontColor,
                                        fontSize: Dimensions.checkKIsWeb(context)  ? context.h * 0.025 : 10.sp,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (_currentPage == 2) {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              AppScreens.signInPage,
                                              (route) => false,);
                                        } else {
                                          _pageController.animateToPage(
                                            _currentPage + 1,
                                            curve: Curves.ease,
                                            duration: const Duration(
                                                milliseconds: 500,),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: context.h * 0.06,
                                        width: context.h * 0.08,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primaryColor,),
                                        child: Center(
                                            child: Icon(
                                          localizations.localeName == "en"
                                              ? Icons.arrow_forward_ios_rounded
                                              : Icons.arrow_back_ios,
                                          color: Colors.white,
                                        ),),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPageViewWidget() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [
        Column(
          children: [
            Text(
              "Manage your training\nsessions",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryFontColor,
                fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.04 : 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0),
              child: Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(
                  color: AppColors.secondaryFontColor,
                  fontSize: Dimensions.checkKIsWeb(context)  ? context.h * 0.025 : 10.sp,
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Manage your training\nsessions",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryFontColor,
                fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.04 : 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0),
              child: Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(
                  color: AppColors.secondaryFontColor,
                  fontSize: Dimensions.checkKIsWeb(context)  ? context.h * 0.025 : 10.sp,
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Manage your training\nsessions",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryFontColor,
                fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.04 : 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0),
              child: Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(
                  color: AppColors.secondaryFontColor,
                  fontSize: Dimensions.checkKIsWeb(context)  ? context.h * 0.025 : 10.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class CustomAppBarWidget extends StatelessWidget {
  final String localeName;
  final Color backgroundColor;
  final Function? onBack;

  const CustomAppBarWidget({
    this.backgroundColor = Colors.black,
    this.onBack,
    required this.localeName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      width: context.w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logos/filled_app_logo.svg',
                  width: Dimensions.checkKIsWeb(context)
                      ? context.w * 0.035
                      : context.w * 0.075,
                  height: Dimensions.checkKIsWeb(context)
                      ? context.w * 0.035
                      : context.w * 0.075,
                  color: AppColors.logoColor,
                ),
                const SizedBox(width: 8),
                // Image.asset('assets/images/logos/logo_text.png',
                //   color: AppColors.logoColor,)
                Text(
                  "MPAC SPORTS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.032
                        : 13.sp,
                    color: AppColors.primaryColor,
                  ),
                )
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppScreens.notificationsPage)
                        .then((value) {
                      (context as Element).markNeedsBuild();
                    });
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 35,
                        height: 35,
                        child: Center(
                          child: Icon(
                            Icons.notifications,
                            color: AppColors.unSelectedWidgetColor,
                          ),
                        ),
                      ),
                      notificationsCount == 0
                          ? Container()
                          : Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    notificationsCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Dimensions.checkKIsWeb(context)
                                          ? context.h * 0.006
                                          : 6.sp,
                                    ),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppScreens.myAccountPage)
                        .then((value) {
                      (context as Element).markNeedsBuild();
                      if (onBack != null) {
                        onBack!();
                      }
                    });
                  },
                  child: Container(
                    width: Dimensions.checkKIsWeb(context)
                        ? context.w * 0.04
                        : context.w * 0.08,
                    height: context.h * 0.08,
                    decoration: getIt<SharedPreferences>().getString(
                              SharedPreferencesKeys.userProfilePicture,
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
                                getIt<SharedPreferences>().getString(
                                  SharedPreferencesKeys.userProfilePicture,
                                )!,
                              ),
                              fit: !kIsWeb ? BoxFit.contain : BoxFit.cover,
                            ),
                          ),
                    child: getIt<SharedPreferences>().getString(
                              SharedPreferencesKeys.userProfilePicture,
                            ) ==
                            null
                        ? Icon(
                            Icons.person,
                            color: Colors.grey.withOpacity(0.5),
                            size: Dimensions.checkKIsWeb(context)
                                ? context.w * 0.02
                                : context.w * 0.05,
                          )
                        : Container(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

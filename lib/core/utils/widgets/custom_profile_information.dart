import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/shared_keys.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

class CustomProfileInformation extends StatelessWidget {
  const CustomProfileInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: kIsWeb ? context.w * 0.17 : context.w * 0.35,
          height: kIsWeb ? context.w * 0.17 : context.w * 0.35,
          child: Stack(
            children: [
              Container(
                width: kIsWeb ? context.w * 0.17 : context.w * 0.35,
                height: kIsWeb ? context.w * 0.17 : context.w * 0.35,
                decoration: BoxDecoration(
                  color: getIt<SharedPreferences>().getString(
                            SharedPreferencesKeys.userProfilePicture,
                          ) ==
                          null
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  /*  image: getIt<SharedPreferences>().getString(
                                SharedPreferencesKeys.userProfilePicture) ==
                            null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(getIt<SharedPreferences>()
                                .getString(
                                    SharedPreferencesKeys.userProfilePicture)!),
                            fit: BoxFit.cover)*/
                ),
                child: getIt<SharedPreferences>().getString(
                          SharedPreferencesKeys.userProfilePicture,
                        ) !=
                        null
                    ? ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100)),
                        child: Image.network(
                          getIt<SharedPreferences>().getString(
                            SharedPreferencesKeys.userProfilePicture,
                          )!,
                          loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primaryColor,
                              ),
                            );
                          },
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.black54,
                        size: kIsWeb ? context.w * 0.06 : context.w * 0.1,
                      ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: kIsWeb ? context.h * 0.0265 : 11.sp,
                  ),
                ),
                getIt<PrefsHelper>().userInfo().firstName == null
                    ? Container()
                    : Text(
                        "${getIt<PrefsHelper>().userInfo().firstName!} ${getIt<PrefsHelper>().userInfo().lastName!}",
                        style: TextStyle(
                          color: AppColors.secondaryFontColor,
                          fontSize: kIsWeb ? context.h * 0.025 : 10.sp,
                        ),
                      ),
                const SizedBox(
                  height: 6,
                ),
                Container(
                  color: AppColors.secondaryFontColor,
                  height: 0.5,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: kIsWeb ? context.h * 0.0265 : 11.sp,
                  ),
                ),
                Text(
                  getIt<PrefsHelper>().userInfo().email!,
                  style: TextStyle(
                    color: AppColors.secondaryFontColor,
                    fontSize: kIsWeb ? context.h * 0.025 : 10.sp,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Container(
                  color: AppColors.secondaryFontColor,
                  height: 0.5,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "Mobile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: kIsWeb ? context.h * 0.0265 : 11.sp,
                  ),
                ),
                Text(
                  getIt<PrefsHelper>().userInfo().mobileNumber == null
                      ? "-"
                      : getIt<PrefsHelper>().userInfo().mobileNumber!,
                  style: TextStyle(
                    color: AppColors.secondaryFontColor,
                    fontSize: kIsWeb ? context.h * 0.025 : 10.sp,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color(0xffD9D9D9).withOpacity(0.8);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        height: size.height,
        width: size.width,
      ),
      math.pi * 0.185, // 0.5
      math.pi / 1.6, // 1.5
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class CustomAppLogo extends StatelessWidget {
  const CustomAppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        SvgPicture.asset(
          'assets/images/logos/app_logo.svg',
          width: kIsWeb? context.h * 0.17 :context.w * 0.25,
          height:kIsWeb? context.h * 0.17 : context.h * 0.15,
          color: AppColors.logoColor,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "GT",
          style: TextStyle(fontFamily: "Inter",
              fontWeight: FontWeight.bold,
              fontSize: 23.sp,
              color: AppColors.logoColor,),
        )
      ],
    );
  }
}

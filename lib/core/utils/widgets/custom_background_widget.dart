import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';

import 'package:mpac_app/core/utils/constants/colors.dart';

class CustomBackgroundWidget extends StatelessWidget {
  const CustomBackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: context.h * 0.40,
            width: context.w * 0.40,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primaryColor,),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: context.h * 0.40,
            width: context.w * 0.40 ,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primaryColor,),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(
            color: Colors.black.withOpacity(0.40),
            height: context.h,
            width: context.w,
            alignment: Alignment.center,
          ),
        ),
      ],
    );
  }


}

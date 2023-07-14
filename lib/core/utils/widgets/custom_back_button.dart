import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';

import 'package:mpac_app/core/utils/constants/colors.dart';

class CustomBackButton extends StatelessWidget {
  final Function onBackClicked;
  final String localeName;
  final Color? arrowColor;
  final Color? backgroundColor;

  const CustomBackButton(
      {Key? key,
      required this.onBackClicked,
      required this.localeName, this.backgroundColor = Colors.transparent,
       this.arrowColor,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onBackClicked();
      },
      child: Container(
        width: Dimensions.checkKIsWeb(context)  ? context.h * 0.08 :context.w * 0.15,
        height: Dimensions.checkKIsWeb(context)  ? context.h * 0.08 :context.w * 0.15,
        decoration:  BoxDecoration(
          color: backgroundColor,
            borderRadius:const BorderRadius.all(Radius.circular(8)),),
        child: Padding(
          padding: EdgeInsets.only(
              left: localeName == "en" ? 8.0 : 0.0,
              right: localeName == "ar" ? 8.0 : 0.0,),
          child: Icon(
              localeName == "en"
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              color: arrowColor??AppColors.primaryColor,
              size: Dimensions.checkKIsWeb(context) ? context.h * 0.04 :context.w * 0.05,),
        ),
      ),
    );
  }
}

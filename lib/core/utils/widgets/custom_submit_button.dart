import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

class CustomSubmitButton extends StatelessWidget {
  final String buttonText;
  final Color backgroundColor;
  final Color hoverColor;
  final Color textColor;
  final bool isLoading;
  final Function onPressed;
  final bool disable;

  const CustomSubmitButton(
      {super.key,
      required this.buttonText,
      required this.backgroundColor,
      required this.hoverColor,
      required this.textColor,
      required this.onPressed,
      this.disable = false,
      this.isLoading = false,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.h * 0.08,
      width: context.w,
      child: ElevatedButton(
        onPressed: () {
          if (!disable) {
            onPressed();
          }
        },
        style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(hoverColor),
            backgroundColor: MaterialStateProperty.all(
                disable ? backgroundColor.withOpacity(0.4) : backgroundColor,),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),),),
            elevation: MaterialStateProperty.all(3),
            shadowColor:
                MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),),
        child: isLoading
            ? SpinKitThreeBounce(
                color: Colors.white,
                size: 3.h,
              )
            : Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                      color: textColor,
                      fontSize: context.w > 550  ? context.h * 0.028 : 13.sp,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,),
                ),
              ),
      ),
    );
  }
}

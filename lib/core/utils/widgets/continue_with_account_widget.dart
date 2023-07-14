import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

class ContinueWithAccountWidget extends StatelessWidget {
  final String buttonText;
  final Color backgroundColor;
  final Color hoverColor;
  final Color textColor;
  final Color borderColor;
  final bool isLoading;
  final Function onPressed;
  final Widget widgetAtFirst;

  const ContinueWithAccountWidget(
      {super.key, required this.buttonText,
      required this.backgroundColor,
      required this.hoverColor,
      required this.textColor,
      required this.borderColor,
      required this.onPressed,
      required this.widgetAtFirst,
      this.isLoading = false,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.h * 0.08,
      width: context.w,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(hoverColor),
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  side: BorderSide(color: borderColor),),),
          elevation: MaterialStateProperty.all(0),
        ),
        child: isLoading
            ? SpinKitThreeBounce(
                color: Colors.white,
                size: 3.h,
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                          height: 25, width: 25, child: widgetAtFirst,),
                      const SizedBox(width: 12,),
                      Expanded(
                        child: Text(
                          buttonText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor, fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.026 :13.sp),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

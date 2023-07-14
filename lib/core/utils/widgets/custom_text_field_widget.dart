import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final String hintText;

  //final String labelText;
  final String errorText;
  final bool showError;
  final bool obscureText;
  final TextInputType inputType;
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String)? onSubmit;
  final int maxLines;
  final bool? isFocused;
  final Color? backgroundColor;
  final bool hasLabel;
  final Widget? icon;
  final bool hasBorder;
  final bool autocorrect;
  final Widget? iconAtFirst;
  final String? title;
  final TextInputAction? textInputAction;
  final bool onlyDigits;

  const CustomTextFieldWidget({
    super.key,
    required this.onChanged,
    this.onSubmit,
    this.textInputAction = TextInputAction.done,
    required this.hintText,
    this.errorText = '',
    this.title,
    this.showError = false,
    this.autocorrect = true,
    this.obscureText = false,
    this.onlyDigits = false,
    this.isFocused = false,
    this.hasLabel = true,
    this.hasBorder = true,
    this.maxLines = 1,
    this.icon,
    this.iconAtFirst,
    this.backgroundColor = const Color(0xff141313),
    required this.controller,
    required this.inputType,
    // required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == null
            ? Container()
            : Text(
                title!,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.secondaryFontColor,
                ),
              ),
        title == null ? Container() : const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          // height: height * 0.075,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            color: AppColors.textFieldColor /*Colors.grey.withOpacity(0.1)*/,
            border: Border.all(
              color: showError ? Colors.red : AppColors.textFieldColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: TextField(
                      inputFormatters: onlyDigits
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null,
                      maxLines: maxLines,
                      autocorrect: autocorrect,
                      controller: controller,
                      keyboardType: inputType,
                      obscureText: obscureText,
                      textInputAction: textInputAction,
                      onSubmitted: (str) {
                        if (onSubmit != null) {
                          onSubmit!(str);
                        }
                      },
                      onChanged: onChanged,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.028
                            : 12.sp, // 8
                        color: AppColors.primaryFontColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontSize: Dimensions.checkKIsWeb(context)
                              ? context.h * 0.028
                              : 12.sp, // 10
                          color: AppColors.hintTextFieldColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      cursorColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                icon == null ? Container() : icon!
              ],
            ),
          ),
        ),
        Visibility(
          visible: showError,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: kIsWeb ? context.h * 0.026 : 11.sp,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

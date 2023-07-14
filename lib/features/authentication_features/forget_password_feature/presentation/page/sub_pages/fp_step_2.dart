import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class FpStep2 extends StatefulWidget {
  final AppLocalizations localizations;
  final bool isObscurePassword;
  final bool isObscureConfirmPassword;
  final bool errorCodeValidation;
  final bool errorPasswordValidation;
  final bool errorMisMatchingValidation;
  final bool errorConfirmPasswordValidation;
  final Function(bool) onChangeObscurePassword;
  final Function(bool) onChangeObscureConfirmPassword;
  final Function(String) onChangeCode;
  final Function(String) onChangeConfirmPassword;
  final Function(String) onChangePassword;

  const FpStep2({
    required this.localizations,
    required this.isObscurePassword,
    required this.errorCodeValidation,
    required this.errorPasswordValidation,
    required this.errorConfirmPasswordValidation,
    required this.errorMisMatchingValidation,
    required this.onChangeObscureConfirmPassword,
    required this.onChangeCode,
    required this.onChangeObscurePassword,
    required this.onChangePassword,
    required this.onChangeConfirmPassword,
    required this.isObscureConfirmPassword,
    Key? key,
  }) : super(key: key);

  @override
  State<FpStep2> createState() => _FpStep2State();
}

class _FpStep2State extends State<FpStep2> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.localizations.enter_your_new_password,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(
          height: context.h * 0.05,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: getOTPWidget(),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 3.h),
          child: CustomTextFieldWidget(
            title: widget.localizations.new_password,
            onChanged: (val) {
              widget.onChangePassword(val);
            },
            hintText: '',
            controller: _passwordController,
            inputType: TextInputType.text,
            obscureText: widget.isObscurePassword,
            showError: widget.errorPasswordValidation ||
                widget.errorMisMatchingValidation,
            errorText: widget.errorMisMatchingValidation
                ? "Password and confirmation are not identical"
                : 'invalid input!, must be at least 6 characters or number!',
            icon: GestureDetector(
              onTap: () {
                widget.onChangeObscurePassword(!widget.isObscurePassword);
              },
              child: !widget.isObscurePassword
                  ? Icon(
                      Icons.remove_red_eye,
                      color: AppColors.primaryFontColor,
                    )
                  : SvgPicture.asset(
                      'assets/images/icons/eye.svg',
                      width: context.h * 0.035,
                      color: AppColors.primaryFontColor,
                    ),
            ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 24.0, right: 24, top: 1.h, bottom: 3.h),
          child: Text(
            widget.localizations.reset_password_desc,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppColors.secondaryFontColor,
              fontSize: 9.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.h),
          child: CustomTextFieldWidget(
            title: widget.localizations.confirm_password,
            onChanged: (val) {
              widget.onChangeConfirmPassword(val);
            },
            hintText: '',
            controller: _confirmPasswordController,
            inputType: TextInputType.text,
            obscureText: widget.isObscureConfirmPassword,
            showError: widget.errorConfirmPasswordValidation ||
                widget.errorMisMatchingValidation,
            errorText: widget.errorMisMatchingValidation
                ? "Password and confirmation are not identical"
                : 'invalid input!, must be at least 6 characters or number!',
            icon: GestureDetector(
              onTap: () {
                widget.onChangeObscureConfirmPassword(
                  !widget.isObscureConfirmPassword,
                );
              },
              child: !widget.isObscureConfirmPassword
                  ? Icon(
                      Icons.remove_red_eye,
                      color: AppColors.primaryFontColor,
                    )
                  : SvgPicture.asset(
                      'assets/images/icons/eye.svg',
                      width: context.h * 0.035,
                      color: AppColors.primaryFontColor,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getOTPWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.checkKIsWeb(context) ? context.w * 0.1 : 10.0,
      ),
      child: PinCodeTextField(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        appContext: context,
        pastedTextStyle: TextStyle(
          color: Colors.green.shade600,
          fontWeight: FontWeight.bold,
        ),
        length: 4,
        blinkWhenObscuring: true,
        animationType: AnimationType.fade,
        validator: (v) {
          if (v!.length < 3) {
            return "Complete the code please.";
          } else {
            return null;
          }
        },
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: Dimensions.checkKIsWeb(context)
              ? context.w * 0.14
              : context.w * 0.17,
          fieldWidth: Dimensions.checkKIsWeb(context)
              ? context.w * 0.14
              : context.w * 0.17,
          activeFillColor:
              widget.errorCodeValidation ? Colors.red : Colors.white,
          inactiveFillColor:
              widget.errorCodeValidation ? Colors.red : Colors.white,
          selectedColor: Colors.white,
          activeColor: Colors.white,
          selectedFillColor: AppColors.primaryColor,
          borderWidth: 0,
        ),
        cursorColor: Colors.black,
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        controller: _pinCodeController,
        keyboardType: TextInputType.number,
        boxShadows: const [
          BoxShadow(
            offset: Offset(0, 1),
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
        onCompleted: (v) {},
        onChanged: (value) {
          widget.onChangeCode(value);
        },
        beforeTextPaste: (text) {
          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
          //but you can show anything you want here, like your pop up saying wrong paste format or etc
          return true;
        },
      ),
    );
  }
}

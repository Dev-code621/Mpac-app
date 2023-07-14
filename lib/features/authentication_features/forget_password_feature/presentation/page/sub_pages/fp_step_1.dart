import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:sizer/sizer.dart';

import 'package:mpac_app/core/utils/constants/colors.dart';

class FpStep1 extends StatefulWidget {
  final AppLocalizations localizations;

  final Function(String) onChangingEmail;
  final bool errorEmailValidation;

  const FpStep1(
      {required this.localizations,
      required this.onChangingEmail,
      required this.errorEmailValidation,
      Key? key,})
      : super(key: key);

  @override
  State<FpStep1> createState() => _FpStep1State();
}

class _FpStep1State extends State<FpStep1> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.localizations.forget_password,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,),
          ),
        ),
        SizedBox(
          height: context.h * 0.05,
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.localizations.enter_email_address,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: AppColors.secondaryFontColor, fontSize: 12.sp),
          ),
        ),
        SizedBox(
          height: context.h * 0.015,
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.localizations.we_will_send_link_to_your_email,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: AppColors.secondaryFontColor, fontSize: 12.sp),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 3.h),
          child: CustomTextFieldWidget(
            onChanged: (val) {
              widget.onChangingEmail(val);
            },
            hintText: widget.localizations.email,
            controller: _emailController,
            inputType: TextInputType.text,
            showError: widget.errorEmailValidation,
            errorText: 'invalid input!',
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';

class CustomDialogs {
  static congratsDialog({
    required BuildContext context,
    required AppLocalizations localizations,
    required Function onSubmit,
    bool barrierDismissible = false,
    String? textButtonUnderMainButton,
    Function? onTextButtonClicked,
  }) {
    showDialog(
        context: context,
        // barrierDismissible: barrierDismissible,
        builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),),
                  //this right here
                  child: SizedBox(
                    width: context.w * 0.8,
                    // height: Dimensions.checkKIsWeb(context) ? context.h * 0.6 :context.h * 0.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Image.asset(
                          'assets/images/general/basketball.png',
                          height: context.h * 0.20,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.welcome_to_mpac,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.03 :14.sp,
                              color: AppColors.primaryFontColor,
                              fontWeight: FontWeight.bold,),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          localizations.welcome_to_mpac_desc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.028 :12.sp,
                              color: AppColors.secondaryFontColor,),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0,),
                          child: CustomSubmitButton(
                              buttonText: "Continue"
                                  .toUpperCase(),
                              backgroundColor: AppColors.primaryColor,
                              hoverColor: Colors.grey.withOpacity(0.5),
                              textColor: Colors.white,
                              onPressed: () {
                                onSubmit();
                              },),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),),
            ),);
  }

  static  missingVariationsSelection({
    required BuildContext context,
    required Function onSubmit,
    required String missedSportsNames,
    required AppLocalizations localizations,
    String? textButtonUnderMainButton,
    Function? onTextButtonClicked,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),),
                  //this right here
                  child: SizedBox(
                    width: context.w * 0.8,
                    // height: context.h * 0.4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: context.h * 0.01),
                        Icon(
                          Icons.warning_amber,
                          color: Colors.red,
                          size: context.h * 0.15,
                        ),
                        SizedBox(height: context.h * 0.01),
                        Text(
                          localizations.warning,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.032 : 14.sp,
                              color: AppColors.primaryFontColor,
                              fontWeight: FontWeight.bold,),
                        ),
                        SizedBox(height: context.h * 0.008),
                        Padding(
                          padding: const EdgeInsets.symmetric( horizontal: 12.0),
                          child: Text(
                            localizations.some_variations_missing_desc(missedSportsNames),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.028 :12.sp,
                                color: AppColors.secondaryFontColor,),
                          ),
                        ),
                        SizedBox(height: context.h * 0.01),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0,),
                          child: CustomSubmitButton(
                              buttonText: "Continue to add details",
                              backgroundColor: AppColors.primaryColor,
                              hoverColor: Colors.grey.withOpacity(0.5),
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },),
                        ),

                        const SizedBox(height: 12),

                      ],
                    ),
                  ),),
            ),);
  }

  static Future<Future> deleteDialog(BuildContext context, Function onSubmit) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xff141313),
            title: Text(
              'Delete',
              style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,),
            ),
            content: Text(
              'Are you sure you want to delete this post?',
              style: TextStyle(
                fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.026 : 13.sp,
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppColors.hintTextFieldColor,
                    fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.026 : 13.sp,

                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.red,
                      fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.026 : 13.sp,
                    ),
                  ),
                  onPressed: () {
                    onSubmit();
                  },),
            ],
          );
        },);
  }


}

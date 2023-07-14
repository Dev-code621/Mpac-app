
import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_background_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/widgets/custom_app_logo.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(),
      ),
      body: SizedBox(
        width: context.w,
        height: context.h,
        child: Stack(
          children: [
            const CustomBackgroundWidget(),
            Column(
              children: [
                Expanded(
                    child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomAppLogo(),
                      SizedBox(
                        height: context.h * 0.1,
                      ),
                      Text(
                        "Sport Management\nPlatform",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.logoColor,
                            fontFamily: "Inter",
                            fontSize: 15.sp,),
                      )
                    ],
                  ),
                ),),
                Padding(
                  padding: EdgeInsets.only(left: 24.0, right: 24, bottom: 10.h),
                  child: CustomSubmitButton(
                    buttonText: localizations.getStarted.toUpperCase(),
                    backgroundColor: AppColors.primaryColor,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, AppScreens.onBoardingSteps, (route) => false);
                    },
                    hoverColor: Colors.grey.withOpacity(0.5),
                    textColor: Colors.white,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

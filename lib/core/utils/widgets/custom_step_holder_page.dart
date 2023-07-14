import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_io/io.dart';

class CustomStepHolderPage extends StatefulWidget {
  final String title;
  final Widget step1;
  final Widget step2;
  final Function onBackButtonClicked;
  final PageController pageController;
  final int currentPageIndex;
  final bool hideBackButton;
  final ViewType viewType;

  const CustomStepHolderPage(
      {required this.pageController,
      required this.currentPageIndex,
      required this.title,
      required this.step1,
      required this.step2,
      required this.onBackButtonClicked,
      required this.viewType,
      this.hideBackButton = false,
      Key? key,})
      : super(key: key);

  @override
  State<CustomStepHolderPage> createState() => _CustomStepHolderPageState();
}

class _CustomStepHolderPageState extends State<CustomStepHolderPage> {
  late AppLocalizations localizations;

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if(widget.viewType == ViewType.splash){
          widget.onBackButtonClicked();
          if(widget.currentPageIndex == 0){
            exit(0);
          }
          return Future.value(false);
        } else {
          widget.onBackButtonClicked();
          return Future.value(widget.currentPageIndex == 0);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: widget.hideBackButton == true && widget.currentPageIndex == 0
              ? null
              : CustomBackButton(
                  onBackClicked: () {
                    widget.onBackButtonClicked();
                  },
                  localeName: localizations.localeName,
                ),
          title: Text(widget.title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: kIsWeb ? context.h * 0.032 : 14.sp,),),
        ),
        body: Column(
          children: [
            SizedBox(
              height: context.h * 0.025,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          color: widget.currentPageIndex == 1
                              ? AppColors.primaryOffColor.withOpacity(0.8)
                              : AppColors.primaryColor,),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          color: widget.currentPageIndex == 0
                              ? Colors.white
                              : AppColors.primaryColor,),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: context.h * 0.01,
            ),
            Expanded(
                child: PageView(
              controller: widget.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [widget.step1, widget.step2],
            ),),
            /*Padding(
              padding: EdgeInsets.only(bottom: 5.h),
              child: CustomSubmitButton(
                buttonText: widget.currentPageIndex == 0
                    ? widget.btnTextStep1
                    : widget.btnTextStep2,
                backgroundColor: AppColors.primaryColor,
                onPressed: () {
                  widget.onStepSubmit();
                },
                hoverColor: Colors.grey.withOpacity(0.5),
                textColor: Colors.white,
              ),
            )*/
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';

import 'package:mpac_app/core/utils/constants/colors.dart';

class EventTypeSelectionWidget extends StatelessWidget {
  final bool withRadioButton;
  final String title1;
  final bool isSelected1;
  final String path1;

  final bool isSelected2;
  final String title2;
  final String path2;

  final Function click1;
  final Function click2;

  const EventTypeSelectionWidget(
      {required this.title1,
      required this.title2,
      required this.withRadioButton,
      required this.isSelected1,
      required this.isSelected2,
      required this.path1,
      required this.path2,
      required this.click1,
      required this.click2,
      Key? key,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                click1();
              },
              child: Container(
                width: Dimensions.checkKIsWeb(context) ? context.w * 0.15 :context.w * 0.3,
                // height: context.h * 0.20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: isSelected1
                        ? [
                            BoxShadow(
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, -5),)
                          ]
                        : [],
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),),),
                child: Column(children: [
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  Container(
                    width: Dimensions.checkKIsWeb(context) ? context.w * 0.125 :context.w * 0.25,
                    height: Dimensions.checkKIsWeb(context) ? context.w * 0.125 :context.w * 0.25,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.hintTextFieldColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        image: DecorationImage(
                            image: AssetImage(path1), fit: BoxFit.cover,),),
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 10.0),
                        child: Container(
                          width: Dimensions.checkKIsWeb(context) ? context.w * 0.025 :context.w * 0.05,
                          height: Dimensions.checkKIsWeb(context) ? context.w * 0.025 :context.w * 0.05,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isSelected1
                                      ? AppColors.secondaryFontColor
                                      : AppColors.borderColor,
                                  width: 1,),),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: Dimensions.checkKIsWeb(context) ? context.w * 0.015 :context.w * 0.03,
                                  height: Dimensions.checkKIsWeb(context) ? context.w * 0.015 :context.w * 0.03,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected1
                                          ? AppColors.secondaryFontColor
                                          : Colors.white,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        title1,
                        style: TextStyle(color: AppColors.primaryFontColor),
                      )
                    ],
                  )
                ],),
              ),
            ),
            isSelected1
                ? Container(
              width: Dimensions.checkKIsWeb(context) ? context.w * 0.25 :context.w * 0.38,
              height: 5.0,
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),),
                  )
                : Container()
          ],
        ),
        SizedBox(
          width: context.w * 0.1,
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                click2();
              },
              child: Container(
                width: Dimensions.checkKIsWeb(context) ? context.w * 0.15 :context.w * 0.3,
                // height: context.h * 0.20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: isSelected2
                        ? [const BoxShadow(blurRadius: 5, color: Colors.grey)]
                        : [],
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),),),
                child: Column(children: [
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  Container(
                    width: Dimensions.checkKIsWeb(context) ? context.w * 0.125 :context.w * 0.25,
                    height: Dimensions.checkKIsWeb(context) ? context.w * 0.125 :context.w * 0.25,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        image: DecorationImage(
                            image: AssetImage(path2), fit: BoxFit.cover,),),
                  ),
                  SizedBox(
                    height: context.h * 0.01,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 10.0),
                        child: Container(
                          width: Dimensions.checkKIsWeb(context) ? context.w * 0.025 :context.w * 0.05,
                          height: Dimensions.checkKIsWeb(context) ? context.w * 0.025 :context.w * 0.05,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isSelected2
                                      ? AppColors.secondaryFontColor
                                      : AppColors.hintTextFieldColor,
                                  width: 1,),),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: Dimensions.checkKIsWeb(context) ? context.w * 0.015 :context.w * 0.03,
                                  height: Dimensions.checkKIsWeb(context) ? context.w * 0.015 :context.w * 0.03,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected2
                                          ? AppColors.secondaryFontColor
                                          : Colors.white,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        title2,
                        style: TextStyle(color: AppColors.primaryFontColor),
                      )
                    ],
                  )
                ],),
              ),
            ),
            isSelected2
                ? Container(
                    width: Dimensions.checkKIsWeb(context) ? context.w * 0.25 :context.w * 0.38,
                    height: 5.0,
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),),
                  )
                : Container()
          ],
        ),
      ],
    );
  }
}

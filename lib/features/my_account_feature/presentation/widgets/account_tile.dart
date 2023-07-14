import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';

class AccountTile extends StatelessWidget {
  final String title;
  final String svgPath;
  final bool withDivider;
  final bool withArrowIcon;
  final Function onTap;

  const AccountTile({
    this.withDivider = true,
    this.withArrowIcon = false,
    required this.title,
    required this.onTap,
    required this.svgPath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.03
                              : context.w * 0.045,
                          height: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.03
                              : context.w * 0.045,
                          child: SvgPicture.asset(
                            svgPath,
                            width: Dimensions.checkKIsWeb(context)
                                ? context.w * 0.03
                                : context.w * 0.045,
                            height: Dimensions.checkKIsWeb(context)
                                ? context.w * 0.03
                                : context.w * 0.045,
                            color: const Color(0xffB7B7B7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Dimensions.checkKIsWeb(context)
                                  ? context.h * 0.028
                                  : 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  withArrowIcon
                      ? Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: const Color(0xffB7B7B7),
                          size: Dimensions.checkKIsWeb(context)
                              ? context.w * 0.0225
                              : context.w * 0.045,
                        )
                      : Container()
                ],
              ),
            ),
            withDivider
                ? Container(
                    width: context.w,
                    height: 0.5,
                    color: AppColors.secondaryFontColor,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';

class SelectProfileWidget extends StatelessWidget {
  final bool isSelected;
  final Color containerColor;
  final String title;
  final String description;
  final String svgPath;

  const SelectProfileWidget(
      {required this.isSelected,
      required this.title,
      required this.description,
      required this.svgPath,
      required this.containerColor,
      Key? key,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w,
      height: context.h * 0.2,
      decoration: BoxDecoration(
        color: containerColor,
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12.0, bottom: 8.0, top: 8.0,),
              child: SvgPicture.asset(svgPath,
                  width: context.w * 0.27, height: context.w * 0.27,),
            ),
          ],
        ),
      ),
    );
  }
}

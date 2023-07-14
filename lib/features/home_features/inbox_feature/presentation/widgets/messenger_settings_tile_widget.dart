// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mpac_app/core/utils/constants/colors.dart';
// import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
// import 'package:sizer/sizer.dart';
//
// class MessengerSettingsTileWidget extends StatelessWidget {
//   final String svgPath;
//   final String title;
//   final bool withArrow;
//   final bool withDivider;
//   final String subtitle;
//   final Function onTap;
//
//   const MessengerSettingsTileWidget(
//       {super.key, required this.svgPath,
//       required this.title,
//       required this.withArrow,
//       required this.onTap,
//       this.withDivider = true,
//       required this.subtitle,});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: (){
//               onTap();
//             },
//             child: SizedBox(
//               width: context.w,
//               height: context.h * 0.08,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: context.h * 0.06,
//                         width: context.h * 0.06,
//                         child: Stack(
//                           children: [
//                             Align(
//                               alignment: Alignment.center,
//                               child: SvgPicture.asset(
//                                 svgPath,
//                                 height: context.w * 0.055,
//                                 width: context.w * 0.055,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                         title,
//                         style: TextStyle(color: Colors.white, fontSize: 12.sp),
//                       ),
//                     ],
//                   ),
//                   withArrow
//                       ? Row(
//                           children: [
//                             Text(
//                               subtitle,
//                               style: TextStyle(
//                                   color: AppColors.secondaryFontColor,
//                                   fontSize: 10.sp,),
//                             ),
//                             const SizedBox(
//                               width: 8,
//                             ),
//                             Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               color: AppColors.secondaryFontColor,
//                             )
//                           ],
//                         )
//                       : Container()
//                 ],
//               ),
//             ),
//           ),
//           withDivider
//               ? Container(
//                   width: context.w,
//                   height: 0.5,
//                   color: AppColors.unSelectedWidgetColor,
//                 )
//               : Container()
//         ],
//       ),
//     );
//   }
// }

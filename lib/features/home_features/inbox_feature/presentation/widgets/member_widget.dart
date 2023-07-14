// import 'package:flutter/material.dart';
// import 'package:mpac_app/core/utils/constants/colors.dart';
// import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
// import 'package:sendbird_sdk/core/models/member.dart';
// import 'package:sizer/sizer.dart';
// import 'package:string_validator/string_validator.dart';
//
// class MemberWidget extends StatelessWidget {
//   final Member member;
//   final bool withDivider;
//
//   const MemberWidget(this.member, this.withDivider, {Key? key})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//       child: SizedBox(
//         width: context.w,
//         // height: context.h * 0.08,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         getUserProfileImage(context),
//                         const SizedBox(
//                           width: 16,
//                         ),
//                         Expanded(
//                           child: Text(
//                             member.nickname,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   !isUUID(member.userId)
//                       ? Text("Operator",
//                           style: TextStyle(
//                               color: AppColors.unSelectedWidgetColor,
//                               fontSize: 12.sp,),)
//                       : Container(),
//                   const SizedBox(width: 8,),
//
//                   const Icon(
//                     Icons.more_vert_sharp,
//                     color: Colors.white,
//                   )
//                 ],
//               ),
//             ),
//             withDivider
//                 ? Container(
//                     width: context.w,
//                     height: 0.5,
//                     color: AppColors.unSelectedWidgetColor,
//                   )
//                 : Container()
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget getUserProfileImage(BuildContext context) {
//     return Container(
//       height: context.h * 0.06,
//       width: context.h * 0.06,
//       decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.black.withOpacity(0.5),
//           image: member.profileUrl == null
//               ? null
//               : DecorationImage(
//                   fit: BoxFit.cover,
//                   image: NetworkImage(member.profileUrl!),
//                 ),),
//       child: member.profileUrl == null
//           ? const Icon(
//               Icons.person,
//               color: Colors.black,
//             )
//           : null,
//     );
//   }
// }

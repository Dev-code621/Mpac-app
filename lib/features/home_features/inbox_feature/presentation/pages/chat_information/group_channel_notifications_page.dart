// import 'package:flutter/material.dart';
// import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
// import 'package:sendbird_sdk/sendbird_sdk.dart';
// import 'package:sizer/sizer.dart';
//
// import 'package:mpac_app/core/utils/constants/colors.dart';
//
// class GroupChannelNotificationPage extends StatefulWidget {
//   final GroupChannel groupChannel;
//
//   const GroupChannelNotificationPage(this.groupChannel, {Key? key})
//       : super(key: key);
//
//   @override
//   State<GroupChannelNotificationPage> createState() =>
//       _GroupChannelNotificationPageState();
// }
//
// class _GroupChannelNotificationPageState
//     extends State<GroupChannelNotificationPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
//       body: Column(
//         children: [
//           appBarWidget(),
//           Container(
//             color: const Color(0xff161616),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Column(children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Notifications',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     Switch(
//                       value: true,
//                       onChanged: (val) {},
//                       activeColor: AppColors.primaryColor,
//                     )
//                   ],
//                 ),
//                 Text(
//                   "Turn on push notifications if you wish to be notified when messages are delivered to this channel.",
//                   style: TextStyle(color: AppColors.secondaryFontColor),
//                 ),
//                 const SizedBox(
//                   height: 24,
//                 ),
//                 Container(
//                   width: context.w,
//                   height: 0.5,
//                   color: AppColors.unSelectedWidgetColor,
//                 ),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'All new messages',
//                       style: TextStyle(color: Colors.white, fontSize: 12.sp),
//                     ),
//                     Radio(
//                       value: true,
//                       groupValue: true,
//                       onChanged: (val) {},
//                       activeColor: AppColors.primaryColor,
//                     )
//                   ],
//                 ),
//
//                 Container(
//                   width: context.w,
//                   height: 0.5,
//                   color: AppColors.unSelectedWidgetColor,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Mentions only',
//                       style: TextStyle(color: Colors.white, fontSize: 12.sp),
//                     ),
//                     Radio(
//                       value: false,
//                       groupValue: false,
//                       onChanged: (val) {},
//                       activeColor: AppColors.unSelectedWidgetColor,
//                     )
//                   ],
//                 ),
//
//
//               ],),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget appBarWidget() {
//     return Container(
//       height: context.h * 0.08,
//       decoration: const BoxDecoration(color: Color(0xff2C2C2C), boxShadow: [
//         BoxShadow(blurRadius: 5, color: Colors.black, offset: Offset(0, 0))
//       ],),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: SizedBox(
//                   width: context.h * 0.08,
//                   height: context.h * 0.08,
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 6.0),
//                       child: Icon(Icons.arrow_back_ios,
//                           color: const Color(0xffB7B7B7), size: context.h * 0.03,),
//                     ),
//                   ),
//                 ),
//               ),
//               Text(
//                 "Notifications",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.bold,),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

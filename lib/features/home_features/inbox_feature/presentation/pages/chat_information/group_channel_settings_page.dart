// import 'package:flutter/material.dart';
// import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
// import 'package:mpac_app/features/home_features/inbox_feature/presentation/widgets/messenger_settings_tile_widget.dart';
// import 'package:sendbird_sdk/sendbird_sdk.dart';
// import 'package:sizer/sizer.dart';
//
// import 'package:mpac_app/core/utils/constants/colors.dart';
// import 'package:mpac_app/features/home_features/inbox_feature/presentation/pages/chat_information/group_channel_notifications_page.dart';
// import 'package:mpac_app/features/home_features/inbox_feature/presentation/pages/chat_information/group_channel_members_page.dart';
//
// class GroupChannelSettingsPage extends StatefulWidget {
//   final GroupChannel groupChannel;
//
//   const GroupChannelSettingsPage(this.groupChannel, {Key? key})
//       : super(key: key);
//
//   @override
//   State<GroupChannelSettingsPage> createState() =>
//       _GroupChannelSettingsPageState();
// }
//
// class _GroupChannelSettingsPageState extends State<GroupChannelSettingsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
//       body: Column(
//         children: [
//           appBarWidget(),
//           Container(
//             color: const Color(0xff161616),
//             width: context.w,
//             height: context.h * 0.55,
//             child: Column(
//               children: [
//                 const SizedBox(height: 25),
//                 Container(
//                   width: context.h * 0.12,
//                   height: context.h * 0.12,
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                           image: NetworkImage(widget.groupChannel.coverUrl!),),),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   widget.groupChannel.name!,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.bold,),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 MessengerSettingsTileWidget(
//                   title: 'Notifications',
//                   svgPath: 'assets/images/general/notification.svg',
//                   withArrow: true,
//                   subtitle: 'On',
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => GroupChannelNotificationPage(widget.groupChannel),),);
//                   },
//                 ),
//                 MessengerSettingsTileWidget(
//                   title: 'Members',
//                   svgPath: 'assets/images/general/members.svg',
//                   withArrow: true,
//                   subtitle: widget.groupChannel.memberCount.toString(),
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => GroupChannelMembersPage(widget.groupChannel),),);
//                   },
//                 ),
//                 MessengerSettingsTileWidget(
//                   title: 'Search In Channel',
//                   svgPath: 'assets/images/general/search.svg',
//                   withArrow: false,
//                   subtitle: "",
//                   onTap: () {
//
//                   },
//                 ),
//                 MessengerSettingsTileWidget(
//                   title: 'Leave Channel',
//                   svgPath: 'assets/images/general/logout.svg',
//                   withArrow: false,
//                   withDivider: false,
//                   subtitle: "",
//                   onTap: () {
//
//                   },
//                 ),
//               ],
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
//                 "Channel information",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.bold,),
//               ),
//             ],
//           ),
//           TextButton(
//               onPressed: () {},
//               child: Text(
//                 "Edit",
//                 style:
//                     TextStyle(color: AppColors.primaryColor, fontSize: 13.sp),
//               ),)
//         ],
//       ),
//     );
//   }
// }

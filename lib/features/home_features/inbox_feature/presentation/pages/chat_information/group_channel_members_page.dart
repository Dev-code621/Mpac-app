// import 'package:flutter/material.dart';
// import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
// import 'package:mpac_app/features/home_features/inbox_feature/presentation/widgets/member_widget.dart';
// import 'package:sendbird_sdk/sendbird_sdk.dart';
// import 'package:sizer/sizer.dart';
//
// class GroupChannelMembersPage extends StatefulWidget {
//   final GroupChannel groupChannel;
//
//   const GroupChannelMembersPage(this.groupChannel, {Key? key})
//       : super(key: key);
//
//   @override
//   State<GroupChannelMembersPage> createState() =>
//       _GroupChannelMembersPageState();
// }
//
// class _GroupChannelMembersPageState extends State<GroupChannelMembersPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
//       body: Column(
//         children: [
//           appBarWidget(),
//           Expanded(
//               child: Container(
//             color: const Color(0xff161616),
//             child: ListView.builder(
//                 itemCount: widget.groupChannel.members.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return MemberWidget(widget.groupChannel.members[index],
//                       index != widget.groupChannel.members.length - 1,);
//                 },),
//           ),)
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
//                 "Members",
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

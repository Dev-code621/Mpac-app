import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/pages/group_channel_view.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sizer/sizer.dart';

class MessengerTileWidget extends StatelessWidget {
  final GroupChannel groupChannel;

  const MessengerTileWidget(this.groupChannel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ChatScreen(
        //               userId: getIt<PrefsHelper>().getUserId,
        //               otherUserIds: ["beso"],
        //             )));

        GroupChannel.getChannel(groupChannel.channelUrl).then((channel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupChannelPage(groupChannel: channel),
            ),
          );
        }).catchError((e) {
          //handle error
        });
      },
      child: SizedBox(
        width: context.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Row(
            children: [
              getMessengerTileImageWidget(context),
              SizedBox(
                width: context.w * 0.05,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            groupChannel.name == null
                                ? "-"
                                : groupChannel.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          groupChannel.lastMessage == null
                              ? "-"
                              : readTimestamp(
                                  groupChannel.lastMessage!.createdAt,
                                ),
                          style: TextStyle(
                            color: AppColors.secondaryFontColor,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            groupChannel.lastMessage == null
                                ? "-"
                                : groupChannel.lastMessage!.message,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.secondaryFontColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        groupChannel.unreadMessageCount == 0
                            ? Container()
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.blueColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    groupChannel.unreadMessageCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getMessengerTileImageWidget(BuildContext context) {
    return Container(
      width: context.w * 0.15,
      height: context.w * 0.15,
      decoration: groupChannel.coverUrl == null
          ? null
          : BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image:
                  DecorationImage(image: NetworkImage(groupChannel.coverUrl!)),
            ),
    );
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = '${diff.inDays}day ago';
      } else {
        time = '${diff.inDays}days ago';
      }
    }

    return time;
  }
}

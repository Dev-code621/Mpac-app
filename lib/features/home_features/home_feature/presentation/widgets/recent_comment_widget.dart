import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:sizer/sizer.dart';

class RecentCommentWidget extends StatelessWidget {
  final CommentModel commentModel;

  const RecentCommentWidget({required this.commentModel, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppScreens.profilePage,
                      arguments: {
                        'profile_id': commentModel.owner.id,
                        'withAppBar': true,
                        'flowCalled': 'comments'
                      },
                    );
                  },
                  child: Container(
                    width: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.08
                        : context.w * 0.1,
                    height: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.08
                        : context.w * 0.1,
                    decoration: commentModel.owner.image == null
                        ? BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(commentModel.owner.image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                    child: commentModel.owner.image == null
                        ? Icon(
                            Icons.person,
                            color: Colors.grey.withOpacity(0.5),
                            size: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.04
                                : 20,
                          )
                        : Container(),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${commentModel.owner.firstName!} ${commentModel.owner.lastName!}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.026
                            : 11.sp,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      commentModel.comment,
                      style: TextStyle(
                        color: AppColors.hintTextFieldColor,
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.026
                            : 11.sp,
                      ),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  /*String getDate() {
    if (DateTime.now()
            .difference(DateTime(
              int.tryParse(commentModel.createdAt.substring(0, 4))!,
              int.tryParse(commentModel.createdAt.substring(5, 7))!,
              int.tryParse(commentModel.createdAt.substring(8, 10))!,
              int.tryParse(commentModel.createdAt.substring(11, 13))!,
              int.tryParse(commentModel.createdAt.substring(14, 16))!,
              int.tryParse(commentModel.createdAt.substring(17, 19))!,
            ))
            .inDays ==
        0) {
      return DateTime.now()
              .difference(DateTime(
                int.tryParse(commentModel.createdAt.substring(0, 4))!,
                int.tryParse(commentModel.createdAt.substring(5, 7))!,
                int.tryParse(commentModel.createdAt.substring(8, 10))!,
                int.tryParse(commentModel.createdAt.substring(11, 13))!,
                int.tryParse(commentModel.createdAt.substring(14, 16))!,
                int.tryParse(commentModel.createdAt.substring(17, 19))!,
              ))
              .inHours
              .toString() +
          " hours ago";
    } else {
      return DateTime.now()
              .difference(DateTime(
                int.tryParse(commentModel.createdAt.substring(0, 4))!,
                int.tryParse(commentModel.createdAt.substring(5, 7))!,
                int.tryParse(commentModel.createdAt.substring(8, 10))!,
                int.tryParse(commentModel.createdAt.substring(11, 13))!,
                int.tryParse(commentModel.createdAt.substring(14, 16))!,
                int.tryParse(commentModel.createdAt.substring(17, 19))!,
              ))
              .inDays
              .toString() +
          " days ago";
    }
  }
*/

  String timePassed(DateTime datetime, {bool full = true}) {
    datetime = datetime.add(const Duration(hours: 4));
    DateTime now = DateTime.now();
    DateTime ago = datetime;
    Duration dur = now.difference(ago);
    int days = dur.inDays;
    int years = days ~/ 365;
    int months = (days - (years * 365)) ~/ 30;
    int weeks = (days - (years * 365 + months * 30)) ~/ 7;
    int rdays = days - (years * 365 + months * 30 + weeks * 7).toInt();
    int hours = (dur.inHours % 24).toInt();
    int minutes = (dur.inMinutes % 60).toInt();
    int seconds = (dur.inSeconds % 60).toInt();
    var diff = {
      "d": rdays,
      "w": weeks,
      "m": months,
      "y": years,
      "s": seconds,
      "i": minutes,
      "h": hours
    };

    Map str = {
      'y': 'year',
      'm': 'month',
      'w': 'week',
      'd': 'day',
      'h': 'hour',
      'i': 'minute',
      's': 'second',
    };

    str.forEach((k, v) {
      if (diff[k]! > 0) {
        str[k] = '${diff[k]} $v${diff[k]! > 1 ? 's' : ''}';
      } else {
        str[k] = "";
      }
    });
    str.removeWhere((index, ele) => ele == "");
    List<String> tlist = [];
    str.forEach((k, v) {
      tlist.add(v);
    });
    if (full) {
      return str.isNotEmpty ? "${tlist.join(", ")} ago" : "Just Now";
    } else {
      return str.isNotEmpty ? "${tlist[0]} ago" : "Just Now";
    }
  }
}

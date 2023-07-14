import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/comment_model.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';

import 'package:mpac_app/core/utils/constants/colors.dart';

class CommentWidget extends StatelessWidget {
  final CommentModel commentModel;
  final Function(CommentModel) onLongPress;

  const CommentWidget(
      {required this.commentModel, required this.onLongPress, Key? key,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        onLongPress(commentModel);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppScreens.profilePage,
                        arguments: {
                          'profile_id': commentModel.owner.id,
                          'withAppBar': true,
                          'flowCalled': 'comments'
                        },);
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
                                fit: BoxFit.fitHeight,),),
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
                              : 11.sp,),
                    ),
                    Text(
                      // "1 Week ago",
                      timePassedFromString(commentModel.createdAt, full: false),
                      style: TextStyle(
                          color: AppColors.secondaryFontColor,
                          fontSize: Dimensions.checkKIsWeb(context)
                              ? context.h * 0.025
                              : 10.sp,),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              commentModel.comment,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.025 : 11.sp,
              ),
            )
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

  String timePassedFromString(String dateString, {bool full = true}) {
    DateTime dateTime = DateTime.parse(dateString).toUtc();
    DateTime now = DateTime.now().toUtc();
    Duration difference = now.difference(dateTime).abs();

    int days = difference.inDays;
    int years = days ~/ 365;
    int months = days ~/ 30;
    int weeks = days ~/ 7;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;

    Map<String, int> diffs = {
      'y': years,
      'm': months,
      'w': weeks,
      'd': days,
      'h': hours,
      'i': minutes,
      's': seconds,
    };

    Map<String, String> timeStrings = {
      'y': 'year',
      'm': 'month',
      'w': 'week',
      'd': 'day',
      'h': 'hour',
      'i': 'minute',
      's': 'second',
    };

    List<String> timeParts = [];

    timeStrings.forEach((unit, name) {
      int diff = diffs[unit]!;
      if (diff > 0) {
        String timePart = '$diff $name${diff > 1 ? 's' : ''}';
        timeParts.add(timePart);
      }
    });

    if (timeParts.isEmpty) {
      return 'Just now';
    }

    if (full) {
      String lastTimePart = timeParts.removeLast();
      String timePartsWithAnd = '${timeParts.join(', ')} and $lastTimePart';
      return '$timePartsWithAnd ago';
    } else {
      return '${timeParts[0]} ago';
    }
  }
}

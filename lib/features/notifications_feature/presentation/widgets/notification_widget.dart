import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpac_app/core/data/models/notification_entity.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/post_information_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/profile_page.dart';
import 'package:sizer/sizer.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationModel notificationModel;
  final Function onClick;

  const NotificationWidget({
    required this.notificationModel,
    required this.onClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (notificationModel.type == "comment_notification") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostInformationPage(
                postId: notificationModel.postModel!.id,
              ),
            ),
          );
        } else if (notificationModel.type == "follow_notification") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                withAppBar: true,
                profileId: notificationModel.userModel!.id,
                flowCalled: 'notifications',
                holderBloc: getIt<HolderBloc>(),
              ),
            ),
          );
        } else {
          // react_notification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostInformationPage(
                postId: notificationModel.postModel!.id,
              ),
            ),
          );
        }
        onClick();
      },
      child: SizedBox(
        width: context.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Row(
            children: [
              getNotificationWidget(notificationModel.type, context),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationModel.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight:
                            notificationModel.isNew ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      timePassedFromString(
                        notificationModel.createdAt.toString(),
                        full: false,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryFontColor,
                        fontSize: 8.sp,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      notificationModel.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryFontColor,
                        fontSize: 10.sp,
                      ),
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

  Widget getNotificationWidget(String type, BuildContext context) {
    switch (type) {
      case "comment_notification":
        if (notificationModel.userModel!.image != null) {
          return Container(
            width: context.w * 0.13,
            height: context.w * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
              image: DecorationImage(
                image: NetworkImage(notificationModel.userModel!.image!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return Container(
            width: context.w * 0.13,
            height: context.w * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
            ),
            child: Icon(
              Icons.comment,
              color: AppColors.unSelectedWidgetColor,
              size: context.w * 0.055,
            ),
          );
        }

      case "follow_notification":
        if (notificationModel.userModel!.image != null) {
          return Container(
            width: context.w * 0.13,
            height: context.w * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
              image: DecorationImage(
                image: NetworkImage(notificationModel.userModel!.image!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return Container(
            width: context.w * 0.13,
            height: context.w * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.unSelectedWidgetColor,
                    size: context.w * 0.055,
                  ),
                ),
              ],
            ),
          );
        }
      default:
        if (notificationModel.userModel!.image != null) {
          return Container(
            width: context.w * 0.13,
            height: context.w * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
              image: DecorationImage(
                image: NetworkImage(notificationModel.userModel!.image!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return Container(
            width: context.w * 0.13,
            height: context.w * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.unSelectedWidgetColor.withOpacity(0.3),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/nav/trending.svg',
                    color: AppColors.unSelectedWidgetColor,
                    width: context.w * 0.055,
                  ),
                ),
              ],
            ),
          );
        }
    }
  }

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

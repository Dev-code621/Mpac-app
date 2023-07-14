import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/widgets/error/error_view.dart';
import 'package:mpac_app/features/notifications_feature/presentation/bloc/notifications_bloc.dart';
import 'package:mpac_app/features/notifications_feature/presentation/bloc/notifications_event.dart';
import 'package:mpac_app/features/notifications_feature/presentation/bloc/notifications_state.dart';
import 'package:sizer/sizer.dart';

import 'package:mpac_app/features/notifications_feature/presentation/widgets/notification_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late AppLocalizations localizations;
  final _bloc = getIt<NotificationsBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.instance.getInitialMessage().then((value) {
    //   _bloc.add(GetNotifications(false));
    // });

    _bloc.add(GetNotifications(true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, NotificationsState state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                              height: context.h * 0.05,
                              width: context.w * 0.15,
                              child: Center(
                                child: Icon(Icons.arrow_back_ios,
                                    color: const Color(0xffB7B7B7),
                                    size: context.h * 0.025,),
                              ),),
                        ),
                        Text(localizations.notifications,
                            style: TextStyle(
                                color: Colors.white, fontSize: 14.sp,),),
                      ],
                    ),
                    (state.isMarkingAllNotificationsAsRead ||
                            state.allNotificationsMarkedAsRead ||
                            state.notifications
                                .where((element) => element.isNew)
                                .toList()
                                .isEmpty)
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              _bloc.add(MarkAllNotificationsAsRead());
                            },
                            child: SizedBox(
                                height: context.h * 0.02,
                                width: context.w * 0.15,
                                child: Center(
                                    child: Icon(
                                  Icons.mark_chat_read,
                                  color: AppColors.primaryColor,
                                ),),),
                          ),
                  ],
                ),
              ),
              Expanded(child: getNotificationsWidgetStates(state))
            ],
          ),
        );
      },
    );
  }

  Widget getNotificationsWidgetStates(NotificationsState state) {
    if (state.isLoadingNotifications) {
      return Center(
        child: SizedBox(
            width: context.w * 0.5,
            height: context.w * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primaryColor,
            ),),
      );
    } else if (state.errorLoadingNotifications || state.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          _bloc.add(GetNotifications(true));
          return Future.value(true);
        },
        child: Stack(
          children: [
            ListView(),
            Center(
              child: ErrorView(
                color: AppColors.primaryColor.withOpacity(0.8),
                onReload: () {
                  _bloc.add(GetNotifications(true));
                },
                message: state.errorLoadingNotifications
                    ? "Error loading notifications!"
                    : "No notifications found!",
                btnContent: localizations.retry,
                withRefreshBtn: false,
              ),
            ),
          ],
        ),
      );
    } else {
      return RefreshIndicator(
          onRefresh: () {
            _bloc.add(GetNotifications(true));
            return Future.value(true);
          },
          child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (BuildContext context, int index) {

                (index == state.notifications.length - 1 &&
                        state.notifications.length > 14 &&
                        state.canLoadMore)
                    ? _bloc.add(LoadMoreNotifications())
                    : print('');
                return NotificationWidget(
                  notificationModel: state.notifications[index],
                  onClick: () {
                    _bloc.add(MarkNotificationAsRead(
                        state.notifications[index].id, index,),);
                  },
                );
              },),);
    }
  }
}

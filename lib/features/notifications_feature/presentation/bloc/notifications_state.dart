import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/notification_entity.dart';
import 'package:mpac_app/core/presentation/controllers/pagination_controller.dart';

import 'package:mpac_app/core/error/failures.dart';

part 'notifications_state.g.dart';

abstract class NotificationsState
    implements Built<NotificationsState, NotificationsStateBuilder> {
  NotificationsState._();

  factory NotificationsState([Function(NotificationsStateBuilder b) updates]) =
      _$NotificationsState;

  bool get isLoadingNotifications;
  bool get errorLoadingNotifications;
  bool get notificationsLoaded;

  Failure? get failure;

  List<NotificationModel> get notifications;

  bool get isMarkingNotificationAsRead;
  bool get errorMarkingNotificationAsRead;
  bool get notificationMarkedAsRead;

  bool get isMarkingAllNotificationsAsRead;
  bool get errorMarkingAllNotificationsAsRead;
  bool get allNotificationsMarkedAsRead;

  bool get isLoadingMore;
  bool get errorLoadingMore;
  bool get moreNotificationsLoaded;
  bool get canLoadMore;

  PaginationController get paginationController;

  factory NotificationsState.initial() {
    return NotificationsState((b) => b
    ..notifications = []
    ..paginationController = PaginationController()
    ..isLoadingMore = false
    ..errorLoadingMore = false
    ..moreNotificationsLoaded = false
    ..canLoadMore = false
    ..isLoadingNotifications = false
    ..errorLoadingNotifications = false
    ..notificationsLoaded = false
    ..isMarkingNotificationAsRead = false
    ..errorMarkingNotificationAsRead = false
    ..notificationMarkedAsRead = false
    ..isMarkingAllNotificationsAsRead = false
    ..errorMarkingAllNotificationsAsRead = false
    ..allNotificationsMarkedAsRead = false,
    );
  }
}

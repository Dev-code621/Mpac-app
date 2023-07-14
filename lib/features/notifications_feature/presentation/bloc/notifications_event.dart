abstract class NotificationsEvent {}

class GetNotifications extends NotificationsEvent {
  final bool withLoading;

  GetNotifications(this.withLoading);
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String id;
  final int index;

  MarkNotificationAsRead(this.id, this.index);
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}

class LoadMoreNotifications extends NotificationsEvent {}
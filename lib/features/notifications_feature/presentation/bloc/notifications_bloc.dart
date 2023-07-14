import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/pages/splash_page.dart';

import 'package:mpac_app/core/data/repository/repos/notifications_repository.dart';
import 'package:mpac_app/features/notifications_feature/presentation/bloc/notifications_event.dart';
import 'package:mpac_app/features/notifications_feature/presentation/bloc/notifications_state.dart';

@Injectable()
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository notificationsRepository;

  NotificationsBloc(this.notificationsRepository)
      : super(NotificationsState.initial());

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    if (event is GetNotifications) {
      yield* mapToGetNotifications(event.withLoading);
    } else if (event is MarkNotificationAsRead) {
      yield* mapToMarkNotificationAsRead(event.id, event.index);
    } else if (event is MarkAllNotificationsAsRead) {
      yield* mapToMarkAllNotificationAsRead();
    } else if (event is LoadMoreNotifications){
      yield* mapToLoadMoreNotifications();
    }
  }

  Stream<NotificationsState> mapToLoadMoreNotifications () async* {
    if(state.canLoadMore && state.notifications.length > 14){
      yield state.rebuild((p0) => p0
        ..isLoadingMore = true
        ..errorLoadingMore = false
        ..moreNotificationsLoaded = false,);
      final result = await notificationsRepository.getNotifications(
          offset: state.paginationController.offset + 15,
          limit: state.paginationController.limit,);
      yield* result.fold((l) async* {
        yield state.rebuild((p0) => p0
          ..failure = l
          ..isLoadingMore = false
          ..errorLoadingMore = true
          ..moreNotificationsLoaded = false,);
      }, (r) async* {
        notificationsCount = r.where((element) => element.isNew).toList().length;
        yield state.rebuild((p0) => p0
          ..canLoadMore = r.length > state.paginationController.limit - 1
          ..paginationController!.offset = state.paginationController.offset + 15
          ..notifications!.addAll(r)
          ..isLoadingMore = false
          ..errorLoadingMore = false
          ..moreNotificationsLoaded = true,);
      });
    } else {

    }
  }

  Stream<NotificationsState> mapToGetNotifications(bool withLoading) async* {
    yield state.rebuild((p0) => p0
      ..isLoadingNotifications = withLoading
      ..errorLoadingNotifications = false
      ..notificationsLoaded = false,);
    final result = await notificationsRepository.getNotifications();
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isLoadingNotifications = false
        ..errorLoadingNotifications = true
        ..notificationsLoaded = false,);
    }, (r) async* {
      notificationsCount = r.where((element) => element.isNew).toList().length;
      yield state.rebuild((p0) => p0
        ..notifications = r
        ..canLoadMore = r.length > 14
        ..isLoadingNotifications = false
        ..errorLoadingNotifications = false
        ..notificationsLoaded = true,);
    });
  }

  Stream<NotificationsState> mapToMarkNotificationAsRead(String id, int index) async* {
    yield state.rebuild((p0) => p0
      ..isMarkingNotificationAsRead = true
      ..errorMarkingNotificationAsRead = false
      ..notificationMarkedAsRead = false,);
    final result = await notificationsRepository.markAsRead(id);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isMarkingNotificationAsRead = false
        ..errorMarkingNotificationAsRead = true
        ..notificationMarkedAsRead = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..notifications![index].isNew = false
        ..isMarkingNotificationAsRead = false
        ..errorMarkingNotificationAsRead = false
        ..notificationMarkedAsRead = true,);
    });
    yield* mapToGetNotifications(false);

  }

  Stream<NotificationsState> mapToMarkAllNotificationAsRead() async* {
    yield state.rebuild((p0) => p0
      ..isMarkingAllNotificationsAsRead = true
      ..errorMarkingAllNotificationsAsRead = false
      ..allNotificationsMarkedAsRead = false,);
    final result = await notificationsRepository.marAllAsRead();
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isMarkingAllNotificationsAsRead = false
        ..errorMarkingAllNotificationsAsRead = true
        ..allNotificationsMarkedAsRead = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..isMarkingAllNotificationsAsRead = false
        ..errorMarkingAllNotificationsAsRead = false
        ..allNotificationsMarkedAsRead = true,);
    });
    yield* mapToGetNotifications(false);

  }
}

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import 'package:mpac_app/features/home_features/inbox_feature/presentation/bloc/inbox_event.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/bloc/inbox_state.dart';

@Injectable()
class InboxBloc extends Bloc<InboxEvent, InboxState> {
  InboxBloc() : super(InboxState.initial());

  void onGetUserChannels() {
    add(GetUserChannels());
  }

  void onClearFailures() {
    add(ClearFailures());
  }

  void onUpdateChannels(List<GroupChannel> channels) {
    add(UpdateChannels(channels));
  }

  @override
  Stream<InboxState> mapEventToState(InboxEvent event) async* {
    if (event is GetUserChannels) {
      yield* mapToGetUserChannels();
    } else if (event is UpdateChannels) {
      yield state.rebuild((p0) => p0
        ..channels = event.channels
        ..channelsLoaded = true,);
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0..channelsLoaded = false);
    }
  }

  Stream<InboxState> mapToGetUserChannels() async* {
    yield state.rebuild((p0) => p0
      ..isLoadingChannels = true
      ..errorLoadingChannels = false
      ..channelsLoaded = false,);

    List<GroupChannel> channels = await getGroupChannels();

    yield state.rebuild((p0) => p0
      ..channels = channels
      ..isLoadingChannels = false
      ..errorLoadingChannels = false
      ..channelsLoaded = true,);
  }

  Future<List<GroupChannel>> getGroupChannels() async {
    try {
      final query = GroupChannelListQuery()
        ..myMemberStateFilter = MyMemberStateFilter.all;
        // ..order = GroupChannelListOrder.latestLastMessage;
        // ..limit = 15;
      return await query.next();
    } catch (e) {
      return [];
    }
  }
}

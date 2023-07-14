import 'package:built_value/built_value.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

part 'inbox_state.g.dart';

abstract class InboxState implements Built<InboxState, InboxStateBuilder> {
  InboxState._();

  factory InboxState([Function(InboxStateBuilder b) updates]) = _$InboxState;

  int get currentPageIndex;

  List<GroupChannel> get channels;

  bool get isLoadingChannels;
  bool get errorLoadingChannels;
  bool get channelsLoaded;

  factory InboxState.initial() {
    return InboxState((b) => b
      ..currentPageIndex = 0
      ..channels = []
      ..isLoadingChannels = false
      ..errorLoadingChannels = false
      ..channelsLoaded = false,);
  }
}

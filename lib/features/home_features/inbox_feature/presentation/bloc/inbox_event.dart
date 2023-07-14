import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

abstract class InboxEvent {}

class GetUserChannels extends InboxEvent {}

class ClearFailures extends InboxEvent {}

class UpdateChannels extends InboxEvent {
  final List<GroupChannel> channels;

  UpdateChannels(this.channels);
}
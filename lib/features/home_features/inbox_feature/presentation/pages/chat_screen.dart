// import 'package:dash_chat/dash_chat.dart';
// import 'package:flutter/material.dart';
// import 'package:mpac_app/core/utils/constants/constants.dart';
// import 'package:sendbird_sdk/sendbird_sdk.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String userId;
//   final List<String> otherUserIds;
//
//   const ChatScreen({required this.userId, required this.otherUserIds, Key? key})
//       : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> with ChannelEventHandler {
//   List<BaseMessage> _messages = [];
//   GroupChannel? _groupChannel;
//
//   @override
//   void initState() {
//     load();
//     SendbirdSdk().addChannelEventHandler("chat", this);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     SendbirdSdk().removeChannelEventHandler("chat");
//
//     _groupChannel!.deleteChannel();
//     super.dispose();
//   }
//
//
//   @override
//   void onMessageReceived(BaseChannel channel, BaseMessage message) {
//     setState(() {
//       _messages.add(message);
//     });
//     super.onMessageReceived(channel, message);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: DashChat(
//         messages: asDashChatMessages(_messages),
//         user: asDashChatUser(SendbirdSdk().currentUser),
//         onSend: (ChatMessage c) {
//           var sentMessage =
//           _groupChannel!.sendUserMessageWithText(c.text!);
//           setState(() {
//             _messages.add(sentMessage);
//           });
//         },
//       ),
//     );
//   }
//
//   List<ChatMessage> asDashChatMessages(List<BaseMessage> messages) {
//     return [
//       for (BaseMessage bM in messages)
//         ChatMessage(
//           text: bM.message,
//           user: asDashChatUser(bM.sender),
//         )
//     ];
//   }
//
//   ChatUser asDashChatUser(User? user) {
//     if (user == null) {
//       return ChatUser(uid: "", name: "", avatar: "");
//     } else {
//       return ChatUser(
//           uid: user.userId, name: user.nickname, avatar: user.profileUrl);
//     }
//   }
//
//   void load() async {
//     try {
//       final sendBird = SendbirdSdk(appId: sendbirdAppId);
//       final _ = await sendBird.connect(widget.userId);
//       _groupChannel = await getExistingChannel();
//     } catch (e) {
//     }
//   }
//
//   Future<void> getMessages(GroupChannel channel) async {
//     try {
//       List<BaseMessage> messages = await channel.getMessagesByTimestamp(
//           DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
//       setState(() {
//         _messages = messages;
//       });
//     } catch (e) {
//     }
//   }
//
//   Future<GroupChannel> getExistingChannel() async {
//     final query = GroupChannelListQuery()
//       ..userIdsExactlyIn = widget.otherUserIds
//       ..limit = 15;
//     List<GroupChannel> channels = await query.loadNext();
//     if (channels.isEmpty) {
//       final channel = await createChannel(widget.otherUserIds);
//       getMessages(channel);
//       return channel;
//     } else {
//       getMessages(channels[0]);
//       return channels[0];
//     }
//   }
//
//   Future<GroupChannel> createChannel(List<String> userIds) async {
//     try {
//       final params = GroupChannelParams()..userIds = userIds;
//       final channel = await GroupChannel.createChannel(params);
//       return channel;
//     } catch (e) {
//       throw e;
//     }
//   }
// }

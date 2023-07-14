import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/bloc/inbox_bloc.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/bloc/inbox_state.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/pages/group_channel_view.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/widgets/messenger_tile_widget.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

// import 'package:sendbird_sdk/sendbird_sdk.dart' as sendbird_sdk;
import 'package:sizer/sizer.dart';

class InboxPage extends StatefulWidget {
  final HolderBloc holderBloc;

  const InboxPage({
    required this.holderBloc,
    Key? key,
  }) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final _bloc = getIt<InboxBloc>();
  final List<GroupChannel> _channels = [];
  bool _isLoading = true;

  @override
  void initState() {
    // getExistingChannel();
    super.initState();
    SendbirdChat.init(appId: sendbirdAppId);
    // SendbirdChat.addChannelHandler('MyOpenChannelHandler', MyGroupChannelHandler());
    // SendbirdChat.setLogLevel(LogLevel.info);

    // sendbird_sdk.SendbirdSdk()
    //     .addChannelEventHandler('channel_list_view', this);

    if (sendbirdToken.isNotEmpty && sendbirdAppId.isNotEmpty) {
      SendbirdChat.connect(
        getIt<PrefsHelper>().getUserId,
        accessToken: sendbirdToken,
      ).then((value) {
        _getGroupChannels();
      });
    }
  }

  @override
  void dispose() {
    // sendbird_sdk.SendbirdSdk().removeChannelEventHandler("channel_list_view");
    SendbirdChat.removeAllChannelHandlers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener(
          bloc: BlocProvider.of<InboxBloc>(context),
          listener: (BuildContext context, InboxState state) {
            if (state.channelsLoaded) {
              setState(() {});

              if (_channels.isNotEmpty) {
                _bloc.onUpdateChannels(_channels);
                _bloc.onGetUserChannels();
              }

              BlocProvider.of<InboxBloc>(context).onClearFailures();
            }
          },
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    height: context.w * 0.5,
                    width: context.w * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              : _channels.isEmpty
                  ? Center(
                      child: Text(
                        "You haven't been added to groups yet",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<InboxBloc>(context).onGetUserChannels();
                      },
                      child: ListView.builder(
                        itemCount: _channels.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              MessengerTileWidget(_channels[index]),
                              index == _channels.length - 1
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                    )
                                  : Container()
                            ],
                          );
                        },
                      ),
                    )),
    );
  }

  Future<List<GroupChannel>> _getGroupChannels() async {
    try {
      final query = GroupChannelListQuery()
        // ..order = GroupChannelListOrder.latestLastMessage
        ..myMemberStateFilter = MyMemberStateFilter.all;
      // ..limit = 10;
      final groupChannels = await query.next();

      // final query = sendbird_sdk.GroupChannelListQuery()
      //   ..includeEmptyChannel = true
      //   ..order = sendbird_sdk.GroupChannelListOrder.latestLastMessage;
      // ..limit = 15;

      _channels.addAll(groupChannels);
      setState(() {
        _isLoading = false;
      });
      return _channels;
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });

      return [];
    }
  }

  // Future<sendbird_sdk.GroupChannel> getExistingChannel() async {
  //   final _ = await sendBird.connect(getIt<PrefsHelper>().getUserId);
  //
  //   final query = sendbird_sdk.GroupChannelListQuery()..userIdsExactlyIn = [''];
  //   // ..limit = 15;
  //   List<sendbird_sdk.GroupChannel> channels = await query.loadNext();
  //   if (channels.isEmpty) {
  //     final channel = await createChannel(['BESO']);
  //     return channel;
  //   } else {
  //     return channels[0];
  //   }
  // }

  Future<GroupChannel> createChannel(List<String> userIds) async {
    try {
      final params = GroupChannelCreateParams()
        ..userIds = userIds
        ..isPublic = true;
      // ..operatorUserIds = [OPERATOR_USER_IDS];
      final groupChannel = await GroupChannel.createChannel(params);
      groupChannel.join();
      // final openChannel = await OpenChannel.createChannel(OpenChannelCreateParams());

      // final params = sendbird_sdk.GroupChannelParams()..userIds = userIds;
      // final channel = await sendbird_sdk.GroupChannel.createChannel(params);
      return groupChannel;
    } catch (e) {
      rethrow;
    }
  }

  void gotoChannel(String channelUrl) async {
    final openChannel = await OpenChannel.getChannel(channelUrl);

    await openChannel.enter();

    // sendbird_sdk.GroupChannel.getChannel(channelUrl).then((channel) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => GroupChannelView(groupChannel: channel),
    //     ),
    //   );
    // }).catchError((e) {
    //   //handle error
    // });
  }
}

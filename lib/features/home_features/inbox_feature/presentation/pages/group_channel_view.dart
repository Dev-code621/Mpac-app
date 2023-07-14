import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpac_app/core/data/prefs/prefs_helper.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sizer/sizer.dart';

class GroupChannelPage extends StatefulWidget {
  final GroupChannel groupChannel;

  const GroupChannelPage({Key? key, required this.groupChannel})
      : super(key: key);

  @override
  State<GroupChannelPage> createState() => GroupChannelPageState();
}

class GroupChannelPageState extends State<GroupChannelPage> {
  late String channelUrl;
  final itemScrollController = ItemScrollController();
  final textEditingController = TextEditingController();
  MessageCollection? collection;

  String title = '';
  bool hasPrevious = false;
  bool hasNext = false;
  List<BaseMessage> messageList = [];
  List<String> memberIdList = [];

  double? uploadProgressValue;

  Uint8List? fileBytes;
  String? filePath;

  @override
  void initState() {
    super.initState();
    channelUrl = widget.groupChannel.channelUrl;
    _initializeMessageCollection();
  }

  void _initializeMessageCollection() {
    GroupChannel.getChannel(channelUrl).then((channel) {
      collection = MessageCollection(
        channel: channel,
        params: MessageListParams(),
        handler: MyMessageCollectionHandler(this),
      )..initialize();

      setState(() {
        title = '${channel.name} (${messageList.length})';
        memberIdList = channel.members.map((member) => member.userId).toList();
        memberIdList.sort((a, b) => a.compareTo(b));
      });
    });
  }

  void _disposeMessageCollection() {
    collection?.dispose();
  }

  @override
  void dispose() {
    _disposeMessageCollection();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title, maxLines: 2),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.file_upload),
        //     onPressed: () async {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => GroupChannelSendFileMessagePage(
        //               groupChannel: widget.groupChannel),
        //         ),
        //       );
        //       // Get.toNamed('/group_channel/send_file_message/$channelUrl')
        //       //     ?.then((_) => _refresh());
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.person_add),
        //     onPressed: () async {
        //       Get.toNamed('/group_channel/invite/$channelUrl')
        //           ?.then((_) => _refresh());
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.exit_to_app),
        //     onPressed: () async {
        //       await collection?.channel.leave();
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // memberIdList.isNotEmpty ? _memberIdBox() : Container(),
          // hasPrevious ? _previousButton() : Container(),
          Expanded(
            child: (collection != null && collection!.messageList.isNotEmpty)
                ? _list()
                : Container(),
          ),
          // hasNext ? _nextButton() : Container(),
          _messageSender(),
        ],
      ),
    );
  }

  Widget _memberIdBox() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.maxFinite,
            child: Text(
              memberIdList.toString(),
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 12.0, color: Colors.green),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _previousButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_less, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (collection != null) {
            if (collection!.params.reverse) {
              if (collection!.hasNext && !collection!.isLoading) {
                await collection!.loadNext();
              }
            } else {
              if (collection!.hasPrevious && !collection!.isLoading) {
                await collection!.loadPrevious();
              }
            }
          }

          setState(() {
            if (collection != null) {
              hasPrevious = collection!.hasPrevious;
              hasNext = collection!.hasNext;
            }
          });
        },
      ),
    );
  }

  Widget _list() {
    return ScrollablePositionedList.builder(
      physics: const BouncingScrollPhysics(),
      initialScrollIndex: (collection != null && collection!.params.reverse)
          ? 0
          : messageList.length - 1,
      itemScrollController: itemScrollController,
      itemCount: messageList.length,
      itemBuilder: (BuildContext context, int index) {
        BaseMessage message = messageList[index];
        final imageProvider = Image.network(message.sender!.profileUrl).image;
        final unreadMembers = (collection != null)
            ? collection!.channel.getUnreadMembers(message)
            : [];

        return message.sender!.userId == getIt<PrefsHelper>().getUserId
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.delete),
                        SizedBox(
                          width: 10,
                        ),
                        Text("delete")
                      ],
                    ),
                  ),
                ],
                onSelected: (index) async {
                  switch (index) {
                    case 1:
                      await collection?.channel
                          .deleteMessage(message.messageId);
                      break;
                  }
                },
                child: Column(
                  children: [
                    ListTile(
                      title: index >= 1
                          ? message.sender!.userId !=
                                  messageList[index - 1].sender!.userId
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Padding(
                                    //   padding:
                                    //   const EdgeInsets.only(right: 4.0),
                                    //   child: Text(
                                    //     message.sender?.nickname ?? '',
                                    //     style: TextStyle(
                                    //         fontSize: 14.sp,
                                    //         color: Colors.white),
                                    //   ),
                                    // ),
                                    InkWell(
                                      onTap: () {
                                        showImageViewer(
                                          context,
                                          imageProvider,
                                          onViewerDismissed: () {},
                                        );
                                      },
                                      child: Widgets.imageNetwork(
                                        message.sender?.profileUrl,
                                        MediaQuery.of(context).size.width > 760 ? 20.sp : 35.sp,
                                        Icons.account_circle,
                                        isProfile: true,
                                      ),
                                    ),
                                    // Container(
                                    //   margin: const EdgeInsets.only(left: 16),
                                    //   alignment: Alignment.centerRight,
                                    //   child: Text(
                                    //     DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                                    //         .toString(),
                                    //     style: const TextStyle(
                                    //         fontSize: 12.0, color: Colors.white),
                                    //   ),
                                    // ),
                                  ],
                                )
                              : Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Padding(
                                //   padding:
                                //   const EdgeInsets.only(right: 4.0),
                                //   child: Text(
                                //     message.sender?.nickname ?? '',
                                //     style: TextStyle(
                                //         fontSize: 14.sp,
                                //         color: Colors.white),
                                //   ),
                                // ),
                                InkWell(
                                  onTap: () {
                                    showImageViewer(
                                      context,
                                      imageProvider,
                                      onViewerDismissed: () {},
                                    );
                                  },
                                  child: Widgets.imageNetwork(
                                    message.sender?.profileUrl,
                                    MediaQuery.of(context).size.width > 760 ? 20.sp : 35.sp,
                                    Icons.account_circle,
                                    isProfile: true,
                                  ),
                                ),
                                // Container(
                                //   margin: const EdgeInsets.only(left: 16),
                                //   alignment: Alignment.centerRight,
                                //   child: Text(
                                //     DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                                //         .toString(),
                                //     style: const TextStyle(
                                //         fontSize: 12.0, color: Colors.white),
                                //   ),
                                // ),
                              ],
                            ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(
                            left: 20.sp, right: 20.sp, top: 5.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (message is FileMessage)
                                ? Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          final imageProvider =
                                              Image.network(message.secureUrl!)
                                                  .image;
                                          showImageViewer(
                                            context,
                                            imageProvider,
                                            onViewerDismissed: () {},
                                          );
                                        },
                                        child: Widgets.imageNetwork(
                                            message.secureUrl,
                                            150.sp,
                                            Icons.file_present),
                                      ),
                                      // Expanded(
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.only(left: 4.0),
                                      //     child: Text(
                                      //       message.name ?? '',
                                      //       style:
                                      //           const TextStyle(color: Colors.white),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.5),
                                        color: Colors.white),
                                    padding: EdgeInsets.all(10.sp),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    child: Text(
                                      message.message,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                            // if (message.sender != null && message.sender!.isCurrentUser)
                            //   Container(
                            //     alignment: Alignment.centerRight,
                            //     child: Text(
                            //       unreadMembers.isNotEmpty
                            //           ? '${unreadMembers.length}'
                            //           : '',
                            //       style: const TextStyle(
                            //         fontSize: 12.0,
                            //         color: Colors.green,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: index >= 1
                          ? message.sender!.userId !=
                                  messageList[index - 1].sender!.userId
                              ? 0
                              : 20.sp
                          : 0,
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  ListTile(
                    title: index >= 1
                        ? message.sender!.userId !=
                                messageList[index - 1].sender!.userId
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showImageViewer(
                                        context,
                                        imageProvider,
                                        onViewerDismissed: () {},
                                      );
                                    },
                                    child: Widgets.imageNetwork(
                                      message.sender?.profileUrl,
                                      MediaQuery.of(context).size.width > 760 ? 20.sp : 35.sp,
                                      Icons.account_circle,
                                      isProfile: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        message.sender?.nickname ?? '',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(left: 16),
                                  //   alignment: Alignment.centerRight,
                                  //   child: Text(
                                  //     DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                                  //         .toString(),
                                  //     style: const TextStyle(
                                  //         fontSize: 12.0, color: Colors.white),
                                  //   ),
                                  // ),
                                ],
                              )
                            : Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  showImageViewer(
                                    context,
                                    imageProvider,
                                    onViewerDismissed: () {},
                                  );
                                },
                                child: Widgets.imageNetwork(
                                  message.sender?.profileUrl,
                                  MediaQuery.of(context).size.width > 760 ? 20.sp : 35.sp,
                                  Icons.account_circle,
                                  isProfile: true,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    message.sender?.nickname ?? '',
                                    style: TextStyle(
                                        fontSize: 14.sp, color: Colors.white),
                                  ),
                                ),
                              ),
                              // Container(
                              //   margin: const EdgeInsets.only(left: 16),
                              //   alignment: Alignment.centerRight,
                              //   child: Text(
                              //     DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                              //         .toString(),
                              //     style: const TextStyle(
                              //         fontSize: 12.0, color: Colors.white),
                              //   ),
                              // ),
                            ],
                          ),
                    subtitle: Padding(
                      padding:
                          EdgeInsets.only(left: 20.sp, right: 20.sp, top: 5.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (message is FileMessage)
                              ? Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final imageProvider =
                                            Image.network(message.secureUrl!)
                                                .image;
                                        showImageViewer(
                                          context,
                                          imageProvider,
                                          onViewerDismissed: () {},
                                        );
                                      },
                                      child: Widgets.imageNetwork(
                                          message.secureUrl,
                                          150.sp,
                                          Icons.file_present),
                                    ),
                                    // Expanded(
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.only(left: 4.0),
                                    //     child: Text(
                                    //       message.name ?? '',
                                    //       style:
                                    //           const TextStyle(color: Colors.white),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.5),
                                      color: Colors.white),
                                  padding: EdgeInsets.all(10.sp),
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: Text(
                                    message.message,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                          // if (message.sender != null && message.sender!.isCurrentUser)
                          //   Container(
                          //     alignment: Alignment.centerRight,
                          //     child: Text(
                          //       unreadMembers.isNotEmpty
                          //           ? '${unreadMembers.length}'
                          //           : '',
                          //       style: const TextStyle(
                          //         fontSize: 12.0,
                          //         color: Colors.green,
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: index >= 1
                        ? message.sender!.userId !=
                                messageList[index - 1].sender!.userId
                            ? 0
                            : 20.sp
                        : 0,
                  )
                ],
              );
      },
    );
  }

  Widget _nextButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_more, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (collection != null) {
            if (collection!.params.reverse) {
              if (collection!.hasPrevious && !collection!.isLoading) {
                await collection!.loadPrevious();
              }
            } else {
              if (collection!.hasNext && !collection!.isLoading) {
                await collection!.loadNext();
              }
            }
          }

          setState(() {
            if (collection != null) {
              hasPrevious = collection!.hasPrevious;
              hasNext = collection!.hasNext;
            }
          });
        },
      ),
    );
  }

  Widget _messageSender() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.sp),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12.5)),
        child: Row(
          children: [
            Expanded(
              child: Widgets.textField(textEditingController, 'Message',
                  enabled: (uploadProgressValue == null ||
                      uploadProgressValue! == 1.0)),
            ),
            (uploadProgressValue != null)
                ? uploadProgressValue! < 1.0
                    ? CircularProgressIndicator(value: uploadProgressValue)
                    : IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () async {
                          await pickImage().then((value) => onImagePicked());
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => GroupChannelSendFileMessagePage(
                          //       groupChannel: widget.groupChannel,
                          //     ),
                          //   ),
                          // );
                          // Get.toNamed('/group_channel/send_file_message/$channelUrl')
                          //     ?.then((_) => _refresh());
                        },
                      )
                : IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () async {
                      await pickImage().then((value) => onImagePicked());
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => GroupChannelSendFileMessagePage(
                      //       groupChannel: widget.groupChannel,
                      //     ),
                      //   ),
                      // );
                      // Get.toNamed('/group_channel/send_file_message/$channelUrl')
                      //     ?.then((_) => _refresh());
                    },
                  ),
            IconButton(
              onPressed: (uploadProgressValue == null ||
                      uploadProgressValue! == 1.0)
                  ? () {
                      if (textEditingController.value.text.isEmpty) {
                        return;
                      }

                      collection?.channel.sendUserMessage(
                        UserMessageCreateParams(
                          message: textEditingController.value.text,
                        ),
                        handler: (UserMessage message, SendbirdException? e) {
                          if (e != null) throw Exception(e.toString());
                        },
                      );

                      textEditingController.clear();
                    }
                  : null,
              icon: const Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      if (kIsWeb) {
        fileBytes = result.files.single.bytes;
      } else {
        filePath = result.files.single.path;
      }

      if (fileBytes != null || filePath != null) {
        setState(() {
          textEditingController.text = result.files.first.name;
        });
      }
    }
  }

  void onImagePicked() async {
    FileMessageCreateParams? params;
    if (kIsWeb && fileBytes != null) {
      params = FileMessageCreateParams.withFileBytes(
        fileBytes!,
        fileName: textEditingController.text,
      );
    } else if (filePath != null) {
      params = FileMessageCreateParams.withFile(
        File(filePath!),
        fileName: textEditingController.text,
      );
    }

    if (params != null) {
      final channel = await GroupChannel.getChannel(channelUrl);
      channel.sendFileMessage(
        params,
        handler: (FileMessage message, SendbirdException? e) {
          textEditingController.clear();
          // Get.back();
        },
        progressHandler: (sentBytes, totalBytes) {
          setState(() {
            uploadProgressValue = (sentBytes / totalBytes);
          });
        },
      );
    }
    textEditingController.clear();
  }

  void _refresh({bool markAsRead = false}) {
    if (markAsRead) {
      SendbirdChat.markAsRead(channelUrls: [channelUrl]);
    }

    setState(() {
      if (collection != null) {
        messageList = collection!.messageList;
        title = '${collection!.channel.name} (${messageList.length})';
        hasPrevious = collection!.params.reverse
            ? collection!.hasNext
            : collection!.hasPrevious;
        hasNext = collection!.params.reverse
            ? collection!.hasPrevious
            : collection!.hasNext;
        memberIdList =
            collection!.channel.members.map((member) => member.userId).toList();
        memberIdList.sort((a, b) => a.compareTo(b));
      }
    });
  }

  void _scrollToAddedMessages(CollectionEventSource eventSource) async {
    if (collection == null || collection!.messageList.length <= 1) return;

    final reverse = collection!.params.reverse;
    final previous = eventSource == CollectionEventSource.messageLoadPrevious;

    final int index;
    if ((reverse && previous) || (!reverse && !previous)) {
      index = collection!.messageList.length - 1;
    } else {
      index = 0;
    }

    while (!itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class MyMessageCollectionHandler extends MessageCollectionHandler {
  final GroupChannelPageState _state;

  MyMessageCollectionHandler(this._state);

  @override
  void onMessagesAdded(MessageContext context, GroupChannel channel,
      List<BaseMessage> messages) async {
    _state._refresh(markAsRead: true);

    if (context.collectionEventSource !=
        CollectionEventSource.messageInitialize) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _state._scrollToAddedMessages(context.collectionEventSource),
      );
    }
  }

  @override
  void onMessagesUpdated(MessageContext context, GroupChannel channel,
      List<BaseMessage> messages) {
    _state._refresh();
  }

  @override
  void onMessagesDeleted(MessageContext context, GroupChannel channel,
      List<BaseMessage> messages) {
    _state._refresh();
  }

  @override
  void onChannelUpdated(GroupChannelContext context, GroupChannel channel) {
    _state._refresh();
  }

  @override
  void onChannelDeleted(GroupChannelContext context, String deletedChannelUrl) {
    Get.back();
  }

  @override
  void onHugeGapDetected() {
    _state._disposeMessageCollection();
    _state._initializeMessageCollection();
  }
}

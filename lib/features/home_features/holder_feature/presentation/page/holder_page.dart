import 'dart:io';
import 'package:animations/animations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/constants/constants.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_bloc.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/bloc/holder_state.dart';
import 'package:mpac_app/features/home_features/holder_feature/presentation/widgets/custom_appbar_widget.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_state.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/page/home_page.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/pages/inbox_page.dart';
import 'package:mpac_app/features/home_features/profile_feature/presentation/pages/profile_page.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_bloc.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_state.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/pages/trending_page.dart';
import 'package:mpac_app/main.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sizer/sizer.dart';

late BuildContext topLevelContext;

Future<void> onBackgroundMessage(RemoteMessage message) {
  if (message.data['type'] == "react_notification" ||
      message.data['type'] == "comment_notification") {
    Navigator.pushNamed(
      topLevelContext,
      AppScreens.postInformationPage,
      arguments: {'postId': message.data['post_id']},
    );
  }
  if (message.data['tye'] == 'follow_notification') {
    Navigator.pushNamed(
      topLevelContext,
      AppScreens.profilePage,
      arguments: {
        'profile_id': message.data['user_id'],
        'withAppBar': true,
        'flowCalled': 'notifications'
      },
    );
  }

  return Future.value(true);
}

class HolderPage extends StatefulWidget {
  const HolderPage({Key? key}) : super(key: key);

  @override
  State<HolderPage> createState() => _HolderPageState();
}

class _HolderPageState extends State<HolderPage> {
  final _bloc = getIt<HolderBloc>();
  List<Widget> pages = [];
  late AppLocalizations localizations;
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'ic_launcher_foreground',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    topLevelContext = context;
    BlocProvider.of<HomeBloc>(context).onGetFeedPosts();
    BlocProvider.of<TrendingBloc>(context).onGetTrendingPosts();
    pages = [
      HomePage(holderBloc: _bloc),
      TrendingPage(holderBloc: _bloc),
      InboxPage(holderBloc: _bloc),
      ProfilePage(withAppBar: false, flowCalled: "profile", holderBloc: _bloc),
    ];
    //connect(sendbirdAppId, getIt<PrefsHelper>().getUserId);

    if (!kIsWeb && Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestPermission()
          .then((value) {});
      FirebaseMessaging.instance.getInitialMessage().then(
            (value) => setState(
              () {
                // _resolved = true;
                // initialMessage = value?.data.toString();

                if (value != null) {
                  showFlutterNotification(value);
                }
              },
            ),
          );
      FirebaseMessaging.onMessage.listen(showFlutterNotification);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == "react_notification" ||
            message.data['type'] == "comment_notification") {
          Navigator.pushNamed(
            context,
            AppScreens.postInformationPage,
            arguments: {'postId': message.data['post_id']},
          );
        }
        if (message.data['tye'] == 'follow_notification') {
          Navigator.pushNamed(
            context,
            AppScreens.profilePage,
            arguments: {
              'profile_id': message.data['user_id'],
              'withAppBar': true,
              'flowCalled': 'notifications'
            },
          );
        }
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   // arguments: MessageArguments(message, true),
        // );
      });

      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    if (kIsWeb) {
      initializeFirebaseForSafari();
    }
  }

  initializeFirebaseForSafari() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

    if (!webBrowserInfo.browserName
        .toString()
        .toLowerCase()
        .contains("safari")) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DynamicDialog(
                title: message.notification!.title,
                body: message.notification!.body,
              );
            }),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == "react_notification" ||
            message.data['type'] == "comment_notification") {
          Navigator.pushNamed(
            context,
            AppScreens.postInformationPage,
            arguments: {'postId': message.data['post_id']},
          );
        }
        if (message.data['tye'] == 'follow_notification') {
          Navigator.pushNamed(
            context,
            AppScreens.profilePage,
            arguments: {
              'profile_id': message.data['user_id'],
              'withAppBar': true,
              'flowCalled': 'notifications'
            },
          );
        }
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   // arguments: MessageArguments(message, true),
        // );
      });

      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, HolderState state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(),
          ),
          backgroundColor: Colors.black,
          bottomNavigationBar: _bottomNavigationBar(state),
          body: Column(
            children: [
              state.currentPageIndex == 3
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CustomAppBarWidget(
                        localeName: localizations.localeName,
                        backgroundColor: state.currentPageIndex == 3
                            ? const Color(0xff111111)
                            : Colors.black,
                      ),
                    ),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) =>
                      FadeThroughTransition(
                    fillColor: AppColors.secondaryBackgroundColor,
                    secondaryAnimation: secondaryAnimation,
                    animation: animation,
                    child: child,
                  ),
                  child: pages[state.currentPageIndex],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomNavigationBar(HolderState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.11 +
          MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/home.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/home.svg',
                  tabIndex: homeTab,
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/trending.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/trending.svg',
                  tabIndex: trendingTab,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.085,
                  width: MediaQuery.of(context).size.height * 0.085,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.logoColor,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppScreens.addNewPostPage,
                      );
                    },
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/inbox.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/inbox.svg',
                  tabIndex: inboxTab,
                ),
                tabWidget(
                  state: state,
                  svgPath: 'assets/images/nav/active/profile.svg',
                  inActiveSvgPath: 'assets/images/nav/inactive/profile.svg',
                  tabIndex: profileTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tabWidget({
    required HolderState state,
    required svgPath,
    required inActiveSvgPath,
    required int tabIndex,
  }) {
    return InkWell(
      onTap: () => _navigateTo(tabIndex),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 6.h,
            height: 6.h,
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    state.currentPageIndex == tabIndex
                        ? svgPath
                        : inActiveSvgPath,
                    height: Dimensions.checkKIsWeb(context)
                        ? context.h * 0.03
                        : context.h * 0.027,
                    // color: state.currentPageIndex == tabIndex
                    //     ? Colors.white
                    //     : AppColors.unSelectedWidgetColor,
                  ),
                ),
              ],
            ),
          ),
          // Expanded(child: SizedBox())
          Text(
            getTitleBasedOnIndex(tabIndex),
            style: TextStyle(
              fontSize:
                  Dimensions.checkKIsWeb(context) ? context.h * 0.026 : 11.sp,
              color: state.currentPageIndex == tabIndex
                  ? Colors.white
                  : AppColors.unSelectedWidgetColor,
            ),
          )
        ],
      ),
    );
  }

  String getTitleBasedOnIndex(int index) {
    switch (index) {
      case 0:
        return localizations.home;
      case 1:
        return localizations.trending;
      case 2:
        return localizations.inbox;
      default:
        return localizations.profile;
    }
  }

  void _navigateTo(int index) {
    _bloc.onChangePageIndex(index);
    disposeAll(
      BlocProvider.of<HomeBloc>(context).state,
      BlocProvider.of<TrendingBloc>(context).state,
    );
  }

  void disposeAll(HomeState state, TrendingState tState) {
    for (int i = 0; i < state.posts.length; i++) {
      for (int j = 0; j < state.posts[i].medias.length; j++) {
        if (state.posts[i].medias[j].videoPlayerController != null) {
          state.posts[i].medias[j].videoPlayerController!.dispose();
          state.posts[i].medias[j].videoPlayerController = null;
          state.posts[i].medias[j].isVideoPaused = false;
          state.posts[i].medias[j].isLoading = false;
          state.posts[i].medias[j].showSettings = false;
        }
      }
    }

    for (int i = 0; i < tState.posts.length; i++) {
      for (int j = 0; j < tState.posts[i].medias.length; j++) {
        if (tState.posts[i].medias[j].videoPlayerController != null) {
          tState.posts[i].medias[j].videoPlayerController!.dispose();
          tState.posts[i].medias[j].videoPlayerController = null;
        }
      }
    }
  }
}

class DynamicDialog extends StatefulWidget {
  final title;
  final body;

  const DynamicDialog({super.key, this.title, this.body});

  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: <Widget>[
        OutlinedButton.icon(
          label: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        )
      ],
      content: Text(widget.body),
    );
  }
}

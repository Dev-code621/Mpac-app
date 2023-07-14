import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mpac_app/app.dart';
import 'package:mpac_app/core/data/repository/repos/post_repository.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/presentation/bloc/app_bloc.dart';
import 'package:mpac_app/features/home_features/home_feature/presentation/bloc/home_bloc.dart';
import 'package:mpac_app/features/home_features/inbox_feature/presentation/bloc/inbox_bloc.dart';
import 'package:mpac_app/features/home_features/trending_feature/presentation/bloc/trending_bloc.dart';
import 'package:mpac_app/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDi();

  if (!kIsWeb) {
    await VideoCompress.deleteAllCache();

    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });

    await Firebase.initializeApp();

    PhotoManager.clearFileCache();

    bool isFlutterLocalNotificationsInitialized = false;

    Future<void> setupFlutterNotifications() async {
      if (isFlutterLocalNotificationsInitialized) {
        return;
      }

      const channelId = 'uploads';
      const channelName = 'Uploads';
      const channelDescription = 'Notifications for ongoing uploads';

      const AndroidNotificationChannel uploadsChannel =
          AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        enableVibration: false,
        enableLights: false,
        showBadge: false,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(uploadsChannel);

      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      isFlutterLocalNotificationsInitialized = true;
    }

    await setupFlutterNotifications();
  }

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

    if (!webBrowserInfo.browserName
        .toString()
        .toLowerCase()
        .contains("safari")) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }

  await dotenv.load(fileName: ".env");

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(
          create: (context) => AppBloc(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) =>
              HomeBloc(postRepository: getIt<PostRepository>()),
        ),
        BlocProvider<TrendingBloc>(
          create: (_) => TrendingBloc(getIt<PostRepository>()),
        ),
        // BlocProvider<AddPostBloc>(
        //     create: (_) => AddPostBloc(getIt<PostRepository>(), getIt<>)),
        BlocProvider<InboxBloc>(
          create: (_) => InboxBloc(),
        ),
      ],
      child: const App(),
    ),
  );
}

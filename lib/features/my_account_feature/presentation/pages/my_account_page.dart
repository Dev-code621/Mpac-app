import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/custom_image_picker.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_bloc.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_state.dart';
import 'package:mpac_app/features/my_account_feature/presentation/bloc/my_account_event.dart';
import 'package:mpac_app/features/my_account_feature/presentation/widgets/account_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_profile_information.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> with FlushBarMixin {
  late AppLocalizations localizations;
  ImagePicker imagePicker = ImagePicker();
  final _bloc = getIt<MyAccountBloc>();
  CustomImagePicker ciPicker = CustomImagePicker();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, MyAccountState state) {
        if (state.errorUploadingPicture && state.failure != null) {
          _bloc.add(ClearFailures());
          exceptionFlushBar(
            context: context,
            duration: const Duration(milliseconds: 1500),
            message: (state.failure as ServerFailure).errorMessage ??
                "Server error!",
            onHidden: () {
              _bloc.add(ClearFailures());
            },
            onChangeStatus: (s) {},
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff373737),
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(),
        ),
        body: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, MyAccountState state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: SizedBox(
                                height: context.h * 0.05,
                                width: Dimensions.checkKIsWeb(context)
                                    ? context.w * 0.075
                                    : context.w * 0.15,
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: const Color(0xffB7B7B7),
                                    size: context.h * 0.025,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              localizations.my_account,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimensions.checkKIsWeb(context)
                                    ? context.h * 0.032
                                    : 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: const [CustomProfileInformation()],
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.05,
                  ),
                  // AccountTile(
                  //     title: localizations.follow_and_invite_friends,
                  //     svgPath: 'assets/images/account_icons/invite.svg',
                  //     onTap: () {
                  //       Navigator.pushNamed(
                  //           context, AppScreens.followAndInvitePage);
                  //     },
                  //     withArrowIcon: true),
                  // AccountTile(
                  //     title: localizations.my_players,
                  //     onTap: () {},
                  //     svgPath: 'assets/images/icons/players.svg'),
                  AccountTile(
                    title: localizations.license_agreement,
                    onTap: () {},
                    svgPath:
                        'assets/images/account_icons/licence_agreement.svg',
                  ),
                  AccountTile(
                    title: localizations.download_my_data,
                    onTap: () {},
                    svgPath: 'assets/images/account_icons/download.svg',
                  ),
                  AccountTile(
                    title: localizations.help,
                    onTap: () {},
                    svgPath: 'assets/images/account_icons/help.svg',
                    withArrowIcon: true,
                  ),
                  AccountTile(
                    title: localizations.logout,
                    onTap: () async {
                      if (kIsWeb) {
                        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                        WebBrowserInfo webBrowserInfo =
                            await deviceInfo.webBrowserInfo;
                        if (!webBrowserInfo.browserName
                            .toString()
                            .toLowerCase()
                            .contains("safari")) {
                          FirebaseMessaging.instance.deleteToken();
                          getIt<SharedPreferences>().clear();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppScreens.splashPage,
                            (route) => false,
                          );
                        } else {
                          getIt<SharedPreferences>().clear();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppScreens.splashPage,
                            (route) => false,
                          );
                        }
                      } else {
                        FirebaseMessaging.instance.deleteToken();
                        getIt<SharedPreferences>().clear();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppScreens.splashPage,
                          (route) => false,
                        );
                      }
                    },
                    svgPath: 'assets/images/account_icons/logout.svg',
                  ),
                  // AccountTile(
                  //     withDivider: false,
                  //     title: localizations.delete_my_account,
                  //     onTap: () {},
                  //     svgPath: 'assets/images/account_icons/delet_account.svg'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

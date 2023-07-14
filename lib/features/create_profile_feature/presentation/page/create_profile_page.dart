import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_event.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/sub_pages/player_information_page.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/sub_pages/player_status_location_page.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_step_holder_page.dart';
import 'package:mpac_app/core/utils/widgets/dialogs/custom_dialog.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_bloc.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/bloc/create_profile_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum ViewType { initial, coach, splash, profile }

class CreateProfilePage extends StatefulWidget {
  final ViewType viewType;

  const CreateProfilePage({required this.viewType, Key? key}) : super(key: key);

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage>
    with FlushBarMixin {
  late AppLocalizations localizations;
  final PageController _pageController = PageController();
  final _bloc = getIt<CreateProfileBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _bloc.onLoadCountries();
    _bloc.add(GetCurrentUser());
    if (!kIsWeb) {
      FirebaseMessaging.instance.getToken().then((value) {
        String? token = value;
        _bloc.add(ChangingFirebaseToken(value!));
      });
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
      FirebaseMessaging.instance.getToken().then((value) {
        String? token = value;
        _bloc.add(ChangingFirebaseToken(value!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, CreateProfileState state) {
        if (state.informationUpdated) {
          _bloc.onClearFailures();
          if (state.currentPageIndex == 0) {
            _pageController.animateToPage(
              1,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 500),
            );
            _bloc.onChangePageIndex(1);
          } else {
            if (widget.viewType == ViewType.initial ||
                widget.viewType == ViewType.splash) {
              CustomDialogs.congratsDialog(
                  context: context,
                  localizations: localizations,
                  onSubmit: () {
                    Navigator.pushNamed(
                        context, AppScreens.selectYourProfilePage);
                    // Navigator.pop(context);
                    // Navigator.pushNamed(context, AppScreens.sportSelectionPage,
                    //     arguments: {'viewType': ViewType.initial},);
                  },);
            } else {
              Navigator.pushNamed(context, AppScreens.sportSelectionPage,
                  arguments: {'viewType': ViewType.splash},);
            }
          }
        }
        if (state.failure != null) {
          _bloc.onClearFailures();
          exceptionFlushBar(
              onChangeStatus: (s) {},
              onHidden: () {
                _bloc.onClearFailures();
              },
              duration: const Duration(milliseconds: 2000),
              message:
                  (state.failure as ServerFailure).errorMessage ?? "Error!",
              context: context,);
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, CreateProfileState state) {
          return CustomStepHolderPage(
            viewType: widget.viewType,
            hideBackButton: (widget.viewType == ViewType.splash),
            title: localizations.create_profile,
            step1: PlayerInformationPage(
                bloc: _bloc,
                localizations: localizations,
                onStepSubmit: () {
                  _bloc.add(HitUpdateButton(0));

                  // _pageController.animateToPage(
                  //   state.currentPageIndex + 1,
                  //   curve: Curves.ease,
                  //   duration: const Duration(milliseconds: 500),
                  // );
                  // _bloc.onChangePageIndex(state.currentPageIndex + 1);
                },
                onChangeCountry: (s) {
                  _bloc.onLoadStates(s, false);
                },),
            step2: PlayerStatusLocationPage(
                bloc: _bloc,
                localizations: localizations,
                onChangeCountry: (s) {
                  _bloc.onLoadStates(s, true);
                },
                onStepSubmit: () {
                  _bloc.add(HitUpdateButton(1));

                  // if (widget.viewType == ViewType.initial) {
                  //   CustomDialogs.congratsDialog(
                  //       context: context,
                  //       localizations: localizations,
                  //       onSubmit: () {
                  //         Navigator.pushNamed(
                  //             context, AppScreens.selectYourProfilePage);
                  //       });
                  // } else {
                  //   Navigator.pushNamed(
                  //       context, AppScreens.sportSelectionPage,
                  //       arguments: {'viewType': widget.viewType});
                  // }
                },),
            currentPageIndex: state.currentPageIndex,
            pageController: _pageController,
            onBackButtonClicked: () {
              if (state.currentPageIndex == 1) {
                _pageController.animateToPage(
                  0,
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 500),
                );
                _bloc.onChangePageIndex(0);
              } else {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }
}

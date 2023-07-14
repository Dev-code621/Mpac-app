import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/widgets/custom_app_logo.dart';
import 'package:mpac_app/core/utils/widgets/custom_background_widget.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/bloc/splash_bloc.dart';
import 'package:mpac_app/features/onboarding_features/splash_feature/presentation/bloc/splash_state.dart';
import 'package:sizer/sizer.dart';

int notificationsCount = 0;

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _bloc = getIt<SplashBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.onCheckJWT();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, SplashState state) {
        if (state.jwtChecked && state.currentSignedInUser != null) {
          if(state.currentSignedInUser!.isEmailVerified!){
            if(state.currentSignedInUser!.onBoardingStep! > 4){
              Navigator.pushNamedAndRemoveUntil(context, AppScreens.holderPage, (route) => false);
            } else {
              if(state.currentSignedInUser!.onBoardingStep! == 1 || state.currentSignedInUser!.onBoardingStep! == 2){
                Navigator.pushNamedAndRemoveUntil(context, AppScreens.createProfilePage, (route) => false, arguments: {'viewType': ViewType.splash});
              } else if(state.currentSignedInUser!.onBoardingStep! == 3 ){
                Navigator.pushNamedAndRemoveUntil(context, AppScreens.sportSelectionPage, (route) => false, arguments: {'viewType': ViewType.splash});
              } else if(state.currentSignedInUser!.onBoardingStep! == 4 || state.currentSignedInUser!.onBoardingStep! == 5){
                Navigator.pushNamedAndRemoveUntil(context, AppScreens.holderPage, (route) => false);
              }
            }
          } else {
            if(state.currentSignedInUser!.onBoardingStep! == 1 || state.currentSignedInUser!.onBoardingStep! == 2){
              Navigator.pushNamedAndRemoveUntil(context, AppScreens.createProfilePage, (route) => false, arguments: {'viewType': ViewType.splash});
            } else if(state.currentSignedInUser!.onBoardingStep! == 3){
              // Navigator.pushNamedAndRemoveUntil(context, AppScreens.sportSelectionPage, (route) => false, arguments: {'viewType': ViewType.splash});
              Navigator.pushNamedAndRemoveUntil(context, AppScreens.holderPage, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, AppScreens.holderPage, (route) => false);
            }
            Navigator.pushNamedAndRemoveUntil(context, AppScreens.otpVerificationPage, (route) => false, arguments: {
              'viewType': ViewType.splash
            },);
            // Navigator.pushNamedAndRemoveUntil(context, AppScreens.holderPage, (route) => false);
          }
        }
        if (state.errorCheckingJWT || state.notLoggedIn) {
          Navigator.pushNamedAndRemoveUntil(context, AppScreens.getStartedPage, (route) => false);
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, SplashState state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  const CustomBackgroundWidget(),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomAppLogo(),
                              SizedBox(
                                height: context.h * 0.1,
                              ),
                              Text(
                                "Sport Management\nPlatform",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.logoColor,
                                    fontFamily: "Inter",
                                    fontSize: 15.sp,),
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 24.0, right: 24, bottom: 10.h,),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                              strokeWidth: 1.5,
                            ),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

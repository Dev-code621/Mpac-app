import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/continue_with_account_widget.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/authentication_features/sign_in_feature/presentation/bloc/sign_in_bloc.dart';
import 'package:mpac_app/features/authentication_features/sign_in_feature/presentation/bloc/sign_in_state.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:sizer/sizer.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with FlushBarMixin {
  late AppLocalizations localizations;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _bloc = getIt<SignInBloc>();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, SignInState state) {
        if (state.loggedIn) {
          _bloc.onClearFailure();
          if (state.signedInUser!.isEmailVerified!) {
            if (state.signedInUser!.onBoardingStep! > 4) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppScreens.holderPage,
                (route) => false,
              );
            } else {
              if (state.signedInUser!.onBoardingStep! == 1 ||
                  state.signedInUser!.onBoardingStep! == 2) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppScreens.createProfilePage,
                  (route) => false,
                  arguments: {'viewType': ViewType.splash},
                );
              } else if (state.signedInUser!.onBoardingStep! == 3) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppScreens.sportSelectionPage,
                  (route) => false,
                  arguments: {'viewType': ViewType.splash},
                );
              } else if (state.signedInUser!.onBoardingStep! == 4 ||
                  state.signedInUser!.onBoardingStep! == 5) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppScreens.holderPage,
                  (route) => false,
                );
              }
            }
          } else {
            Navigator.pushNamed(
              context,
              AppScreens.otpVerificationPage,
              arguments: {'viewType': ViewType.initial},
            );
          }
        }
        if (state.errorLoggingIn) {
          if (state.failure != null) {
            _bloc.onClearFailure();
            exceptionFlushBar(
              onChangeStatus: (s) {},
              onHidden: () {
                _bloc.onClearFailure();
              },
              duration: const Duration(milliseconds: 2000),
              message:
                  (state.failure as ServerFailure).errorMessage ?? "Error!",
              context: context,
            );
          }
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, SignInState state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: context.h * 0.05),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localizations.welcome,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.041
                            : 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.06,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localizations.sign_in,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimensions.checkKIsWeb(context)
                            ? context.h * 0.031
                            : 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.015,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomTextFieldWidget(
                      onChanged: (val) {
                        _bloc.onChangingEmail(val);
                      },
                      showError: state.errorValidationEmail,
                      errorText: localizations.invalid_email,
                      hintText: localizations.email,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      inputType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(
                    height: context.h * 0.010,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomTextFieldWidget(
                      autocorrect: false,
                      onChanged: (val) {
                        _bloc.onChangingPassword(val);
                      },
                      showError: state.errorValidationPassword,
                      errorText: localizations.invalid_password,
                      hintText: localizations.password,
                      obscureText: state.isObscureText,
                      controller: _passwordController,
                      inputType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      onSubmit: (v) {
                        _bloc.onHitLoginButton();
                      },
                      icon: GestureDetector(
                        onTap: () {
                          _bloc.onChangeObscureText(!state.isObscureText);
                        },
                        child: !state.isObscureText
                            ? Icon(
                                Icons.remove_red_eye,
                                color: AppColors.primaryFontColor,
                              )
                            : SvgPicture.asset(
                                'assets/images/icons/eye.svg',
                                width: context.h * 0.035,
                                color: AppColors.primaryFontColor,
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Align(
                      alignment: localizations.localeName == "ar"
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppScreens.forgetPasswordPage,
                          );
                        },
                        child: Text(
                          localizations.forget_password,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.026
                                : 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.h * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.dont_have_an_account,
                        style: TextStyle(
                          color: AppColors.secondaryFontColor,
                          fontSize: Dimensions.checkKIsWeb(context)
                              ? context.h * 0.031
                              : 14.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppScreens.signUpPage);
                        },
                        child: Text(
                          localizations.sign_up.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: Dimensions.checkKIsWeb(context)
                                ? context.h * 0.031
                                : 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.secondaryFontColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10.0,
                            left: 10.0,
                            bottom: 24.0,
                            top: 24.0,
                          ),
                          child: Text(
                            localizations.or_sign_up_with_email.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Dimensions.checkKIsWeb(context)
                                  ? context.h * 0.026
                                  : 11.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.secondaryFontColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  //   child: ContinueWithAccountWidget(
                  //     buttonText: localizations.continue_with_facebook,
                  //     backgroundColor: AppColors.blueColor,
                  //     hoverColor: Colors.black.withOpacity(0.1),
                  //     textColor: Colors.white,
                  //     borderColor: AppColors.blueColor,
                  //     onPressed: () {},
                  //     widgetAtFirst:
                  //         SvgPicture.asset('assets/images/icons/facebook.svg'),
                  //   ),
                  // ),
                  SizedBox(
                    height: context.h * 0.015,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ContinueWithAccountWidget(
                      buttonText: localizations.continue_with_google,
                      backgroundColor: Colors.white,
                      hoverColor: Colors.black.withOpacity(0.1),
                      textColor: AppColors.primaryFontColor,
                      borderColor: Colors.white,
                      onPressed: () {
                        googleSignIn.signIn().then((value) async {
                          String? token =
                              await value!.authentication.then((value) {});
                          if (token != null) {
                            _bloc.onContinueWithGoogle(token);
                          }
                        });
                      },
                      widgetAtFirst:
                          SvgPicture.asset('assets/images/icons/google.svg'),
                    ),
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                    SizedBox(
                      height: context.h * 0.015,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ContinueWithAccountWidget(
                        buttonText: localizations.continue_with_apple,
                        backgroundColor: Colors.white,
                        hoverColor: Colors.black.withOpacity(0.1),
                        textColor: AppColors.primaryFontColor,
                        borderColor: Colors.white,
                        onPressed: () {
                          _bloc.onContinueWithApple();
                        },
                        widgetAtFirst:
                            SvgPicture.asset('assets/images/icons/apple.svg'),
                      ),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24,
                      bottom: 5.h,
                      top: 8.h,
                    ),
                    child: CustomSubmitButton(
                      buttonText: localizations.log_in.toUpperCase(),
                      backgroundColor: AppColors.primaryColor,
                      onPressed: () {
                        _bloc.onHitLoginButton();
                        // Navigator.pushNamed(context, AppScreens.holderPage);
                      },
                      hoverColor: Colors.grey.withOpacity(0.5),
                      textColor: Colors.white,
                      isLoading: state.isLoggingIn,
                      disable: state.isLoggingIn,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

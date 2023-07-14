import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/continue_with_account_widget.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_text_field_widget.dart';
import 'package:mpac_app/features/authentication_features/sign_up_feature/presentation/bloc/sign_up_bloc.dart';
import 'package:mpac_app/features/authentication_features/sign_up_feature/presentation/bloc/sign_up_state.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:sizer/sizer.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with FlushBarMixin {
  late AppLocalizations localizations;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _bloc = getIt<SignUpBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, SignUpState state) {
        if (state.signedUp) {
          Navigator.pushNamed(
            context,
            AppScreens.otpVerificationPage,
            arguments: {'viewType': ViewType.initial},
          );
          _bloc.onClearFailures();
        }
        if (state.errorSigningUp) {
          if (state.failure != null) {
            _bloc.onClearFailures();
            exceptionFlushBar(
              context: context,
              duration: const Duration(milliseconds: 1500),
              message: (state.failure as ServerFailure).errorMessage ??
                  "Server error!",
              onHidden: () {
                _bloc.onClearFailures();
              },
              onChangeStatus: (s) {},
            );
          }
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, SignUpState state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: Column(
              children: [
                Align(
                  alignment: localizations.localeName == "ar"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: CustomBackButton(
                    localeName: localizations.localeName,
                    onBackClicked: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            localizations.create_your_account,
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
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        //   child: CustomTextFieldWidget(
                        //       onChanged: (val) {
                        //         _bloc.onChangingUsername(val);
                        //       },
                        //       showError: state.errorValidationUsername,
                        //       errorText: localizations.invalid_input,
                        //       hintText: localizations.username,
                        //       controller: _usernameController,
                        //       inputType: TextInputType.emailAddress),
                        // ),
                        SizedBox(
                          height: context.h * 0.010,
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
                            controller: _passwordController,
                            obscureText: state.isObscureText,
                            textInputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            onSubmit: (v) {
                              _bloc.onHitSignUpButton();
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
                                  localizations.or_sign_up_with_email
                                      .toUpperCase(),
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
                        //     widgetAtFirst: SvgPicture.asset(
                        //         'assets/images/icons/facebook.svg'),
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
                            onPressed: () {},
                            widgetAtFirst: SvgPicture.asset(
                              'assets/images/icons/google.svg',
                            ),
                          ),
                        ),
                        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                          SizedBox(
                            height: context.h * 0.015,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: ContinueWithAccountWidget(
                              buttonText: localizations.continue_with_apple,
                              backgroundColor: Colors.white,
                              hoverColor: Colors.black.withOpacity(0.1),
                              textColor: AppColors.primaryFontColor,
                              borderColor: Colors.white,
                              onPressed: () {},
                              widgetAtFirst: SvgPicture.asset(
                                  'assets/images/icons/apple.svg'),
                            ),
                          ),
                        ],
                        SizedBox(
                          height: context.h * 0.05,
                        ),
                        // getPrivacyPolicyWidget(state),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 24.0,
                            right: 24,
                            bottom: 5.h,
                            top: 5.h,
                          ),
                          child: CustomSubmitButton(
                            buttonText: localizations.sign_up.toUpperCase(),
                            backgroundColor: AppColors.primaryColor,
                            onPressed: () {
                              _bloc.onHitSignUpButton();
                              // Navigator.pushNamed(
                              //     context, AppScreens.otpVerificationPage);
                            },
                            hoverColor: Colors.grey.withOpacity(0.5),
                            textColor: Colors.white,
                            isLoading: state.isSigningUp,
                            disable: state.isSigningUp,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getPrivacyPolicyWidget(SignUpState state) {
    return Align(
      alignment: localizations.localeName == "en"
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 3, right: 3),
        child: GestureDetector(
          onTap: () {
            _bloc.onChangingPrivacyPolicyStatus(!state.privacyPolicyStatus);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  _bloc.onChangingPrivacyPolicyStatus(
                      !state.privacyPolicyStatus);
                },
                child: SizedBox(
                  height: context.w * 0.06,
                  width: context.w * 0.06,
                  child: Stack(
                    children: [
                      Container(
                        height: context.w * 0.06,
                        width: context.w * 0.06,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                      ),
                      Center(
                        child: Center(
                          child: Icon(
                            Icons.done,
                            color: state.privacyPolicyStatus
                                ? Colors.black
                                : Colors.white,
                            size: context.w * 0.05,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              RichText(
                text: TextSpan(
                  text: localizations.i_have_read,
                  style: TextStyle(
                    color: AppColors.secondaryFontColor,
                    fontSize: 13.sp,
                  ),
                  children: [
                    TextSpan(
                      text: " ${localizations.privacy_policy}",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13.sp,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

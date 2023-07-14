import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/dimensions.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';
import 'package:mpac_app/features/authentication_features/otp_verification_feature/presentation/bloc/otp_verification_bloc.dart';
import 'package:mpac_app/features/authentication_features/otp_verification_feature/presentation/bloc/otp_verification_event.dart';
import 'package:mpac_app/features/authentication_features/otp_verification_feature/presentation/bloc/otp_verification_state.dart';
import 'package:mpac_app/features/create_profile_feature/presentation/page/create_profile_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class OTPVerificationPage extends StatefulWidget {
  final ViewType viewType;

  const OTPVerificationPage(this.viewType, {Key? key}) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with FlushBarMixin, TickerProviderStateMixin {
  late AppLocalizations localizations;
  final TextEditingController _pinCodeController = TextEditingController();
  final _bloc = getIt<OtpVerificationBloc>();

  int _counter = 0;
  late AnimationController _controller;
  int levelClock = 60;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: levelClock),
    );
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.viewType == ViewType.splash) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppScreens.signInPage,
            (route) => false,
          );
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: BlocListener(
        bloc: _bloc,
        listener: (BuildContext context, OtpVerificationState state) {
          if (state.codeSubmitted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppScreens.createProfilePage,
              (route) => false,
              arguments: {'viewType': ViewType.splash},
            );
          }

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
          if (state.codeSent) {
            setState(() {
              _controller.reset();
              _controller.forward();
            });
            _bloc.onClearFailure();
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, OtpVerificationState state) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.zero,
                child: AppBar(),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: getBodyWidget(state),
                        ),
                        SizedBox(height: context.h * 0.15),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 24.0,
                            right: 24,
                            bottom: 5.h,
                            top: 3.h,
                          ),
                          child: CustomSubmitButton(
                            buttonText:
                                localizations.verify_email.toUpperCase(),
                            backgroundColor: AppColors.primaryColor,
                            onPressed: () {
                              _bloc.add(SubmitCode());
                              // Navigator.pushNamed(context, AppScreens.createProfilePage,
                              //     arguments: {'viewType': ViewType.initial});
                            },
                            hoverColor: Colors.grey.withOpacity(0.5),
                            textColor: Colors.white,
                            isLoading: state.submittingCode,
                            disable: state.submittingCode,
                          ),
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CustomBackButton(
                      localeName: localizations.localeName,
                      onBackClicked: () {
                        if (widget.viewType == ViewType.splash) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppScreens.signInPage,
                            (route) => false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getBodyWidget(OtpVerificationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: context.h * 0.1,
        ),
        Image.asset(
          'assets/images/general/otp-background.png',
          width: context.w * 0.50,
          height: context.h * 0.15,
        ),
        SizedBox(
          height: context.h * 0.03,
        ),
        Text(
          localizations.verify_your_email,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize:
                Dimensions.checkKIsWeb(context) ? context.h * 0.041 : 18.sp,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          localizations.verify_your_email_desc,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:
                Dimensions.checkKIsWeb(context) ? context.h * 0.028 : 12.sp,
            color: AppColors.secondaryFontColor,
          ),
        ),
        SizedBox(
          height: context.h * 0.03,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                Dimensions.checkKIsWeb(context) ? context.w * 0.1 : 10.0,
          ),
          child: PinCodeTextField(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            appContext: context,
            pastedTextStyle: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
            ),
            length: 4,
            blinkWhenObscuring: true,
            animationType: AnimationType.fade,
            validator: (v) {
              if (v!.length < 3) {
                return "Complete the code please.";
              } else {
                return null;
              }
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: Dimensions.checkKIsWeb(context)
                  ? context.w * 0.14
                  : context.w * 0.17,
              fieldWidth: Dimensions.checkKIsWeb(context)
                  ? context.w * 0.14
                  : context.w * 0.17,
              activeFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              selectedColor: Colors.white,
              activeColor: Colors.white,
              selectedFillColor: AppColors.primaryColor,
              borderWidth: 0,
            ),
            cursorColor: Colors.black,
            animationDuration: const Duration(milliseconds: 300),
            enableActiveFill: true,
            controller: _pinCodeController,
            keyboardType: TextInputType.number,
            boxShadows: const [
              BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
            onCompleted: (v) {},
            onChanged: (value) {
              _bloc.add(ChangingCode(value));
            },
            beforeTextPaste: (text) {
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Resend the code?",
              style: TextStyle(
                fontSize:
                    Dimensions.checkKIsWeb(context) ? context.h * 0.028 : 12.sp,
                color: AppColors.secondaryFontColor,
              ),
            ),
            Duration(seconds: _controller.value.toInt()).inSeconds < 1
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Countdown(
                      animation: StepTween(
                        begin: levelClock,
                        end: 0,
                      ).animate(_controller),
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      _bloc.add(ResendVerificationCode());
                    },
                    child: state.resendingCode
                        ? SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                              strokeWidth: 1.5,
                            ),
                          )
                        : Text(
                            "Resend",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: Dimensions.checkKIsWeb(context)
                                  ? context.h * 0.028
                                  : 12.sp,
                            ),
                          ),
                  ),
          ],
        ),
      ],
    );
  }
}

class Countdown extends AnimatedWidget {
  const Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  Text build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);
    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text(
      timerText,
      style: TextStyle(
        fontSize: Dimensions.checkKIsWeb(context) ? context.h * 0.028 : 12.sp,
        color: AppColors.primaryColor,
      ),
    );
  }
}

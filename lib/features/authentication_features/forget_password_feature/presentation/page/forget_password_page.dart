import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mpac_app/core/dependency_injection/injection_container.dart';
import 'package:mpac_app/core/error/failures.dart';
import 'package:mpac_app/core/utils/extensions/extension_on_context.dart';
import 'package:mpac_app/core/utils/mixins/flush_bar_mixin.dart';
import 'package:mpac_app/core/utils/widgets/custom_back_button.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/bloc/forget_password_bloc.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/bloc/forget_password_event.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/bloc/forget_password_state.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/page/sub_pages/fp_step_1.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/page/sub_pages/fp_step_2.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/page/sub_pages/fp_step_3.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/widgets/custom_submit_button.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage>
    with FlushBarMixin {
  late AppLocalizations localizations;
  final TextEditingController _emailController = TextEditingController();
  late PageController _pageController;
  final _bloc = getIt<ForgetPasswordBloc>();

  @override
  void didChangeDependencies() {
    localizations = AppLocalizations.of(context)!;
    _pageController = PageController();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, ForgetPasswordState state) async {
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
              context: context,);
        }

        if (state.requestPasswordReset) {
          _bloc.onClearFailure();

          _bloc.add(ChangePageIndex(1));
          _pageController.animateToPage(
            1,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 500),
          );
        }
        if (state.passwordReset) {
          _bloc.onClearFailure();

          _bloc.add(ChangePageIndex(2));
          _pageController.animateToPage(
            2,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 500),
          );
          await Future.delayed(const Duration(seconds: 7));
          Navigator.pop(context);
          _bloc.onClearFailure();
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ForgetPasswordState state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.zero,
              child: AppBar(),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: localizations.localeName == "ar"
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: CustomBackButton(
                      localeName: localizations.localeName,
                      onBackClicked: () {
                        if (state.currentPageIndex != 2) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                      width: context.w,
                      height: context.h * 0.65,
                      child: getPageViewWidget(state),),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 24.0, right: 24, bottom: 5.h, top: 5.h,),
                    child: CustomSubmitButton(
                      buttonText: state.currentPageIndex == 2
                          ? localizations.done.toUpperCase()
                          : state.currentPageIndex == 1
                              ? "SUBMIT"
                              : localizations.send.toUpperCase(),
                      backgroundColor: AppColors.primaryColor,
                      onPressed: () {
                        if (state.currentPageIndex == 0) {
                          _bloc.add(SubmitRequestResetPassword());
                        } else if(state.currentPageIndex == 1){
                          _bloc.add(SubmitResetPassword());
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      hoverColor: Colors.grey.withOpacity(0.5),
                      textColor: Colors.white,
                      isLoading: state.isResettingPassword,
                      disable: state.isResettingPassword,
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

  Widget getPageViewWidget(ForgetPasswordState state) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        _bloc.add(ChangePageIndex(index));
      },
      children: [
        FpStep1(
          localizations: localizations,
          errorEmailValidation: state.errorEmailValidation,
          onChangingEmail: (val) => _bloc.add(ChangingEmail(val)),
        ),
        FpStep2(
          errorMisMatchingValidation: state.errorMisMatchValidation,
          errorCodeValidation: state.errorCodeValidation,
          errorPasswordValidation: state.errorPasswordValidation,
          errorConfirmPasswordValidation: state.errorConfirmPasswordValidation,
          localizations: localizations,
          isObscureConfirmPassword: state.isConfirmPasswordObscure,
          isObscurePassword: state.isPasswordObscure,
          onChangeObscureConfirmPassword: (val) =>
              _bloc.add(ChangingObscureConfirmPassword(val)),
          onChangeObscurePassword: (val) =>
              _bloc.add(ChangingObscurePassword(val)),
          onChangeCode: (val) => _bloc.add(ChangingCode(val)),
          onChangeConfirmPassword: (val) =>
              _bloc.add(ChangingConfirmPassword(val)),
          onChangePassword: (val) => _bloc.add(ChangingPassword(val)),
        ),
        FpStep3(localizations: localizations),
      ],
    );
  }
}

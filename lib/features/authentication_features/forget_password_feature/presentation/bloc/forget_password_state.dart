import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/error/failures.dart';

part 'forget_password_state.g.dart';

abstract class ForgetPasswordState
    implements Built<ForgetPasswordState, ForgetPasswordStateBuilder> {
  ForgetPasswordState._();

  factory ForgetPasswordState([Function(ForgetPasswordStateBuilder b) updates]) =
  _$ForgetPasswordState;

  String get email;
  String get password;
  String get confirmPassword;
  String get code;

  bool get isResettingPassword;
  bool get errorResettingPassword;
  bool get passwordReset;
  bool get requestPasswordReset;

  bool get errorEmailValidation;
  bool get errorPasswordValidation;
  bool get errorConfirmPasswordValidation;

  bool get errorMisMatchValidation;
  bool get errorCodeValidation;

  bool get isPasswordObscure;
  bool get isConfirmPasswordObscure;

  Failure? get failure;

  int get currentPageIndex;

  factory ForgetPasswordState.initial() {
    return ForgetPasswordState((b) => b
      ..email = ""
      ..password = ""
      ..code = ""
      ..confirmPassword = ""
      ..currentPageIndex = 0
      ..requestPasswordReset = false
      ..isPasswordObscure = true
      ..isConfirmPasswordObscure = true
      ..isResettingPassword = false
      ..errorResettingPassword = false
      ..passwordReset = false
      ..errorEmailValidation = false
      ..errorEmailValidation = false
      ..errorPasswordValidation = false
      ..errorConfirmPasswordValidation = false
      ..errorMisMatchValidation = false
      ..errorCodeValidation = false,
    );
  }
}

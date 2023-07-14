import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/error/failures.dart';

part 'sign_up_state.g.dart';

abstract class SignUpState implements Built<SignUpState, SignUpStateBuilder> {
  SignUpState._();

  factory SignUpState([Function(SignUpStateBuilder b) updates]) = _$SignUpState;

  String get username;
  String get email;
  String get password;

  bool get isSigningUp;
  bool get errorSigningUp;
  bool get signedUp;

  bool get errorValidationUsername;
  bool get errorValidationEmail;
  bool get errorValidationPassword;

  Failure? get failure;

  bool get isObscureText;

  bool get privacyPolicyStatus;

  factory SignUpState.initial() {
    return SignUpState((b) => b
      ..username = ""
      ..email = ""
      ..password = ""
      ..privacyPolicyStatus = false
      ..isSigningUp = false
      ..isObscureText = true
      ..errorSigningUp = false
      ..signedUp = false
      ..errorValidationUsername = false
      ..errorValidationEmail = false
      ..errorValidationPassword = false,
    );
  }
}

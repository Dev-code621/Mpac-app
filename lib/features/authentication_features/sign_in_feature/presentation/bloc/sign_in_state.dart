import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/error/failures.dart';

part 'sign_in_state.g.dart';

abstract class SignInState implements Built<SignInState, SignInStateBuilder> {
  SignInState._();

  factory SignInState([Function(SignInStateBuilder b) updates]) = _$SignInState;

  String get email;
  String get password;

  bool get isLoggingIn;
  bool get errorLoggingIn;
  bool get loggedIn;

  bool get errorValidationEmail;
  bool get errorValidationPassword;

  bool get isObscureText;

  Failure? get failure;

  UserModel? get signedInUser;

  factory SignInState.initial() {
    return SignInState((b) => b
      ..email = ""
      ..password = ""
      ..isLoggingIn = false
      ..isObscureText = true
      ..errorValidationEmail = false
      ..errorValidationPassword = false
      ..errorLoggingIn = false
      ..loggedIn = false,);
  }
}

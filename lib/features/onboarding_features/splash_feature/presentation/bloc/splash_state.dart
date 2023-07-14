import 'package:built_value/built_value.dart';
import 'package:mpac_app/core/data/models/user_model.dart';
import 'package:mpac_app/core/error/failures.dart';

part 'splash_state.g.dart';

abstract class SplashState implements Built<SplashState, SplashStateBuilder> {
  SplashState._();

  factory SplashState([Function(SplashStateBuilder b) updates]) = _$SplashState;

  bool get isCheckingJWT;
  bool get errorCheckingJWT;
  bool get jwtChecked;
  bool get notLoggedIn;

  Failure? get failure;

  UserModel? get currentSignedInUser;

  factory SplashState.initial() {
    return SplashState((b) => b
      ..isCheckingJWT = false
      ..errorCheckingJWT = false
      ..notLoggedIn = false
      ..jwtChecked = false,);
  }
}

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/auth_repository.dart';
import 'package:mpac_app/core/data/repository/repos/profile_repository.dart';
import 'package:mpac_app/core/utils/validator/input_validators.dart';
import 'package:mpac_app/features/authentication_features/sign_in_feature/presentation/bloc/sign_in_event.dart';
import 'package:mpac_app/features/authentication_features/sign_in_feature/presentation/bloc/sign_in_state.dart';

@Injectable()
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final InputValidators inputValidators;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  SignInBloc(this.inputValidators, this.authRepository, this.profileRepository)
      : super(SignInState.initial());

  void onChangingEmail(String val) {
    add(ChangingEmail(val));
  }

  void onContinueWithGoogle(String val) {
    add(ContinueWithGoogle(val));
  }

  void onContinueWithApple() {
    add(ContinueWithApple());
  }

  void onChangingPassword(String val) {
    add(ChangingPassword(val));
  }

  void onHitLoginButton() {
    add(HitLoginButton());
  }

  void onClearFailure() {
    add(ClearFailures());
  }

  void onChangeObscureText(bool obscure) {
    add(ChangeObscureText(obscure));
  }

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is ChangingEmail) {
      yield state.rebuild(
        (p0) => p0
          ..email = event.val
          ..errorValidationEmail = false,
      );
    } else if (event is ChangingPassword) {
      yield state.rebuild(
        (p0) => p0
          ..password = event.val
          ..errorValidationPassword = false,
      );
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0..failure = null);
    } else if (event is HitLoginButton) {
      yield* mapToLoginStates();
    } else if (event is ChangeObscureText) {
      yield state.rebuild((p0) => p0..isObscureText = event.isObscureText);
    } else if (event is ContinueWithGoogle) {
      yield* mapToContinueWithGoogle(event.val);
    } else if (event is ContinueWithApple) {
      yield* mapToContinueWithApple();
    }
  }

  Stream<SignInState> mapToContinueWithApple() async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoggingIn = true
        ..errorLoggingIn = false
        ..loggedIn = false,
    );

    final result = await authRepository.continueWithAppleAccount();

    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isLoggingIn = false
          ..errorLoggingIn = true
          ..loggedIn = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..signedInUser = r
          ..isLoggingIn = false
          ..errorLoggingIn = false
          ..loggedIn = true,
      );
    });
  }

  Stream<SignInState> mapToContinueWithGoogle(String token) async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoggingIn = true
        ..errorLoggingIn = false
        ..loggedIn = false,
    );
    final result = await authRepository.continueWithGoogleAccount(
      googleToken: token,
    );
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isLoggingIn = false
          ..errorLoggingIn = true
          ..loggedIn = false,
      );
    }, (r) async* {
      yield state.rebuild(
        (p0) => p0
          ..signedInUser = r
          ..isLoggingIn = false
          ..errorLoggingIn = false
          ..loggedIn = true,
      );
    });
  }

  Stream<SignInState> mapToLoginStates() async* {
    if (state.email.trim().isEmpty ||
        !inputValidators.validateEmailInput(state.email)) {
      yield state.rebuild((p0) => p0..errorValidationEmail = true);
    } else if (state.password.trim().isEmpty ||
        !inputValidators.validatePasswordInput(state.password)) {
      yield state.rebuild((p0) => p0..errorValidationPassword = true);
    } else {
      yield* login();
    }
  }

  Stream<SignInState> login() async* {
    yield state.rebuild(
      (p0) => p0
        ..isLoggingIn = true
        ..errorLoggingIn = false
        ..loggedIn = false,
    );
    final result = await authRepository.login(
      email: state.email,
      password: state.password,
    );
    yield* result.fold((l) async* {
      yield state.rebuild(
        (p0) => p0
          ..failure = l
          ..isLoggingIn = false
          ..errorLoggingIn = true
          ..loggedIn = false,
      );
    }, (r) async* {
      if (kIsWeb) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

        if (!webBrowserInfo.browserName
            .toString()
            .toLowerCase()
            .contains("safari")) {
          try{
            await FirebaseMessaging.instance.getToken().then((value) async {
              await profileRepository.updateUserInformation(
                firebaseToken: value!,
              );
            });
          }catch(e){
            print("error in firebase token $e");
          }

          await authRepository.getSendBirdAppId();
          await authRepository.getSendbirdToken(token: r.token!);
        }
      } else {
        await FirebaseMessaging.instance.getToken().then((value) async {
          await profileRepository.updateUserInformation(firebaseToken: value!);
        });
        await authRepository.getSendBirdAppId();
        await authRepository.getSendbirdToken(token: r.token!);
      }
      yield state.rebuild(
        (p0) => p0
          ..signedInUser = r
          ..isLoggingIn = false
          ..errorLoggingIn = false
          ..loggedIn = true,
      );
    });
  }
}

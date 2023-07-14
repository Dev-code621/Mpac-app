import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/auth_repository.dart';
import 'package:mpac_app/core/utils/validator/input_validators.dart';

import 'package:mpac_app/features/authentication_features/sign_up_feature/presentation/bloc/sign_up_event.dart';
import 'package:mpac_app/features/authentication_features/sign_up_feature/presentation/bloc/sign_up_state.dart';

@Injectable()
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepository;
  final InputValidators inputValidators;

  SignUpBloc(this.authRepository, this.inputValidators)
      : super(SignUpState.initial());

  void onChangingUsername(String val) {
    add(ChangingUsername(val));
  }

  void onChangingEmail(String val) {
    add(ChangingEmail(val));
  }

  void onChangingPassword(String val) {
    add(ChangingPassword(val));
  }

  void onClearFailures() {
    add(ClearFailures());
  }

  void onHitSignUpButton() {
    add(HitSignUpButton());
  }


  void onChangeObscureText(bool obscure){
    add(ChangingObscurePassword(obscure));
  }

  void onChangingPrivacyPolicyStatus(bool obscure){
    add(ChangingPrivacyPolicyStatus(obscure));
  }

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is ChangingUsername) {
      yield state.rebuild((p0) => p0
        ..username = event.val
        ..errorValidationUsername = false,);
    } else if (event is ChangingEmail) {
      yield state.rebuild((p0) => p0
        ..email = event.val
        ..errorValidationEmail = false,);
    } else if (event is ChangingPassword) {
      yield state.rebuild((p0) => p0
        ..password = event.val
        ..errorValidationPassword = false,);
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0
        ..failure = null
        ..errorSigningUp = false
        ..signedUp = false,);
    } else if(event is HitSignUpButton) {
      yield* mapToSignUpStates();
    } else if(event is ChangingObscurePassword){
      yield state.rebuild((p0) => p0..isObscureText = event.isObscureText);
    } else if(event is ChangingPrivacyPolicyStatus){
      yield state.rebuild((p0) => p0..privacyPolicyStatus = event.privacyPolicyStatus);
    }
  }

  Stream<SignUpState> mapToSignUpStates() async* {
   /* if(state.username.trim().isEmpty || state.username.length < 5){
      yield state.rebuild((p0) => p0..errorValidationUsername = true);
    } else*/ if(state.email.trim().isEmpty || !inputValidators.validateEmailInput(state.email)){
      yield state.rebuild((p0) => p0..errorValidationEmail = true);
    } else if(state.password.trim().isEmpty || !inputValidators.validatePasswordInput(state.password)){
      yield state.rebuild((p0) => p0..errorValidationPassword = true);
    } else {
      yield* signUp();
    }
  }

  Stream<SignUpState> signUp () async* {
    yield state.rebuild((p0) => p0
      ..isSigningUp = true
      ..errorSigningUp = false
      ..signedUp = false,);
    final result = await authRepository.signUp(
        username: state.username, email: state.email, password: state.password,);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..isSigningUp = false
        ..errorSigningUp = true
        ..signedUp = false,);
    }, (r) async* {
      await authRepository.getSendBirdAppId();
      await authRepository.getSendbirdToken(token: r.token!);

      yield state.rebuild((p0) => p0
        ..isSigningUp = false
        ..errorSigningUp = false
        ..signedUp = true,);
    });

  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/forget_password_repository.dart';
import 'package:mpac_app/core/utils/validator/input_validators.dart';
import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/bloc/forget_password_state.dart';

import 'package:mpac_app/features/authentication_features/forget_password_feature/presentation/bloc/forget_password_event.dart';

@Injectable()
class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepository forgetPasswordRepository;
  final InputValidators inputValidators;

  ForgetPasswordBloc(this.forgetPasswordRepository, this.inputValidators)
      : super(ForgetPasswordState.initial());

  void onClearFailure() {
    add(ClearFailures());
  }

  @override
  Stream<ForgetPasswordState> mapEventToState(
      ForgetPasswordEvent event,) async* {
    if (event is ChangingEmail) {
      yield state.rebuild((p0) => p0
        ..email = event.val
        ..errorEmailValidation = false,);
    } else if (event is ChangingPassword) {
      yield state.rebuild((p0) => p0
        ..errorMisMatchValidation = false
        ..password = event.val
        ..errorPasswordValidation = false,);
    } else if (event is ChangingConfirmPassword) {
      yield state.rebuild((p0) => p0
        ..confirmPassword = event.val
        ..errorConfirmPasswordValidation = false
        ..errorMisMatchValidation = false,);
    } else if (event is SubmitResetPassword) {
      yield* mapToSubmitResetPassword();
    } else if (event is SubmitRequestResetPassword) {
      yield* mapToSubmitRequestResetPassword();
    } else if (event is ChangePageIndex) {
      yield state.rebuild((p0) => p0..currentPageIndex = event.index);
    } else if (event is ClearFailures) {
      yield state.rebuild((p0) => p0
        ..passwordReset = false
        ..errorResettingPassword = false
        ..requestPasswordReset = false
        ..failure = null,);
    } else if (event is ChangingObscurePassword) {
      yield state.rebuild((p0) => p0..isPasswordObscure = event.isObscureText);
    } else if (event is ChangingObscureConfirmPassword) {
      yield state
          .rebuild((p0) => p0..isConfirmPasswordObscure = event.isObscureText);
    } else if (event is ChangingCode) {
      yield state.rebuild((p0) => p0..code = event.val..errorCodeValidation = false);
    }
  }

  Stream<ForgetPasswordState> mapToSubmitRequestResetPassword() async* {
    if (!inputValidators.validateEmailInput(state.email)) {
      yield state.rebuild((p0) => p0..errorEmailValidation = true);
    } else {
      yield state.rebuild((p0) => p0
        ..isResettingPassword = true
        ..errorResettingPassword = false
        ..requestPasswordReset = false,);
      final result = await forgetPasswordRepository.requestResetPassword(email: state.email);
      yield* result.fold((l) async* {
        yield state.rebuild((p0) => p0
          ..failure = l
          ..isResettingPassword = false
          ..errorResettingPassword = true
          ..requestPasswordReset = false,);
      }, (r) async* {
        yield state.rebuild((p0) => p0
          ..isResettingPassword = false
          ..errorResettingPassword = false
          ..requestPasswordReset = true,);
      });
    }
  }

  Stream<ForgetPasswordState> mapToSubmitResetPassword() async* {
    if (!inputValidators.validateEmailInput(state.email)) {
      yield state.rebuild((p0) => p0..errorEmailValidation = true);
    } else if(state.code.length < 3){
      yield state.rebuild((p0) => p0..errorCodeValidation = true);
    } else if(state.password.length < 5){
      yield state.rebuild((p0) => p0..errorPasswordValidation = true);
    } else if(state.confirmPassword.length < 5){
      yield state.rebuild((p0) => p0..errorConfirmPasswordValidation = true);
    } else if(state.password != state.confirmPassword){
      yield state.rebuild((p0) => p0..errorMisMatchValidation = true);
    }else {
      yield state.rebuild((p0) => p0
        ..isResettingPassword = true
        ..errorResettingPassword = false
        ..passwordReset = false,);
      final result = await forgetPasswordRepository.resetPassword(
          state.code, state.password, state.email,);
      yield* result.fold((l) async* {
        yield state.rebuild((p0) => p0
          ..failure = l
          ..isResettingPassword = false
          ..errorResettingPassword = true
          ..passwordReset = false,);
      }, (r) async* {
        yield state.rebuild((p0) => p0
          ..isResettingPassword = false
          ..errorResettingPassword = false
          ..passwordReset = true,);
      });
    }
  }
}

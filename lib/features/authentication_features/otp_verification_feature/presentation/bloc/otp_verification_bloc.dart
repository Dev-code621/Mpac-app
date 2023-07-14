import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mpac_app/core/data/repository/repos/auth_repository.dart';
import 'package:mpac_app/features/authentication_features/otp_verification_feature/presentation/bloc/otp_verification_event.dart';
import 'package:mpac_app/features/authentication_features/otp_verification_feature/presentation/bloc/otp_verification_state.dart';

@Injectable()
class OtpVerificationBloc
    extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  final AuthRepository authRepository;

  OtpVerificationBloc(this.authRepository)
      : super(OtpVerificationState.initial());

  void onClearFailure() {
    add(ClearFailure());
  }

  @override
  Stream<OtpVerificationState> mapEventToState(
      OtpVerificationEvent event,) async* {
    if (event is ChangingCode) {
      yield state.rebuild((p0) => p0
        ..code = event.val
        ..errorValidationCode = false,);
    } else if (event is SubmitCode) {
      if (state.code.isEmpty || state.code.length < 4) {
        yield state.rebuild((p0) => p0..errorValidationCode = true);
      }
      yield* mapToSubmitCode();
    } else if (event is ClearFailure) {
      yield state.rebuild((p0) => p0..failure = null..codeSent = false);
    } else if (event is ResendVerificationCode) {
      yield* mapToSendVerificationCode();
    }
  }

  Stream<OtpVerificationState> mapToSendVerificationCode() async* {
    yield state.rebuild((p0) => p0
      ..resendingCode = true
      ..errorSendingCode = false
      ..codeSent = false,);
    final result = await authRepository.resendOTPCode();
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..resendingCode = false
        ..errorSendingCode = true
        ..codeSent = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..resendingCode = false
        ..errorSendingCode = false
        ..codeSent = true,);
    });
  }

  Stream<OtpVerificationState> mapToSubmitCode() async* {
    yield state.rebuild((p0) => p0
      ..submittingCode = true
      ..errorSubmittingCode = false
      ..codeSubmitted = false,);
    final result = await authRepository.checkCode(code: state.code);
    yield* result.fold((l) async* {
      yield state.rebuild((p0) => p0
        ..failure = l
        ..submittingCode = false
        ..errorSubmittingCode = true
        ..codeSubmitted = false,);
    }, (r) async* {
      yield state.rebuild((p0) => p0
        ..submittingCode = false
        ..errorSubmittingCode = false
        ..codeSubmitted = true,);
    });
  }
}

import 'package:built_value/built_value.dart';

import 'package:mpac_app/core/error/failures.dart';

part 'otp_verification_state.g.dart';

abstract class OtpVerificationState
    implements Built<OtpVerificationState, OtpVerificationStateBuilder> {
  OtpVerificationState._();

  factory OtpVerificationState(
          [Function(OtpVerificationStateBuilder b) updates,]) =
      _$OtpVerificationState;

  bool get submittingCode;
  bool get errorSubmittingCode;
  bool get codeSubmitted;

  bool get errorValidationCode;

  Failure? get failure;

  String get code;

  bool get resendingCode;
  bool get errorSendingCode;
  bool get codeSent;

  factory OtpVerificationState.initial() {
    return OtpVerificationState((b) => b
      ..resendingCode = false
      ..errorSendingCode = false
      ..codeSent = false
      ..submittingCode = false
      ..errorSubmittingCode = false
      ..codeSubmitted = false
      ..errorValidationCode = false
      ..code = "",);
  }
}

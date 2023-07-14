abstract class OtpVerificationEvent {}

class ChangingCode extends OtpVerificationEvent {
  final String val;

  ChangingCode(this.val);
}

class SubmitCode extends OtpVerificationEvent {}
class ClearFailure extends OtpVerificationEvent {}

class ResendVerificationCode extends OtpVerificationEvent {}
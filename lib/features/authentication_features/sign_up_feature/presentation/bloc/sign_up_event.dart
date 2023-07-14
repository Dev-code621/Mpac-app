abstract class SignUpEvent {}

class ChangingUsername extends SignUpEvent {
  final String val;

  ChangingUsername(this.val);
}

class ChangingEmail extends SignUpEvent {
  final String val;

  ChangingEmail(this.val);
}

class ChangingPassword extends SignUpEvent {
  final String val;

  ChangingPassword(this.val);
}

class ClearFailures extends SignUpEvent {}

class HitSignUpButton extends SignUpEvent {}

class ChangingObscurePassword extends SignUpEvent {
  final bool isObscureText;

  ChangingObscurePassword(this.isObscureText);
}

class ChangingPrivacyPolicyStatus extends SignUpEvent {
  final bool privacyPolicyStatus;

  ChangingPrivacyPolicyStatus(this.privacyPolicyStatus);
}

abstract class SignInEvent {}

class ChangingEmail extends SignInEvent {
  final String val;

  ChangingEmail(this.val);
}

class ChangingPassword extends SignInEvent {
  final String val;

  ChangingPassword(this.val);
}

class ContinueWithGoogle extends SignInEvent {
  final String val;

  ContinueWithGoogle(this.val);
}

class ClearFailures extends SignInEvent {}

class ContinueWithApple extends SignInEvent {}

class HitLoginButton extends SignInEvent {}

class ChangeObscureText extends SignInEvent {
  final bool isObscureText;

  ChangeObscureText(this.isObscureText);
}

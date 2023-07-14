abstract class ForgetPasswordEvent {}

class ChangingPassword extends ForgetPasswordEvent {
  final String val;

  ChangingPassword(this.val);
}

class ChangingConfirmPassword extends ForgetPasswordEvent {
  final String val;

  ChangingConfirmPassword(this.val);
}

class ChangingEmail extends ForgetPasswordEvent {
  final String val;

  ChangingEmail(this.val);
}

class SubmitResetPassword extends ForgetPasswordEvent {}

class SubmitRequestResetPassword extends ForgetPasswordEvent {}

class ClearFailures extends ForgetPasswordEvent {}

class ChangePageIndex extends ForgetPasswordEvent {
  final int index;

  ChangePageIndex(this.index);
}

class ChangingObscurePassword extends ForgetPasswordEvent {
  final bool isObscureText;

  ChangingObscurePassword(this.isObscureText);
}

class ChangingObscureConfirmPassword extends ForgetPasswordEvent {
  final bool isObscureText;

  ChangingObscureConfirmPassword(this.isObscureText);
}

class ChangingCode extends ForgetPasswordEvent {
  final String val;

  ChangingCode(this.val);
}
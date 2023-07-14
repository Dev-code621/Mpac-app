
class InputValidators {
  RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",);

  RegExp phoneRegExp = RegExp(r'^\+?\d{6,16}');

  bool validateEmailInput(String email) {
    if (email.contains('.') && email.contains('@')) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePasswordInput(String? password) {
    if (password != null && password.length >= 5) {
      return true;
    } else {
      return false;
    }
  }

  bool validateFirstNameInput(String username) {
    if (username.length > 5) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePhoneNumberInput(String phoneNumber) =>
      phoneNumber.isNotEmpty && phoneRegExp.hasMatch(phoneNumber);

  bool validateStringIsNumber(String? s) =>
      s != null && double.tryParse(s) != null;
}

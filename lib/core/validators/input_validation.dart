class InputValidation {
  static String email(String _input) {
    if (_input.isEmpty || _input.trim().isEmpty) return 'cannot be empty';
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_input)) return 'wrong email format';

    return null;
  }

  static String password(String _input) {
    if (_input.isEmpty || _input.trim().isEmpty) return 'cannot be empty';
    if (_input.length < 8) return 'password must be at least 8 characters';

    return null;
  }

  static String passwordConfirmation(String _input, String _originPassword) {
    if (_input.isEmpty || _input.trim().isEmpty) return 'cannot be empty';
    if (_originPassword != _input) return 'passwords are not the same';

    return null;
  }

  static String allowOnlyLettersAndSpaces(String _input) {
    if (_input.isEmpty || _input.trim().isEmpty) return 'cannot be empty';
    if (!RegExp(r'[a-zA-Z ]+$').hasMatch(_input))
      return 'should contain only letters and spaces';

    return null;
  }

  static String allowNumbersOnly(String _input) {
    if (_input.isEmpty || _input.trim().isEmpty) return 'cannot be empty';
    if (!RegExp(r'^[0-9]+$').hasMatch(_input))
      return 'should contain only numbers';

    return null;
  }
}

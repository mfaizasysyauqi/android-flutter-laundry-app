class Validators {
  static String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Role cannot be empty';
    }

    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name cannot be empty';
    }

    return null;
  }

  static String? validateUniqueName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unique name cannot be empty';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email is not valid';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }

    final phoneRegExp = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number is not valid';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address cannot be empty';
    }

    return null;
  }

  static String? validateNumeric(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  static void handleLoginErrors(
    String errorMessage,
    Function(String?) setEmailError,
    Function(String?) setPasswordError,
  ) {
    if (errorMessage.contains("User not found") ||
        errorMessage.contains("Email not found") ||
        errorMessage.contains("user-not-found") ||
        errorMessage.contains("EmailNotFoundException")) {
      setEmailError('User not found. Please check your email.');
      setPasswordError(null);
    } else if (errorMessage.contains("incorrect") ||
        errorMessage.contains("wrong") ||
        errorMessage.contains("wrong-password") ||
        errorMessage.contains("WrongPasswordException")) {
      setEmailError(null);
      setPasswordError('Password is incorrect. Please try again.');
    } else {
      setEmailError(null);
      setPasswordError(null);
    }
  }
}

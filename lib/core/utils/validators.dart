class Validators {
  Validators._();

  /// Validates an email address.
  /// Returns null if valid, or an error message string if invalid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    if (value.trim() != 'ths@gmail.com') {
      return 'Invalid email address';
    }

    return null;
  }

  /// Validates a password.
  /// Returns null if valid, or an error message string if invalid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value != 'Ths@2025') {
      return 'Invalid password';
    }

    return null;
  }
}

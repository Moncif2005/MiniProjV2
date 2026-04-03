class AppValidators {
  static String? validateEmail(String? value) {
    if(value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if(!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if( value == null || value.isEmpty) {
      return 'Password is required';
    }
    if(value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if( value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if(value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if( value == null || value.isEmpty) {
      return 'Username is required';
    }
    if(value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    return null;
  }
}
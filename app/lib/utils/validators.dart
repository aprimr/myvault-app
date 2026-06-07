class FieldValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (value.trim().length < 5) return "Name must be at least 5 characters";
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";

    final email = value.trim();
    final atIndex = email.indexOf('@');

    if (atIndex < 3) return "At least 3 characters required before @";

    final domainPart = email.substring(atIndex + 1);
    final dotIndex = domainPart.lastIndexOf('.');

    if (dotIndex < 2) {
      return "At least 2 characters required in domain name before .";
    }
    if (domainPart.substring(dotIndex + 1).length < 2) {
      return "At least 2 characters required after .";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) return "Password must be at least 8 characters";
    if (!value.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least 1 digit";
    }
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return "Password must contain at least 1 letter";
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return "Password must contain at least 1 special character";
    }
    return null;
  }
}

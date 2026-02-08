class Validators {
  static String? requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? numberField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  static String? emailField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phoneField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? priceField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid price';
    }
    if (parsed <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }
}


import 'package:dynamic_flutter_forms/dynamic_forms.dart';

/// A utility class for validating form fields.
class FormValidator {
  static String? validateField(CustomFormField field, String? value) {
    if (field.required && (value == null || value.isEmpty)) {
      return 'The ${field.label} field is required';
    }

    // Default validators
    for (var validator in field.validators) {
      switch (validator.type) {
        case 'required':
          return _requiredValidator(value, field);
        case 'email':
          return _emailValidator(value, field);
        case 'phone':
          return _phoneValidator(value, field);
        case 'pattern':
          return _patternValidator(value, field);
        case 'future_date':
          return _futureDateValidator(value, field);
        case 'past_date':
          return _pastDateValidator(value, field);
        case 'min_length':
          return _minLengthValidator(value, field);
        case 'max_length':
          return _maxLengthValidator(value, field);
        default:
          return "";
      }
    }

    return null;
  }

  /// Validates that a value is not empty.
  static String? _requiredValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates that a value is a valid email address.
  static String? _emailValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? _phoneValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  /// Validates that a value matches a regular expression pattern.
  static String? _patternValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    // Find the pattern validator
    final patternValidator = field.validators.firstWhere(
      (v) => v.type == 'pattern',
      orElse: () => Validator(name: 'pattern', type: 'pattern'),
    );

    if (patternValidator.value != null) {
      final pattern = RegExp(patternValidator.value!);
      if (!pattern.hasMatch(value)) {
        return 'Invalid format';
      }
    }
    return null;
  }

  /// Validates that a date is in the future.
  static String? _futureDateValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      if (date.isBefore(now)) {
        return 'Date must be in the future';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }

  /// Validates that a date is in the past.
  static String? _pastDateValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      if (date.isAfter(now)) {
        return 'Date must be in the past';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }

  /// Validates that a string has a minimum length.
  static String? _minLengthValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    // Find the min length validator
    final minLengthValidator = field.validators.firstWhere(
      (v) => v.type == 'min_length',
      orElse: () => Validator(name: 'min_length', type: 'min_length'),
    );

    if (minLengthValidator.value != null) {
      final minLength = int.tryParse(minLengthValidator.value!) ?? 0;
      if (value.length < minLength) {
        return 'Must be at least $minLength characters';
      }
    }
    return null;
  }

  /// Validates that a string does not exceed a maximum length.
  static String? _maxLengthValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    // Find the max length validator
    final maxLengthValidator = field.validators.firstWhere(
      (v) => v.type == 'max_length',
      orElse: () => Validator(name: 'max_length', type: 'max_length'),
    );

    if (maxLengthValidator.value != null) {
      final maxLength = int.tryParse(maxLengthValidator.value!) ?? 0;
      if (value.length > maxLength) {
        return 'Must not exceed $maxLength characters';
      }
    }
    return null;
  }
}

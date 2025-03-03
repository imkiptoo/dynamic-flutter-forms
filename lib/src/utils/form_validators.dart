import 'package:dynamic_flutter_forms/dynamic_forms.dart';

/// A utility class for validating form fields.
class FormValidator {
  // Cache for validators to avoid repeated lookups
  static final Map<String, Map<String, Validator>> _validatorCache = {};

  static String? validateField(CustomFormField field, String? value) {
    if (field.required && (value == null || value.isEmpty)) {
      return 'The ${field.label} field is required';
    }

    // Skip validation if empty and not required
    if (value == null || value.isEmpty) return null;

    // Use cached validators if available, or build the cache
    if (!_validatorCache.containsKey(field.id)) {
      _validatorCache[field.id] = {};
      for (var validator in field.validators) {
        _validatorCache[field.id]![validator.type] = validator;
      }
    }

    // Check each validator type
    final validators = _validatorCache[field.id]!;

    // Required validation (already handled above)
    if (validators.containsKey('required')) {
      final error = _requiredValidator(value, field);
      if (error != null) return error;
    }

    // Email validation
    if (validators.containsKey('email')) {
      final error = _emailValidator(value, field);
      if (error != null) return error;
    }

    // Phone validation
    if (validators.containsKey('phone')) {
      final error = _phoneValidator(value, field);
      if (error != null) return error;
    }

    // Pattern validation
    if (validators.containsKey('pattern')) {
      final error = _patternValidator(value, field, validators['pattern']);
      if (error != null) return error;
    }

    // Future date validation
    if (validators.containsKey('future_date')) {
      final error = _futureDateValidator(value, field);
      if (error != null) return error;
    }

    // Past date validation
    if (validators.containsKey('past_date')) {
      final error = _pastDateValidator(value, field);
      if (error != null) return error;
    }

    // Min length validation
    if (validators.containsKey('min_length')) {
      final error = _minLengthValidator(value, field, validators['min_length']);
      if (error != null) return error;
    }

    // Max length validation
    if (validators.containsKey('max_length')) {
      final error = _maxLengthValidator(value, field, validators['max_length']);
      if (error != null) return error;
    }

    return null;
  }

  // Clear validator cache for a field or all fields
  static void clearValidatorCache([String? fieldId]) {
    if (fieldId != null) {
      _validatorCache.remove(fieldId);
    } else {
      _validatorCache.clear();
    }
  }

  /// Validates that a value is not empty.
  static String? _requiredValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Cached regex patterns to avoid recreating them
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _phoneRegex = RegExp(r'^\d{10}$');

  /// Validates that a value is a valid email address.
  static String? _emailValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? _phoneValidator(String? value, CustomFormField field) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    if (!_phoneRegex.hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  // Cache for compiled regex patterns
  static final Map<String, RegExp> _patternCache = {};

  /// Validates that a value matches a regular expression pattern.
  static String? _patternValidator(String? value, CustomFormField field, Validator? patternValidator) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    if (patternValidator?.value != null) {
      final patternValue = patternValidator!.value!;

      // Use cached RegExp if available
      if (!_patternCache.containsKey(patternValue)) {
        _patternCache[patternValue] = RegExp(patternValue);
      }

      final pattern = _patternCache[patternValue]!;
      if (!pattern.hasMatch(value)) {
        return patternValidator.message ?? 'Invalid format';
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
  static String? _minLengthValidator(String? value, CustomFormField field, Validator? minLengthValidator) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    if (minLengthValidator?.value != null) {
      final minLength = int.tryParse(minLengthValidator!.value!) ?? 0;
      if (value.length < minLength) {
        return minLengthValidator.message ?? 'Must be at least $minLength characters';
      }
    }
    return null;
  }

  /// Validates that a string does not exceed a maximum length.
  static String? _maxLengthValidator(String? value, CustomFormField field, Validator? maxLengthValidator) {
    if (value == null || value.isEmpty) {
      return null; // Not required, handled by required validator
    }

    if (maxLengthValidator?.value != null) {
      final maxLength = int.tryParse(maxLengthValidator!.value!) ?? 0;
      if (value.length > maxLength) {
        return maxLengthValidator.message ?? 'Must not exceed $maxLength characters';
      }
    }
    return null;
  }
}
import 'package:flutter/material.dart';
import '../theme/form_theme.dart';
import '../models/form_state.dart';

/// Provides styling utilities for dynamic forms.
class FormStyles {
  // Cache for frequently used styles to avoid unnecessary recreations
  static final Map<String, TextStyle> _textStyleCache = {};
  static final Map<int, InputDecoration> _decorationCache = {};
  static final Map<int, ButtonStyle> _buttonStyleCache = {};
  static final Map<String, Color> _colorCache = {};

  /// Creates input decoration for form fields.
  ///
  /// [context] is the build context.
  /// [labelText] is the label to display.
  /// [hintText] is the hint to display when the field is empty.
  /// [fieldId] is the ID of the field (used for state-based styling).
  /// [formState] is the current state of the form.
  /// [suffixIcon] is an optional icon to display at the end of the field.
  /// [multiLine] indicates whether the field supports multiple lines.
  static InputDecoration inputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    String? fieldId,
    CustomFormState? formState,
    Widget? suffixIcon,
    bool multiLine = false,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto,
  }) {
    final theme = DynamicFormTheme.of(context);

    // Use decoration cache only when there's no form state to consider
    // (since state changes would require recreation anyway)
    if (formState == null || fieldId == null) {
      final cacheKey = Object.hash(
          labelText,
          hintText,
          suffixIcon?.hashCode,
          multiLine,
          floatingLabelBehavior.index,
          theme.hashCode
      );

      if (_decorationCache.containsKey(cacheKey)) {
        return _decorationCache[cacheKey]!;
      }

      final decoration = InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.borderRadius),
          borderSide: BorderSide(
            color: theme.disabledColor,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: multiLine ? 12 : 8,
        ),
        floatingLabelBehavior: floatingLabelBehavior,
        suffixIcon: suffixIcon,
        filled: false,
      );

      _decorationCache[cacheKey] = decoration;
      return decoration;
    }

    // Continue with state-dependent styling
    Color? fillColor;
    Color borderColor = theme.disabledColor;
    String? errorText;

    if (fieldId != null && formState != null && formState.fields.containsKey(fieldId)) {
      final field = formState.fields[fieldId]!;

      if (!field.valid) {
        errorText = field.error;
        fillColor = theme.errorColor.withOpacity(0.1);
        borderColor = theme.errorColor;
      } else if (field.submitted) {
        fillColor = theme.validColor.withOpacity(0.1);
        borderColor = theme.validColor;
      } else if (field.isModified) {
        fillColor = theme.modifiedColor.withOpacity(0.1);
        borderColor = theme.modifiedColor;
      }
    }

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: multiLine ? 12 : 8,
      ),
      floatingLabelBehavior: floatingLabelBehavior,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: errorText != null ? theme.errorColor.withOpacity(0.1) : fillColor,
      errorText: errorText,
    );
  }

  /// Gets the text style for required field indicators.
  ///
  /// [context] is the build context.
  static TextStyle requiredFieldStyle(BuildContext context) {
    final theme = DynamicFormTheme.of(context);
    final cacheKey = 'required_${theme.requiredColor.value}';

    if (!_textStyleCache.containsKey(cacheKey)) {
      _textStyleCache[cacheKey] = TextStyle(
        color: theme.requiredColor,
        fontWeight: FontWeight.bold,
      );
    }

    return _textStyleCache[cacheKey]!;
  }

  /// Gets the button style for form buttons.
  ///
  /// [context] is the build context.
  static ButtonStyle buttonStyle(BuildContext context) {
    final theme = DynamicFormTheme.of(context);
    final themeOfContext = Theme.of(context);

    final cacheKey = Object.hash(
        theme.hashCode,
        themeOfContext.primaryColor.value,
        themeOfContext.colorScheme.onPrimary.value
    );

    if (!_buttonStyleCache.containsKey(cacheKey)) {
      _buttonStyleCache[cacheKey] = theme.buttonStyle ?? ElevatedButton.styleFrom(
        padding: theme.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        backgroundColor: themeOfContext.primaryColor,
        foregroundColor: themeOfContext.colorScheme.onPrimary,
      );
    }

    return _buttonStyleCache[cacheKey]!;
  }

  /// Gets the text style for field labels.
  ///
  /// [context] is the build context.
  static TextStyle labelStyle(BuildContext context) {
    final theme = DynamicFormTheme.of(context);
    final cacheKey = 'label_${theme.hashCode}';

    if (!_textStyleCache.containsKey(cacheKey)) {
      _textStyleCache[cacheKey] = theme.labelStyle ?? const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
    }

    return _textStyleCache[cacheKey]!;
  }

  /// Gets the background color for a field based on its state.
  static Color getFieldColor(BuildContext context, String fieldId, CustomFormState formState) {
    final theme = DynamicFormTheme.of(context);
    final field = formState.fields[fieldId];

    if (field == null) {
      return Colors.transparent;
    }

    // Generate cache key based on field state
    final cacheKey = '${fieldId}_bg_${field.valid}_${field.isModified}_${formState.isSubmitted}';

    if (!_colorCache.containsKey(cacheKey)) {
      Color color = Colors.transparent;

      // Show error color if invalid
      if (!field.valid) {
        color = theme.errorColor.withOpacity(0.1);
      }
      // Show modified color if changed from initial and not yet successfully submitted
      else if (field.isModified && !formState.isSubmitted) {
        color = theme.modifiedColor.withOpacity(0.1);
      }
      // Only show success color after the entire form has been successfully submitted
      else if (field.valid && formState.isSubmitted) {
        color = theme.validColor.withOpacity(0.1);
      }

      _colorCache[cacheKey] = color;
    }

    return _colorCache[cacheKey]!;
  }

  /// Gets the border color for a field based on its state.
  static Color getBorderColor(BuildContext context, String fieldId, CustomFormState formState) {
    final theme = DynamicFormTheme.of(context);
    final field = formState.fields[fieldId];

    if (field == null) {
      return theme.disabledColor;
    }

    // Generate cache key based on field state
    final cacheKey = '${fieldId}_border_${field.valid}_${field.isModified}_${formState.isSubmitted}';

    if (!_colorCache.containsKey(cacheKey)) {
      Color color = theme.disabledColor;

      // Show error color if invalid
      if (!field.valid) {
        color = theme.errorColor;
      }
      // Show modified color if changed from initial and not yet successfully submitted
      else if (field.isModified && !formState.isSubmitted) {
        color = theme.modifiedColor;
      }
      // Only show success color after the entire form has been successfully submitted
      else if (field.valid && formState.isSubmitted) {
        color = theme.validColor;
      }

      _colorCache[cacheKey] = color;
    }

    return _colorCache[cacheKey]!;
  }

  /// Gets the toggle color for a boolean field based on its state.
  static Color getToggleColor(BuildContext context, String fieldId, CustomFormState formState, bool isOn) {
    final theme = DynamicFormTheme.of(context);
    final field = formState.fields[fieldId];

    if (field == null) {
      return isOn ? theme.modifiedColor : theme.disabledColor;
    }

    // Generate cache key based on field state and toggle position
    final cacheKey = '${fieldId}_toggle_${field.valid}_${field.isModified}_${formState.isSubmitted}_${isOn}';

    if (!_colorCache.containsKey(cacheKey)) {
      Color color = isOn ? theme.modifiedColor : theme.disabledColor;

      // Error state
      if (!field.valid) {
        color = theme.errorColor;
      }
      // Modified state (not yet submitted)
      else if (field.isModified && !formState.isSubmitted) {
        color = theme.modifiedColor;
      }
      // Successfully submitted state
      else if (formState.isSubmitted) {
        color = theme.validColor;
      }

      _colorCache[cacheKey] = color;
    }

    return _colorCache[cacheKey]!;
  }

  /// Clear style caches to free memory
  static void clearCaches() {
    _textStyleCache.clear();
    _decorationCache.clear();
    _buttonStyleCache.clear();
    _colorCache.clear();
  }
}
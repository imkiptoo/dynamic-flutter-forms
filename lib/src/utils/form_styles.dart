import 'package:flutter/material.dart';
import '../theme/form_theme.dart';
import '../models/form_state.dart';

/// Provides styling utilities for dynamic forms.
class FormStyles {
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
    return TextStyle(
      color: theme.requiredColor,
      fontWeight: FontWeight.bold,
    );
  }

  /// Gets the button style for form buttons.
  ///
  /// [context] is the build context.
  static ButtonStyle buttonStyle(BuildContext context) {
    final theme = DynamicFormTheme.of(context);

    return theme.buttonStyle ?? ElevatedButton.styleFrom(
      padding: theme.buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  /// Gets the text style for field labels.
  ///
  /// [context] is the build context.
  static TextStyle labelStyle(BuildContext context) {
    final theme = DynamicFormTheme.of(context);

    return theme.labelStyle ?? TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  /// Gets the background color for a field based on its state.
  static Color getFieldColor(BuildContext context, String fieldId, CustomFormState formState) {
    final theme = DynamicFormTheme.of(context);
    final field = formState.fields[fieldId];

    if (field == null) {
      return Colors.transparent;
    }

    // Show error color if invalid
    if (!field.valid) {
      return theme.errorColor.withOpacity(0.1);
    }

    // Show modified color if changed from initial and not yet successfully submitted
    if (field.isModified && !formState.isSubmitted) {
      return theme.modifiedColor.withOpacity(0.1);
    }

    // Only show success color after the entire form has been successfully submitted
    if (field.valid && formState.isSubmitted) {
      return theme.validColor.withOpacity(0.1);
    }

    // Default background is transparent
    return Colors.transparent;
  }

  /// Gets the border color for a field based on its state.
  static Color getBorderColor(BuildContext context, String fieldId, CustomFormState formState) {
    final theme = DynamicFormTheme.of(context);
    final field = formState.fields[fieldId];

    if (field == null) {
      return theme.disabledColor;
    }

    // Show error color if invalid
    if (!field.valid) {
      return theme.errorColor;
    }

    // Show modified color if changed from initial and not yet successfully submitted
    if (field.isModified && !formState.isSubmitted) {
      return theme.modifiedColor;
    }

    // Only show success color after the entire form has been successfully submitted
    if (field.valid && formState.isSubmitted) {
      return theme.validColor;
    }

    // Default border color is gray
    return theme.disabledColor;
  }

  /// Gets the toggle color for a boolean field based on its state.
  static Color getToggleColor(BuildContext context, String fieldId, CustomFormState formState, bool isOn) {
    final theme = DynamicFormTheme.of(context);
    final field = formState.fields[fieldId];

    if (field == null) {
      return isOn ? theme.modifiedColor : theme.disabledColor;
    }

    // Error state
    if (!field.valid) {
      return theme.errorColor;
    }

    // Modified state (not yet submitted)
    if (field.isModified && !formState.isSubmitted) {
      return theme.modifiedColor;
    }

    // Successfully submitted state
    if (formState.isSubmitted) {
      return theme.validColor;
    }

    // Default state based on toggle position
    return isOn ? theme.modifiedColor : theme.disabledColor;
  }
}
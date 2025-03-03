import 'package:flutter/material.dart';

/// A theme extension for customizing dynamic forms.
class DynamicFormTheme extends ThemeExtension<DynamicFormTheme> {
  /// Border radius for form elements.
  final double borderRadius;

  /// Padding for form fields.
  final EdgeInsets fieldPadding;

  /// Padding for the entire form.
  final EdgeInsets formPadding;

  /// Padding for buttons in the form.
  final EdgeInsets buttonPadding;

  /// Color for required field indicators.
  final Color requiredColor;

  /// Color for fields that have been modified but not submitted.
  final Color modifiedColor;

  /// Color for fields that have been successfully validated.
  final Color validColor;

  /// Color for fields that have failed validation.
  final Color errorColor;

  /// Color for disabled fields.
  final Color disabledColor;

  /// Text style for field labels.
  final TextStyle? labelStyle;

  /// Button style for form buttons.
  final ButtonStyle? buttonStyle;

  /// Creates a new [DynamicFormTheme] instance.
  ///
  /// [borderRadius] is the border radius for form elements.
  /// [fieldPadding] is the padding for form fields.
  /// [formPadding] is the padding for the entire form.
  /// [buttonPadding] is the padding for buttons in the form.
  /// [requiredColor] is the color for required field indicators.
  /// [modifiedColor] is the color for fields that have been modified but not submitted.
  /// [validColor] is the color for fields that have been successfully validated.
  /// [errorColor] is the color for fields that have failed validation.
  /// [disabledColor] is the color for disabled fields.
  /// [labelStyle] is the text style for field labels.
  /// [buttonStyle] is the button style for form buttons.
  const DynamicFormTheme({
    this.borderRadius = 8.0,
    this.fieldPadding = const EdgeInsets.only(bottom: 16.0),
    this.formPadding = const EdgeInsets.all(16.0),
    this.buttonPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.requiredColor = Colors.red,
    this.modifiedColor = Colors.blue,
    this.validColor = Colors.green,
    this.errorColor = Colors.red,
    this.disabledColor = Colors.grey,
    this.labelStyle,
    this.buttonStyle,
  });

  /// Creates a copy of this [DynamicFormTheme] with the given fields replaced.
  @override
  DynamicFormTheme copyWith({
    double? borderRadius,
    EdgeInsets? fieldPadding,
    EdgeInsets? formPadding,
    EdgeInsets? buttonPadding,
    Color? requiredColor,
    Color? modifiedColor,
    Color? validColor,
    Color? errorColor,
    Color? disabledColor,
    TextStyle? labelStyle,
    ButtonStyle? buttonStyle,
  }) {
    return DynamicFormTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      fieldPadding: fieldPadding ?? this.fieldPadding,
      formPadding: formPadding ?? this.formPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      requiredColor: requiredColor ?? this.requiredColor,
      modifiedColor: modifiedColor ?? this.modifiedColor,
      validColor: validColor ?? this.validColor,
      errorColor: errorColor ?? this.errorColor,
      disabledColor: disabledColor ?? this.disabledColor,
      labelStyle: labelStyle ?? this.labelStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  /// Linearly interpolates between two [DynamicFormTheme]s.
  @override
  DynamicFormTheme lerp(DynamicFormTheme? other, double t) {
    if (other is! DynamicFormTheme) {
      return this;
    }

    return DynamicFormTheme(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
      fieldPadding: EdgeInsets.lerp(fieldPadding, other.fieldPadding, t)!,
      formPadding: EdgeInsets.lerp(formPadding, other.formPadding, t)!,
      buttonPadding: EdgeInsets.lerp(buttonPadding, other.buttonPadding, t)!,
      requiredColor: Color.lerp(requiredColor, other.requiredColor, t)!,
      modifiedColor: Color.lerp(modifiedColor, other.modifiedColor, t)!,
      validColor: Color.lerp(validColor, other.validColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      buttonStyle: t < 0.5 ? buttonStyle : other.buttonStyle,
    );
  }

  /// Helper method to interpolate doubles.
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Gets the [DynamicFormTheme] from the given [BuildContext].
  static DynamicFormTheme of(BuildContext context) {
    return Theme.of(context).extension<DynamicFormTheme>() ??
        DynamicFormTheme(
          labelStyle: Theme.of(context).textTheme.titleMedium,
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        );
  }
}
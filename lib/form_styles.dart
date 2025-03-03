import 'package:flutter/material.dart';

class FormStyles {
  static const double borderRadius = 8.0;
  static const EdgeInsets fieldPadding = EdgeInsets.only(bottom: 16.0);
  static const EdgeInsets formPadding = EdgeInsets.only(right: 16, top: 16, bottom: 16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16);

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Color? fillColor,
    Color? borderColor,
    String? errorText,
    Widget? suffixIcon,
    bool? multiLine = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor ?? Colors.grey,
        ),
      ),
      /*constraints: multiLine! ? BoxConstraints(maxHeight: 40) : null,*/
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: errorText != null ? Colors.red.shade50 : fillColor,
      errorText: errorText,
    );
  }

  static TextStyle requiredFieldStyle() {
    return TextStyle(
      color: Colors.red.shade700,
    );
  }

  static ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: Colors.blue,
    );
  }

  static labelStyle(BuildContext context) {
    return TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }
}
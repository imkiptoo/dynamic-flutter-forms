import 'package:flutter/material.dart';

/// Defines a form field validator with a name, type, and optional message.
class Validator {
  /// Unique identifier for the validator.
  final String name;

  /// Type of validation to perform (e.g., 'email', 'pattern').
  final String type;

  /// Optional value for pattern-based validators.
  final String? value;

  /// Custom error message to display when validation fails.
  final String? message;

  /// Creates a new [Validator] instance.
  ///
  /// [name] is a unique identifier for the validator.
  /// [type] specifies the validation type (e.g., 'email', 'pattern').
  /// [value] is used for pattern-based validators.
  /// [message] is a custom error message to display when validation fails.
  const Validator({
    required this.name,
    required this.type,
    this.value,
    this.message,
  });

  /// Creates a JSON representation of this validator.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (value != null) 'value': value,
      if (message != null) 'message': message,
    };
  }

  /// Creates a validator from a JSON map.
  factory Validator.fromJson(Map<String, dynamic> json) {
    return Validator(
      name: json['name'],
      type: json['type'],
      value: json['value'],
      message: json['message'],
    );
  }
}

/// Defines the available field types for dynamic forms.
enum FieldType {
  /// Single-line text input.
  text,

  /// Email input with validation.
  email,

  /// Telephone number input.
  tel,

  /// Numeric input.
  number,

  /// Dropdown select input.
  select,

  /// Date picker input.
  date,

  /// Date and time picker input.
  datetime,

  /// Multi-line text input.
  textarea,

  /// Composite address input.
  address,

  /// Multi-select dropdown or checkboxes.
  multiselect,

  /// Boolean toggle input.
  boolean,

  /// Spacer or section divider.
  spacer,

  /// Button.
  button,
}

/// Defines a custom form field with various properties and configurations.
class CustomFormField {
  /// Unique identifier for the field.
  final String id;

  /// Display label for the field.
  final String label;

  /// Type of field to display.
  final FieldType type;

  /// Placeholder text when the field is empty.
  final String placeholder;

  /// Initial value for the field.
  final dynamic initialValue;

  /// Whether the field is required for form submission.
  final bool required;

  /// Whether the field is disabled (non-interactive).
  final bool disabled;

  /// Whether the field is read-only.
  final bool readonly;

  /// Whether the field should be included in form submissions.
  final bool insert;

  /// Whether to enable input masking.
  final bool enableMask;

  /// Format string for date/time fields.
  final String? format;

  /// Selector string for dynamic options loading.
  final String? selector;

  /// Label for selector fields.
  final String? selectorLabel;

  /// List of validators to apply to the field.
  final List<Validator> validators;

  /// Text input action for keyboard.
  final TextInputAction? textInputAction;

  /// Maximum length for text input.
  final int? maxLength;

  /// Available options for select fields.
  final List<Map<String, dynamic>>? options;

  /// Whether the field supports multiple lines.
  final bool multiline;

  /// Number of rows for multiline text fields.
  final int rows;

  /// Creates a new [CustomFormField] instance.
  ///
  /// [id] is a unique identifier for the field.
  /// [label] is the display label for the field.
  /// [type] specifies the type of field to display.
  /// [placeholder] is the text to show when the field is empty.
  /// [initialValue] is the starting value for the field.
  /// [required] indicates whether the field is mandatory.
  /// [disabled] prevents interaction with the field when true.
  /// [readonly] makes the field non-editable but still selectable.
  /// [insert] determines if the field should be included in form submissions.
  /// [enableMask] enables input masking for formatted fields.
  /// [format] is a format string for date/time fields.
  /// [selector] is a string for dynamic options loading.
  /// [selectorLabel] is a label for selector fields.
  /// [validators] is a list of validation rules to apply.
  /// [textInputAction] controls the keyboard's submit button appearance.
  /// [maxLength] limits the maximum number of characters.
  /// [options] provides available choices for select fields.
  /// [multiline] enables multiple lines for text input.
  /// [rows] sets the number of visible rows for multiline fields.
  const CustomFormField({
    required this.id,
    required this.label,
    this.type = FieldType.text,
    this.placeholder = '',
    this.initialValue = '',
    this.required = false,
    this.disabled = false,
    this.readonly = false,
    this.insert = true,
    this.enableMask = false,
    this.format,
    this.selector,
    this.selectorLabel,
    this.validators = const [],
    this.textInputAction,
    this.maxLength,
    this.options = const[],
    this.multiline = false,
    this.rows = 1,
  });

  /// Creates a JSON representation of this form field.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.toString().split('.').last,
      'placeholder': placeholder,
      'initialValue': initialValue,
      'required': required,
      'disabled': disabled,
      'readonly': readonly,
      'insert': insert,
      'enableMask': enableMask,
      if (format != null) 'format': format,
      if (selector != null) 'selector': selector,
      if (selectorLabel != null) 'selectorLabel': selectorLabel,
      'validators': validators.map((v) => v.toJson()).toList(),
      if (textInputAction != null) 'textInputAction': textInputAction.toString(),
      if (maxLength != null) 'maxLength': maxLength,
      if (options != null) 'options': options,
      'multiline': multiline,
      'rows': rows,
    };
  }

  /// Creates a [CustomFormField] from a JSON map.
  factory CustomFormField.fromJson(Map<String, dynamic> json) {
    return CustomFormField(
      id: json['id'],
      label: json['label'],
      type: _fieldTypeFromString(json['type']),
      placeholder: json['placeholder'] ?? '',
      initialValue: json['initialValue'] ?? '',
      required: json['required'] ?? false,
      disabled: json['disabled'] ?? false,
      readonly: json['readonly'] ?? false,
      insert: json['insert'] ?? true,
      enableMask: json['enableMask'] ?? false,
      format: json['format'],
      selector: json['selector'],
      selectorLabel: json['selectorLabel'],
      validators: (json['validators'] as List?)
          ?.map((v) => Validator.fromJson(v))
          .toList() ??
          [],
      maxLength: json['maxLength'],
      options: (json['options'] as List?)
          ?.map((o) => o as Map<String, dynamic>)
          .toList(),
      multiline: json['multiline'] ?? false,
      rows: json['rows'] ?? 1,
    );
  }

  /// Creates a copy of this [CustomFormField] with the given fields replaced.
  CustomFormField copyWith({
    String? id,
    String? label,
    FieldType? type,
    String? placeholder,
    dynamic initialValue,
    bool? required,
    bool? disabled,
    bool? readonly,
    bool? insert,
    bool? enableMask,
    String? format,
    String? selector,
    String? selectorLabel,
    List<Validator>? validators,
    TextInputAction? textInputAction,
    int? maxLength,
    List<Map<String, dynamic>>? options,
    bool? multiline,
    int? rows,
  }) {
    return CustomFormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      placeholder: placeholder ?? this.placeholder,
      initialValue: initialValue ?? this.initialValue,
      required: required ?? this.required,
      disabled: disabled ?? this.disabled,
      readonly: readonly ?? this.readonly,
      insert: insert ?? this.insert,
      enableMask: enableMask ?? this.enableMask,
      format: format ?? this.format,
      selector: selector ?? this.selector,
      selectorLabel: selectorLabel ?? this.selectorLabel,
      validators: validators ?? this.validators,
      textInputAction: textInputAction ?? this.textInputAction,
      maxLength: maxLength ?? this.maxLength,
      options: options ?? this.options,
      multiline: multiline ?? this.multiline,
      rows: rows ?? this.rows,
    );
  }

  /// Converts a string to a [FieldType] enum value.
  static FieldType _fieldTypeFromString(String type) {
    return FieldType.values.firstWhere(
          (e) => e.toString().split('.').last == type,
      orElse: () => FieldType.text,
    );
  }
}
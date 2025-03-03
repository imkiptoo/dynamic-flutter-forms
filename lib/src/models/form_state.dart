/// Represents the state of an individual form field.
class CustomFormFieldState {
  /// The current value of the field as a string.
  String value;

  /// Whether the field is in its initial state (not modified).
  bool initial;

  /// Whether the field's current value is valid.
  bool valid;

  /// Whether the field has been submitted.
  bool submitted;

  /// Error message if validation failed.
  String? error;

  /// Creates a new [CustomFormFieldState] instance.
  ///
  /// [value] is the current value of the field.
  /// [initial] indicates whether the field is in its initial state.
  /// [valid] indicates whether the field's current value is valid.
  /// [submitted] indicates whether the field has been submitted.
  /// [error] is the error message if validation failed.
  CustomFormFieldState({
    this.value = '',
    this.initial = true,
    this.valid = true,
    this.submitted = false,
    this.error,
  });

  /// Whether the field has been modified from its initial state.
  bool get isModified => !initial;

  /// Creates a copy of this [CustomFormFieldState] with the given fields replaced.
  CustomFormFieldState copyWith({
    String? value,
    bool? initial,
    bool? valid,
    bool? submitted,
    String? error,
  }) {
    return CustomFormFieldState(
      value: value ?? this.value,
      initial: initial ?? this.initial,
      valid: valid ?? this.valid,
      submitted: submitted ?? this.submitted,
      error: error ?? this.error,
    );
  }

  /// Creates a JSON representation of this field state.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'initial': initial,
      'valid': valid,
      'submitted': submitted,
      if (error != null) 'error': error,
    };
  }

  /// Creates a [CustomFormFieldState] from a JSON map.
  factory CustomFormFieldState.fromJson(Map<String, dynamic> json) {
    return CustomFormFieldState(
      value: json['value'] ?? '',
      initial: json['initial'] ?? true,
      valid: json['valid'] ?? true,
      submitted: json['submitted'] ?? false,
      error: json['error'],
    );
  }
}

/// Represents the state of an entire form.
class CustomFormState {
  /// Map of field IDs to their respective states.
  Map<String, CustomFormFieldState> fields;

  /// Whether the form is currently being submitted.
  bool isSubmitting;

  /// Global error message for the form.
  String? globalError;

  /// Creates a new [CustomFormState] instance.
  ///
  /// [fields] is a map of field IDs to their respective states.
  /// [isSubmitting] indicates whether the form is currently being submitted.
  /// [globalError] is a global error message for the form.
  CustomFormState({
    Map<String, CustomFormFieldState>? fields,
    this.isSubmitting = false,
    this.globalError,
  }) : fields = fields ?? {};

  /// Whether all fields in the form are valid.
  bool get isValid => fields.values.every((field) => field.valid);

  /// Whether any field in the form has been modified.
  bool get hasModifications => fields.values.any((field) => field.isModified);

  /// Returns a map of field IDs to their values.
  Map<String, dynamic> get values {
    return fields.map((key, value) => MapEntry(key, value.value));
  }

  /// Creates a copy of this [CustomFormState] with the given fields replaced.
  CustomFormState copyWith({
    Map<String, CustomFormFieldState>? fields,
    bool? isSubmitting,
    String? globalError,
  }) {
    return CustomFormState(
      fields: fields ?? Map.from(this.fields),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      globalError: globalError ?? this.globalError,
    );
  }

  /// Updates a specific field's state.
  void updateField(String id, CustomFormFieldState state) {
    fields[id] = state;
  }

  /// Updates a specific field's value and validates it.
  void updateFieldValue(String id, String value, {String? error}) {
    final field = fields[id];
    if (field != null) {
      fields[id] = field.copyWith(
        value: value,
        initial: false,
        valid: error == null,
        error: error,
      );
    }
  }

  /// Resets all fields to their initial state.
  void reset(Map<String, String> initialValues) {
    for (final id in fields.keys) {
      fields[id] = CustomFormFieldState(
        value: initialValues[id] ?? '',
        initial: true,
        valid: true,
        submitted: false,
      );
    }
    globalError = null;
  }
}
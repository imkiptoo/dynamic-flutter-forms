/// Represents the state of an individual form field.
class CustomFormFieldState {
  /// The current value of the field as a string.
  String value;

  /// The initial value when the form was created
  final String initialValue;

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
  /// [initialValue] is the starting value of the field.
  /// [initial] indicates whether the field is in its initial state.
  /// [valid] indicates whether the field's current value is valid.
  /// [submitted] indicates whether the field has been submitted.
  /// [error] is the error message if validation failed.
  CustomFormFieldState({
    this.value = '',
    String? initialValue,
    this.initial = true,
    this.valid = true,
    this.submitted = false,
    this.error,
  }) : initialValue = initialValue ?? value;

  /// Whether the field has been truly modified from its initial value.
  bool get isModified {
    // Special handling for boolean values (stored as strings)
    if ((value == 'true' || value == 'false') &&
        (initialValue == 'true' || initialValue == 'false')) {
      return value.toLowerCase() != initialValue.toLowerCase();
    }
    return value != initialValue;
  }

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
      initialValue: initialValue, // Keep original initialValue
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
      'initialValue': initialValue,
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
      initialValue: json['initialValue'],
      initial: json['initial'] ?? true,
      valid: json['valid'] ?? true,
      submitted: json['submitted'] ?? false,
      error: json['error'],
    );
  }

  /// Checks if this state equals another state (for efficient rebuilds)
  bool equals(CustomFormFieldState other) {
    return value == other.value &&
        initialValue == other.initialValue &&
        initial == other.initial &&
        valid == other.valid &&
        submitted == other.submitted &&
        error == other.error;
  }
}

/// Represents the state of an entire form.
class CustomFormState {
  /// Map of field IDs to their respective states.
  Map<String, CustomFormFieldState> fields;

  /// Whether the form is currently being submitted.
  bool isSubmitting;

  /// Whether the form has been successfully submitted.
  bool isSubmitted;

  /// Global error message for the form.
  String? globalError;

  /// Set of fields that have been modified and need rebuilding
  final Set<String> modifiedFields = {};

  /// Creates a new [CustomFormState] instance.
  ///
  /// [fields] is a map of field IDs to their respective states.
  /// [isSubmitting] indicates whether the form is currently being submitted.
  /// [isSubmitted] indicates whether the form has been successfully submitted.
  /// [globalError] is a global error message for the form.
  CustomFormState({
    Map<String, CustomFormFieldState>? fields,
    this.isSubmitting = false,
    this.isSubmitted = false,
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

  /// Returns only the fields that need validation (modified or submitted)
  Iterable<String> get fieldsNeedingValidation {
    return fields.entries
        .where((entry) => entry.value.isModified || !entry.value.valid)
        .map((entry) => entry.key);
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
    final existingState = fields[id];
    if (existingState == null || !existingState.equals(state)) {
      fields[id] = state;
      modifiedFields.add(id);
    }
  }

  /// Updates a specific field's value and validates it.
  void updateFieldValue(String id, String value, {String? error}) {
    final field = fields[id];
    if (field != null) {
      final oldField = CustomFormFieldState(
        value: field.value,
        initialValue: field.initialValue,
        initial: field.initial,
        valid: field.valid,
        submitted: field.submitted,
        error: field.error,
      );

      field.value = value;
      field.initial = field.value == field.initialValue;
      field.valid = error == null;
      field.error = error;

      // Only mark as modified if something actually changed
      if (!oldField.equals(field)) {
        modifiedFields.add(id);
      }
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
      modifiedFields.add(id);
    }
    globalError = null;
  }

  /// Clears the list of modified fields after they've been processed
  void clearModifiedFields() {
    modifiedFields.clear();
  }
}
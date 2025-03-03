/*
class CustomFormFieldState {
  String value;
  bool initial;
  bool valid;
  bool submitted;
  String? error;

  CustomFormFieldState({
    this.value = '',
    this.initial = true,
    this.valid = true,
    this.submitted = false,
    this.error,
  });

  bool get isModified => !initial;
}

class CustomFormState {
  Map<String, CustomFormFieldState> fields = {};
  bool isSubmitting = false;
  String? globalError;

  bool get isValid => fields.values.every((field) => field.valid);

  bool get hasModifications => fields.values.any((field) => field.isModified);
}*/

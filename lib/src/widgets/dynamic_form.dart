import 'package:dynamic_flutter_forms/src/widgets/form_field_shimmer.dart';
import 'package:flutter/material.dart';
import '../models/form_field.dart';
import '../models/form_state.dart';
import '../theme/form_theme.dart';
import '../utils/form_styles.dart';
import 'form_widgets.dart';

/// A callback for form submission with the form data.
typedef OnFormSubmit = Future<void> Function(Map<String, dynamic> formData);

/// A callback for form reset.
typedef OnFormReset = void Function();

/// A callback for form validation.
typedef OnFormValidate = String? Function(CustomFormField field, String? value);

/// A controller for dynamic forms.
class DynamicFormController {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final _formState = CustomFormState();

  final List<CustomFormField> _formFields;
  final OnFormValidate? _onValidate;

  /// Whether the form is in a loading state (showing shimmer)
  bool isLoading = false;

  /// Whether the form is in a submitting state (disabled but no shimmer)
  bool isSubmitting = false;

  /// Creates a new [DynamicFormController] instance.
  DynamicFormController({
    required List<CustomFormField> formFields,
    OnFormValidate? onValidate,
  })  : _formFields = formFields,
        _onValidate = onValidate {
    _initializeForm();
  }

  void _initializeForm() {
    for (var field in _formFields) {
      String initialValue = field.initialValue?.toString() ?? '';
      _controllers[field.id] = TextEditingController(text: initialValue);
      _focusNodes[field.id] = FocusNode();
      _formState.fields[field.id] = CustomFormFieldState(
        value: initialValue,
        initialValue: initialValue,
        initial: true,
        valid: true,
        submitted: false,
      );
    }
  }

  /// Sets the loading state of the form (showing shimmer)
  void setLoading(bool loading) {
    isLoading = loading;
  }

  /// Sets the submitting state of the form (disabled without shimmer)
  void setSubmitting(bool submitting) {
    isSubmitting = submitting;
    _formState.isSubmitting = submitting;
  }

  /// Gets whether the form is currently being processed (either loading or submitting)
  bool get isProcessing => isLoading || isSubmitting || _formState.isSubmitting;

  /// Submits the form programmatically.
  Future<bool> submit() async {
    if (_formKey.currentState!.validate()) {
      for (var fieldId in _formState.fields.keys) {
        final field = _formState.fields[fieldId]!;
        field.submitted = true;
      }
      return true;
    }
    return false;
  }

  /// Resets the form to its initial state.
  void reset() {
    for (var field in _formFields) {
      final controller = _controllers[field.id];
      if (controller != null) {
        controller.text = field.initialValue?.toString() ?? '';
      }
      _formState.fields[field.id] = CustomFormFieldState(
        value: field.initialValue?.toString() ?? '',
        initial: true,
        valid: true,
        submitted: false,
      );
    }
    _formState.globalError = null;
  }

  /// Gets the current form data.
  Map<String, dynamic> get formData {
    final result = <String, dynamic>{};
    for (var entry in _formState.fields.entries) {
      result[entry.key] = entry.value.value;
    }
    return result;
  }

  /// Gets the current form state.
  CustomFormState get formState => _formState;

  /// Gets the controllers for the form fields.
  Map<String, TextEditingController> get controllers => _controllers;

  /// Gets the focus nodes for the form fields.
  Map<String, FocusNode> get focusNodes => _focusNodes;

  /// Gets the form key.
  GlobalKey<FormState> get formKey => _formKey;

  /// Gets the list of form fields.
  List<CustomFormField> get formFields => _formFields;

  /// Validates a field.
  String? validateField(CustomFormField field, String? value) {
    if (_onValidate != null) {
      return _onValidate(field, value);
    }

    if (field.required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }

    for (var validator in field.validators) {
      switch (validator.type) {
        case 'email':
          final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (value != null && !emailRegex.hasMatch(value)) {
            return validator.message ?? 'Invalid email format';
          }
          break;
        case 'pattern':
          if (validator.value != null && value != null) {
            final pattern = RegExp(validator.value!);
            if (!pattern.hasMatch(value)) {
              return validator.message ?? 'Invalid format';
            }
          }
          break;
      }
    }
    return null;
  }

  /// Updates a field's state.
  void updateFieldState(String fieldId, String value) {
    final field = _formState.fields[fieldId];
    if (field != null) {
      final customField = _formFields.firstWhere((f) => f.id == fieldId,
          orElse: () => throw Exception('Field not found: $fieldId'));

      final error = validateField(customField, value);

      // Check if the value is different from the initial value
      // For boolean fields, convert to lowercase for comparison
      final initialValue = field.initialValue.toLowerCase();
      final newValue = value.toLowerCase();
      final isModified = initialValue != newValue;

      field.value = value;
      field.initial = !isModified; // Set initial to false if modified
      field.submitted = false;
      field.valid = error == null;
      field.error = error;
    }
  }

  /// Disposes of the controller.
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
  }
}

/// A dynamic form widget that creates form fields based on field definitions.
class DynamicForm extends StatefulWidget {
  /// The list of form fields to display.
  final List<CustomFormField> formFields;

  /// Callback when the form is submitted.
  final OnFormSubmit? onSubmit;

  /// Callback when the form is reset.
  final OnFormReset? onReset;

  /// Callback to validate form fields.
  final OnFormValidate? onValidate;

  /// Custom theme for the form.
  final DynamicFormTheme? theme;

  /// Text for the submit button.
  final String submitButtonText;

  /// Whether to show a reset button.
  final bool showResetButton;

  /// Text for the reset button.
  final String resetButtonText;

  /// Whether to show confirmation dialogs.
  final bool showConfirmationDialogs;

  /// Controller for the form.
  final DynamicFormController? controller;

  /// Whether the form is in a loading state (displays shimmer).
  final bool isLoading;

  /// Creates a new [DynamicForm] widget.
  ///
  /// [formFields] is the list of form fields to display.
  /// [onSubmit] is called when the form is submitted.
  /// [onReset] is called when the form is reset.
  /// [onValidate] is called to validate form fields.
  /// [theme] is a custom theme for the form.
  /// [submitButtonText] is the text for the submit button.
  /// [showResetButton] determines whether to show a reset button.
  /// [resetButtonText] is the text for the reset button.
  /// [showConfirmationDialogs] determines whether to show confirmation dialogs.
  /// [controller] is a controller for the form.
  /// [isLoading] determines whether the form is in a loading state (displays shimmer).
  const DynamicForm({
    Key? key,
    required this.formFields,
    this.onSubmit,
    this.onReset,
    this.onValidate,
    this.theme,
    this.submitButtonText = 'Submit',
    this.showResetButton = false,
    this.resetButtonText = 'Reset',
    this.showConfirmationDialogs = true,
    this.controller,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  late DynamicFormController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        DynamicFormController(
          formFields: widget.formFields,
          onValidate: widget.onValidate,
        );
  }

  @override
  void didUpdateWidget(DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ??
          DynamicFormController(
            formFields: widget.formFields,
            onValidate: widget.onValidate,
          );
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateFieldState(String fieldId, dynamic value) {
    setState(() {
      _controller.updateFieldState(fieldId, value);
    });
  }

  Future<bool> _confirmReset() async {
    if (!widget.showConfirmationDialogs) {
      return true;
    }

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Form?'),
        content: Text('Are you sure you want to reset all fields to their initial values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text('Reset'),
          ),
        ],
      ),
    ).then((value) {
      // Remove focus after the dialog is closed
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
      return value ?? false;
    });
  }

  void _resetForm() {
    setState(() {
      _controller.reset();
    });

    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    for (var node in _controller._focusNodes.values) {
      if(node.hasFocus) {
        node.unfocus();
      }
    }

    final formState = _controller.formState;

    // Mark all fields as ready for validation
    setState(() {
      for (var fieldId in formState.fields.keys) {
        final field = formState.fields[fieldId]!;
        final controller = _controller.controllers[fieldId];
        if (controller != null) {
          final customField = widget.formFields.firstWhere((f) => f.id == fieldId);
          final error = _controller.validateField(customField, controller.text);
          field.valid = error == null;
          field.error = error;
          // Don't mark as submitted yet - we'll do that after successful submission
        }
      }
    });

    // If all fields are valid, proceed
    if (formState.isValid) {
      // Show confirmation dialog if needed
      if (widget.showConfirmationDialogs && !await _confirmSubmit()) {
        return;
      }

      // Set submitting state
      setState(() {
        _isSubmitting = true;
        formState.isSubmitting = true;
        formState.isSubmitted = false; // Reset in case of previous submission
      });

      try {
        // Call onSubmit callback
        if (widget.onSubmit != null) {
          await widget.onSubmit!(_controller.formData);
        }

        // Mark form as successfully submitted and update all fields
        setState(() {
          _isSubmitting = false;
          formState.isSubmitting = false;
          formState.isSubmitted = true; // Mark as successfully submitted

          // Now mark all fields as submitted
          for (var fieldId in formState.fields.keys) {
            final field = formState.fields[fieldId]!;
            field.submitted = true;
          }
        });
      } catch (e) {
        setState(() {
          _isSubmitting = false;
          formState.isSubmitting = false;
          formState.isSubmitted = false;
          formState.globalError = 'Submission failed: ${e.toString()}';
        });
      }
    }
  }

  Future<bool> _confirmSubmit() async {
    FocusScope.of(context).unfocus();

    if (!widget.showConfirmationDialogs) {
      return true;
    }

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Form?'),
        content: const Text('Are you sure you want to submit the form?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ).then((value) {
      // Remove focus after the dialog is closed
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
      return value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formTheme = widget.theme ?? DynamicFormTheme.of(context);
    final formState = _controller.formState;

    // Check if form is disabled during submission
    final bool isFormDisabled = _isSubmitting;

    return Theme(
      data: Theme.of(context).copyWith(
        extensions: <ThemeExtension<dynamic>>[
          formTheme,
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: formTheme.formPadding,
          child: Form(
            key: _controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (formState.globalError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      formState.globalError!,
                      style: TextStyle(color: formTheme.errorColor),
                    ),
                  ),

                // Show shimmer placeholders only when loading, not when submitting
                if (widget.isLoading)
                // Show shimmer placeholders for loading state
                  ...widget.formFields.map((field) =>
                      FormFieldShimmer.buildShimmerField(field, context)
                  )
                else
                // Show actual form fields - they'll be disabled during submission
                  ...widget.formFields.map((field) => FormWidgets.buildFormField(
                    field.copyWith(
                      // Disable fields during submission (not during loading)
                      disabled: field.disabled || _isSubmitting,
                    ),
                    _controller.controllers,
                    _controller.focusNodes,
                    formState,
                    _updateFieldState,
                    context,
                    widget.formFields,
                  )),

                // Buttons section
                Container(
                  padding: EdgeInsets.only(left: 16, right: 0, top: 8, bottom: 16),
                  child: Row(
                    children: [
                      if (widget.showResetButton)
                        Expanded(
                          child: widget.isLoading
                          // Shimmer for reset button during loading only
                              ? FormFieldShimmer.buildShimmerField(
                              CustomFormField(
                                id: 'reset-button-shimmer',
                                label: 'Reset Form',
                                type: FieldType.button,
                              ),
                              context
                          )
                          // Regular reset button (disabled during submission)
                              : InkWell(
                            onTap: isFormDisabled ? null : () async {
                              if (await _confirmReset()) {
                                _resetForm();
                              }
                            },
                            radius: formTheme.borderRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isFormDisabled ? Colors.black38 : Colors.red.shade700,
                                  width: 1.25,
                                ),
                                borderRadius: BorderRadius.circular(formTheme.borderRadius),
                                color: isFormDisabled ? Colors.black12 : Colors.red.shade50,
                              ),
                              height: 40,
                              child: Text(
                                widget.resetButtonText,
                                style: TextStyle(
                                  color: isFormDisabled ? Colors.black38 : Colors.red.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if(widget.showResetButton) SizedBox(width: 16),
                      Expanded(
                        child: widget.isLoading
                        // Shimmer for submit button during loading only
                            ? FormFieldShimmer.buildShimmerField(
                            CustomFormField(
                              id: 'submit-button-shimmer',
                              label: 'Submit Form',
                              type: FieldType.button,
                            ),
                            context
                        )
                        // Regular submit button (with loading indicator during submission)
                            : InkWell(
                          onTap: isFormDisabled ? null : _submitForm,
                          radius: formTheme.borderRadius,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFormDisabled ? Colors.black38 : Colors.green.shade700,
                                width: 1.25,
                              ),
                              borderRadius: BorderRadius.circular(formTheme.borderRadius),
                              color: isFormDisabled ? Colors.black12 : Colors.green.shade700,
                            ),
                            height: 40,
                            child: _isSubmitting
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              widget.submitButtonText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
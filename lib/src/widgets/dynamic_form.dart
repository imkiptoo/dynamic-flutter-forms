import 'package:dynamic_flutter_forms/src/widgets/form_field_shimmer.dart';
import 'package:flutter/material.dart';
import '../models/form_field.dart';
import '../models/form_state.dart';
import '../theme/form_theme.dart';
import '../utils/form_styles.dart';
import '../utils/form_validators.dart';
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

  // ValueNotifiers for reactive UI updates
  final Map<String, ValueNotifier<CustomFormFieldState>> _fieldStateNotifiers = {};
  final ValueNotifier<bool> _isProcessingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<String?> _globalErrorNotifier = ValueNotifier<String?>(null);

  final List<CustomFormField> _formFields;
  final OnFormValidate? _onValidate;

  // Track visible fields for more efficient resource management
  final Set<String> _visibleFieldIds = {};

  // Time threshold for cleanup of unused resources
  static const Duration _cleanupThreshold = Duration(minutes: 1);
  DateTime _lastCleanupTime = DateTime.now();

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

  /// Initializes the form with controllers, focus nodes, and state notifiers
  void _initializeForm() {
    for (var field in _formFields) {
      String initialValue = field.initialValue?.toString() ?? '';

      // Create field state
      _formState.fields[field.id] = CustomFormFieldState(
        value: initialValue,
        initialValue: initialValue,
        initial: true,
        valid: true,
        submitted: false,
      );

      // Create notifier for this field's state
      _fieldStateNotifiers[field.id] = ValueNotifier<CustomFormFieldState>(
          _formState.fields[field.id]!
      );
    }

    // Initialize global state notifiers
    _globalErrorNotifier.value = null;
    _isValidNotifier.value = true;
  }

  /// Lazy-loads controller for a field when needed
  /// Lazy-loads controller for a field when needed
  TextEditingController _getOrCreateController(String fieldId) {
    if (!_controllers.containsKey(fieldId)) {
      String initialValue = _formState.fields[fieldId]?.value ?? '';
      _controllers[fieldId] = TextEditingController(text: initialValue);
    }
    return _controllers[fieldId]!;
  }

  /// Lazy-loads focus node for a field when needed
  FocusNode _getOrCreateFocusNode(String fieldId) {
    if (!_focusNodes.containsKey(fieldId)) {
      _focusNodes[fieldId] = FocusNode();
    }
    return _focusNodes[fieldId]!;
  }

  /// Marks a field as visible to manage resources
  void markFieldVisible(String fieldId) {
    _visibleFieldIds.add(fieldId);
    // If field becomes visible, ensure it has controller and focusNode
    // We need to initialize both to avoid potential errors
    String initialValue = _formState.fields[fieldId]?.value ?? '';

    if (!_controllers.containsKey(fieldId)) {
      _controllers[fieldId] = TextEditingController(text: initialValue);
    }

    if (!_focusNodes.containsKey(fieldId)) {
      _focusNodes[fieldId] = FocusNode();
    }
  }

  /// Marks a field as invisible to manage resources
  void markFieldInvisible(String fieldId) {
    _visibleFieldIds.remove(fieldId);
    // Consider cleanup if many fields are invisible
    _maybeCleanupResources();
  }

  /// Cleanup unused resources to reduce memory usage
  void _maybeCleanupResources() {
    final now = DateTime.now();
    if (now.difference(_lastCleanupTime) < _cleanupThreshold) return;

    _lastCleanupTime = now;

    // Find controllers/focusNodes for fields that aren't visible
    final unusedControllerIds = _controllers.keys
        .where((id) => !_visibleFieldIds.contains(id))
        .toList();

    for (final id in unusedControllerIds) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
    }

    final unusedFocusNodeIds = _focusNodes.keys
        .where((id) => !_visibleFieldIds.contains(id))
        .toList();

    for (final id in unusedFocusNodeIds) {
      _focusNodes[id]?.dispose();
      _focusNodes.remove(id);
    }

    // Also clear validator cache for invisible fields
    for (final id in unusedControllerIds) {
      FormValidator.clearValidatorCache(id);
    }
  }

  /// Sets the loading state of the form (showing shimmer)
  void setLoading(bool loading) {
    isLoading = loading;
    _isProcessingNotifier.value = loading || isSubmitting;
  }

  /// Sets the submitting state of the form (disabled without shimmer)
  void setSubmitting(bool submitting) {
    isSubmitting = submitting;
    _formState.isSubmitting = submitting;
    _isProcessingNotifier.value = isLoading || submitting;
  }

  /// Gets whether the form is currently being processed (either loading or submitting)
  bool get isProcessing => isLoading || isSubmitting || _formState.isSubmitting;

  /// Gets a notifier for the processing state
  ValueNotifier<bool> get isProcessingNotifier => _isProcessingNotifier;

  /// Gets a notifier for the validity state
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  /// Gets a notifier for the global error
  ValueNotifier<String?> get globalErrorNotifier => _globalErrorNotifier;

  /// Submits the form programmatically.
  Future<bool> submit() async {
    if (_formKey.currentState!.validate()) {
      for (var fieldId in _formState.fields.keys) {
        final field = _formState.fields[fieldId]!;
        field.submitted = true;

        // Update notifier to reflect the change
        if (_fieldStateNotifiers.containsKey(fieldId)) {
          _fieldStateNotifiers[fieldId]!.value = field;
        }
      }
      return true;
    }
    return false;
  }

  /// Resets the form to its initial state.
  void reset() {
    final initialValues = <String, String>{};

    for (var field in _formFields) {
      initialValues[field.id] = field.initialValue?.toString() ?? '';
    }

    _formState.reset(initialValues);

    // Update controllers for visible fields
    for (var fieldId in _visibleFieldIds) {
      final value = initialValues[fieldId] ?? '';
      if (_controllers.containsKey(fieldId)) {
        _controllers[fieldId]!.text = value;
      }
    }

    // Update notifiers
    for (var fieldId in _fieldStateNotifiers.keys) {
      if (_formState.fields.containsKey(fieldId)) {
        _fieldStateNotifiers[fieldId]!.value = _formState.fields[fieldId]!;
      }
    }

    _globalErrorNotifier.value = null;
    _isValidNotifier.value = true;
  }

  /// Gets the current form data.
  Map<String, dynamic> get formData {
    final result = <String, dynamic>{};
    for (var entry in _formState.fields.entries) {
      // Only include fields that are marked for insertion
      final field = _formFields.firstWhere(
              (f) => f.id == entry.key,
          orElse: () => CustomFormField(id: entry.key, label: '', insert: true)
      );

      if (field.insert) {
        result[entry.key] = entry.value.value;
      }
    }
    return result;
  }

  /// Gets the current form state.
  CustomFormState get formState => _formState;

  /// Gets the controllers for the form fields.
  Map<String, TextEditingController> get controllers => _controllers;

  /// Gets the focus nodes for the form fields.
  Map<String, FocusNode> get focusNodes => _focusNodes;

  /// Gets state notifiers for fields
  Map<String, ValueNotifier<CustomFormFieldState>> get fieldStateNotifiers => _fieldStateNotifiers;

  /// Gets the form key.
  GlobalKey<FormState> get formKey => _formKey;

  /// Gets the list of form fields.
  List<CustomFormField> get formFields => _formFields;

  /// Validates a field.
  String? validateField(CustomFormField field, String? value) {
    if (_onValidate != null) {
      return _onValidate(field, value);
    }

    return FormValidator.validateField(field, value);
  }

  /// Updates a field's state.
  void updateFieldState(String fieldId, String value) {
    final field = _formState.fields[fieldId];
    if (field != null) {
      final customField = _formFields.firstWhere(
              (f) => f.id == fieldId,
          orElse: () => throw Exception('Field not found: $fieldId')
      );

      // Only validate if value changed (optimization)
      if (field.value != value) {
        final error = validateField(customField, value);

        // Check if the value is different from the initial value
        final initialValue = field.initialValue.toLowerCase();
        final newValue = value.toLowerCase();
        final isModified = initialValue != newValue;

        // Store previous state to check if an update is needed
        final oldValid = field.valid;
        final oldError = field.error;

        // Update field state
        field.value = value;
        field.initial = !isModified;
        field.submitted = false;
        field.valid = error == null;
        field.error = error;

        // Only update notifier if something important changed
        if (oldValid != field.valid || oldError != field.error || isModified) {
          if (_fieldStateNotifiers.containsKey(fieldId)) {
            _fieldStateNotifiers[fieldId]!.value = field;
          }
        }

        // Check overall form validity
        _isValidNotifier.value = _formState.isValid;
      }
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
    for (var notifier in _fieldStateNotifiers.values) {
      notifier.dispose();
    }
    _isProcessingNotifier.dispose();
    _isValidNotifier.dispose();
    _globalErrorNotifier.dispose();

    FormValidator.clearValidatorCache();
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

  /// Whether to use slivers for better scroll performance
  final bool useSlivers;

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
  /// [useSlivers] determines whether to use SliverList for better performance with long forms.
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
    this.useSlivers = false,
  }) : super(key: key);

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  late DynamicFormController _controller;
  bool _isSubmitting = false;

  // Track visible fields for optimization
  final Map<int, bool> _visibleFields = {};

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
    // Don't use setState for every field update
    _controller.updateFieldState(fieldId, value);
  }

  Future<bool> _confirmReset() async {
    if (!widget.showConfirmationDialogs) {
      return true;
    }

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Form?'),
        content: const Text('Are you sure you want to reset all fields to their initial values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Reset'),
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
    _controller.reset();

    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    for (var node in _controller.focusNodes.values) {
      if(node.hasFocus) {
        node.unfocus();
      }
    }

    final formState = _controller.formState;

    // Validate only fields that need validation (optimization)
    bool isValid = true;
    for (var fieldId in formState.fieldsNeedingValidation) {
      final field = formState.fields[fieldId]!;
      final controller = _controller.controllers[fieldId];
      if (controller != null) {
        final customField = widget.formFields.firstWhere((f) => f.id == fieldId);
        final error = _controller.validateField(customField, controller.text);
        field.valid = error == null;
        field.error = error;

        if (!field.valid) isValid = false;

        // Update field state notifier
        if (_controller.fieldStateNotifiers.containsKey(fieldId)) {
          _controller.fieldStateNotifiers[fieldId]!.value = field;
        }
      }
    }

    // If all fields are valid, proceed
    if (isValid) {
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
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            formState.isSubmitting = false;
            formState.isSubmitted = true; // Mark as successfully submitted

            // Now mark all fields as submitted
            for (var fieldId in formState.fields.keys) {
              final field = formState.fields[fieldId]!;
              field.submitted = true;

              // Update field state notifier
              if (_controller.fieldStateNotifiers.containsKey(fieldId)) {
                _controller.fieldStateNotifiers[fieldId]!.value = field;
              }
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            formState.isSubmitting = false;
            formState.isSubmitted = false;
            formState.globalError = 'Submission failed: ${e.toString()}';
            _controller.globalErrorNotifier.value = formState.globalError;
          });
        }
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

  // Visibility changed callback for a field
  void _onFieldVisibilityChanged(int index, bool isVisible) {
    _visibleFields[index] = isVisible;

    final fieldId = widget.formFields[index].id;
    if (isVisible) {
      _controller.markFieldVisible(fieldId);
    } else {
      _controller.markFieldInvisible(fieldId);
    }
  }

  // Build a form field with visibility tracking
  Widget _buildFormField(int index) {
    final field = widget.formFields[index];

    return VisibilityDetectorWidget(
      key: ValueKey('field-${field.id}'),
      onVisibilityChanged: (visible) => _onFieldVisibilityChanged(index, visible),
      child: FormWidgets.buildFormField(
        field.copyWith(
          // Disable fields during submission (not during loading)
          disabled: field.disabled || _isSubmitting,
        ),
        _controller.controllers,
        _controller.focusNodes,
        _controller.formState,
        _updateFieldState,
        context,
        widget.formFields,
        _controller.fieldStateNotifiers,
      ),
    );
  }

  // Build a form field shimmer with visibility tracking
  Widget _buildFieldShimmer(int index) {
    return VisibilityDetectorWidget(
      key: ValueKey('shimmer-${widget.formFields[index].id}'),
      onVisibilityChanged: (visible) => _onFieldVisibilityChanged(index, visible),
      child: FormFieldShimmer.buildShimmerField(widget.formFields[index], context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formTheme = widget.theme ?? DynamicFormTheme.of(context);
    final formState = _controller.formState;

    // Initialize controllers and focus nodes for all fields upfront
    // This helps prevent issues with lazy loading during the build phase
    if (!widget.isLoading) {
      for (var field in widget.formFields) {
        _controller.markFieldVisible(field.id);
      }
    }

    // Check if form is disabled during submission
    final bool isFormDisabled = _isSubmitting;

    final Widget formContent = Theme(
      data: Theme.of(context).copyWith(
        extensions: <ThemeExtension<dynamic>>[
          formTheme,
        ],
      ),
      child: widget.useSlivers
          ? _buildSliverForm(formTheme, formState, isFormDisabled)
          : _buildStandardForm(formTheme, formState, isFormDisabled),
    );

    return Form(
      key: _controller.formKey,
      child: formContent,
    );
  }

  // Build standard form with a Column layout
  Widget _buildStandardForm(DynamicFormTheme formTheme, CustomFormState formState, bool isFormDisabled) {
    return SingleChildScrollView(
      child: Padding(
        padding: formTheme.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Global error message (using ValueListenableBuilder for efficient updates)
            ValueListenableBuilder<String?>(
              valueListenable: _controller.globalErrorNotifier,
              builder: (context, errorMessage, child) {
                return errorMessage != null
                    ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: formTheme.errorColor),
                  ),
                )
                    : const SizedBox.shrink();
              },
            ),

            // Form fields
            ...List.generate(widget.formFields.length, (index) {
              // Show shimmer placeholders only when loading, not when submitting
              if (widget.isLoading) {
                return _buildFieldShimmer(index);
              } else {
                return _buildFormField(index);
              }
            }),

            // Buttons section
            _buildFormButtons(formTheme, isFormDisabled),
          ],
        ),
      ),
    );
  }

  // Build sliver-based form for better performance with long forms
  Widget _buildSliverForm(DynamicFormTheme formTheme, CustomFormState formState, bool isFormDisabled) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: formTheme.formPadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Global error message
              ValueListenableBuilder<String?>(
                valueListenable: _controller.globalErrorNotifier,
                builder: (context, errorMessage, child) {
                  return errorMessage != null
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: formTheme.errorColor),
                    ),
                  )
                      : const SizedBox.shrink();
                },
              ),
            ]),
          ),
        ),

        // Form fields with efficient builder pattern
        SliverPadding(
          padding: EdgeInsets.zero,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (widget.isLoading) {
                  return _buildFieldShimmer(index);
                } else {
                  return _buildFormField(index);
                }
              },
              childCount: widget.formFields.length,
            ),
          ),
        ),

        // Buttons section
        SliverPadding(
          padding: formTheme.formPadding,
          sliver: SliverToBoxAdapter(
            child: _buildFormButtons(formTheme, isFormDisabled),
          ),
        ),
      ],
    );
  }

  // Button section (shared between form layouts)
  Widget _buildFormButtons(DynamicFormTheme formTheme, bool isFormDisabled) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 0, top: 8, bottom: 16),
      child: Row(
        children: [
          if (widget.showResetButton)
            Expanded(
              child: widget.isLoading
              // Shimmer for reset button during loading only
                  ? FormFieldShimmer.buildShimmerField(
                  const CustomFormField(
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
          if(widget.showResetButton) const SizedBox(width: 16),
          Expanded(
            child: widget.isLoading
            // Shimmer for submit button during loading only
                ? FormFieldShimmer.buildShimmerField(
                const CustomFormField(
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
                    ? const SizedBox(
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
                  style: const TextStyle(
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
    );
  }
}

/// Simplified visibility detector for form fields
class VisibilityDetectorWidget extends StatefulWidget {
  final Widget child;
  final Function(bool) onVisibilityChanged;

  const VisibilityDetectorWidget({
    required Key key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  _VisibilityDetectorWidgetState createState() => _VisibilityDetectorWidgetState();
}

class _VisibilityDetectorWidgetState extends State<VisibilityDetectorWidget> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Consider widgets visible by default until scroll events indicate otherwise
    _isVisible = true;
    widget.onVisibilityChanged(true);
  }

  @override
  void dispose() {
    widget.onVisibilityChanged(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
        return false;
      },
      child: widget.child,
    );
  }

  void _checkVisibility() {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    try {
      final RenderBox box = renderObject as RenderBox;
      final Offset topLeft = box.localToGlobal(Offset.zero);
      final Size size = box.size;

      // Simple visibility check - if widget is on screen
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      final screenSize = mediaQuery.size;
      final screenInsets = mediaQuery.padding;

      final bool isVisible =
          (topLeft.dy + size.height > 0) &&
              (topLeft.dy < screenSize.height - screenInsets.bottom) &&
              (topLeft.dx + size.width > 0) &&
              (topLeft.dx < screenSize.width - screenInsets.right);

      if (_isVisible != isVisible) {
        _isVisible = isVisible;
        widget.onVisibilityChanged(isVisible);
      }
    } catch (e) {
      // If error occurs, assume visible
      if (!_isVisible) {
        _isVisible = true;
        widget.onVisibilityChanged(true);
      }
    }
  }
}
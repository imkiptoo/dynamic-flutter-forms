import 'package:dynamic_flutter_forms/src/utils/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_flutter_forms/dynamic_forms.dart';

class ExampleFormScreen extends StatefulWidget {
  const ExampleFormScreen({Key? key}) : super(key: key);

  @override
  _ExampleFormScreenState createState() => _ExampleFormScreenState();
}

class _ExampleFormScreenState extends State<ExampleFormScreen> {
  // Use const for static form field definitions to improve widget rebuilding efficiency
  static const List<CustomFormField> _formFields = [
    CustomFormField(
      id: 'id',
      label: 'ID',
      type: FieldType.text,
      placeholder: 'Select ID',
      initialValue: '245234',
      required: true,
      disabled: true,
      readonly: true,
      insert: false,
    ),
    CustomFormField(
      id: 'name',
      label: 'Name',
      type: FieldType.text,
      placeholder: 'Enter Name',
      required: false,
    ),
    CustomFormField(
      id: 'pm_notifications',
      label: 'PM Notifications',
      type: FieldType.boolean,
      placeholder: '',
      required: true,
      initialValue: false,
    ),
    CustomFormField(
      id: 'email',
      label: 'Email',
      type: FieldType.email,
      placeholder: 'Enter Email',
      required: true,
      validators: [
        Validator(name: 'email', type: 'email'),
      ],
    ),
    CustomFormField(
      id: 'type_id',
      label: 'Type',
      type: FieldType.select,
      placeholder: 'Select Type',
      selector: 'setup.employee_types.select',
      required: true,
      options: [
        {'id': '1', 'name': 'Admin'},
        {'id': '2', 'name': 'User'},
      ],
    ),
    CustomFormField(
      id: 'comments',
      label: 'Comments',
      type: FieldType.textarea,
      placeholder: 'Enter Comments',
      required: false,
      multiline: true,
      rows: 3,
    ),
    CustomFormField(
      id: 'date_of_birth',
      label: 'Date of Birth',
      type: FieldType.date,
      placeholder: 'Enter Date of Birth',
      required: true,
      enableMask: true,
      format: 'd/M/yyyy',
    ),
    CustomFormField(
      id: 'date_reported',
      label: 'Date & Time Reported',
      type: FieldType.datetime,
      placeholder: 'Enter Date & Time Reported',
      required: true,
      enableMask: true,
      format: 'd MMM yyyy hh:mm a',
    ),
    CustomFormField(
      id: 'roles',
      label: 'Roles',
      type: FieldType.multiselect,
      placeholder: 'Select Roles',
      required: true,
      options: [
        {'id': '1', 'name': 'Admin'},
        {'id': '2', 'name': 'User'},
        {'id': '3', 'name': 'Manager'},
        {'id': '4', 'name': 'Viewer'},
      ],
    ),
    CustomFormField(
      id: 'spacer-1',
      label: '',
      type: FieldType.spacer,
    ),
  ];

  bool _isLoading = false; // For data loading with shimmer effect
  bool _isSubmitting = false; // For form submission without shimmer
  late DynamicFormController _formController;

  // Use debounce for loading operations to prevent rapidly toggling the loading state
  DateTime _lastLoadingToggle = DateTime.now();
  static const _debounceThreshold = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _formController = DynamicFormController(
      formFields: _formFields,
      onValidate: FormValidator.validateField,
    );

    // Start loading data immediately when the form opens
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Only update loading state if not already loading
    if (!_isLoading) {
      setState(() {
        _isLoading = true; // Show shimmer during initial data loading
      });
    }

    try {
      // Simulate API call to load data
      await Future.delayed(const Duration(seconds: 3));

      // Batch all form updates instead of updating each field individually
      // to trigger fewer rebuilds
      _batchUpdateFormFields({
        'id': '12345',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'pm_notifications': 'true',
        'type_id': '1',
      });
    } catch (e) {
      debugPrint('Error loading data: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide shimmer after data is loaded
        });
      }
    }
  }

  // Helper to update multiple form fields in a single batch
  void _batchUpdateFormFields(Map<String, String> updates) {
    for (final entry in updates.entries) {
      final controller = _formController.controllers[entry.key];
      if (controller != null) {
        controller.text = entry.value;
        _formController.updateFieldState(entry.key, entry.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form Example'),
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (_isLoading || _isSubmitting) ? null : () {
              _loadInitialData();
            },
          ),
          // Toggle loading state button (for demo) with debounce
          IconButton(
            icon: Icon(_isLoading ? Icons.hourglass_full : Icons.hourglass_empty),
            onPressed: _isSubmitting ? null : () {
              // Prevent rapid toggling of loading state
              final now = DateTime.now();
              if (now.difference(_lastLoadingToggle) > _debounceThreshold) {
                _lastLoadingToggle = now;
                setState(() {
                  _isLoading = !_isLoading;
                });
              }
            },
            tooltip: 'Toggle Loading State',
          ),
          // New toggle submission state button (for demo) with debounce
          IconButton(
            icon: Icon(_isSubmitting ? Icons.send : Icons.send_outlined),
            onPressed: _isLoading ? null : () {
              // Prevent rapid toggling of submission state
              final now = DateTime.now();
              if (now.difference(_lastLoadingToggle) > _debounceThreshold) {
                _lastLoadingToggle = now;
                setState(() {
                  _isSubmitting = !_isSubmitting;
                });
              }
            },
            tooltip: 'Toggle Submission State',
          ),
        ],
      ),
      body: DynamicForm(
        formFields: _formFields,
        onSubmit: _handleSubmit,
        onReset: _handleReset,
        onValidate: FormValidator.validateField,
        showResetButton: true,
        submitButtonText: 'Submit Form',
        resetButtonText: 'Clear Form',
        isLoading: _isLoading, // Pass the loading state for shimmer effect
        controller: _formController, // Pass the controller for better state management
        useSlivers: false, // Temporarily disabled sliver support until all issues are fixed
      ),
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    setState(() {
      _isSubmitting = true; // Disable form during submission (no shimmer)
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false; // Re-enable form after submission
    });

    debugPrint('Form data: $formData');

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleReset() {
    debugPrint('Form reset');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form has been reset'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _formController.dispose();

    // Clean up cached resources
    FormValidator.clearValidatorCache();
    FormStyles.clearCaches();

    super.dispose();
  }
}
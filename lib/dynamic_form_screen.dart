import 'package:flutter/material.dart';
import 'package:dynamic_forms/form_state.dart';
import 'form_field.dart';
import 'form_state.dart';
import 'form_widgets.dart';

class DynamicFormScreen extends StatefulWidget {
  @override
  _DynamicFormScreenState createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final _formState = CustomFormState();

  final List<CustomFormField> _formFields = [
    CustomFormField(
      id: 'id',
      label: 'ID',
      type: FieldType.text,
      placeholder: 'Select ID',
      initialValue: '123',
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
      required: true,
    ),
    CustomFormField(
      id: 'pm_notifications',
      label: 'PM Notifications',
      type: FieldType.boolean,
      placeholder: '',
      required: true,
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
      id: 'date_of_birth',
      label: 'Date of Birth',
      type: FieldType.date,
      placeholder: 'Enter Date of Birth',
      required: true,
      enableMask: true,
      format: 'd/M/yyyy',
    ),
    CustomFormField(
      id: 'spacer-1',
      label: '',
      type: FieldType.spacer,
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
      id: 'mobile_phone',
      label: 'Mobile Phone',
      type: FieldType.tel,
      placeholder: 'Enter Mobile Phone',
      required: true,
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
      id: 'spacer',
      label: 'Address',
      type: FieldType.spacer,
    ),
    CustomFormField(
      id: 'address',
      label: 'Address',
      type: FieldType.address,
      placeholder: 'Enter Address',
      required: true,
    ),
    CustomFormField(
      id: 'incident_date_time',
      label: 'Incident Date & Time',
      type: FieldType.datetime,
      placeholder: 'Enter Incident Date & Time',
      required: true,
      enableMask: true,
      format: 'dd/MM/yyyy HH:mm',
    ),
    CustomFormField(
      id: 'roles',
      label: 'Roles',
      type: FieldType.select,
      placeholder: 'Select Roles',
      required: true,
      options: [
        {'id': '1', 'name': 'Admin'},
        {'id': '2', 'name': 'User'},
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    for (var field in _formFields) {
      _controllers[field.id] = TextEditingController(text: field.initialValue);
      _focusNodes[field.id] = FocusNode();
      _formState.fields[field.id] = CustomFormFieldState(
        value: field.initialValue ?? '',
        initial: true,
        valid: true,
        submitted: false,
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  void _updateFieldState(String fieldId, String value) {
    setState(() {
      var field = _formState.fields[fieldId]!;
      field.value = value;
      field.initial = false;
      field.submitted = false;

      String? error = _validateField(value, _formFields.firstWhere((f) => f.id == fieldId));
      field.valid = error == null;
      field.error = error;
    });
  }

  String? _validateField(String? value, CustomFormField field) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              if (await _confirmReset()) {
                _resetForm();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_formState.globalError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _formState.globalError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ..._formFields.map((field) => FormWidgets.buildFormField(
                      field,
                      _controllers,
                      _focusNodes,
                      _formState,
                      _updateFieldState,
                      context,
                      _formFields,
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                    onPressed: _formState.isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: _formState.isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmReset() async {
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
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _resetForm() {
    setState(() {
      for (var field in _formFields) {
        final controller = _controllers[field.id];
        if (controller != null) {
          controller.text = field.initialValue ?? '';
        }
        _formState.fields[field.id] = CustomFormFieldState(
          value: field.initialValue ?? '',
          initial: true,
          valid: true,
          submitted: false,
        );
      }
      _formState.globalError = null;
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      for (var fieldId in _formState.fields.keys) {
        final field = _formState.fields[fieldId]!;
        final controller = _controllers[fieldId];
        if (controller != null) {
          final error = _validateField(
            controller.text,
            _formFields.firstWhere((f) => f.id == fieldId),
          );
          field.valid = error == null;
          field.error = error;
          field.submitted = error != null;
        }
      }
    });

    if (_formState.isValid) {
      if (!await _confirmSubmit()) {
        return;
      }

      setState(() {
        _formState.isSubmitting = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 1));

        final formData = _formState.fields.map((key, value) => MapEntry(key, value.value));
        debugPrint('Form Data: $formData');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _formState.isSubmitting = false;
        });

        for (var fieldId in _formState.fields.keys) {
          final field = _formState.fields[fieldId]!;
          field.submitted = true;
        }
      } catch (e) {
        setState(() {
          _formState.isSubmitting = false;
          _formState.globalError = 'Submission failed. Please try again.';
        });
      }
    }
  }

  Future<bool> _confirmSubmit() async {
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
    ) ?? false;
  }
}
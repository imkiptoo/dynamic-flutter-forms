import 'package:flutter/material.dart';
import 'package:dynamic_flutter_forms/dynamic_forms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Forms Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        extensions: [
          DynamicFormTheme(
            borderRadius: 8.0,
            fieldPadding: const EdgeInsets.only(bottom: 16.0),
            formPadding: const EdgeInsets.only(left: 0, right: 16),
            buttonPadding: const EdgeInsets.symmetric(vertical: 16.0),
            requiredColor: Colors.red,
            modifiedColor: Colors.blue,
            validColor: Colors.green,
            errorColor: Colors.red,
            disabledColor: Colors.grey,
          ),
        ],
      ),
      home: const ExampleFormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExampleFormScreen extends StatefulWidget {
  const ExampleFormScreen({Key? key}) : super(key: key);

  @override
  _ExampleFormScreenState createState() => _ExampleFormScreenState();
}

class _ExampleFormScreenState extends State<ExampleFormScreen> {
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form Example'),
        elevation: 0,
      ),
      body: DynamicForm(
        formFields: _formFields,
        onSubmit: _handleSubmit,
        onReset: _handleReset,
        onValidate: _validateField,
        showResetButton: true,
        submitButtonText: 'Submit Form',
        resetButtonText: 'Clear Form',
      ),
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('Form data: $formData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
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

  String? _validateField(CustomFormField field, String? value) {
    if (field.required && (value == null || value.isEmpty)) {
      return 'The ${field.label} field is required';
    }

    // Example of custom validation for specific fields
    if (field.id == 'mobile_phone' && value != null) {
      if (value.length < 10) {
        return 'Phone number must be at least 10 digits';
      }
    }

    // Default validators
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
}
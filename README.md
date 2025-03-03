# Flutter Dynamic Form Library

A customizable and easy-to-use dynamic form library for Flutter applications.

## Features

- Create dynamic forms with various field types
- Customizable validation
- Form state management
- Responsive design
- Easy integration
- Support for various field types:
    - Text
    - Email
    - Phone
    - Number
    - Select/Dropdown
    - Date
    - DateTime
    - Textarea
    - Boolean/Switch
    - Spacer/Divider
    - Address

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_dynamic_forms: ^1.0.0
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_forms/flutter_dynamic_forms.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Form Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyFormPage(),
    );
  }
}

class MyFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define form fields
    final List<DynamicFormField> formFields = [
      DynamicFormField(
        id: 'name',
        label: 'Full Name',
        type: FieldType.text,
        placeholder: 'Enter your full name',
        required: true,
      ),
      DynamicFormField(
        id: 'email',
        label: 'Email Address',
        type: FieldType.email,
        placeholder: 'Enter your email',
        required: true,
        validators: [
          Validator(name: 'email', type: 'email'),
        ],
      ),
      DynamicFormField(
        id: 'birthdate',
        label: 'Date of Birth',
        type: FieldType.date,
        placeholder: 'Select date of birth',
        format: 'yyyy-MM-dd',
        required: true,
      ),
    ];

    // Create form configuration
    final formConfig = DynamicFormConfig(
      fields: formFields,
      onSubmit: (Map<String, dynamic> formData) {
        print('Form submitted: $formData');
        // Process the form data
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form Example'),
      ),
      body: DynamicForm(
        config: formConfig,
        showResetButton: true,
        submitButtonText: 'Submit Form',
      ),
    );
  }
}
```

### Advanced Configuration

The library provides various customization options:

```dart
DynamicForm(
  config: formConfig,
  formStyle: DynamicFormStyle(
    borderRadius: 12.0,
    fieldSpacing: 20.0,
    primaryColor: Colors.blue,
    errorColor: Colors.red.shade700,
    successColor: Colors.green,
  ),
  showResetButton: true,
  resetButtonText: 'Clear Form',
  submitButtonText: 'Submit',
  confirmResetDialog: true,
  confirmSubmitDialog: true,
  loadingIndicator: CircularProgressIndicator(),
  onFormValidationFailed: () {
    // Custom handling for validation failure
  },
)
```

## Form Field Types

### Text Field
```dart
DynamicFormField(
  id: 'first_name',
  label: 'First Name',
  type: FieldType.text,
  placeholder: 'Enter your first name',
  required: true,
)
```

### Email Field
```dart
DynamicFormField(
  id: 'email',
  label: 'Email',
  type: FieldType.email,
  placeholder: 'Enter your email',
  required: true,
  validators: [
    Validator(name: 'email', type: 'email'),
  ],
)
```

### Select/Dropdown Field
```dart
DynamicFormField(
  id: 'country',
  label: 'Country',
  type: FieldType.select,
  placeholder: 'Select your country',
  required: true,
  options: [
    {'id': 'us', 'name': 'United States'},
    {'id': 'ca', 'name': 'Canada'},
    {'id': 'uk', 'name': 'United Kingdom'},
  ],
)
```

### Date Field
```dart
DynamicFormField(
  id: 'birth_date',
  label: 'Date of Birth',
  type: FieldType.date,
  placeholder: 'Select your date of birth',
  required: true,
  format: 'yyyy-MM-dd',
)
```

### Boolean/Switch Field
```dart
DynamicFormField(
  id: 'subscribe',
  label: 'Subscribe to newsletter',
  type: FieldType.boolean,
  initialValue: 'false',
)
```

## Validation

The library includes built-in validators and supports custom validation:

```dart
DynamicFormField(
  id: 'password',
  label: 'Password',
  type: FieldType.text,
  placeholder: 'Enter password',
  required: true,
  validators: [
    Validator(
      name: 'min_length',
      type: 'pattern',
      value: r'.{8,}',
      message: 'Password must be at least 8 characters',
    ),
    Validator(
      name: 'has_uppercase',
      type: 'pattern',
      value: r'[A-Z]',
      message: 'Password must contain at least one uppercase letter',
    ),
  ],
)
```

## Handling Form Submission

The form data is provided as a `Map<String, dynamic>` where keys are field IDs and values are the input values:

```dart
final formConfig = DynamicFormConfig(
  fields: formFields,
  onSubmit: (Map<String, dynamic> formData) {
    // Access individual field values
    final name = formData['name'];
    final email = formData['email'];
    
    // Send data to API
    apiService.createUser(name, email);
  },
);
```

## Customizing Appearance

You can customize the appearance of the form using the `DynamicFormStyle` class:

```dart
DynamicForm(
  config: formConfig,
  formStyle: DynamicFormStyle(
    borderRadius: 8.0,
    fieldSpacing: 16.0,
    labelStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    inputTextStyle: TextStyle(
      fontSize: 16,
      color: Colors.black,
    ),
    errorTextStyle: TextStyle(
      fontSize: 12,
      color: Colors.red.shade700,
    ),
    buttonTextStyle: TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    primaryColor: Colors.indigo,
    buttonColor: Colors.indigo,
    successColor: Colors.green.shade600,
    errorColor: Colors.red.shade700,
  ),
)
```
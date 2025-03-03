# Dynamic Forms

A highly configurable dynamic forms library for Flutter that allows you to create forms with various field types, validations, and customization options.

## Features

- Create dynamic forms with a variety of field types
- Built-in validation with customizable validation rules
- Fully customizable styling through theming
- Form state management
- Easy integration with Flutter apps
- Support for various input types (text, email, date, boolean, select, etc.)

## Demo

[![](https://markdown-videos-api.jorgenkh.no/youtube/MZD1zSw_cwA)](https://youtu.be/MZD1zSw_cwA)


## Installation

Add this package to your pubspec.yaml:

```yaml
dependencies:
  dynamic_forms: ^0.1.0
```

Then run:

```
flutter pub get
```

## Usage

### Basic Form

```dart
import 'package:flutter/material.dart';
import 'package:dynamic_forms/dynamic_forms.dart';

class MyFormPage extends StatelessWidget {
  final List<CustomFormField> formFields = [
    CustomFormField(
      id: 'name',
      label: 'Name',
      type: FieldType.text,
      placeholder: 'Enter your name',
      required: true,
    ),
    CustomFormField(
      id: 'email',
      label: 'Email',
      type: FieldType.email,
      placeholder: 'Enter your email',
      required: true,
      validators: [
        Validator(name: 'email', type: 'email'),
      ],
    ),
    CustomFormField(
      id: 'agree',
      label: 'I agree to the terms',
      type: FieldType.boolean,
      required: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Form')),
      body: DynamicForm(
        formFields: formFields,
        onSubmit: (formData) {
          print('Form submitted: $formData');
          // Handle form submission
        },
      ),
    );
  }
}
```

### Custom Styling

You can customize the appearance of your forms using the `DynamicFormTheme`:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      DynamicFormTheme(
        borderRadius: 8.0,
        requiredColor: Colors.red,
        modifiedColor: Colors.blue,
        validColor: Colors.green,
        errorColor: Colors.red,
      ),
    ],
  ),
  home: MyFormPage(),
);
```

### Advanced Usage with Controller

For more control over the form, you can use a `DynamicFormController`:

```dart
class MyAdvancedFormPage extends StatefulWidget {
  @override
  _MyAdvancedFormPageState createState() => _MyAdvancedFormPageState();
}

class _MyAdvancedFormPageState extends State<MyAdvancedFormPage> {
  late DynamicFormController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = DynamicFormController(
      formFields: [
        // Your form fields here
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Form'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_controller.formState.isValid) {
                print('Form data: ${_controller.formData}');
              }
            },
          ),
        ],
      ),
      body: DynamicForm(
        controller: _controller,
        formFields: _controller.formFields,
        onSubmit: (formData) {
          // Handle submission
        },
      ),
    );
  }
}
```

## Supported Field Types

- `text`: Single-line text input
- `email`: Email input with validation
- `tel`: Telephone number input
- `number`: Numeric input
- `select`: Dropdown select input
- `date`: Date picker input
- `datetime`: Date and time picker input
- `textarea`: Multi-line text input
- `address`: Composite address input
- `multiselect`: Multi-select dropdown
- `boolean`: Boolean toggle input
- `spacer`: Spacer or section divider

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
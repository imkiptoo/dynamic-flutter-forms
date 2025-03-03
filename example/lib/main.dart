import 'package:dynamic_flutter_forms/src/utils/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_flutter_forms/dynamic_forms.dart';

import 'example_form_screen.dart';

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
            requiredColor: Colors.red.shade700,
            modifiedColor: Colors.blue,
            validColor: Colors.green,
            errorColor: Colors.red,
            disabledColor: Colors.grey,
          ),
        ],
      ),
      home: const ExampleFormScreen(),
      locale: Locale("en", "US"),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:dynamic_flutter_forms/dynamic_forms.dart';

import 'example_form_screen.dart';

void main() {
  // Enable Flutter performance optimization flags
  WidgetsFlutterBinding.ensureInitialized();

  // Custom error handler to log form-related errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('DynamicForm')) {
      debugPrint('Dynamic Form error: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
    }
    FlutterError.presentError(details);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cache the form theme to avoid rebuilding it
    final formTheme = DynamicFormTheme(
      borderRadius: 8.0,
      fieldPadding: const EdgeInsets.only(bottom: 16.0),
      formPadding: const EdgeInsets.only(left: 0, right: 16),
      buttonPadding: const EdgeInsets.symmetric(vertical: 16.0),
      requiredColor: Colors.red.shade700,
      modifiedColor: Colors.blue,
      validColor: Colors.green,
      errorColor: Colors.red,
      disabledColor: Colors.grey,
    );

    return MaterialApp(
      title: 'Dynamic Forms Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        extensions: [formTheme],
      ),
      home: const ExampleFormScreen(),
      locale: const Locale("en", "US"),
      debugShowCheckedModeBanner: false,
    );
  }
}
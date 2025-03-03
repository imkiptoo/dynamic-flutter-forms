import 'package:flutter/material.dart';
import 'dynamic_form_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DynamicFormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
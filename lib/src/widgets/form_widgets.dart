import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/form_field.dart';
import '../models/form_state.dart';
import '../utils/form_styles.dart';

/// A collection of widgets for building form fields.
class FormWidgets {
  /// Builds a form field based on its type.
  ///
  /// [field] is the field definition.
  /// [controllers] is a map of controllers for the fields.
  /// [focusNodes] is a map of focus nodes for the fields.
  /// [formState] is the current state of the form.
  /// [updateFieldState] is a callback to update the field state.
  /// [context] is the build context.
  /// [formFields] is the list of all form fields.
  static Widget buildFormField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
    List<CustomFormField> formFields,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: field.type == FieldType.spacer ? 0 : 16),
                child: field.required
                    ? Text(
                        "*",
                        style: FormStyles.requiredFieldStyle(context),
                      )
                    : SizedBox(),
              ),
              Expanded(
                child: _buildFieldByType(
                  field,
                  controllers,
                  focusNodes,
                  formState,
                  updateFieldState,
                  context,
                  formFields,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a field widget based on its type.
  static Widget _buildFieldByType(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
    List<CustomFormField> formFields,
  ) {
    switch (field.type) {
      case FieldType.datetime:
        return buildDateTimeField(field, controllers, focusNodes, formState, updateFieldState, context);
      case FieldType.select:
        return buildSelectField(field, controllers, formState, updateFieldState, context);
      case FieldType.textarea:
        return buildTextAreaField(field, controllers, focusNodes, formState, updateFieldState, context);
      case FieldType.date:
        return buildDateField(field, controllers, focusNodes, formState, updateFieldState, context);
      case FieldType.boolean:
        return buildBooleanField(field, controllers, formState, updateFieldState, context);
      case FieldType.spacer:
        return buildSpacerField(field, context);
      case FieldType.multiselect:
        return buildMultiSelectField(field, controllers, formState, updateFieldState, context);
      case FieldType.address:
        return buildAddressField(field, controllers, focusNodes, formState, updateFieldState, context);
      default:
        return buildTextField(field, controllers, focusNodes, formState, updateFieldState, context, formFields);
    }
  }

  /// Builds a text field.
  static Widget buildTextField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
    List<CustomFormField> formFields,
  ) {
    final isLastField = field == formFields.last;
    List<TextInputFormatter>? formatters;

    if (field.enableMask && field.type == FieldType.tel) {
      formatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    }

    if (field.maxLength != null) {
      formatters = [
        ...formatters ?? [],
        LengthLimitingTextInputFormatter(field.maxLength),
      ];
    }

    return TextFormField(
      key: Key(field.id),
      controller: controllers[field.id],
      focusNode: focusNodes[field.id],
      enabled: !field.disabled,
      readOnly: field.readonly,
      keyboardType: _getKeyboardType(field.type),
      textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
      inputFormatters: formatters,
      maxLines: field.multiline ? field.rows : 1,
      decoration: FormStyles.inputDecoration(
        context: context,
        labelText: field.label,
        hintText: field.placeholder,
        fieldId: field.id,
        formState: formState,
      ),
      onChanged: (value) => updateFieldState(field.id, value),
      onFieldSubmitted: (value) {
        if (!isLastField) {
          final nextIndex = formFields.indexOf(field) + 1;
          // Find the next enabled field
          for (int i = nextIndex; i < formFields.length; i++) {
            final nextField = formFields[i];
            if (!nextField.disabled && nextField.type != FieldType.spacer) {
              FocusScope.of(context).requestFocus(focusNodes[nextField.id]);
              break;
            }
          }
        }
      },
    );
  }

  /// Builds a select field (dropdown).
  static Widget buildSelectField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
  ) {
    final currentValue = controllers[field.id]?.text;
    final items = field.options?.map<DropdownMenuItem<String>>((option) {
          return DropdownMenuItem<String>(
            value: option['id'].toString(),
            child: Text(option['name']),
          );
        }).toList() ??
        [];

    // Ensure the current value is in the items list
    final isValidValue = items.any((item) => item.value == currentValue);

    return DropdownButtonFormField<String>(
      value: isValidValue ? currentValue : null,
      decoration: FormStyles.inputDecoration(
        context: context,
        labelText: field.label,
        hintText: field.placeholder,
        fieldId: field.id,
        formState: formState,
      ),
      style: TextStyle(fontSize: 16, color: Colors.black),
      borderRadius: BorderRadius.circular(8.0),
      items: items,
      onChanged: field.disabled || field.readonly
          ? null
          : (value) {
              if (value != null) {
                controllers[field.id]?.text = value;
                updateFieldState(field.id, value);
              }
            },
    );
  }

  /// Builds a multi-select field.
  static Widget buildMultiSelectField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
  ) {
    // Simple implementation that uses a comma-separated string
    // A more robust implementation might use a custom dialog or chips
    final currentValues = controllers[field.id]?.text.split(',').where((s) => s.isNotEmpty).toList() ?? [];

    return FormField<List<String>>(
      initialValue: currentValues,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: FormStyles.inputDecoration(
                context: context,
                labelText: field.label,
                hintText: field.placeholder,
                fieldId: field.id,
                formState: formState,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentValues.isNotEmpty ? SizedBox(height: Platform.isAndroid || Platform.isIOS ? 0 : 8,) : Container(),
                  Wrap(
                    spacing: Platform.isAndroid || Platform.isIOS ? 8 : 12.0,
                    runSpacing: Platform.isAndroid || Platform.isIOS ? 0 : 8.0,
                    alignment: WrapAlignment.start,
                    children: currentValues.map((value) {
                      final option = field.options?.firstWhere(
                        (o) => o['id'].toString() == value,
                        orElse: () => {'id': value, 'name': value},
                      );
                      final name = option?['name'] ?? value;

                      return Chip(
                        labelPadding: EdgeInsets.all(0),
                        padding: EdgeInsets.only(left: 8),
                        label: Text(name),
                        onDeleted: field.disabled || field.readonly
                            ? null
                            : () {
                                final newValues = List<String>.from(currentValues)..remove(value);
                                controllers[field.id]?.text = newValues.join(',');
                                updateFieldState(field.id, newValues.join(','));
                              },
                      );
                    }).toList(),
                  ),
                  if (!field.disabled && !field.readonly)
                    SizedBox(
                      height: 32,
                      child: DropdownButton<String>(
                        focusColor: Colors.transparent,
                        hint: Text('Add ${field.label}', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.normal)),
                        isExpanded: true,
                        underline: Container(),
                        borderRadius: BorderRadius.circular(8),
                        itemHeight: 48,
                        items: (field.options ?? []).where((o) => !currentValues.contains(o['id'].toString())).map<DropdownMenuItem<String>>((option) {
                          return DropdownMenuItem<String>(
                            value: option['id'].toString(),
                            child: Text(option['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final newValues = List<String>.from(currentValues)..add(value);
                            controllers[field.id]?.text = newValues.join(',');
                            updateFieldState(field.id, newValues.join(','));
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12.0,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds a date and time picker field.
  static Widget buildDateTimeField(
      CustomFormField field,
      Map<String, TextEditingController> controllers,
      Map<String, FocusNode> focusNodes,
      CustomFormState formState,
      Function(String, String) updateFieldState,
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: field.disabled || field.readonly
          ? null
          : () async {
        // Parse existing date if available
        DateTime initialDate = DateTime.now();
        if (controllers[field.id]?.text.isNotEmpty == true) {
          try {
            initialDate = DateFormat(field.format ?? 'yyyy-MM-dd h:mm a').parse(controllers[field.id]!.text);
          } catch (e) {
            // If parsing fails, use current date
          }
        }

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: initialTime,
            builder: (BuildContext context, Widget? child) {
              // Force 12-hour format
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: false,
                ),
                child: child!,
              );
            },
          );
          if (pickedTime != null) {
            DateTime dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            // Use AM/PM format if no specific format is provided
            String formatPattern = field.format ?? 'yyyy-MM-dd h:mm a';
            String formattedDateTime = DateFormat(formatPattern).format(dateTime);

            controllers[field.id]?.text = formattedDateTime;
            updateFieldState(field.id, formattedDateTime);
          }
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          key: Key(field.id),
          controller: controllers[field.id],
          focusNode: focusNodes[field.id],
          enabled: !field.disabled,
          readOnly: true,
          decoration: FormStyles.inputDecoration(
            context: context,
            labelText: field.label,
            hintText: field.placeholder,
            fieldId: field.id,
            formState: formState,
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  /// Builds a multi-line text field.
  static Widget buildTextAreaField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
  ) {
    return TextFormField(
      key: Key(field.id),
      controller: controllers[field.id],
      focusNode: focusNodes[field.id],
      enabled: !field.disabled,
      readOnly: field.readonly,
      maxLines: field.rows,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.top,
      decoration: FormStyles.inputDecoration(
        context: context,
        labelText: field.label,
        hintText: field.placeholder,
        fieldId: field.id,
        formState: formState,
        multiLine: true,
      ),
      onChanged: (value) => updateFieldState(field.id, value),
    );
  }

  /// Builds a date picker field.
  static Widget buildDateField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: field.disabled || field.readonly
          ? null
          : () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                String formattedDate = DateFormat(field.format ?? 'yyyy-MM-dd').format(pickedDate);
                controllers[field.id]?.text = formattedDate;
                updateFieldState(field.id, formattedDate);
              }
            },
      child: AbsorbPointer(
        child: TextFormField(
          key: Key(field.id),
          controller: controllers[field.id],
          focusNode: focusNodes[field.id],
          enabled: !field.disabled,
          readOnly: true,
          decoration: FormStyles.inputDecoration(
            context: context,
            labelText: field.label,
            hintText: field.placeholder,
            fieldId: field.id,
            formState: formState,
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  /// Builds a spacer or section divider.
  static Widget buildSpacerField(
    CustomFormField field,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        field.label.isEmpty
            ? SizedBox()
            : Text(
                field.label,
                style: FormStyles.labelStyle(context),
              ),
        field.label.isEmpty ? SizedBox() : SizedBox(height: 4),
        Container(
          height: 1,
          margin: EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
            color: Colors.black26,
          ),
        ),
      ],
    );
  }

  /// Builds a boolean toggle field.
  static Widget buildBooleanField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
  ) {
    bool currentValue = controllers[field.id]?.text.toLowerCase() == 'true';

    return GestureDetector(
      onTap: field.disabled || field.readonly
          ? null
          : () {
              controllers[field.id]?.text = (!currentValue).toString();
              updateFieldState(field.id, (!currentValue).toString());
            },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: FormStyles.getBorderColor(context, field.id, formState),
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: FormStyles.getFieldColor(context, field.id, formState),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field.label,
              style: TextStyle(fontSize: 16),
            ),
            Container(
              width: 48,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentValue ? Theme.of(context).primaryColor : Colors.grey[600]!,
                  width: 1.25,
                ),
                color: currentValue ? Theme.of(context).primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: currentValue ? null : 3,
                    right: currentValue ? 3 : null,
                    top: 3,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: currentValue ? Colors.white : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an address field (composite field).
  static Widget buildAddressField(
    CustomFormField field,
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    CustomFormState formState,
    Function(String, String) updateFieldState,
    BuildContext context,
  ) {
    // For simplicity, just rendering a text field
    // A more robust implementation would include multiple fields
    return buildTextField(field, controllers, focusNodes, formState, updateFieldState, context, [field]);
  }

  /// Gets the appropriate keyboard type for a field.
  static TextInputType _getKeyboardType(FieldType type) {
    switch (type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.tel:
        return TextInputType.phone;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.textarea:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }
}

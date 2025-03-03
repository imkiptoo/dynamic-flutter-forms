/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../lib_bkp/form_field.dart';
import 'form_state.dart';
import 'form_styles.dart';

class FormWidgets {
  static Widget buildFormField(CustomFormField field, Map<String, TextEditingController> controllers, Map<String, FocusNode> focusNodes, CustomFormState formState, Function(String, String) updateFieldState, BuildContext context, List<CustomFormField> formFields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: field.type == FieldType.spacer ? 0 : 16),
              child: field.required
                  ? Text(
                      "*",
                      style: FormStyles.requiredFieldStyle(),
                    )
                  : SizedBox(),
            ),
            Expanded(
              child: field.type == FieldType.datetime
                  ? buildDateTimeField(field, controllers, focusNodes, formState, updateFieldState, context)
                  : field.type == FieldType.select
                      ? buildSelectField(field, controllers, formState, updateFieldState, context)
                      : field.type == FieldType.textarea
                          ? buildTextAreaField(field, controllers, focusNodes, formState, updateFieldState)
                          : field.type == FieldType.date
                              ? buildDateField(field, controllers, focusNodes, formState, updateFieldState, context)
                              : field.type == FieldType.boolean
                                  ? buildBooleanField(field, controllers, formState, updateFieldState, context)
                                  : field.type == FieldType.spacer
                                      ? buildSpacerField(field, context)
                                      : buildTextField(field, controllers, focusNodes, formState, updateFieldState, context, formFields),
            ),
          ],
        ),
        SizedBox(height: field.type == FieldType.spacer ? 0 : 16),
      ],
    );
  }

  static Widget buildTextField(CustomFormField field, Map<String, TextEditingController> controllers, Map<String, FocusNode> focusNodes, CustomFormState formState, Function(String, String) updateFieldState, BuildContext context, List<CustomFormField> formFields) {
    final isLastField = field == formFields.last;
    List<TextInputFormatter>? formatters;

    if (field.enableMask && field.type == FieldType.tel) {
      formatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    }

    if (field.type == FieldType.date) {
      return GestureDetector(
        onTap: () async {
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
            readOnly: field.readonly,
            decoration: FormStyles.inputDecoration(
              labelText: field.label,
              hintText: field.placeholder,
              fillColor: _getFieldColor(field.id, formState),
              borderColor: _getBorderColor(field.id, formState),
              errorText: formState.fields[field.id]?.error,
            ),
          ),
        ),
      );
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
        labelText: field.label,
        hintText: field.placeholder,
        fillColor: _getFieldColor(field.id, formState),
        borderColor: _getBorderColor(field.id, formState),
        errorText: formState.fields[field.id]?.error,
      ),
      onChanged: (value) => updateFieldState(field.id, value),
      onFieldSubmitted: (value) {
        if (!isLastField) {
          final nextField = formFields[formFields.indexOf(field) + 1];
          FocusScope.of(context).requestFocus(focusNodes[nextField.id]);
        }
      },
    );
  }

  static Widget buildSelectField(CustomFormField field, Map<String, TextEditingController> controllers, CustomFormState formState, Function(String, String) updateFieldState, BuildContext context) {
    final currentValue = controllers[field.id]?.text;
    final items = field.options?.map((option) {
      return DropdownMenuItem<String>(
        value: option['id'].toString(),
        child: Text(option['name']),
      );
    }).toList();

    // Ensure the current value is in the items list
    final isValidValue = items?.any((item) => item.value == currentValue) ?? false;

    return DropdownButtonFormField<String>(
      value: isValidValue ? currentValue : null,
      decoration: FormStyles.inputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        fillColor: _getFieldColor(field.id, formState),
        borderColor: _getBorderColor(field.id, formState),
        errorText: formState.fields[field.id]?.error,
      ),
      style: TextStyle(fontSize: 15.6, color: Colors.black),
      borderRadius: BorderRadius.circular(FormStyles.borderRadius),
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

  static Widget buildDateTimeField(CustomFormField field, Map<String, TextEditingController> controllers, Map<String, FocusNode> focusNodes, CustomFormState formState, Function(String, String) updateFieldState, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            DateTime dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            String formattedDateTime = DateFormat(field.format ?? 'yyyy-MM-dd HH:mm').format(dateTime);
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
          readOnly: field.readonly,
          decoration: FormStyles.inputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            fillColor: _getFieldColor(field.id, formState),
            borderColor: _getBorderColor(field.id, formState),
            errorText: formState.fields[field.id]?.error,
            suffixIcon: Container(padding: EdgeInsets.only(right: 8),child: Icon(Icons.calendar_today)),
          ),
        ),
      ),
    );
  }

  static Widget buildTextAreaField(CustomFormField field, Map<String, TextEditingController> controllers, Map<String, FocusNode> focusNodes, CustomFormState formState, Function(String, String) updateFieldState) {
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
        labelText: field.label,
        hintText: field.placeholder,
        fillColor: _getFieldColor(field.id, formState),
        borderColor: _getBorderColor(field.id, formState),
        errorText: formState.fields[field.id]?.error,
        multiLine: true,
      ),
      onChanged: (value) => updateFieldState(field.id, value),
    );
  }

  static Widget buildDateField(CustomFormField field, Map<String, TextEditingController> controllers, Map<String, FocusNode> focusNodes, CustomFormState formState, Function(String, String) updateFieldState, BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
          readOnly: field.readonly,
          decoration: FormStyles.inputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            fillColor: _getFieldColor(field.id, formState),
            borderColor: _getBorderColor(field.id, formState),
            errorText: formState.fields[field.id]?.error,
            suffixIcon: Container(padding: EdgeInsets.only(right: 8),child: Icon(Icons.calendar_today)),
          ),
        ),
      ),
    );
  }

  static Widget buildSpacerField(CustomFormField field, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        field.label == ""
            ? SizedBox()
            : Text(
                field.label,
                style: FormStyles.labelStyle(context),
              ),
        field.label == "" ? SizedBox() : SizedBox(height: 4),
        Container(
          height: 1,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  static Widget buildBooleanField(CustomFormField field, Map<String, TextEditingController> controllers, CustomFormState formState, Function(String, String) updateFieldState, BuildContext context) {
    bool currentValue = controllers[field.id]?.text.toLowerCase() == 'true';

    return GestureDetector(
      onTap: field.disabled || field.readonly
          ? null
          : () {
              controllers[field.id]?.text = (!currentValue).toString();
              updateFieldState(field.id, (!currentValue).toString());
            },
      child: AbsorbPointer(
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              key: Key(field.id),
              //controller: controllers[field.id],
              enabled: !field.disabled,
              readOnly: true,
              initialValue: currentValue.toString(),
              style: TextStyle(
                color: Colors.transparent,
              ),
              decoration: FormStyles.inputDecoration(
                labelText: field.label,
                hintText: field.placeholder,
                fillColor: _getFieldColor(field.id, formState),
                borderColor: _getBorderColor(field.id, formState),
                errorText: formState.fields[field.id]?.error,
              ),
            ),
            Positioned(
              left: 12,
              child: Text(currentValue ? "Yes" : "No", style: TextStyle(fontSize: 16)),
            ),
            Positioned(
              right: 16,
              child: Container(
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
            ),
          ],
        ),
      ),
    );

    */
/*return SwitchListTile(
      title: Text(field.label),
      value: currentValue,
      contentPadding: EdgeInsets.only(right: 8, left: 11),
      tileColor: _getFieldColor(field.id, formState),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FormStyles.borderRadius),
        side: BorderSide(
          color: _getBorderColor(field.id, formState),
        ),
      ),

      onChanged: field.disabled || field.readonly
          ? null
          : (value) {
              controllers[field.id]?.text = value.toString();
              updateFieldState(field.id, value.toString());
            },
      activeColor: Theme.of(context).primaryColor,
      inactiveThumbColor: Colors.grey,
    );*//*

  }

  static TextInputType _getKeyboardType(FieldType type) {
    switch (type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.tel:
        return TextInputType.phone;
      case FieldType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  static Color _getFieldColor(String fieldId, CustomFormState formState) {
    final field = formState.fields[fieldId]!;

    if (field.initial) {
      return Colors.transparent;
    }

    if (!field.submitted) {
      return Colors.blue.shade50;
    }

    return field.valid ? Colors.green.shade50 : Colors.red.shade50;
  }

  static Color _getBorderColor(String fieldId, CustomFormState formState) {
    final field = formState.fields[fieldId]!;

    if (field.initial) {
      return Colors.grey;
    }

    if (!field.submitted) {
      return Colors.blue;
    }

    return field.valid ? Colors.green : Colors.red;
  }
}
*/

import 'dart:io';

import 'package:dynamic_flutter_forms/dynamic_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/form_field.dart';
import '../models/form_state.dart';
import '../utils/form_styles.dart';

/// A collection of widgets for building form fields.
class FormWidgets {
  // Cache for patterns and keyboard types
  static final Map<FieldType, TextInputType> _keyboardTypeCache = {};
  static final Map<int, List<TextInputFormatter>> _formattersCache = {};

  /// Builds a form field based on its type.
  ///
  /// [field] is the field definition.
  /// [controllers] is a map of controllers for the fields.
  /// [focusNodes] is a map of focus nodes for the fields.
  /// [formState] is the current state of the form.
  /// [updateFieldState] is a callback to update the field state.
  /// [context] is the build context.
  /// [formFields] is the list of all form fields.
  /// [fieldStateNotifiers] is a map of ValueNotifiers for field states.
  static Widget buildFormField(
      CustomFormField field,
      Map<String, TextEditingController> controllers,
      Map<String, FocusNode> focusNodes,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      List<CustomFormField> formFields, [
        Map<String, ValueNotifier<CustomFormFieldState>>? fieldStateNotifiers,
      ]) {
    // Ensure both controller and focusNode exist
    TextEditingController controller;
    FocusNode focusNode;

    // Get or create controller
    if (controllers.containsKey(field.id)) {
      controller = controllers[field.id]!;
    } else {
      controller = TextEditingController(text: field.initialValue?.toString() ?? '');
      controllers[field.id] = controller;
    }

    // Get or create focus node
    if (focusNodes.containsKey(field.id)) {
      focusNode = focusNodes[field.id]!;
    } else {
      focusNode = FocusNode();
      focusNodes[field.id] = focusNode;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                    : const SizedBox(),
              ),
              Expanded(
                child: fieldStateNotifiers != null && fieldStateNotifiers.containsKey(field.id)
                    ? _buildFieldWithValueNotifier(
                  field,
                  controller,
                  focusNode,
                  fieldStateNotifiers[field.id]!,
                  updateFieldState,
                  context,
                  formFields,
                  focusNodes,
                )
                    : _buildFieldByType(
                  field,
                  controller,
                  focusNode,
                  formState,
                  updateFieldState,
                  context,
                  formFields,
                  focusNodes,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  // Global focus nodes storage for when direct map access isn't available
  static final Map<String, FocusNode> _globalFocusNodes = {};

  /// Builds a field with a ValueNotifier for more efficient rebuilds
  static Widget _buildFieldWithValueNotifier(
      CustomFormField field,
      TextEditingController controller,
      FocusNode focusNode,
      ValueNotifier<CustomFormFieldState> fieldStateNotifier,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      List<CustomFormField> formFields,
      Map<String, FocusNode> allFocusNodes,
      ) {
    return ValueListenableBuilder<CustomFormFieldState>(
      valueListenable: fieldStateNotifier,
      builder: (context, fieldState, child) {
        // Create a minimal version of formState with just this field
        final singleFieldFormState = CustomFormState();
        singleFieldFormState.fields[field.id] = fieldState;

        return _buildFieldByType(
          field,
          controller,
          focusNode,
          singleFieldFormState,
          updateFieldState,
          context,
          formFields,
          allFocusNodes,
        );
      },
    );
  }

  /// Builds a field widget based on its type.
  static Widget _buildFieldByType(
      CustomFormField field,
      TextEditingController controller,
      FocusNode focusNode,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      List<CustomFormField> formFields,
      Map<String, FocusNode> allFocusNodes,
      ) {
    switch (field.type) {
      case FieldType.datetime:
        return buildDateTimeField(field, controller, focusNode, formState, updateFieldState, context);
      case FieldType.select:
        return buildSelectField(field, controller, formState, updateFieldState, context);
      case FieldType.textarea:
        return buildTextAreaField(field, controller, focusNode, formState, updateFieldState, context);
      case FieldType.date:
        return buildDateField(field, controller, focusNode, formState, updateFieldState, context);
      case FieldType.boolean:
        return buildBooleanField(field, controller, formState, updateFieldState, context);
      case FieldType.spacer:
        return buildSpacerField(field, context);
      case FieldType.multiselect:
        return buildMultiSelectField(field, controller, formState, updateFieldState, context);
      case FieldType.address:
        return buildAddressField(field, controller, focusNode, formState, updateFieldState, context);
      default:
        return buildTextField(field, controller, focusNode, formState, updateFieldState, context, formFields, allFocusNodes);
    }
  }

  /// Builds a text field.
  static Widget buildTextField(
      CustomFormField field,
      TextEditingController controller,
      FocusNode focusNode,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      List<CustomFormField> formFields,
      Map<String, FocusNode> allFocusNodes,
      ) {
    final isLastField = field == formFields.last;

    // Use cached text formatters
    List<TextInputFormatter>? formatters;
    int formatterCacheKey = field.id.hashCode;
    if (field.maxLength != null) formatterCacheKey ^= field.maxLength.hashCode;
    if (field.type == FieldType.tel) formatterCacheKey ^= field.type.index;

    if (!_formattersCache.containsKey(formatterCacheKey)) {
      formatters = [];

      if (field.enableMask && field.type == FieldType.tel) {
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        formatters.add(LengthLimitingTextInputFormatter(10));
      }

      if (field.maxLength != null) {
        formatters.add(LengthLimitingTextInputFormatter(field.maxLength));
      }

      _formattersCache[formatterCacheKey] = formatters;
    } else {
      formatters = _formattersCache[formatterCacheKey];
    }

    // MODIFIED: Add listener to controller to ensure state updates
    // when the controller changes from external sources
    if (!controller.hasListeners) {
      controller.addListener(() {
        updateFieldState(field.id, controller.text);
      });
    }

    return TextFormField(
      key: Key(field.id),
      controller: controller,
      focusNode: focusNode,
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
      // MODIFIED: Update field state immediately on change
      onChanged: (value) {
        updateFieldState(field.id, value);
      },
      onFieldSubmitted: (value) {
        if (!isLastField) {
          final nextIndex = formFields.indexOf(field) + 1;
          // Find the next enabled field
          for (int i = nextIndex; i < formFields.length; i++) {
            final nextField = formFields[i];
            if (!nextField.disabled && nextField.type != FieldType.spacer) {
              // Use the focus node from our parameters if available
              if (allFocusNodes.containsKey(nextField.id)) {
                FocusScope.of(context).requestFocus(allFocusNodes[nextField.id]);
              } else {
                // Fall back to our global cache if needed
                if (!_globalFocusNodes.containsKey(nextField.id)) {
                  _globalFocusNodes[nextField.id] = FocusNode();
                }
                FocusScope.of(context).requestFocus(_globalFocusNodes[nextField.id]);
              }
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
      TextEditingController controller,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      ) {
    final currentValue = controller.text;

    // Memoize dropdown items since they don't change often
    final cacheKey = '${field.id}_items';
    final items = _getCachedDropdownItems(field, cacheKey);

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
      style: const TextStyle(fontSize: 16, color: Colors.black),
      borderRadius: BorderRadius.circular(8.0),
      items: items,
      onChanged: field.disabled || field.readonly
          ? null
          : (value) {
        if (value != null) {
          controller.text = value;
          updateFieldState(field.id, value);
        }
      },
    );
  }

  // Cache for dropdown items to avoid recreating frequently
  static final Map<String, List<DropdownMenuItem<String>>> _dropdownItemsCache = {};

  // Helper to get cached dropdown items
  static List<DropdownMenuItem<String>> _getCachedDropdownItems(CustomFormField field, String cacheKey) {
    if (!_dropdownItemsCache.containsKey(cacheKey)) {
      _dropdownItemsCache[cacheKey] = field.options?.map<DropdownMenuItem<String>>((option) {
        return DropdownMenuItem<String>(
          value: option['id'].toString(),
          child: Text(option['name']),
        );
      }).toList() ?? [];
    }
    return _dropdownItemsCache[cacheKey]!;
  }

  /// Builds a multi-select field.
  static Widget buildMultiSelectField(
      CustomFormField field,
      TextEditingController controller,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      ) {
    // Simple implementation that uses a comma-separated string
    // Extract to a list only once, not on every rebuild
    final currentValues = controller.text.split(',').where((s) => s.isNotEmpty).toList();

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
                  currentValues.isNotEmpty
                      ? SizedBox(
                    height: Platform.isAndroid || Platform.isIOS ? 0 : 8,
                  )
                      : Container(),
                  Wrap(
                    spacing: Platform.isAndroid || Platform.isIOS ? 8 : 12.0,
                    runSpacing: Platform.isAndroid || Platform.isIOS ? 0 : 8.0,
                    alignment: WrapAlignment.start,
                    children: _buildOptionChips(field, currentValues, controller, updateFieldState),
                  ),
                  if (!field.disabled && !field.readonly)
                    SizedBox(
                      height: 32,
                      child: _buildOptionDropdown(field, currentValues, controller, updateFieldState),
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

  // Helper to build option chips (extracted for clarity)
  static List<Widget> _buildOptionChips(
      CustomFormField field,
      List<String> currentValues,
      TextEditingController controller,
      Function(String, dynamic) updateFieldState
      ) {
    // Cache option name lookup for better performance
    final Map<String, String> optionNameCache = {};
    if (field.options != null) {
      for (var option in field.options!) {
        optionNameCache[option['id'].toString()] = option['name'];
      }
    }

    return currentValues.map((value) {
      final name = optionNameCache[value] ?? value;

      return Chip(
        labelPadding: EdgeInsets.zero,
        label: Text(name),
        onDeleted: field.disabled || field.readonly
            ? null
            : () {
          final newValues = List<String>.from(currentValues)..remove(value);
          controller.text = newValues.join(',');
          updateFieldState(field.id, newValues.join(','));
        },
      );
    }).toList();
  }

  // Helper to build option dropdown (extracted for clarity)
  static Widget _buildOptionDropdown(
      CustomFormField field,
      List<String> currentValues,
      TextEditingController controller,
      Function(String, dynamic) updateFieldState
      ) {
    // Filter options that haven't been selected yet
    final availableOptions = (field.options ?? [])
        .where((o) => !currentValues.contains(o['id'].toString()))
        .toList();

    return DropdownButton<String>(
      focusColor: Colors.transparent,
      hint: Text(
          'Add ${field.label}',
          style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.normal
          )
      ),
      isExpanded: true,
      underline: Container(),
      borderRadius: BorderRadius.circular(8),
      itemHeight: 48,
      items: availableOptions.map<DropdownMenuItem<String>>((option) {
        return DropdownMenuItem<String>(
          value: option['id'].toString(),
          child: Text(option['name']),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          final newValues = List<String>.from(currentValues)..add(value);
          controller.text = newValues.join(',');
          updateFieldState(field.id, newValues.join(','));
        }
      },
    );
  }

  // Cache for DateFormat objects
  static final Map<String, DateFormat> _dateFormatCache = {};

  // Helper to get cached DateFormat
  static DateFormat _getCachedDateFormat(String? format, String defaultFormat) {
    final formatString = format ?? defaultFormat;
    if (!_dateFormatCache.containsKey(formatString)) {
      _dateFormatCache[formatString] = DateFormat(formatString);
    }
    return _dateFormatCache[formatString]!;
  }

  /// Builds a date and time picker field.
  static Widget buildDateTimeField(
      CustomFormField field,
      TextEditingController controller,
      FocusNode focusNode,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: field.disabled || field.readonly
          ? null
          : () async {
        // Parse existing date if available
        DateTime initialDate = DateTime.now();
        if (controller.text.isNotEmpty) {
          try {
            final format = _getCachedDateFormat(field.format, 'yyyy-MM-dd h:mm a');
            initialDate = format.parse(controller.text);
          } catch (e) {
            // If parsing fails, use current date
          }
        }

        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);
          final TimeOfDay? pickedTime = await showTimePicker(
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
            final DateTime dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            // Use AM/PM format if no specific format is provided
            final formatPattern = field.format ?? 'yyyy-MM-dd h:mm a';
            final format = _getCachedDateFormat(formatPattern, 'yyyy-MM-dd h:mm a');
            final formattedDateTime = format.format(dateTime);

            controller.text = formattedDateTime;
            updateFieldState(field.id, formattedDateTime);
          }
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          key: Key(field.id),
          controller: controller,
          focusNode: focusNode,
          enabled: !field.disabled,
          readOnly: true,
          decoration: FormStyles.inputDecoration(
            context: context,
            labelText: field.label,
            hintText: field.placeholder,
            fieldId: field.id,
            formState: formState,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  /// Builds a multi-line text field.
  static Widget buildTextAreaField(
      CustomFormField field,
      TextEditingController controller,
      FocusNode focusNode,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      ) {
    return TextFormField(
      key: Key(field.id),
      controller: controller,
      focusNode: focusNode,
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
      TextEditingController controller,
      FocusNode focusNode,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
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
          final format = _getCachedDateFormat(field.format, 'yyyy-MM-dd');
          final formattedDate = format.format(pickedDate);
          controller.text = formattedDate;
          updateFieldState(field.id, formattedDate);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          key: Key(field.id),
          controller: controller,
          focusNode: focusNode,
          enabled: !field.disabled,
          readOnly: true,
          decoration: FormStyles.inputDecoration(
            context: context,
            labelText: field.label,
            hintText: field.placeholder,
            fieldId: field.id,
            formState: formState,
            suffixIcon: const Icon(Icons.calendar_today),
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
            ? const SizedBox()
            : Text(
          field.label,
          style: FormStyles.labelStyle(context),
        ),
        field.label.isEmpty ? const SizedBox() : const SizedBox(height: 4),
        Container(
          height: 1,
          margin: const EdgeInsets.only(bottom: 0),
          decoration: const BoxDecoration(
            color: Colors.black26,
          ),
        ),
      ],
    );
  }

  /// Builds a boolean toggle field.
  static Widget buildBooleanField(
      CustomFormField field,
      TextEditingController controller,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      ) {
    // Parse boolean value once, not on every render pass
    final bool currentValue = controller.text.toLowerCase() == 'true';

    return TextFormField(
      key: Key(field.id),
      controller: controller,
      enabled: !field.disabled,
      readOnly: true,
      keyboardType: _getKeyboardType(field.type),
      maxLines: field.multiline ? field.rows : 1,
      canRequestFocus: false,
      onTap: field.disabled || field.readonly
          ? null
          : () {
        final newValue = (!currentValue).toString();
        controller.text = newValue;
        updateFieldState(field.id, newValue);
      },
      style: const TextStyle(
        color: Colors.transparent,
      ),
      decoration: FormStyles.inputDecoration(
        context: context,
        labelText: field.label,
        hintText: field.placeholder,
        fieldId: field.id,
        formState: formState,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ).copyWith(
        suffix: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentValue ? "Yes" : "No",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
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
      onChanged: (value) => updateFieldState(field.id, value),
    );
  }

  /// Builds an address field (composite field).
  static Widget buildAddressField(
      CustomFormField field,
      TextEditingController controller,
      FocusNode focusNode,
      CustomFormState formState,
      Function(String, dynamic) updateFieldState,
      BuildContext context,
      ) {
    // For simplicity, just rendering a text field
    // A more robust implementation would include multiple fields
    return buildTextField(field, controller, focusNode, formState, updateFieldState, context, [field], {});
  }

  /// Gets the appropriate keyboard type for a field.
  static TextInputType _getKeyboardType(FieldType type) {
    if (!_keyboardTypeCache.containsKey(type)) {
      switch (type) {
        case FieldType.email:
          _keyboardTypeCache[type] = TextInputType.emailAddress;
          break;
        case FieldType.tel:
          _keyboardTypeCache[type] = TextInputType.phone;
          break;
        case FieldType.number:
          _keyboardTypeCache[type] = TextInputType.number;
          break;
        case FieldType.textarea:
          _keyboardTypeCache[type] = TextInputType.multiline;
          break;
        default:
          _keyboardTypeCache[type] = TextInputType.text;
          break;
      }
    }
    return _keyboardTypeCache[type]!;
  }

  /// Clears caches to free memory (call when form is disposed)
  static void clearCaches() {
    _keyboardTypeCache.clear();
    _formattersCache.clear();
    _dropdownItemsCache.clear();
    _dateFormatCache.clear();
  }
}
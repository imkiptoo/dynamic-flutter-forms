import 'package:flutter/material.dart';
import '../models/form_field.dart';
import '../theme/form_theme.dart';
import 'shimmer_effect.dart';

/// A collection of shimmer placeholders for form fields.
class FormFieldShimmer {
  /// Creates a shimmer placeholder for a form field.
  static Widget buildShimmerField(
      CustomFormField field,
      BuildContext context,
      ) {
    // Default shimmer colors
    final Color baseColor = Colors.black12;
    final Color highlightColor = Colors.transparent;

    switch (field.type) {
      case FieldType.select:
        return buildSelectFieldShimmer(field, context, baseColor, highlightColor);
      case FieldType.textarea:
        return buildTextAreaFieldShimmer(field, context, baseColor, highlightColor);
      case FieldType.date:
      case FieldType.datetime:
        return buildDateFieldShimmer(field, context, baseColor, highlightColor);
      case FieldType.boolean:
        return buildBooleanFieldShimmer(field, context, baseColor, highlightColor);
      case FieldType.spacer:
        return buildSpacerFieldShimmer(field, context, baseColor, highlightColor);
      case FieldType.multiselect:
        return buildMultiSelectFieldShimmer(field, context, baseColor, highlightColor);
      default:
        return buildTextFieldShimmer(field, context, baseColor, highlightColor);
    }
  }

  /// Creates a shimmer placeholder for a text field.
  static Widget buildTextFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 16,
                alignment: Alignment.center,
                child: field.required
                    ? ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape:  BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                )
                    : SizedBox(),
              ),
              Expanded(
                child: ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(formTheme.borderRadius),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a select field.
  static Widget buildSelectFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 16,
            alignment: Alignment.center,
            child: field.required
                ? ShimmerBuilder(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape:  BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
            )
                : SizedBox(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select field shimmer
                ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(formTheme.borderRadius),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 20,
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
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a textarea field.
  static Widget buildTextAreaFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    final formTheme = DynamicFormTheme.of(context);
    final double height = field.rows * 24.0;

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
                padding: EdgeInsets.only(top: 16),
                child: field.required
                    ? ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : SizedBox(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label shimmer
                    ShimmerBuilder(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: field.label.length * 8.0,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Textarea field shimmer
                    ShimmerBuilder(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: height + 24, // Add padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(formTheme.borderRadius),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a date field.
  static Widget buildDateFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    final formTheme = DynamicFormTheme.of(context);

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
                padding: EdgeInsets.only(top: 16),
                child: field.required
                    ? ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : SizedBox(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label shimmer
                    ShimmerBuilder(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: field.label.length * 8.0,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Date field shimmer
                    ShimmerBuilder(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(formTheme.borderRadius),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 16,
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
            ],
          ),
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a boolean field.
  static Widget buildBooleanFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 16,
            alignment: Alignment.center,
            child: field.required
                ? ShimmerBuilder(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape:  BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
            )
                : SizedBox(),
          ),
          Expanded(
            child: ShimmerBuilder(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(formTheme.borderRadius),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Label shimmer inside the container
                    Container(
                      width: field.label.length * 8.0,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Toggle shimmer
                    Container(
                      width: 48,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a spacer field.
  static Widget buildSpacerFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (field.label.isNotEmpty)
            ShimmerBuilder(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: field.label.length * 8.0,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          if (field.label.isNotEmpty) SizedBox(height: 4),
          ShimmerBuilder(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 1,
              margin: EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a multiselect field.
  static Widget buildMultiSelectFieldShimmer(
      CustomFormField field,
      BuildContext context,
      Color baseColor,
      Color highlightColor,
      ) {
    final formTheme = DynamicFormTheme.of(context);

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
                padding: EdgeInsets.only(top: 16),
                child: field.required
                    ? ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : SizedBox(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label shimmer
                    ShimmerBuilder(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: field.label.length * 8.0,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Multiselect container shimmer
                    ShimmerBuilder(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: 80, // Taller for multiselect field
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(formTheme.borderRadius),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chip-like items shimmer
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 60,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Add button shimmer
                            Container(
                              width: 120,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
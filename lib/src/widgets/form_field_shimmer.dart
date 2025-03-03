import 'package:flutter/material.dart';
import '../models/form_field.dart';
import '../theme/form_theme.dart';
import 'shimmer_effect.dart';

/// A collection of shimmer placeholders for form fields.
class FormFieldShimmer {
  // Cache shimmer colors to avoid recreation
  static final Color baseColor = Colors.black12;
  static final Color highlightColor = Colors.white70;

  /// Creates a shimmer placeholder for a form field.
  static Widget buildShimmerField(
      CustomFormField field,
      BuildContext context,
      ) {
    switch (field.type) {
      case FieldType.select:
      case FieldType.multiselect:
        return buildSelectFieldShimmer(field, context);
      case FieldType.textarea:
        return buildTextAreaFieldShimmer(field, context);
      case FieldType.date:
      case FieldType.datetime:
        return buildDateFieldShimmer(field, context);
      case FieldType.boolean:
        return buildBooleanFieldShimmer(field, context);
      case FieldType.spacer:
        return buildSpacerFieldShimmer(field, context);
      case FieldType.button:
        return buildButtonFieldShimmer(field, context);
      default:
        return buildTextFieldShimmer(field, context);
    }
  }

  /// Creates a shimmer placeholder for a text field.
  static Widget buildTextFieldShimmer(
      CustomFormField field,
      BuildContext context,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
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
                    : const SizedBox(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          width: field.label.length * 8.0,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                      ],
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
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                : const SizedBox(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: field.placeholder.length * 8.0,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(16),
                        borderRadius: BorderRadius.circular(8),
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

  /// Creates a shimmer placeholder for a textarea field.
  static Widget buildTextAreaFieldShimmer(
      CustomFormField field,
      BuildContext context,
      ) {
    final formTheme = DynamicFormTheme.of(context);
    final double height = field.rows * 24.0;

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
                    : const SizedBox(),
              ),
              Expanded(
                child: ShimmerBuilder(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: height + 18, // Add padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(formTheme.borderRadius),
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: // Label shimmer inside the container
                    Row(
                      children: [
                        Container(
                          width: field.label.length * 8.0,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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

  /// Creates a shimmer placeholder for a date field.
  static Widget buildDateFieldShimmer(
      CustomFormField field,
      BuildContext context,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                : const SizedBox(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Label shimmer inside the container
                    Container(
                      width: field.label.length * 8.0,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(16),
                        borderRadius: BorderRadius.circular(8),
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

  /// Creates a shimmer placeholder for a boolean field.
  static Widget buildBooleanFieldShimmer(
      CustomFormField field,
      BuildContext context,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                : const SizedBox(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Label shimmer inside the container
                    Container(
                      width: field.label.length * 8.0,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Toggle shimmer
                    Container(
                      width: 48,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(16),
                        borderRadius: BorderRadius.circular(24),
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
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
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
          if (field.label.isNotEmpty) const SizedBox(height: 4),
          ShimmerBuilder(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a shimmer placeholder for a text field.
  static Widget buildButtonFieldShimmer(
      CustomFormField field,
      BuildContext context,
      ) {
    final formTheme = DynamicFormTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ShimmerBuilder(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(formTheme.borderRadius),
                border: Border.all(color: Colors.black12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: field.label.length * 8.0,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(24),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
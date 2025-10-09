import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';

/// Utility class for enhanced form handling with flutter_form_builder
/// Provides consistent form field styling and validation across the app
class FormBuilderUtils {
  // ============================================================================
  // Form Field Builders
  // ============================================================================

  /// Build a standard text field with consistent styling
  static Widget buildTextField({
    required String name,
    required String label,
    String? hintText,
    String? helperText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    int? maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    TextEditingController? controller,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: name,
        controller: controller,
        initialValue: initialValue,
        enabled: enabled,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(
          color: enabled ? null : Theme.of(AppAnimations.navigatorKey.currentContext!).disabledColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: helperText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).colorScheme.error,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: enabled
              ? Theme.of(AppAnimations.navigatorKey.currentContext!).cardColor
              : Theme.of(AppAnimations.navigatorKey.currentContext!).disabledColor.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  /// Build a number field specifically for amounts/money
  static Widget buildAmountField({
    required String name,
    required String label,
    String? hintText = '请输入金额',
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    TextEditingController? controller,
    String? initialValue,
    int decimalPlaces = 2,
  }) {
    return buildTextField(
      name: name,
      label: label,
      hintText: hintText,
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      validator: (value) {
        if (validator != null) {
          final result = validator(value);
          if (result != null) return result;
        }

        if (value == null || value.isEmpty) return null;

        final numValue = double.tryParse(value);
        if (numValue == null) return '请输入有效的金额';

        if (numValue < 0) return '金额不能为负数';

        return null;
      },
      onChanged: (value) {
        // Auto-format amount as user types
        if (value != null && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue != null) {
            // You could add auto-formatting here if needed
          }
        }
        onChanged?.call(value);
      },
      controller: controller,
      initialValue: initialValue,
    );
  }

  /// Build a date picker field
  static Widget buildDateField({
    required String name,
    required String label,
    String? hintText,
    bool enabled = true,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? Function(DateTime?)? validator,
    void Function(DateTime?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderDateTimePicker(
        name: name,
        initialValue: initialDate,
        enabled: enabled,
        inputType: InputType.date,
        format: DateFormat('yyyy-MM-dd'),
        firstDate: firstDate ?? DateTime(1900),
        lastDate: lastDate ?? DateTime(2100),
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText ?? '请选择日期',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: enabled
              ? Theme.of(AppAnimations.navigatorKey.currentContext!).cardColor
              : Theme.of(AppAnimations.navigatorKey.currentContext!).disabledColor.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  /// Build a dropdown field
  static Widget buildDropdown<T>({
    required String name,
    required String label,
    required List<DropdownMenuItem<T>> items,
    T? initialValue,
    bool enabled = true,
    String? hintText,
    String? Function(T?)? validator,
    void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderDropdown<T>(
        name: name,
        initialValue: initialValue,
        enabled: enabled,
        validator: validator,
        onChanged: onChanged,
        items: items,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(AppAnimations.navigatorKey.currentContext!).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: enabled
              ? Theme.of(AppAnimations.navigatorKey.currentContext!).cardColor
              : Theme.of(AppAnimations.navigatorKey.currentContext!).disabledColor.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  /// Build a checkbox field
  static Widget buildCheckbox({
    required String name,
    required String title,
    String? subtitle,
    bool initialValue = false,
    bool enabled = true,
    void Function(bool?)? onChanged,
  }) {
    return FormBuilderCheckbox(
      name: name,
      initialValue: initialValue,
      enabled: enabled,
      onChanged: onChanged,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(AppAnimations.navigatorKey.currentContext!).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            )
          : Text(title),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  /// Build a switch field
  static Widget buildSwitch({
    required String name,
    required String title,
    String? subtitle,
    bool initialValue = false,
    bool enabled = true,
    void Function(bool?)? onChanged,
  }) {
    return FormBuilderSwitch(
      name: name,
      initialValue: initialValue,
      enabled: enabled,
      onChanged: onChanged,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
    );
  }

  /// Build a slider field
  static Widget buildSlider({
    required String name,
    required String label,
    double initialValue = 0,
    required double min,
    required double max,
    int? divisions,
    String? displayFormat,
    bool enabled = true,
    void Function(double?)? onChanged,
  }) {
    return FormBuilderSlider(
      name: name,
      initialValue: initialValue,
      min: min,
      max: max,
      divisions: divisions,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
      numberFormat: displayFormat != null ? NumberFormat(displayFormat) : null,
    );
  }

  // ============================================================================
  // Validation Helpers
  // ============================================================================

  /// Required field validator
  static String? requiredValidator(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '此字段'}不能为空';
    }
    return null;
  }

  /// Email validator
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  /// Phone number validator
  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return null;

    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号码';
    }
    return null;
  }

  /// Amount validator
  static String? amountValidator(String? value, {double min = 0, double? max}) {
    if (value == null || value.isEmpty) return null;

    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '请输入有效的金额';
    }

    if (numValue < min) {
      return '金额不能小于 ${min.toStringAsFixed(2)}';
    }

    if (max != null && numValue > max) {
      return '金额不能大于 ${max.toStringAsFixed(2)}';
    }

    return null;
  }

  /// Length validator
  static String? lengthValidator(String? value, {int? min, int? max, String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (min != null && value.length < min) {
      return '${fieldName ?? '此字段'}长度不能少于$min个字符';
    }

    if (max != null && value.length > max) {
      return '${fieldName ?? '此字段'}长度不能超过$max个字符';
    }

    return null;
  }

  // ============================================================================
  // Form Actions
  // ============================================================================

  /// Build form action buttons (Cancel/Save)
  static Widget buildFormActions({
    required VoidCallback onCancel,
    required VoidCallback onSave,
    bool isLoading = false,
    String saveText = '保存',
    String cancelText = '取消',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(cancelText),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(saveText),
            ),
          ),
        ],
      ),
    );
  }

  /// Build form section header
  static Widget buildSectionHeader({
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(AppAnimations.navigatorKey.currentContext!).primaryColor,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(AppAnimations.navigatorKey.currentContext!).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// Extension Methods
// ============================================================================

extension FormBuilderExtensions on GlobalKey<FormBuilderState> {
  /// Get form data safely
  Map<String, dynamic> getFormData() {
    final state = currentState;
    if (state == null) return {};

    if (!state.saveAndValidate()) {
      throw Exception('表单验证失败');
    }

    return state.value;
  }

  /// Check if form is valid
  bool isValid() {
    final state = currentState;
    return state?.saveAndValidate() ?? false;
  }

  /// Save form without validation
  void save() {
    currentState?.save();
  }

  /// Reset form
  void reset() {
    currentState?.reset();
  }

  /// Get field value safely
  T? getFieldValue<T>(String fieldName) {
    final state = currentState;
    if (state == null) return null;

    return state.value[fieldName] as T?;
  }

  /// Set field value
  void setFieldValue(String fieldName, dynamic value) {
    final state = currentState;
    state?.fields[fieldName]?.didChange(value);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/input_validation.dart';
import 'package:your_finance_flutter/features/transaction_entry/services/validation_service.dart';

/// 输入验证状态
class InputValidationState {
  const InputValidationState({
    this.currentValidation = const InputValidation(),
    this.isValidating = false,
    this.fieldValidations = const {},
  });
  final InputValidation currentValidation;
  final bool isValidating;
  final Map<String, InputValidation> fieldValidations;

  InputValidationState copyWith({
    InputValidation? currentValidation,
    bool? isValidating,
    Map<String, InputValidation>? fieldValidations,
  }) =>
      InputValidationState(
        currentValidation: currentValidation ?? this.currentValidation,
        isValidating: isValidating ?? this.isValidating,
        fieldValidations: fieldValidations ?? this.fieldValidations,
      );
}

/// 输入验证管理器
class InputValidationNotifier extends StateNotifier<InputValidationState> {
  InputValidationNotifier({
    required ValidationService validationService,
  })  : _validationService = validationService,
        super(const InputValidationState());
  final ValidationService _validationService;

  /// 验证完整草稿
  Future<void> validateDraft(DraftTransaction draft) async {
    state = state.copyWith(isValidating: true);

    try {
      final validation = await _validationService.validateDraft(draft);
      state = state.copyWith(
        currentValidation: validation,
        isValidating: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        currentValidation: InputValidation(
          isValid: false,
          errorMessage: '验证失败: $e',
        ).copyWith(lastValidatedAt: DateTime.now()),
        isValidating: false,
      );
    }
  }

  /// 验证单个字段
  Future<void> validateField(String fieldName, Object? value) async {
    try {
      final fieldValidation =
          await _validationService.validateField(fieldName, value);
      final updatedFieldValidations =
          Map<String, InputValidation>.from(state.fieldValidations);
      updatedFieldValidations[fieldName] = fieldValidation;

      state = state.copyWith(fieldValidations: updatedFieldValidations);
    } on Exception catch (e) {
      final errorValidation = InputValidation(
        isValid: false,
        errorMessage: '字段验证失败: $e',
      ).copyWith(lastValidatedAt: DateTime.now());

      final updatedFieldValidations =
          Map<String, InputValidation>.from(state.fieldValidations);
      updatedFieldValidations[fieldName] = errorValidation;

      state = state.copyWith(fieldValidations: updatedFieldValidations);
    }
  }

  /// 批量验证多个字段
  Future<void> validateFields(Map<String, dynamic> fields) async {
    state = state.copyWith(isValidating: true);

    try {
      final validations = await _validationService.validateFields(fields);
      state = state.copyWith(
        fieldValidations: validations,
        isValidating: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        currentValidation: InputValidation(
          isValid: false,
          errorMessage: '批量验证失败: $e',
        ).copyWith(lastValidatedAt: DateTime.now()),
        isValidating: false,
      );
    }
  }

  /// 获取字段验证结果
  InputValidation? getFieldValidation(String fieldName) =>
      state.fieldValidations[fieldName];

  /// 检查所有字段是否有效
  bool areAllFieldsValid() =>
      state.fieldValidations.values.every((validation) => validation.isValid);

  /// 获取所有验证错误
  List<String> getAllErrors() {
    final errors = <String>[];

    if (!state.currentValidation.isValid &&
        state.currentValidation.errorMessage != null) {
      errors.add(state.currentValidation.errorMessage!);
    }

    for (final validation in state.fieldValidations.values) {
      if (!validation.isValid && validation.errorMessage != null) {
        errors.add(validation.errorMessage!);
      }
    }

    return errors;
  }

  /// 获取所有验证警告
  List<String> getAllWarnings() {
    final warnings = <String>[];

    warnings.addAll(state.currentValidation.warnings);

    for (final validation in state.fieldValidations.values) {
      warnings.addAll(validation.warnings);
    }

    return warnings;
  }

  /// 获取所有验证建议
  List<String> getAllSuggestions() {
    final suggestions = <String>[];

    suggestions.addAll(state.currentValidation.suggestions);

    for (final validation in state.fieldValidations.values) {
      suggestions.addAll(validation.suggestions);
    }

    return suggestions;
  }

  /// 清空验证状态
  void clearValidation() {
    state = const InputValidationState();
  }

  /// 重置字段验证
  void resetFieldValidation(String fieldName) {
    final updatedFieldValidations =
        Map<String, InputValidation>.from(state.fieldValidations);
    updatedFieldValidations.remove(fieldName);
    state = state.copyWith(fieldValidations: updatedFieldValidations);
  }
}

/// InputValidationProvider
final inputValidationProvider =
    StateNotifierProvider<InputValidationNotifier, InputValidationState>((ref) {
  final validationService = ref.watch(validationServiceProvider);
  return InputValidationNotifier(validationService: validationService);
});

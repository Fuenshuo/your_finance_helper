import 'package:equatable/equatable.dart';

/// 输入验证模型
class InputValidation extends Equatable {
  /// 是否有效
  final bool isValid;

  /// 验证错误信息
  final String? errorMessage;

  /// 验证警告信息
  final List<String> warnings;

  /// 建议的修正
  final List<String> suggestions;

  /// 最后验证时间
  final DateTime? lastValidatedAt;

  const InputValidation({
    this.isValid = true,
    this.errorMessage,
    this.warnings = const [],
    this.suggestions = const [],
    this.lastValidatedAt,
  });

  InputValidation copyWith({
    bool? isValid,
    String? errorMessage,
    List<String>? warnings,
    List<String>? suggestions,
    DateTime? lastValidatedAt,
  }) {
    return InputValidation(
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      warnings: warnings ?? this.warnings,
      suggestions: suggestions ?? this.suggestions,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt ?? DateTime.now(),
    );
  }

  /// 是否有错误
  bool get hasError => !isValid && errorMessage != null;

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  /// 是否有建议
  bool get hasSuggestions => suggestions.isNotEmpty;

  /// 是否完全通过验证（无错误、无警告）
  bool get isFullyValid => isValid && warnings.isEmpty;

  @override
  List<Object?> get props => [
        isValid,
        errorMessage,
        warnings,
        suggestions,
        lastValidatedAt,
      ];
}

/// 验证规则枚举
enum ValidationRule {
  /// 必需字段
  required('字段不能为空'),

  /// 金额格式
  amountFormat('金额格式不正确'),

  /// 金额范围
  amountRange('金额超出合理范围'),

  /// 日期格式
  dateFormat('日期格式不正确'),

  /// 日期范围
  dateRange('日期超出合理范围'),

  /// 描述长度
  descriptionLength('描述过长'),

  /// 账户存在性
  accountExists('选择的账户不存在'),

  /// 分类存在性
  categoryExists('选择的分类不存在');

  const ValidationRule(this.message);
  final String message;
}


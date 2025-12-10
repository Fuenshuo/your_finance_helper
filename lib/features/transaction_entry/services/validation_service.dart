import '../models/input_validation.dart';
import '../models/draft_transaction.dart';
import '../models/input_validation.dart';

/// 验证服务接口
abstract class ValidationService {
  /// 验证交易草稿
  Future<InputValidation> validateDraft(DraftTransaction draft);

  /// 验证单个字段
  Future<InputValidation> validateField(String fieldName, dynamic value);

  /// 批量验证字段
  Future<Map<String, InputValidation>> validateFields(Map<String, dynamic> fields);
}

/// 默认验证服务实现
class DefaultValidationService implements ValidationService {
  static const double _maxAmount = 10000000.0; // 最大金额限制
  static const double _minAmount = 0.01;       // 最小金额限制
  static const int _maxDescriptionLength = 200; // 最大描述长度
  static const int _minDescriptionLength = 1;   // 最小描述长度

  @override
  Future<InputValidation> validateDraft(DraftTransaction draft) async {
    final errors = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];

    try {
      // 验证金额
      final amountValidation = await validateField('amount', draft.amount);
      if (!amountValidation.isValid && amountValidation.errorMessage != null) {
        errors.add(amountValidation.errorMessage!);
      }
      warnings.addAll(amountValidation.warnings);
      suggestions.addAll(amountValidation.suggestions);

      // 验证描述
      final descriptionValidation = await validateField('description', draft.description);
      if (!descriptionValidation.isValid && descriptionValidation.errorMessage != null) {
        errors.add(descriptionValidation.errorMessage!);
      }
      warnings.addAll(descriptionValidation.warnings);
      suggestions.addAll(descriptionValidation.suggestions);

      // 验证交易类型
      final typeValidation = await validateField('type', draft.type);
      if (!typeValidation.isValid && typeValidation.errorMessage != null) {
        errors.add(typeValidation.errorMessage!);
      }
      warnings.addAll(typeValidation.warnings);
      suggestions.addAll(typeValidation.suggestions);

      // 验证日期
      if (draft.transactionDate != null) {
        final dateValidation = await validateField('transactionDate', draft.transactionDate);
        if (!dateValidation.isValid && dateValidation.errorMessage != null) {
          errors.add(dateValidation.errorMessage!);
        }
        warnings.addAll(dateValidation.warnings);
        suggestions.addAll(dateValidation.suggestions);
      }

      // 业务规则验证
      if (draft.amount != null && draft.amount! > 10000 && draft.type == TransactionType.expense) {
        warnings.add('大额支出建议添加详细说明');
      }

      if (draft.amount != null && draft.amount! > 50000 && draft.type == TransactionType.expense) {
        errors.add('单笔支出金额过大，请确认是否正确');
      }

      if (draft.confidence < 0.3) {
        warnings.add('解析置信度很低，建议手动检查所有信息');
      } else if (draft.confidence < 0.5) {
        suggestions.add('解析置信度较低，建议手动确认交易信息');
      }

      // 逻辑一致性检查
      if (draft.type == TransactionType.transfer && (draft.accountId == null || draft.categoryId == null)) {
        warnings.add('转账交易建议指定转出和转入账户');
      }

      return InputValidation(
        isValid: errors.isEmpty,
        errorMessage: errors.isNotEmpty ? errors.first : null,
        warnings: warnings,
        suggestions: suggestions,
        lastValidatedAt: null,
      );
    } catch (e) {
      return InputValidation(
        isValid: false,
        errorMessage: '验证过程出错: ${e.toString()}',
        lastValidatedAt: null,
      );
    }
  }

  @override
  Future<InputValidation> validateField(String fieldName, dynamic value) async {
    switch (fieldName) {
      case 'amount':
        return _validateAmount(value);
      case 'description':
        return _validateDescription(value);
      case 'type':
        return _validateTransactionType(value);
      case 'transactionDate':
        return _validateTransactionDate(value);
      case 'accountId':
        return _validateAccountId(value);
      case 'categoryId':
        return _validateCategoryId(value);
      default:
        return const InputValidation(isValid: true);
    }
  }

  @override
  Future<Map<String, InputValidation>> validateFields(Map<String, dynamic> fields) async {
    final results = <String, InputValidation>{};

    for (final entry in fields.entries) {
      results[entry.key] = await validateField(entry.key, entry.value);
    }

    return results;
  }

  InputValidation _validateAmount(dynamic value) {
    if (value == null) {
      return const InputValidation(
        isValid: false,
        errorMessage: '金额不能为空',
        suggestions: ['请输入交易金额'],
      );
    }

    if (value is! num) {
      return const InputValidation(
        isValid: false,
        errorMessage: '金额格式不正确',
        suggestions: ['请输入有效的数字金额'],
      );
    }

    final amount = value.toDouble();

    if (amount < _minAmount) {
      return InputValidation(
        isValid: false,
        errorMessage: '金额不能小于 ${_minAmount}',
        suggestions: ['请输入大于 ${_minAmount} 的金额'],
      );
    }

    if (amount > _maxAmount) {
      return InputValidation(
        isValid: false,
        errorMessage: '金额不能超过 ${_maxAmount}',
        suggestions: ['金额过大，请确认是否正确'],
      );
    }

    final warnings = <String>[];
    if (amount > 10000) {
      warnings.add('大额交易，请仔细确认');
    }

    return InputValidation(
      isValid: true,
      warnings: warnings,
      lastValidatedAt: DateTime.now(),
    );
  }

  InputValidation _validateDescription(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const InputValidation(
        isValid: false,
        errorMessage: '描述不能为空',
        suggestions: ['请输入交易描述'],
      );
    }

    final description = value.toString().trim();

    if (description.length < _minDescriptionLength) {
      return const InputValidation(
        isValid: false,
        errorMessage: '描述过短',
        suggestions: ['请输入更详细的描述'],
      );
    }

    if (description.length > _maxDescriptionLength) {
      return InputValidation(
        isValid: false,
        errorMessage: '描述过长，最多 ${_maxDescriptionLength} 个字符',
        suggestions: ['请缩短描述内容'],
      );
    }

    return InputValidation(
      isValid: true,
      lastValidatedAt: DateTime.now(),
    );
  }

  InputValidation _validateTransactionType(dynamic value) {
    if (value == null) {
      return const InputValidation(
        isValid: false,
        errorMessage: '交易类型不能为空',
        suggestions: ['请选择交易类型：收入、支出或转账'],
      );
    }

    if (value is! TransactionType) {
      return const InputValidation(
        isValid: false,
        errorMessage: '无效的交易类型',
        suggestions: ['请选择有效的交易类型'],
      );
    }

    return const InputValidation(
      isValid: true,
    ).copyWith(lastValidatedAt: DateTime.now());
  }

  InputValidation _validateTransactionDate(dynamic value) {
    if (value == null) {
      return const InputValidation(
        isValid: true, // 日期可以为空，使用默认值
        suggestions: ['未设置日期，将使用当前日期'],
      );
    }

    if (value is! DateTime) {
      return const InputValidation(
        isValid: false,
        errorMessage: '无效的日期格式',
        suggestions: ['请选择有效的日期'],
      );
    }

    final date = value as DateTime;
    final now = DateTime.now();

    // 不允许未来日期
    if (date.isAfter(now.add(const Duration(days: 1)))) {
      return const InputValidation(
        isValid: false,
        errorMessage: '不能选择未来日期',
        suggestions: ['请选择今天或之前的日期'],
      );
    }

    // 不允许太久的过去日期（比如超过10年）
    if (date.isBefore(now.subtract(const Duration(days: 365 * 10)))) {
      return const InputValidation(
        isValid: false,
        errorMessage: '日期过于久远',
        suggestions: ['请选择最近的日期'],
      );
    }

    return const InputValidation(
      isValid: true,
    ).copyWith(lastValidatedAt: DateTime.now());
  }

  InputValidation _validateAccountId(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const InputValidation(
        isValid: false,
        errorMessage: '必须选择账户',
        suggestions: ['请选择交易账户'],
      );
    }

    // 这里可以添加账户存在性检查的逻辑
    // 暂时只做基本验证

    return const InputValidation(
      isValid: true,
    ).copyWith(lastValidatedAt: DateTime.now());
  }

  InputValidation _validateCategoryId(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const InputValidation(
        isValid: false,
        errorMessage: '必须选择分类',
        suggestions: ['请选择交易分类'],
      );
    }

    // 这里可以添加分类存在性检查的逻辑
    // 暂时只做基本验证

    return const InputValidation(
      isValid: true,
    ).copyWith(lastValidatedAt: DateTime.now());
  }
}


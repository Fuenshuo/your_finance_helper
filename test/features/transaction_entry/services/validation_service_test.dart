import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/services/validation_service.dart';

void main() {
  late ValidationService validationService;

  setUp(() {
    validationService = DefaultValidationService();
  });

  group('ValidationService', () {

    test('should validate draft with low confidence', () async {
      final draft = DraftTransaction(
        amount: 100.0,
        description: '测试交易',
        type: TransactionType.expense,
        confidence: 0.2, // Low confidence
      );

      final validation = await validationService.validateDraft(draft);

      expect(validation.isValid, true);
      expect(validation.warnings, contains('解析置信度很低，建议手动检查所有信息'));
    });

    test('should reject draft without amount', () async {
      final draft = DraftTransaction(
        description: '测试交易',
        type: TransactionType.expense,
      );

      final validation = await validationService.validateDraft(draft);

      expect(validation.isValid, false);
      expect(validation.errorMessage, contains('金额不能为空'));
    });

    test('should reject draft without description', () async {
      final draft = DraftTransaction(
        amount: 100.0,
        type: TransactionType.expense,
      );

      final validation = await validationService.validateDraft(draft);

      expect(validation.isValid, false);
      expect(validation.errorMessage, contains('描述不能为空'));
    });

    test('should warn for large expense amounts', () async {
      final draft = DraftTransaction(
        amount: 15000.0,
        description: '大额支出',
        type: TransactionType.expense,
      );

      final validation = await validationService.validateDraft(draft);

      expect(validation.isValid, true);
      expect(validation.warnings, contains('大额支出建议添加详细说明'));
    });

    test('should reject extremely large amounts', () async {
      final draft = DraftTransaction(
        amount: 10000000.0,
        description: '超大金额',
        type: TransactionType.expense,
      );

      final validation = await validationService.validateDraft(draft);

      expect(validation.isValid, false);
      expect(validation.errorMessage, contains('单笔支出金额过大'));
    });

    test('should validate field individually', () async {
      final validation = await validationService.validateField('amount', 100.0);
      expect(validation.isValid, true);

      final invalidValidation = await validationService.validateField('amount', null);
      expect(invalidValidation.isValid, false);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';

void main() {
  group('DraftTransaction', () {
    test('should create draft with required fields', () {
      final draft = DraftTransaction(
        amount: 100.0,
        description: 'Test transaction',
        type: TransactionType.expense,
      );

      expect(draft.amount, 100.0);
      expect(draft.description, 'Test transaction');
      expect(draft.type, TransactionType.expense);
      expect(draft.confidence, 0.0);
      expect(draft.createdAt, isNotNull);
      expect(draft.updatedAt, isNotNull);
    });

    test('should check if draft is complete', () {
      final incompleteDraft = DraftTransaction(
        amount: 100.0,
        description: 'Test',
      );

      final completeDraft = DraftTransaction(
        amount: 100.0,
        description: 'Test',
        type: TransactionType.expense,
        accountId: 'account1',
        categoryId: 'category1',
        transactionDate: DateTime.now(),
      );

      expect(incompleteDraft.isComplete, false);
      expect(completeDraft.isComplete, true);
    });

    test('should check if draft has data', () {
      final emptyDraft = DraftTransaction();
      final draftWithData = DraftTransaction(
        amount: 50.0,
        description: 'Has data',
      );

      expect(emptyDraft.hasData, false);
      expect(draftWithData.hasData, true);
    });

    test('should copy draft with updates', () {
      final original = DraftTransaction(
        amount: 100.0,
        description: 'Original',
        type: TransactionType.expense,
      );

      final updated = original.copyWith(
        amount: 200.0,
        description: 'Updated',
      );

      expect(updated.amount, 200.0);
      expect(updated.description, 'Updated');
      expect(updated.type, TransactionType.expense);
    });
  });

  group('TransactionType', () {
    test('should parse transaction type from string', () {
      expect(
        TransactionType.values.firstWhere(
          (e) => e.name == 'expense',
          orElse: () => TransactionType.expense,
        ),
        TransactionType.expense
      );
      expect(
        TransactionType.values.firstWhere(
          (e) => e.name == 'income',
          orElse: () => TransactionType.expense,
        ),
        TransactionType.income
      );
      expect(
        TransactionType.values.firstWhere(
          (e) => e.name == 'transfer',
          orElse: () => TransactionType.expense,
        ),
        TransactionType.transfer
      );
      expect(
        TransactionType.values.firstWhere(
          (e) => e.name == 'invalid',
          orElse: () => TransactionType.expense,
        ),
        TransactionType.expense
      );
      // null case - would need different handling
    });

    test('should have correct display names', () {
      expect(TransactionType.expense.displayName, '支出');
      expect(TransactionType.income.displayName, '收入');
      expect(TransactionType.transfer.displayName, '转账');
    });
  });
}


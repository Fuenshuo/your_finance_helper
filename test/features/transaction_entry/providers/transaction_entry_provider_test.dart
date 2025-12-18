import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/input_validation.dart';
import 'package:your_finance_flutter/features/transaction_entry/providers/transaction_entry_provider.dart';
import 'package:your_finance_flutter/features/transaction_entry/services/transaction_parser_service.dart';
import 'package:your_finance_flutter/features/transaction_entry/services/validation_service.dart';

// Fake implementations for testing
class FakeTransactionParserService implements TransactionParserService {
  String? _lastInput;
  DraftTransaction? _returnValue;
  Exception? _throwException;

  void setReturnValue(DraftTransaction draft) {
    _returnValue = draft;
    _throwException = null;
  }

  void setException(Exception exception) {
    _throwException = exception;
    _returnValue = null;
  }

  String? get lastInput => _lastInput;

  @override
  Future<DraftTransaction> parseTransaction(String input) async {
    _lastInput = input;
    if (_throwException != null) {
      throw _throwException!;
    }
    return _returnValue ?? DraftTransaction(amount: 0.0);
  }

  @override
  double? parseAmount(String input) => null;

  @override
  String? parseDescription(String input) => null;

  @override
  TransactionType? inferTransactionType(String input) => null;

  @override
  double calculateConfidence(DraftTransaction draft) => 0.0;
}

class FakeValidationService implements ValidationService {
  DraftTransaction? _lastDraft;
  InputValidation? _returnValue;

  void setReturnValue(InputValidation validation) {
    _returnValue = validation;
  }

  DraftTransaction? get lastDraft => _lastDraft;

  @override
  Future<InputValidation> validateDraft(DraftTransaction draft) async {
    _lastDraft = draft;
    return _returnValue ?? const InputValidation();
  }

  @override
  Future<InputValidation> validateField(String fieldName, Object? value) async {
    return const InputValidation();
  }

  @override
  Future<Map<String, InputValidation>> validateFields(
    Map<String, dynamic> fields,
  ) async {
    return {};
  }
}

void main() {
  late FakeTransactionParserService fakeParserService;
  late FakeValidationService fakeValidationService;
  late ProviderContainer container;

  setUp(() {
    fakeParserService = FakeTransactionParserService();
    fakeValidationService = FakeValidationService();

    container = ProviderContainer(
      overrides: [
        transactionParserServiceProvider.overrideWithValue(fakeParserService),
        validationServiceProvider.overrideWithValue(fakeValidationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  tearDown(() {
    container.dispose();
  });

  group('TransactionEntryProvider', () {
    test('should initialize with default state', () {
      final state = container.read(transactionEntryProvider);

      expect(state.currentInput, '');
      expect(state.draftTransaction, isNull);
      expect(state.isParsing, false);
      expect(state.parseError, isNull);
      expect(state.isSaving, false);
      expect(state.saveError, isNull);
      expect(state.savedTransaction, isNull);
    });

    test('should update input and parse transaction', () async {
      const testInput = '今天午饭花了25元';
      final mockDraft = DraftTransaction(
        amount: 25.0,
        description: '午饭',
        type: TransactionType.expense,
        confidence: 0.8,
      );

      // Set up fake service return values
      fakeParserService.setReturnValue(mockDraft);
      fakeValidationService.setReturnValue(const InputValidation());

      final notifier = container.read(transactionEntryProvider.notifier);
      await notifier.updateInput(testInput);

      final state = container.read(transactionEntryProvider);
      expect(state.currentInput, testInput);
      expect(state.draftTransaction, isNotNull);
      expect(state.draftTransaction!.amount, 25.0);
      expect(state.isParsing, false);

      expect(fakeParserService.lastInput, testInput);
      expect(fakeValidationService.lastDraft, mockDraft);
    });

    test('should handle parsing errors gracefully', () async {
      const testInput = 'invalid input';
      const errorMessage = '解析失败';

      fakeParserService.setException(Exception(errorMessage));

      final notifier = container.read(transactionEntryProvider.notifier);
      await notifier.updateInput(testInput);

      final state = container.read(transactionEntryProvider);
      expect(state.currentInput, testInput);
      expect(state.draftTransaction, isNull);
      expect(state.parseError, contains('解析失败'));
      expect(state.isParsing, false);
    });

    test('should clear input and draft when empty input provided', () async {
      final notifier = container.read(transactionEntryProvider.notifier);

      // First set some input with mock
      final mockDraft = DraftTransaction(
        amount: 50.0,
        description: 'test',
        type: TransactionType.expense,
      );
      fakeParserService.setReturnValue(mockDraft);
      fakeValidationService.setReturnValue(const InputValidation());

      await notifier.updateInput('some input');
      var state = container.read(transactionEntryProvider);
      expect(state.currentInput, 'some input');

      // Then clear it
      await notifier.updateInput('');
      state = container.read(transactionEntryProvider);
      expect(state.currentInput, '');
      expect(state.draftTransaction, isNull);
      expect(state.parseError, isNull);
    });

    test('should confirm transaction successfully', () async {
      final mockDraft = DraftTransaction(
        amount: 100.0,
        description: '测试交易',
        type: TransactionType.expense,
        accountId: 'account1',
        categoryId: 'category1',
        transactionDate: DateTime.now(),
        confidence: 0.9,
      );

      fakeValidationService
          .setReturnValue(const InputValidation(isValid: true));

      final notifier = container.read(transactionEntryProvider.notifier);

      // Set up state with valid draft and validation
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(
                draftTransaction: mockDraft,
                validation: const InputValidation(isValid: true),
              );

      await notifier.confirmTransaction();

      final state = container.read(transactionEntryProvider);
      expect(state.isSaving, false);
      expect(state.savedTransaction, isNotNull);
      expect(state.draftTransaction, isNull);
      expect(state.currentInput, '');
      expect(state.saveError, isNull);
    });

    test('should handle confirmation errors', () async {
      // Test with incomplete draft (missing required fields)
      final incompleteDraft = DraftTransaction(
        amount: 100.0,
        description: '测试交易',
        type: TransactionType.expense,
        // Missing accountId, categoryId, transactionDate
      );

      fakeValidationService
          .setReturnValue(const InputValidation(isValid: true));

      final notifier = container.read(transactionEntryProvider.notifier);

      // Set up state with incomplete draft
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(
                draftTransaction: incompleteDraft,
                validation: const InputValidation(isValid: true),
              );

      await notifier.confirmTransaction();

      final state = container.read(transactionEntryProvider);
      expect(state.isSaving, false);
      expect(
          state.saveError, isNotNull); // Should have error for incomplete draft
      expect(state.saveError, contains('不完整'));
    });

    test('should cancel transaction', () {
      final notifier = container.read(transactionEntryProvider.notifier);

      // Set up state with some data
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(
                currentInput: 'test input',
                draftTransaction: DraftTransaction(
                  amount: 50.0,
                  description: 'test',
                  type: TransactionType.expense,
                ),
                parseError: 'some error',
              );

      notifier.cancelTransaction();

      final state = container.read(transactionEntryProvider);
      expect(state.currentInput, '');
      expect(state.draftTransaction, isNull);
      expect(state.parseError, isNull);
      expect(state.isParsing, false);
    });

    test('should update transaction field', () async {
      final mockDraft = DraftTransaction(
        amount: 100.0,
        description: '原描述',
        type: TransactionType.expense,
      );

      final updatedDraft = mockDraft.copyWith(description: '新描述');

      fakeValidationService.setReturnValue(const InputValidation());

      final notifier = container.read(transactionEntryProvider.notifier);

      // Set up initial state
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(
                draftTransaction: mockDraft,
              );

      await notifier.updateTransactionField('description', '新描述');

      final state = container.read(transactionEntryProvider);
      expect(state.draftTransaction!.description, '新描述');
      expect(state.draftTransaction!.amount, 100.0);
      expect(state.draftTransaction!.type, TransactionType.expense);

      // Verify validation was called with updated draft
      expect(fakeValidationService.lastDraft?.description, '新描述');
    });

    test('should check if transaction can be saved', () {
      final notifier = container.read(transactionEntryProvider.notifier);

      // Initial state - cannot save
      expect(notifier.canSave(), false);

      // Set up valid draft (complete with all required fields)
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(
                draftTransaction: DraftTransaction(
                  amount: 50.0,
                  description: 'valid transaction',
                  type: TransactionType.expense,
                  accountId: 'account1',
                  categoryId: 'category1',
                  transactionDate: DateTime.now(),
                ),
                validation: const InputValidation(isValid: true),
                isParsing: false,
              );

      expect(notifier.canSave(), true);

      // Set parsing state
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(isParsing: true);

      expect(notifier.canSave(), false);
    });

    test('should clear errors', () {
      final notifier = container.read(transactionEntryProvider.notifier);

      // Set up state with errors
      container.read(transactionEntryProvider.notifier).state =
          container.read(transactionEntryProvider).copyWith(
                parseError: 'parse error',
                saveError: 'save error',
                validation: const InputValidation(
                  isValid: false,
                  errorMessage: 'validation error',
                ),
              );

      notifier.clearErrors();

      final state = container.read(transactionEntryProvider);
      expect(state.parseError, isNull);
      expect(state.saveError, isNull);
      expect(state.validation.errorMessage, isNull);
    });
  });
}

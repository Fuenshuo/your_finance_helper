import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_entry_state.dart';
import '../models/draft_transaction.dart';
import '../models/input_validation.dart';
import '../services/transaction_parser_service.dart';
import '../services/validation_service.dart';

/// 交易录入页面的主要状态管理器
class TransactionEntryNotifier extends StateNotifier<TransactionEntryState> {
  final TransactionParserService _parserService;
  final ValidationService _validationService;

  TransactionEntryNotifier({
    required TransactionParserService parserService,
    required ValidationService validationService,
  }) : _parserService = parserService,
       _validationService = validationService,
       super(const TransactionEntryState());

  /// 更新输入文本并自动解析
  Future<void> updateInput(String input) async {
    state = state.copyWith(currentInput: input);

    if (input.trim().isEmpty) {
      state = state.copyWith(
        draftTransaction: null,
        validation: const InputValidation(),
        parseError: null,
      );
      return;
    }

    state = state.copyWith(isParsing: true, parseError: null);

    try {
      final startTime = DateTime.now();
      final draft = await _parserService.parseTransaction(input);
      final parseTime = DateTime.now().difference(startTime).inMilliseconds;

      final validation = await _validationService.validateDraft(draft);

      state = state.copyWith(
        draftTransaction: draft,
        validation: validation,
        isParsing: false,
        performanceMetrics: state.performanceMetrics.copyWith(
          parseResponseTimeMs: parseTime,
        ),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isParsing: false,
        parseError: e.toString(),
        validation: InputValidation(
          isValid: false,
          errorMessage: '解析失败: ${e.toString()}',
          lastValidatedAt: DateTime.now(),
        ),
      );
    }
  }

  /// 更新草稿交易
  void updateDraft(DraftTransaction draft) {
    state = state.copyWith(draftTransaction: draft);
  }

  /// 清空输入和草稿
  void clearInput() {
    state = const TransactionEntryState();
  }

  /// 重新验证当前草稿
  Future<void> revalidate() async {
    if (state.draftTransaction == null) return;

    try {
      final validation = await _validationService.validateDraft(state.draftTransaction!);
      state = state.copyWith(validation: validation);
    } on Exception catch (e) {
      state = state.copyWith(
        validation: InputValidation(
          isValid: false,
          errorMessage: '验证失败: ${e.toString()}',
        ).copyWith(lastValidatedAt: DateTime.now()),
      );
    }
  }

  /// 获取建议的修正
  List<String> getSuggestions() {
    return state.validation.suggestions;
  }

  /// 检查是否可以保存
  bool canSave() {
    return state.draftTransaction?.isValid == true &&
           state.validation.isValid &&
           !state.isParsing;
  }

  /// 确认交易并保存
  Future<void> confirmTransaction() async {
    if (state.draftTransaction == null || !state.validation.isValid) {
      return;
    }

    state = state.copyWith(isSaving: true, saveError: null);

    try {
      final startTime = DateTime.now();
      final transaction = state.draftTransaction!.toTransaction();

      // TODO: 调用实际的交易保存服务
      // await transactionService.saveTransaction(transaction);
      await Future.delayed(const Duration(milliseconds: 200)); // 模拟保存

      final saveTime = DateTime.now().difference(startTime).inMilliseconds;

      state = state.copyWith(
        isSaving: false,
        savedTransaction: transaction,
        draftTransaction: null,
        validation: const InputValidation(),
        currentInput: '',
        performanceMetrics: state.performanceMetrics.copyWith(
          lastUpdated: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: '保存失败: ${e.toString()}',
      );
    }
  }

  /// 取消当前交易
  void cancelTransaction() {
    state = state.copyWith(
      draftTransaction: null,
      validation: const InputValidation(),
      currentInput: '',
      isParsing: false,
      parseError: null,
    );
  }

  /// 更新交易字段
  Future<void> updateTransactionField(String field, dynamic value) async {
    if (state.draftTransaction == null) return;

    final updatedDraft = state.draftTransaction!.copyWith(
      amount: field == 'amount' ? value : state.draftTransaction!.amount,
      description: field == 'description' ? value : state.draftTransaction!.description,
      type: field == 'type' ? value : state.draftTransaction!.type,
      transactionDate: field == 'date' ? value : state.draftTransaction!.transactionDate,
      accountId: field == 'accountId' ? value : state.draftTransaction!.accountId,
      categoryId: field == 'categoryId' ? value : state.draftTransaction!.categoryId,
    );

    final validation = await _validationService.validateDraft(updatedDraft);

    state = state.copyWith(
      draftTransaction: updatedDraft,
      validation: validation,
    );
  }

  /// 清空错误状态
  void clearErrors() {
    state = state.copyWith(
      parseError: null,
      saveError: null,
      validation: state.validation.copyWith(errorMessage: null),
    );
  }
}

/// TransactionEntryProvider
final transactionEntryProvider = StateNotifierProvider<TransactionEntryNotifier, TransactionEntryState>((ref) {
  final parserService = ref.watch(transactionParserServiceProvider);
  final validationService = ref.watch(validationServiceProvider);

  return TransactionEntryNotifier(
    parserService: parserService,
    validationService: validationService,
  );
});


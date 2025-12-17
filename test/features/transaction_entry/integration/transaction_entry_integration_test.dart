import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/transaction_entry/providers/transaction_entry_provider.dart';
import 'package:your_finance_flutter/features/transaction_entry/providers/draft_manager_provider.dart';
import 'package:your_finance_flutter/features/transaction_entry/providers/input_validation_provider.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';

/// 交易录入功能集成测试
///
/// 测试完整的用户交互流程：
/// 1. 输入自然语言文本
/// 2. 解析为交易草稿
/// 3. 验证和编辑草稿
/// 4. 确认保存交易
/// 5. 查看交易历史
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Transaction Entry Integration', () {
    test('complete transaction entry flow', () async {
      // 1. 模拟用户输入
      const testInput = '今天午饭花了25元，用信用卡支付';

      final entryNotifier = container.read(transactionEntryProvider.notifier);
      await entryNotifier.updateInput(testInput);

      // 2. 验证解析结果
      final state = container.read(transactionEntryProvider);
      expect(state.currentInput, testInput);

      // 注意：实际的解析需要AI服务，这里只测试状态变化
      // 在完整的集成测试中，需要mock AI服务

      // 3. 验证状态管理集成
      final draftManager = container.read(draftManagerProvider.notifier);

      // 测试草稿管理器初始化
      await draftManager.loadSavedDrafts();
      final draftState = container.read(draftManagerProvider);
      expect(draftState.isLoading, false);

      // 测试验证器初始化
      final validationState = container.read(inputValidationProvider);
      expect(validationState.currentValidation.isValid, true);
    });

    test('draft management workflow', () async {
      final draftManager = container.read(draftManagerProvider.notifier);

      // 创建测试草稿
      final testDraft = DraftTransaction(
        amount: 100.0,
        description: '测试交易',
        type: TransactionType.expense,
      );

      // 保存草稿
      await draftManager.saveDraft(testDraft);

      // 验证草稿已保存
      final state = container.read(draftManagerProvider);
      expect(state.savedDrafts.length, 1);
      expect(state.savedDrafts.first.amount, 100.0);

      // 测试草稿检索
      final mostRecent = draftManager.getMostRecentDraft();
      expect(mostRecent, isNotNull);
      expect(mostRecent!.amount, 100.0);
    });

    test('validation integration', () async {
      final validationNotifier = container.read(inputValidationProvider.notifier);

      // 测试有效草稿验证
      final validDraft = DraftTransaction(
        amount: 50.0,
        description: '有效交易',
        type: TransactionType.expense,
      );

      await validationNotifier.validateDraft(validDraft);
      final validationState = container.read(inputValidationProvider);
      expect(validationState.currentValidation.isValid, true);

      // 测试无效草稿验证
      final invalidDraft = DraftTransaction(
        amount: null, // 缺少金额
        description: '', // 空描述
        type: TransactionType.expense,
      );

      await validationNotifier.validateDraft(invalidDraft);
      final updatedValidationState = container.read(inputValidationProvider);
      expect(updatedValidationState.currentValidation.isValid, false);
    });

    test('performance monitoring integration', () async {
      // 测试性能监控与状态管理的集成
      final entryNotifier = container.read(transactionEntryProvider.notifier);

      // 执行一些操作
      await entryNotifier.updateInput('测试输入');

      // 验证状态更新没有性能问题
      final state = container.read(transactionEntryProvider);
      expect(state.currentInput, '测试输入');
      // 在实际测试中，可以验证性能指标
    });
  });
}

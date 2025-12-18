import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';
import 'package:your_finance_flutter/features/transaction_entry/providers/draft_manager_provider.dart';
import 'package:your_finance_flutter/features/transaction_entry/services/draft_persistence_service.dart';

// Mock class
class MockDraftPersistenceService extends Mock
    implements DraftPersistenceService {}

void main() {
  late MockDraftPersistenceService mockPersistenceService;
  late ProviderContainer container;

  setUp(() {
    mockPersistenceService = MockDraftPersistenceService();
    container = ProviderContainer(
      overrides: [
        draftPersistenceServiceProvider
            .overrideWithValue(mockPersistenceService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DraftManagerProvider', () {
    test('should initialize with empty state', () {
      final state = container.read(draftManagerProvider);

      expect(state.savedDrafts, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should load saved drafts successfully', () async {
      final mockDrafts = [
        DraftTransaction(
          amount: 100.0,
          description: '测试交易1',
          type: TransactionType.expense,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        DraftTransaction(
          amount: 200.0,
          description: '测试交易2',
          type: TransactionType.income,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      when(mockPersistenceService.loadAllDrafts())
          .thenAnswer((_) async => mockDrafts);

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.loadSavedDrafts();

      final state = container.read(draftManagerProvider);
      expect(state.isLoading, false);
      expect(state.savedDrafts.length, 2);
      expect(state.savedDrafts[0].amount, 100.0);
      expect(state.savedDrafts[1].amount, 200.0);
      expect(state.error, isNull);

      verify(mockPersistenceService.loadAllDrafts()).called(1);
    });

    test('should handle loading errors', () async {
      const errorMessage = '加载失败';

      when(mockPersistenceService.loadAllDrafts())
          .thenThrow(Exception(errorMessage));

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.loadSavedDrafts();

      final state = container.read(draftManagerProvider);
      expect(state.isLoading, false);
      expect(state.savedDrafts, isEmpty);
      expect(state.error, contains(errorMessage));
    });

    test('should save draft successfully', () async {
      final draft = DraftTransaction(
        amount: 150.0,
        description: '新草稿',
        type: TransactionType.expense,
      );

      final savedDraft = draft.copyWith(updatedAt: DateTime.now());

      when(mockPersistenceService.saveDraft(draft))
          .thenAnswer((_) async => savedDraft);

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.saveDraft(draft);

      final state = container.read(draftManagerProvider);
      expect(state.savedDrafts.length, 1);
      expect(state.savedDrafts[0].amount, 150.0);
      expect(state.error, isNull);

      verify(mockPersistenceService.saveDraft(draft)).called(1);
    });

    test('should update existing draft when saving', () async {
      final existingDraft = DraftTransaction(
        amount: 100.0,
        description: '原有草稿',
        type: TransactionType.expense,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final updatedDraft = existingDraft.copyWith(
        description: '更新后的草稿',
        updatedAt: DateTime.now(),
      );

      // Set up initial state
      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(
        savedDrafts: [existingDraft],
      );

      when(mockPersistenceService.saveDraft(updatedDraft))
          .thenAnswer((_) async => updatedDraft);

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.saveDraft(updatedDraft);

      final state = container.read(draftManagerProvider);
      expect(state.savedDrafts.length, 1);
      expect(state.savedDrafts[0].description, '更新后的草稿');
    });

    test('should handle save errors', () async {
      final draft = DraftTransaction(
        amount: 50.0,
        description: '测试草稿',
        type: TransactionType.expense,
      );

      const errorMessage = '保存失败';

      when(mockPersistenceService.saveDraft(draft))
          .thenThrow(Exception(errorMessage));

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.saveDraft(draft);

      final state = container.read(draftManagerProvider);
      expect(state.error, contains(errorMessage));
    });

    test('should delete draft successfully', () async {
      final draft = DraftTransaction(
        amount: 100.0,
        description: '要删除的草稿',
        type: TransactionType.expense,
      );

      // Set up initial state with the draft
      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(
        savedDrafts: [draft],
      );

      when(mockPersistenceService.deleteDraft(draft))
          .thenAnswer((_) async => {});

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.deleteDraft(draft);

      final state = container.read(draftManagerProvider);
      expect(state.savedDrafts, isEmpty);

      verify(mockPersistenceService.deleteDraft(draft)).called(1);
    });

    test('should handle delete errors', () async {
      final draft = DraftTransaction(
        amount: 75.0,
        description: '测试草稿',
        type: TransactionType.expense,
      );

      const errorMessage = '删除失败';

      when(mockPersistenceService.deleteDraft(draft))
          .thenThrow(Exception(errorMessage));

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.deleteDraft(draft);

      final state = container.read(draftManagerProvider);
      expect(state.error, contains(errorMessage));
    });

    test('should clear all drafts', () async {
      final drafts = [
        DraftTransaction(
            amount: 50.0, description: '草稿1', type: TransactionType.expense),
        DraftTransaction(
            amount: 75.0, description: '草稿2', type: TransactionType.expense),
      ];

      // Set up initial state
      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(savedDrafts: drafts);

      when(mockPersistenceService.clearAllDrafts()).thenAnswer((_) async => {});

      final notifier = container.read(draftManagerProvider.notifier);
      await notifier.clearAllDrafts();

      final state = container.read(draftManagerProvider);
      expect(state.savedDrafts, isEmpty);

      verify(mockPersistenceService.clearAllDrafts()).called(1);
    });

    test('should return most recent draft', () {
      final oldDraft = DraftTransaction(
        amount: 50.0,
        description: '旧草稿',
        type: TransactionType.expense,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final recentDraft = DraftTransaction(
        amount: 100.0,
        description: '新草稿',
        type: TransactionType.expense,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      // Set up state with multiple drafts
      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(
        savedDrafts: [oldDraft, recentDraft],
      );

      final notifier = container.read(draftManagerProvider.notifier);
      final mostRecent = notifier.getMostRecentDraft();

      expect(mostRecent, isNotNull);
      expect(mostRecent!.amount, 100.0);
      expect(mostRecent.description, '新草稿');
    });

    test('should return null when no drafts exist', () {
      final notifier = container.read(draftManagerProvider.notifier);
      final mostRecent = notifier.getMostRecentDraft();

      expect(mostRecent, isNull);
    });

    test('should return correct draft count', () {
      final drafts = [
        DraftTransaction(
            amount: 25.0, description: '草稿1', type: TransactionType.expense),
        DraftTransaction(
            amount: 50.0, description: '草稿2', type: TransactionType.expense),
        DraftTransaction(
            amount: 75.0, description: '草稿3', type: TransactionType.expense),
      ];

      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(savedDrafts: drafts);

      final notifier = container.read(draftManagerProvider.notifier);
      expect(notifier.draftCount, 3);
    });

    test('should detect unsaved draft changes', () {
      final savedDraft = DraftTransaction(
        amount: 100.0,
        description: '已保存草稿',
        type: TransactionType.expense,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final currentDraft = DraftTransaction(
        amount: 100.0,
        description: '当前草稿', // 描述不同
        type: TransactionType.expense,
        updatedAt: DateTime.now(),
      );

      // Set up state with saved draft
      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(
        savedDrafts: [savedDraft],
      );

      final notifier = container.read(draftManagerProvider.notifier);
      final hasUnsavedChanges = notifier.hasUnsavedDraft(currentDraft);

      expect(hasUnsavedChanges, true);
    });

    test('should not detect changes for identical drafts', () {
      final draft = DraftTransaction(
        amount: 100.0,
        description: '相同草稿',
        type: TransactionType.expense,
        updatedAt: DateTime.now(),
      );

      // Set up state with the same draft
      container.read(draftManagerProvider.notifier).state =
          container.read(draftManagerProvider).copyWith(
        savedDrafts: [draft],
      );

      final notifier = container.read(draftManagerProvider.notifier);
      final hasUnsavedChanges = notifier.hasUnsavedDraft(draft);

      expect(hasUnsavedChanges, false);
    });
  });
}

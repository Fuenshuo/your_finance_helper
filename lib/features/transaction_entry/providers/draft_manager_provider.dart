import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/draft_transaction.dart';
import '../services/draft_persistence_service.dart';

/// 草稿管理状态
class DraftManagerState {
  final List<DraftTransaction> savedDrafts;
  final bool isLoading;
  final String? error;

  const DraftManagerState({
    this.savedDrafts = const [],
    this.isLoading = false,
    this.error,
  });

  DraftManagerState copyWith({
    List<DraftTransaction>? savedDrafts,
    bool? isLoading,
    String? error,
  }) {
    return DraftManagerState(
      savedDrafts: savedDrafts ?? this.savedDrafts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 草稿管理器
class DraftManagerNotifier extends StateNotifier<DraftManagerState> {
  final DraftPersistenceService _persistenceService;

  DraftManagerNotifier({
    required DraftPersistenceService persistenceService,
  })  : _persistenceService = persistenceService,
        super(const DraftManagerState());

  /// 加载保存的草稿
  Future<void> loadSavedDrafts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final drafts = await _persistenceService.loadAllDrafts();
      state = state.copyWith(
        savedDrafts: drafts,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载草稿失败: ${e.toString()}',
      );
    }
  }

  /// 保存草稿
  Future<void> saveDraft(DraftTransaction draft) async {
    try {
      final savedDraft = await _persistenceService.saveDraft(draft);
      final updatedDrafts = [...state.savedDrafts];

      // 检查是否已存在相同ID的草稿
      final existingIndex =
          updatedDrafts.indexWhere((d) => d.createdAt == draft.createdAt);
      if (existingIndex >= 0) {
        updatedDrafts[existingIndex] = savedDraft;
      } else {
        updatedDrafts.add(savedDraft);
      }

      state = state.copyWith(savedDrafts: updatedDrafts);
    } on Exception catch (e) {
      state = state.copyWith(error: '保存草稿失败: ${e.toString()}');
    }
  }

  /// 删除草稿
  Future<void> deleteDraft(DraftTransaction draft) async {
    try {
      await _persistenceService.deleteDraft(draft);
      final updatedDrafts = state.savedDrafts.where((d) => d != draft).toList();
      state = state.copyWith(savedDrafts: updatedDrafts);
    } on Exception catch (e) {
      state = state.copyWith(error: '删除草稿失败: ${e.toString()}');
    }
  }

  /// 清空所有草稿
  Future<void> clearAllDrafts() async {
    try {
      await _persistenceService.clearAllDrafts();
      state = state.copyWith(savedDrafts: const []);
    } on Exception catch (e) {
      state = state.copyWith(error: '清空草稿失败: ${e.toString()}');
    }
  }

  /// 获取最近的草稿
  DraftTransaction? getMostRecentDraft() {
    if (state.savedDrafts.isEmpty) return null;
    return state.savedDrafts
        .reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
  }

  /// 获取草稿数量
  int get draftCount => state.savedDrafts.length;

  /// 检查是否有未保存的草稿
  bool hasUnsavedDraft(DraftTransaction currentDraft) {
    return state.savedDrafts.any((saved) =>
        saved.updatedAt != currentDraft.updatedAt &&
        _areDraftsSimilar(saved, currentDraft));
  }

  /// 比较两个草稿是否相似
  bool _areDraftsSimilar(DraftTransaction a, DraftTransaction b) {
    return a.amount == b.amount &&
        a.description == b.description &&
        a.type == b.type &&
        a.accountId == b.accountId &&
        a.categoryId == b.categoryId;
  }
}

/// DraftManagerProvider
final draftManagerProvider =
    StateNotifierProvider<DraftManagerNotifier, DraftManagerState>((ref) {
  final persistenceService = ref.watch(draftPersistenceServiceProvider);
  return DraftManagerNotifier(persistenceService: persistenceService);
});

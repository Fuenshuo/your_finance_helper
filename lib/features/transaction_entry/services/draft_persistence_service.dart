import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';

/// 草稿持久化服务接口
abstract class DraftPersistenceService {
  /// 保存草稿
  Future<DraftTransaction> saveDraft(DraftTransaction draft);

  /// 加载所有草稿
  Future<List<DraftTransaction>> loadAllDrafts();

  /// 根据ID加载草稿
  Future<DraftTransaction?> loadDraft(String id);

  /// 删除草稿
  Future<void> deleteDraft(DraftTransaction draft);

  /// 清空所有草稿
  Future<void> clearAllDrafts();

  /// 获取草稿数量
  Future<int> getDraftCount();
}

/// 默认草稿持久化服务实现
class DefaultDraftPersistenceService implements DraftPersistenceService {
  DefaultDraftPersistenceService({
    Future<SharedPreferences>? prefsFuture,
  }) : _prefsFuture = prefsFuture ?? SharedPreferences.getInstance();
  static const String _draftsKey = 'transaction_drafts';
  static const int _maxDrafts = 50; // 最大保存草稿数量

  final Future<SharedPreferences> _prefsFuture;

  @override
  Future<DraftTransaction> saveDraft(DraftTransaction draft) async {
    try {
      final prefs = await _prefsFuture;
      final drafts = await loadAllDrafts();

      // 更新或添加草稿
      final existingIndex =
          drafts.indexWhere((d) => d.createdAt == draft.createdAt);
      if (existingIndex >= 0) {
        drafts[existingIndex] = draft.copyWith(updatedAt: DateTime.now());
      } else {
        drafts.add(draft);
      }

      // 限制草稿数量，保留最新的
      if (drafts.length > _maxDrafts) {
        drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        drafts.removeRange(_maxDrafts, drafts.length);
      }

      // 序列化并保存
      final draftsJson = drafts.map(_draftToJson).toList();
      final jsonString = jsonEncode(draftsJson);

      // 使用安全存储保存敏感数据
      final encryptedData = await _encryptData(jsonString);
      await prefs.setString(_draftsKey, encryptedData);

      return draft;
    } catch (e) {
      throw Exception('保存草稿失败: $e');
    }
  }

  @override
  Future<List<DraftTransaction>> loadAllDrafts() async {
    try {
      final prefs = await _prefsFuture;
      final encryptedData = prefs.getString(_draftsKey);

      if (encryptedData == null || encryptedData.isEmpty) {
        return [];
      }

      final decryptedData = await _decryptData(encryptedData);
      final draftsJson = jsonDecode(decryptedData) as List<dynamic>;

      final drafts = draftsJson
          .map((json) => _draftFromJson(json as Map<String, dynamic>))
          .where((draft) => draft.hasData) // 只返回有数据的草稿
          .toList();

      // 按更新时间倒序排列
      drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return drafts;
    } catch (e) {
      // 如果解密或解析失败，返回空列表并记录错误
      debugPrint('加载草稿失败: $e');
      return [];
    }
  }

  @override
  Future<DraftTransaction?> loadDraft(String id) async {
    final drafts = await loadAllDrafts();
    return drafts.cast<DraftTransaction?>().firstWhere(
          (draft) => draft?.createdAt.toIso8601String() == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> deleteDraft(DraftTransaction draft) async {
    final prefs = await _prefsFuture;
    final drafts = await loadAllDrafts();

    drafts.removeWhere((d) => d.createdAt == draft.createdAt);

    final draftsJson = drafts.map(_draftToJson).toList();
    final encryptedData = await _encryptData(jsonEncode(draftsJson));

    await prefs.setString(_draftsKey, encryptedData);
  }

  @override
  Future<void> clearAllDrafts() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_draftsKey);
  }

  @override
  Future<int> getDraftCount() async {
    final drafts = await loadAllDrafts();
    return drafts.length;
  }

  /// 加密数据 (简单的base64编码，实际项目中应使用更强的加密)
  Future<String> _encryptData(String data) async {
    // 注意：这是一个简化的实现
    // 在生产环境中，应该使用更强的加密算法
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  /// 解密数据
  Future<String> _decryptData(String encryptedData) async {
    try {
      final bytes = base64Decode(encryptedData);
      return utf8.decode(bytes);
    } catch (e) {
      throw const FormatException('数据解密失败');
    }
  }

  /// 将DraftTransaction转换为JSON
  Map<String, dynamic> _draftToJson(DraftTransaction draft) => {
        'amount': draft.amount,
        'description': draft.description,
        'type': draft.type?.name,
        'accountId': draft.accountId,
        'categoryId': draft.categoryId,
        'transactionDate': draft.transactionDate?.toIso8601String(),
        'tags': draft.tags,
        'isExpense': draft.isExpense,
        'confidence': draft.confidence,
        'createdAt': draft.createdAt.toIso8601String(),
        'updatedAt': draft.updatedAt.toIso8601String(),
      };

  /// 从JSON创建DraftTransaction
  DraftTransaction _draftFromJson(Map<String, dynamic> json) =>
      DraftTransaction(
        amount: json['amount'] as double?,
        description: json['description'] as String?,
        type: json['type'] != null
            ? TransactionType.values.firstWhere(
                (e) => e.name == json['type'],
                orElse: () => TransactionType.expense,
              )
            : null,
        accountId: json['accountId'] as String?,
        categoryId: json['categoryId'] as String?,
        transactionDate: json['transactionDate'] != null
            ? DateTime.parse(json['transactionDate'] as String)
            : null,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
        isExpense: json['isExpense'] as bool?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// DraftPersistenceService Provider
final draftPersistenceServiceProvider = Provider<DraftPersistenceService>(
    (ref) => DefaultDraftPersistenceService());

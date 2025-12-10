import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import '../providers/transaction_entry_provider.dart';
import '../providers/draft_manager_provider.dart';
import '../providers/input_validation_provider.dart';
import 'input_dock/input_dock.dart';
import 'draft_card/draft_card.dart';
import 'timeline/timeline_view.dart';

/// 统一交易录入页面主组件
///
/// 这是交易录入功能的核心UI组件，整合了以下功能：
/// - 自然语言输入面板 (InputDock)
/// - 智能草稿显示卡片 (DraftCard)
/// - 交易历史时间线 (TimelineView)
/// - 自动保存和恢复草稿
/// - 性能监控和错误处理
///
/// 架构特点：
/// - 使用Riverpod进行状态管理
/// - 支持横竖屏适配
/// - 集成性能监控
/// - 错误边界处理
class TransactionEntryScreen extends ConsumerStatefulWidget {
  const TransactionEntryScreen({super.key});

  @override
  ConsumerState<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends ConsumerState<TransactionEntryScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 加载保存的草稿
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(draftManagerProvider.notifier).loadSavedDrafts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 应用暂停时自动保存当前草稿
      _autoSaveDraft();
    }
  }

  void _autoSaveDraft() {
    final entryState = ref.read(transactionEntryProvider);
    if (entryState.draftTransaction?.hasData == true) {
      ref.read(draftManagerProvider.notifier).saveDraft(entryState.draftTransaction!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor.monitorBuild(
      'TransactionEntryScreen',
      () => _buildUnifiedContent(context),
    );
  }

  Widget _buildUnifiedContent(BuildContext context) {
    final entryState = ref.watch(transactionEntryProvider);
    final draftState = ref.watch(draftManagerProvider);
    final validationState = ref.watch(inputValidationProvider);

    final viewInsets = MediaQuery.of(context).padding;
    final dockBottom = kBottomNavigationBarHeight + viewInsets.bottom + 8;
    final cardBottom = dockBottom + 150;
    final scrollBottomPadding = dockBottom + 260;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              // 主内容区域
              Positioned.fill(
                child: Column(
                  children: [
                    // 时间线视图
                    Expanded(
                      child: TimelineView(
                        drafts: draftState.savedDrafts,
                        onDraftSelected: (draft) {
                          ref.read(transactionEntryProvider.notifier).updateDraft(draft);
                          // 重新验证选中的草稿
                          ref.read(inputValidationProvider.notifier).validateDraft(draft);
                        },
                        onDraftDeleted: (draft) {
                          ref.read(draftManagerProvider.notifier).deleteDraft(draft);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 草稿卡片（如果有解析结果）
              if (entryState.draftTransaction != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: cardBottom,
                  child: DraftCard(
                    draft: entryState.draftTransaction!,
                    validation: entryState.validation,
                    isParsing: entryState.isParsing,
                  ),
                ),

              // 输入停靠栏
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: InputDock(),
              ),

              // Toast提示覆盖层
              _buildToastOverlay(context),
            ],
          ),

          // 浮动操作按钮 - 显示验证状态
          floatingActionButton: _buildValidationIndicator(validationState),
        ),
      ),
    );
  }

  Widget _buildValidationIndicator(InputValidationState validationState) {
    if (validationState.currentValidation.isFullyValid) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: 实现保存逻辑
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check),
      );
    }

    if (!validationState.currentValidation.isValid) {
      return FloatingActionButton(
        onPressed: () {
          // 显示错误详情
          _showValidationErrors(validationState);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.error),
      );
    }

    // 有警告的情况
    if (validationState.currentValidation.hasWarnings) {
      return FloatingActionButton(
        onPressed: () {
          _showValidationWarnings(validationState);
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.warning),
      );
    }

    // 默认状态
    return const SizedBox.shrink();
  }

  void _showValidationErrors(InputValidationState validationState) {
    final errors = validationState.currentValidation.errorMessage ?? '未知错误';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('验证错误: $errors'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '查看详情',
          textColor: Colors.white,
          onPressed: () {
            // TODO: 显示详细错误对话框
          },
        ),
      ),
    );
  }

  void _showValidationWarnings(InputValidationState validationState) {
    final warnings = validationState.currentValidation.warnings.join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('验证警告: $warnings'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildToastOverlay(BuildContext context) {
    // 简化的Toast覆盖层实现
    // 在实际实现中，这里应该包含更复杂的Toast管理逻辑
    return const SizedBox.shrink();
  }
}


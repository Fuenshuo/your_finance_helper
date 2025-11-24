import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/parsed_transaction.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/invoice_recognition_service.dart';
import 'package:your_finance_flutter/core/services/ai/natural_language_transaction_service.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

/// Tag状态枚举（流体预判状态机）
enum TagState {
  idle, // 空闲状态
  loading, // 首次加载（显示幽灵骨架）
  refreshing, // 增量更新（保留卡片，显示渐变覆盖）
  success, // 成功（显示真实Tag）
}

/// iOS "Super Box" 统一记账入口 V2
/// 核心理念：去框化、沉浸式对话、输入流思维、AI实时反馈
class UnifiedTransactionEntryScreenV2 extends StatefulWidget {
  const UnifiedTransactionEntryScreenV2({super.key});

  /// 显示键盘伴侣模式入口（Bottom-First Design）
  /// 所有交互下沉到键盘上方，像发微信一样自然
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent, // 完全透明背景
        barrierColor: Colors.black.withOpacity(0.3), // 半透明遮罩
        enableDrag: false, // 禁用拖拽关闭
        builder: (context) => const UnifiedTransactionEntryScreenV2(),
      );

  @override
  State<UnifiedTransactionEntryScreenV2> createState() =>
      _UnifiedTransactionEntryScreenV2State();
}

class _UnifiedTransactionEntryScreenV2State
    extends State<UnifiedTransactionEntryScreenV2>
    with TickerProviderStateMixin {
  static const double _previewCardMinHeight = 190;

  // 统一文本输入框（合并金额和描述）
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  late final Future<NaturalLanguageTransactionService> _nlServiceFuture;
  bool _isLoading = false;

  // AI解析结果（完整保存）
  ParsedTransaction? _aiResult;

  // 防抖和请求去重
  Timer? _parseTimer;
  String? _lastRequestedDescription;

  // Tag状态机（流体预判）
  TagState _tagState = TagState.idle;

  // 账户推荐（本地预测）
  List<Account>? _recommendedAccounts;

  // 最近一次被解析的原始语句快照（用于展示/再次编辑）
  String? _rawInputSnapshot;

  // 控制 TextField 监听器在我们主动清空/填充时不要重置状态
  bool _suppressTextListener = false;

  // 动态加载提示（终端风格）
  Timer? _loadingMessageTimer;
  int _loadingMessageIndex = 0;
  static const List<String> _loadingMessages = [
    '正在识别...',
    '这可能需要一会，请耐心等待...',
    'AI 正在思考中...',
    '让我想想...',
    '正在分析你的输入...',
    '稍等片刻...',
    '正在理解你的意图...',
    '马上就好...',
  ];

  // 空闲状态提示（使用范例，教用户怎么用）
  Timer? _idleMessageTimer;
  int _idleMessageIndex = 0;
  static const List<String> _idleMessages = [
    '试试：星巴克两杯拿铁 70',
    '试试：发工资了 25000',
    '试试：打车去公司 35',
    '试试：交房租 4000',
    '试试：淘宝买衣服 200',
    '试试：年终奖 50000',
    '试试：买菜花了 85',
    '试试：转账给朋友 500',
  ];

  @override
  void initState() {
    super.initState();
    _nlServiceFuture = NaturalLanguageTransactionService.getInstance();

    // 监听输入变化
    _textController.addListener(_onTextChanged);

    // 自动聚焦文本输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
      // 启动空闲状态提示轮播
      _startIdleMessageRotation();
    });
  }

  @override
  void dispose() {
    _parseTimer?.cancel();
    _loadingMessageTimer?.cancel();
    _idleMessageTimer?.cancel();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  /// 显示OCR选项（拍照或相册）
  Future<void> _showOcrOptions() async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIcons.camera(),
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                const Text('拍照识别'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'gallery'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIcons.image(),
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                const Text('从相册选择'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );

    if (choice == null) return;

    try {
      final imageService = ImageProcessingService.getInstance();
      File? imageFile;

      if (choice == 'camera') {
        imageFile = await imageService.takePhoto();
      } else if (choice == 'gallery') {
        imageFile = await imageService.pickImageFromGallery();
      }

      if (imageFile == null) return;

      // 显示识别中状态
      setState(() {
        _tagState = TagState.loading;
      });

      // 调用OCR识别
      final invoiceService = await InvoiceRecognitionService.getInstance();
      final accountProvider = context.read<AccountProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final parsed = await invoiceService.recognizeInvoice(
        imageFile: imageFile,
        accounts: accountProvider.accounts,
        budgets: budgetProvider.envelopeBudgets,
      );

      // 将识别结果填充到输入框
      if (mounted) {
        final recognizedSentence = [
          parsed.description ?? '',
          if (parsed.amount != null) parsed.amount!.toStringAsFixed(0),
        ].where((element) => element.isNotEmpty).join(' ');

        setState(() {
          _aiResult = parsed;
          _tagState = TagState.success;
          _rawInputSnapshot = recognizedSentence.isNotEmpty
              ? recognizedSentence
              : _rawInputSnapshot;
        });

        _clearTextControllerSafely();

        HapticFeedback.lightImpact();

        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              parsed.isValid ? '识别成功！已自动填充' : '识别完成，请补充缺失信息',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tagState = TagState.idle;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('识别失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 启动空闲状态提示轮播（6秒切换一次，降低视觉干扰）
  void _startIdleMessageRotation() {
    _idleMessageTimer?.cancel();
    _idleMessageTimer =
        Timer.periodic(const Duration(milliseconds: 6000), (timer) {
      if (mounted &&
          _textController.text.trim().isEmpty &&
          _tagState != TagState.loading) {
        setState(() {
          _idleMessageIndex = (_idleMessageIndex + 1) % _idleMessages.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// 停止空闲状态提示轮播
  void _stopIdleMessageRotation() {
    _idleMessageTimer?.cancel();
  }

  /// 文本输入变化处理（带防抖和请求去重）
  void _onTextChanged() {
    if (_suppressTextListener) {
      return;
    }

    // 取消之前的定时器
    _parseTimer?.cancel();

    final trimmedValue = _textController.text.trim();

    // 如果描述为空，区分是否处于已有结果的补录阶段
    if (trimmedValue.isEmpty) {
      _parseTimer?.cancel();

      if (_aiResult == null) {
        setState(() {
          _tagState = TagState.idle;
          _lastRequestedDescription = null; // 清除请求记录，允许重新识别
          _recommendedAccounts = null;
          _rawInputSnapshot = null;
        });
        // 重新启动空闲状态提示轮播
        _startIdleMessageRotation();
      } else {
        // 有识别结果时保持卡片展示，仅清空输入缓冲
        setState(() {
          _tagState = TagState.success;
          if (_rawInputSnapshot != null && _rawInputSnapshot!.isNotEmpty) {
            _lastRequestedDescription = _rawInputSnapshot;
          } else {
            _lastRequestedDescription = null;
          }
        });
        // 补录模式下无需重启 idle 提示
        _stopIdleMessageRotation();
      }
      return;
    }

    // 有输入时停止空闲状态提示轮播
    _stopIdleMessageRotation();

    // 至少2个字符才识别（支持"淘宝"、"工资"等常见输入）
    if (trimmedValue.length < 2) {
      return;
    }

    final prospectiveInput = _composeRecognitionInput(trimmedValue);
    if (prospectiveInput.isEmpty) {
      return;
    }

    // 如果和上次请求的描述相同，且已有AI结果，不重复请求
    // 但如果用户删除了内容又重新输入，应该允许重新识别
    if (prospectiveInput == _lastRequestedDescription && _aiResult != null) {
      return;
    }

    // 设置防抖定时器（800ms，符合V3方案要求）
    _parseTimer = Timer(const Duration(milliseconds: 800), () {
      // 再次检查文本是否仍然有效且与当前输入一致
      if (mounted && _textController.text.trim() == trimmedValue) {
        _parseText(trimmedValue);
      }
    });
  }

  /// 解析文本（带请求去重）
  Future<void> _parseText(String text) async {
    if (text.isEmpty) return;

    // 检查文本是否仍然有效（用户可能已经继续输入了）
    if (!mounted || _textController.text.trim() != text) {
      return;
    }

    final effectiveText = _composeRecognitionInput(text);
    if (effectiveText.isEmpty) {
      return;
    }

    final isAppendingFlow = (_rawInputSnapshot?.isNotEmpty ?? false) &&
        _aiResult != null &&
        text.isNotEmpty;

    // 记录本次请求的文本，避免重复请求
    _lastRequestedDescription = effectiveText;

    // AI思考中：首次解析显示骨架，增量解析保持卡片
    setState(() {
      _tagState = isAppendingFlow ? TagState.refreshing : TagState.loading;
      _loadingMessageIndex = 0; // 重置提示索引
    });

    // 启动动态提示轮播（仅首次加载需要）
    _loadingMessageTimer?.cancel();
    if (!isAppendingFlow) {
      _loadingMessageTimer =
          Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (mounted && _tagState == TagState.loading) {
          setState(() {
            _loadingMessageIndex =
                (_loadingMessageIndex + 1) % _loadingMessages.length;
          });
        } else {
          timer.cancel();
        }
      });
    }

    try {
      final nlService = await _nlServiceFuture;
      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final accounts = accountProvider.accounts;
      final budgets = budgetProvider.envelopeBudgets;
      final userHistory = transactionProvider.transactions.take(20).toList();

      final result = await nlService.parseTransaction(
        input: effectiveText,
        userHistory: userHistory,
        accounts: accounts,
        budgets: budgets,
      );

      // 再次检查文本是否仍然有效
      if (mounted && _textController.text.trim() == text) {
        // 停止动态提示轮播
        _loadingMessageTimer?.cancel();

        final shouldSnapshotInput =
            result.parsed.amount != null && result.parsed.amount! > 0;
        final shouldTriggerHaptic =
            _tagState == TagState.refreshing || _tagState == TagState.loading;

        setState(() {
          _aiResult = result.parsed;
          _tagState = TagState.success; // AI思考完成，切换到success状态

          // 调试日志：检查金额识别
          print(
            '[UnifiedTransactionEntryScreenV2._parseText] 💰 AI识别结果: amount=${result.parsed.amount}, category=${result.parsed.category}, accountId=${result.parsed.accountId}',
          );

          // 本地预测：如果识别出分类但缺少账户，计算推荐账户
          if (result.parsed.category != null &&
              result.parsed.accountId == null) {
            _recommendedAccounts = _calculateRecommendedAccounts(
              result.parsed.category!,
              accounts,
              userHistory,
            );
          } else {
            _recommendedAccounts = null; // 如果账户已识别，清除推荐
          }

          if (shouldSnapshotInput || isAppendingFlow) {
            _rawInputSnapshot = effectiveText;
          }
        });

        if (shouldTriggerHaptic) {
          HapticFeedback.lightImpact();
        }

        if ((shouldSnapshotInput || isAppendingFlow) && text.isNotEmpty) {
          _clearTextControllerSafely();
        }
      }
    } catch (e) {
      // 静默失败，不影响输入体验
      // 停止动态提示轮播
      _loadingMessageTimer?.cancel();

      if (mounted) {
        setState(() {
          _tagState = TagState.idle; // 失败时回到idle状态
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    final currentText = _textController.text.trim();
    final hasSnapshot = _rawInputSnapshot?.isNotEmpty ?? false;
    final isAppendFlow =
        _aiResult != null && hasSnapshot && currentText.isNotEmpty;

    final effectiveInput = isAppendFlow
        ? _composeRecognitionInput(currentText)
        : (currentText.isNotEmpty ? currentText : (_rawInputSnapshot ?? ''));

    if (effectiveInput.isEmpty && !_canQuickConfirm) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 如果已经有AI解析结果，直接使用；否则重新解析
      ParsedTransaction finalParsed;
      final shouldReparse = isAppendFlow ||
          _aiResult == null ||
          _aiResult!.amount == null ||
          _aiResult!.amount! <= 0;

      if (!shouldReparse && _aiResult != null) {
        finalParsed = _aiResult!;
      } else {
        // 重新解析文本

        // 获取上下文数据
        final transactionProvider = context.read<TransactionProvider>();
        final accountProvider = context.read<AccountProvider>();
        final budgetProvider = context.read<BudgetProvider>();

        final accounts = accountProvider.accounts;
        final budgets = budgetProvider.envelopeBudgets;
        final userHistory = transactionProvider.transactions.take(20).toList();

        // 解析交易
        final nlService = await _nlServiceFuture;
        final result = await nlService.parseTransaction(
          input: effectiveInput,
          userHistory: userHistory,
          accounts: accounts,
          budgets: budgets,
        );

        finalParsed = result.parsed;
      }

      // 确保有金额
      if (finalParsed.amount == null || finalParsed.amount! <= 0) {
        // 尝试从文本中提取金额
        final amountMatch =
            RegExp(r'(\d+(?:\.\d+)?)').firstMatch(effectiveInput);
        if (amountMatch != null) {
          final amount = double.tryParse(amountMatch.group(1) ?? '');
          if (amount != null && amount > 0) {
            finalParsed = finalParsed.copyWith(amount: amount);
          }
        }
      }

      // 如果仍然没有金额，提示用户
      if (finalParsed.amount == null || finalParsed.amount! <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入金额')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 构建最终交易
      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();

      // 根据交易类型确定账户ID字段
      final accountId = finalParsed.accountId ??
          accountProvider.accounts.firstOrNull?.id ??
          '';
      final isIncome = finalParsed.type == TransactionType.income;
      final isTransfer = finalParsed.type == TransactionType.transfer;

      final transaction = Transaction(
        id: '',
        type: finalParsed.type ?? TransactionType.expense,
        amount: finalParsed.amount!,
        description: finalParsed.description ?? effectiveInput,
        category: finalParsed.category ?? TransactionCategory.otherExpense,
        date: finalParsed.date ?? DateTime.now(),
        notes: finalParsed.notes,
        // 根据交易类型设置账户ID
        fromAccountId: isTransfer || !isIncome ? accountId : null,
        toAccountId: isTransfer || isIncome ? accountId : null,
      );

      await transactionProvider.addTransaction(transaction);

      // 确认满足感：重震动效
      HapticFeedback.heavyImpact();

      // 成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '已记录 ${transaction.type == TransactionType.income ? '收入' : '支出'} ¥${finalParsed.amount!.toStringAsFixed(2)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 关闭页面（带收缩动效）
      if (mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _aiResult = null;
        _rawInputSnapshot = null;
        _tagState = TagState.idle;
        _recommendedAccounts = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCategoryLabel(TransactionCategory? category) {
    if (category == null) return '分类';

    switch (category) {
      case TransactionCategory.salary:
        return '工资';
      case TransactionCategory.bonus:
        return '奖金';
      case TransactionCategory.food:
        return '餐饮';
      case TransactionCategory.transport:
        return '交通';
      default:
        return category.displayName;
    }
  }

  /// 构建金额显示（键盘伴侣模式：大金额预览，悬浮在输入框上方）
  Widget _buildAmountDisplay() {
    final amount = _aiResult!.amount!;
    final type = _aiResult?.type ?? TransactionType.expense;

    // 根据交易类型获取颜色（复用统一的颜色风格接口）
    final amountColor = type == TransactionType.income
        ? AppDesignTokens.successColor(context) // 收入：绿色
        : type == TransactionType.transfer
            ? AppDesignTokens.primaryAction(context) // 转账：主题色
            : AppDesignTokens.accentColor; // 支出：红色

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 600),
      style: TextStyle(
        fontSize: 48, // 键盘伴侣模式：48pt（比之前稍小，因为位置更紧凑）
        fontWeight: FontWeight.w700,
        color: amountColor,
        letterSpacing: -1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // ¥符号：24pt灰色
          Text(
            '¥',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppDesignTokens.spacing4),
          // 金额数字：48pt
          Text(
            amount.toStringAsFixed(0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 格式化日期显示（今天、昨天、具体日期）
  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '时间?';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final daysDifference = dateOnly.difference(today).inDays;

    if (daysDifference == 0) {
      return '今天';
    } else if (daysDifference == -1) {
      return '昨天';
    } else if (daysDifference == 1) {
      return '明天';
    } else if (daysDifference == -2) {
      return '前天';
    } else if (daysDifference == 2) {
      return '后天';
    } else {
      // 显示具体日期：4月30日
      return '${date.month}月${date.day}日';
    }
  }

  /// 安全地清空输入框，避免触发监听器重置AI结果
  void _clearTextControllerSafely() {
    _suppressTextListener = true;
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _suppressTextListener = false;
    });
    _textFocusNode.requestFocus();
  }

  String _composeRecognitionInput(String newSegment) {
    final base = (_rawInputSnapshot ?? '').trim();
    final addition = newSegment.trim();

    if (addition.isEmpty) {
      return base;
    }

    if (base.isEmpty || _aiResult == null) {
      return addition;
    }

    return '$base $addition'.trim();
  }

  String _buildInputHintText() {
    final hasResultContext =
        _aiResult != null && (_rawInputSnapshot?.isNotEmpty ?? false);
    if (hasResultContext && _textController.text.isEmpty) {
      final snapshotText = _truncateSnapshot(_rawInputSnapshot!);
      return '正在完善: "$snapshotText"...';
    }
    return _getGuidancePrompt();
  }

  String _truncateSnapshot(String text, {int maxLength = 18}) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength)}...';
  }

  /// 将快照内容重新填回输入框，方便用户修改并再次识别
  void _restoreSnapshotToInput({bool clearSnapshotAfterRestore = false}) {
    if (_rawInputSnapshot == null) {
      setState(() {
        _aiResult = null;
        _tagState = TagState.idle;
        _recommendedAccounts = null;
      });
      return;
    }

    _suppressTextListener = true;
    _textController
      ..text = _rawInputSnapshot!
      ..selection = TextSelection.collapsed(
        offset: _rawInputSnapshot!.length,
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _suppressTextListener = false;
      _textFocusNode.requestFocus();
    });

    setState(() {
      _aiResult = null;
      _tagState = TagState.idle;
      _recommendedAccounts = null;
      if (clearSnapshotAfterRestore) {
        _rawInputSnapshot = null;
      }
    });
  }

  void _clearRecognitionPreview({bool restoreSnapshot = false}) {
    if (restoreSnapshot && (_rawInputSnapshot?.isNotEmpty ?? false)) {
      _restoreSnapshotToInput(clearSnapshotAfterRestore: true);
      return;
    }

    setState(() {
      _aiResult = null;
      _rawInputSnapshot = null;
      _recommendedAccounts = null;
      _tagState = TagState.idle;
    });
  }

  bool get _canQuickConfirm {
    if (_tagState != TagState.success || _aiResult == null) {
      return false;
    }
    final parsed = _aiResult!;
    final hasAmount = parsed.amount != null && parsed.amount! > 0;
    final hasCategory = parsed.category != null;
    final hasAccount =
        parsed.accountId != null || (parsed.accountName?.isNotEmpty ?? false);
    final confidenceOk = parsed.confidence >= 0.55;
    return hasAmount && hasCategory && hasAccount && confidenceOk;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: AppDesignTokens.spacing8,
            bottom: keyboardHeight + AppDesignTokens.spacing8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 只占用必要高度
            children: [
              // 顶部：关闭按钮（可选，如果用户需要）
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(AppDesignTokens.spacing8),
                      child: PhosphorIcon(
                        PhosphorIcons.x(),
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              _buildRecognitionPreview(),

              // 第3层：智能辅助区（推荐账户）
              if (_recommendedAccounts != null &&
                  _recommendedAccounts!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDesignTokens.spacing8,
                  ),
                  child: _buildAccountRecommendationBar(),
                ),

              // 第2层：输入栏（精致圆角长条，像发微信）
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacing16,
                ),
                child: _buildTextInputBar(), // 新的输入栏组件
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutBack, // 弹簧物理效果
        );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing16,
          vertical: AppDesignTokens.spacing12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 关闭按钮
            IconButton(
              icon: PhosphorIcon(PhosphorIcons.x(), size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

            // 中间留空（去掉"记一笔"文字）
            const SizedBox.shrink(),

            // 智能相机入口（OCR识别发票/小票）
            IconButton(
              icon: PhosphorIcon(PhosphorIcons.scan(), size: 20),
              onPressed: _showOcrOptions,
              color: Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );

  /// 顶部动态引导语（AnimatedSwitcher）
  Widget _buildDynamicGuidance() {
    final prompt = _getGuidancePrompt();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800), // 更慢的切换，像呼吸一样自然
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        // 极慢的 Fade Through（淡入淡出），微小的垂直位移
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1), // 更小的位移，更subtle
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          ),
        );
      },
      child: Text(
        prompt,
        key: ValueKey(prompt),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  /// 获取引导语提示（优先使用LLM生成的nextStuff，否则使用兜底逻辑）
  String _getGuidancePrompt() {
    // 如果AI正在识别中，返回动态提示（终端风格，每1.5秒切换）
    if (_tagState == TagState.loading) {
      return _loadingMessages[_loadingMessageIndex];
    }

    if (_tagState == TagState.refreshing) {
      return 'AI 正在根据补充信息优化...';
    }

    if (_aiResult != null && _tagState == TagState.success) {
      return '添加更多细节，如支付方式或时间…';
    }

    // 如果用户没有输入，返回轮播的空闲提示
    if (_textController.text.isEmpty) {
      return _idleMessages[_idleMessageIndex];
    }

    // 如果AI结果为空，但不在loading状态，返回默认提示
    if (_aiResult == null) {
      return '正在识别...';
    }

    // 优先使用LLM生成的nextStuff引导语（需要过滤掉技术性内容）
    if (_aiResult!.nextStuff != null && _aiResult!.nextStuff!.isNotEmpty) {
      final sanitized = _sanitizeNextStuff(_aiResult!.nextStuff!);
      if (sanitized.isNotEmpty) {
        return sanitized;
      }
    }

    // 兜底逻辑：根据缺失的信息动态提示
    final hasAmount = _aiResult!.amount != null && _aiResult!.amount! > 0;
    final hasAccount = _aiResult!.accountName != null;
    final hasCategory = _aiResult!.category != null;

    if (!hasAmount) {
      return '花了多少钱？';
    }
    if (!hasAccount) {
      return '用哪张卡付的？';
    }
    if (!hasCategory) {
      return '这是什么类型的交易？';
    }

    return '信息已完整 ✓';
  }

  /// 清理nextStuff内容，过滤掉技术性prompt内容，只保留用户友好的引导语
  String _sanitizeNextStuff(String nextStuff) {
    // 移除可能包含的技术性prompt内容
    final technicalPatterns = [
      RegExp('你是一个.*?记账助手', caseSensitive: false),
      RegExp('不要使用.*?敬语', caseSensitive: false),
      RegExp('语气要像.*?', caseSensitive: false),
      RegExp('保持.*?松弛感', caseSensitive: false),
      RegExp('优先级.*?', caseSensitive: false),
      RegExp('如果.*?缺失.*?', caseSensitive: false),
      RegExp('引导语.*?', caseSensitive: false),
      RegExp('简洁.*?自然.*?', caseSensitive: false),
      RegExp('不超过.*?字', caseSensitive: false),
      RegExp('#.*?', caseSensitive: false), // 移除Markdown标题
      RegExp('<.*?>', caseSensitive: false), // 移除XML标签
      RegExp(r'\{.*?\}', caseSensitive: false), // 移除JSON结构
    ];

    var cleaned = nextStuff.trim();

    // 移除技术性模式
    for (final pattern in technicalPatterns) {
      cleaned = cleaned.replaceAll(pattern, '').trim();
    }

    // 如果清理后为空或过长（超过15个字），使用兜底逻辑
    if (cleaned.isEmpty || cleaned.length > 15) {
      return '';
    }

    // 移除多余的空格和标点
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// 输入栏（键盘伴侣模式：精致圆角长条，像发微信）
  Widget _buildTextInputBar() => SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _textFocusNode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: _buildInputHintText(),
                    hintMaxLines: 1,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.spacing12,
                      vertical: 14,
                    ),
                    suffixIcon: _textController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _textController.clear();
                              setState(() {
                                _aiResult = null;
                                _tagState = TagState.idle;
                                _recommendedAccounts = null;
                                _rawInputSnapshot = null;
                              });
                              _textFocusNode.requestFocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppDesignTokens.spacing8,
                              ),
                              child: PhosphorIcon(
                                PhosphorIcons.xCircle(),
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: AppDesignTokens.spacing8),
            Builder(
              builder: (context) {
                final hasText = _textController.text.trim().isNotEmpty;
                final isActive = hasText || _canQuickConfirm;
                final iconData = _canQuickConfirm
                    ? CupertinoIcons.check_mark
                    : Icons.arrow_upward;
                final buttonColor = _canQuickConfirm
                    ? AppDesignTokens.successColor(context)
                    : isActive
                        ? AppDesignTokens.primaryAction(context)
                        : Colors.grey.shade300;
                final iconColor = _canQuickConfirm || hasText
                    ? Colors.white
                    : Colors.grey.shade600;

                return GestureDetector(
                  onTap: isActive ? _handleSubmit : null,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );

  /// 核心文本输入框（自适应高度，支持高亮）- 已废弃，使用_buildTextInputBar
  Widget _buildTextInput() => Container(
        constraints: const BoxConstraints(
          minHeight: 120,
          maxHeight: 300,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing16,
          vertical: AppDesignTokens.spacing16,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          maxLines: null,
          minLines: 3,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            // V3方案：一键清空按钮（当有输入时显示）
            suffixIcon: _textController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _textController.clear();
                      setState(() {
                        _aiResult = null;
                        _tagState = TagState.idle;
                      });
                      // 重新聚焦输入框
                      _textFocusNode.requestFocus();
                      // 停止动态提示轮播
                      _loadingMessageTimer?.cancel();
                      _idleMessageTimer?.cancel();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppDesignTokens.spacing8),
                      child: PhosphorIcon(
                        PhosphorIcons.xCircle(),
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : null,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleSubmit(),
        ),
      );

  /// Loading状态的标签（Shimmer动效）
  Widget _buildLoadingTags() => Wrap(
        spacing: AppDesignTokens.spacing8,
        runSpacing: AppDesignTokens.spacing8,
        children: [
          _buildShimmerTag(width: 60),
          _buildShimmerTag(width: 80),
          _buildShimmerTag(width: 50),
        ],
      );

  /// Shimmer标签（加载动画）
  Widget _buildShimmerTag({required double width}) => Container(
        height: 32,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 1200.ms,
            color: Colors.white.withOpacity(0.5),
          );

  /// 智能标签行（键盘伴侣模式：紧凑显示识别结果）
  Widget _buildSmartTags() {
    if (_aiResult == null) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDesignTokens.spacing8,
      runSpacing: AppDesignTokens.spacing8,
      children: [
        if (_aiResult!.category != null)
          _buildSmartTag(
            icon: PhosphorIcons.tag(),
            label: _getCategoryLabel(_aiResult!.category),
            color: AppDesignTokens.primaryAction(context),
            isFilled: true,
          ),
        if (_aiResult!.accountName != null)
          _buildSmartTag(
            icon: PhosphorIcons.creditCard(),
            label: _aiResult!.accountName!,
            color: AppDesignTokens.primaryAction(context),
            isFilled: true,
          ),
        if (_aiResult!.date != null)
          _buildSmartTag(
            icon: PhosphorIcons.calendarBlank(),
            label: _formatDateForDisplay(_aiResult!.date),
            color: AppDesignTokens.primaryAction(context),
            isFilled: true,
          ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  /// 构建单个智能标签
  Widget _buildSmartTag({
    required IconData icon,
    required String label,
    required Color color,
    required bool isFilled,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
  }) {
    const maxLength = 10; // 限制标签文本长度
    final displayText = label.length > maxLength
        ? '${label.substring(0, maxLength)}...'
        : label;

    final textColor = foregroundColor ?? color;
    final fillColor = backgroundColor ??
        (isFilled ? color.withOpacity(0.12) : Colors.grey.shade100);
    final outlineColor = borderColor ??
        (backgroundColor != null
            ? Colors.transparent
            : (isFilled ? color.withOpacity(0.2) : Colors.grey.shade300));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing12,
        vertical: AppDesignTokens.spacing8,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: AppDesignTokens.spacing4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isFilled ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionPreview() {
    final hasResult = _aiResult != null;
    final isDimmedState = _tagState == TagState.refreshing ||
        (_tagState == TagState.loading && hasResult);

    if (_tagState == TagState.loading && !isDimmedState) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: AppDesignTokens.spacing8,
          left: AppDesignTokens.spacing16,
          right: AppDesignTokens.spacing16,
        ),
        child: _wrapPreviewCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDesignTokens.spacing8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.sparkle(),
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: AppDesignTokens.spacing8),
                  Text(
                    'AI 正在识别',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignTokens.spacing16),
              _buildShimmerLine(height: 32),
              const SizedBox(height: AppDesignTokens.spacing16),
              _buildLoadingTags(),
            ],
          ),
          minHeight: _previewCardMinHeight,
        ),
      );
    }

    if ((_tagState == TagState.success || isDimmedState) && hasResult) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: AppDesignTokens.spacing8,
          left: AppDesignTokens.spacing16,
          right: AppDesignTokens.spacing16,
        ),
        child: _wrapPreviewCard(
          _buildAiSummaryCardContent(isDimmed: isDimmedState),
          minHeight: _previewCardMinHeight,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _wrapPreviewCard(
    Widget child, {
    double? minHeight,
  }) =>
      Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: minHeight ?? 0,
            ),
            padding: const EdgeInsets.all(AppDesignTokens.spacing16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ],
      );

  Widget _buildAiSummaryCardContent({bool isDimmed = false}) {
    final parsed = _aiResult!;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      opacity: isDimmed ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignTokens.spacing8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(
                  PhosphorIcons.receipt(),
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: AppDesignTokens.spacing8),
              const Text(
                '账单预览',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (parsed.confidence > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing12,
                    vertical: AppDesignTokens.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${(parsed.confidence * 100).clamp(0, 100).toStringAsFixed(0)}% 可信度',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
          if (parsed.amount != null && parsed.amount! > 0) ...[
            const SizedBox(height: AppDesignTokens.spacing12),
            Center(child: _buildAmountDisplay()),
          ],
          const SizedBox(height: AppDesignTokens.spacing16),
          _buildSmartTags(),
          if (_rawInputSnapshot?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppDesignTokens.spacing16),
            _buildRawSentenceViewer(),
          ],
        ],
      ),
    );
  }

  Widget _buildRawSentenceViewer() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing12,
          vertical: AppDesignTokens.spacing12,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.format_quote,
              size: 18,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: AppDesignTokens.spacing8),
            Expanded(
              child: Text(
                _rawInputSnapshot ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: _restoreSnapshotToInput,
              child: const Text('编辑'),
            ),
          ],
        ),
      );

  Widget _buildShimmerLine({double height = 20}) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 1200.ms,
            color: Colors.white.withOpacity(0.5),
          );

  /// 底部5W1H槽位展示（填空槽，带流体预判）- 已废弃，使用_buildSmartTags
  Widget _buildSlotArea() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
        child: _buildSlotContent(),
      );

  /// 根据状态构建槽位内容
  Widget _buildSlotContent() {
    switch (_tagState) {
      case TagState.idle:
        // 空闲状态：占位，防止高度跳动
        return const SizedBox(
          height: 40,
          key: ValueKey('idle'),
        );

      case TagState.loading:
        // 加载中：显示幽灵骨架（会呼吸的灰色胶囊）
        return Wrap(
          spacing: AppDesignTokens.spacing8,
          runSpacing: AppDesignTokens.spacing8,
          alignment: WrapAlignment.center,
          key: const ValueKey('loading'),
          children: [
            _buildGhostPill(width: 60), // 模拟"工资"长度
            _buildGhostPill(width: 90), // 模拟"招行工资卡"长度
            _buildGhostPill(width: 50), // 模拟"金额"长度
          ],
        );

      case TagState.refreshing:
      case TagState.success:
        // 成功状态：显示真实槽位
        return Wrap(
          spacing: AppDesignTokens.spacing8,
          runSpacing: AppDesignTokens.spacing8,
          alignment: WrapAlignment.center,
          key: const ValueKey('success'),
          children: [
            // When (时间)
            _buildSlot(
              icon: PhosphorIcons.calendarBlank(),
              label: '时间',
              value: _formatDateForDisplay(_aiResult?.date),
              isFilled: _aiResult?.date != null,
            ),

            // What (分类)
            _buildSlot(
              icon: PhosphorIcons.tag(),
              label: '分类',
              value: _aiResult?.category != null
                  ? _getCategoryLabel(_aiResult!.category)
                  : null,
              hint: '分类?',
              isFilled: _aiResult?.category != null,
            ),

            // Who (对象/商家)
            _buildSlot(
              icon: PhosphorIcons.buildings(),
              label: '对象',
              value: _aiResult?.description,
              hint: '对象?',
              isFilled: _aiResult?.description != null,
            ),

            // How much (金额) - 已单独显示在输入框下方，这里不再显示

            // Where (账户)
            _buildSlot(
              icon: PhosphorIcons.creditCard(),
              label: '账户',
              value: _aiResult?.accountName,
              hint: '账户?',
              isFilled: _aiResult?.accountName != null,
            ),

            // Why (备注)
            _buildSlot(
              icon: PhosphorIcons.note(),
              label: '备注',
              value: _aiResult?.notes,
              hint: '备注?',
              isFilled: _aiResult?.notes != null,
            ),
          ],
        );
    }
  }

  /// 幽灵胶囊：会呼吸的灰色块（Shimmering Pills）
  Widget _buildGhostPill({required double width}) => Container(
        height: 32,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade200, // iOS 浅灰
          borderRadius: BorderRadius.circular(16),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1200.ms,
            color: Colors.white.withOpacity(0.5),
          )
          .animate()
          .fadeIn(duration: 300.ms);

  /// 构建单个槽位
  Widget _buildSlot({
    required IconData icon,
    required String label,
    required bool isFilled,
    String? value,
    String? hint,
  }) {
    final displayText = value ?? hint ?? '$label?';
    final color = isFilled
        ? AppDesignTokens.primaryAction(context)
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        // TODO: 点击槽位手动补全信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了$label槽位')),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing12,
          vertical: AppDesignTokens.spacing8,
        ),
        decoration: BoxDecoration(
          color: isFilled ? color.withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(
            color: isFilled ? color.withOpacity(0.3) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        // V3方案：Missing状态时添加抖动效果
        child: !isFilled && _aiResult != null && _tagState == TagState.success
            ? _buildShakeAnimation(
                child: _buildSlotRow(
                  icon: icon,
                  displayText: displayText,
                  color: color,
                  isFilled: isFilled,
                ),
              )
            : _buildSlotRow(
                icon: icon,
                displayText: displayText,
                color: color,
                isFilled: isFilled,
              ),
      ),
    );
  }

  /// 构建槽位行内容（提取公共部分）
  Widget _buildSlotRow({
    required IconData icon,
    required String displayText,
    required Color color,
    required bool isFilled,
  }) {
    // V3方案：限制文本长度，避免超长文本导致溢出
    const maxLength = 12; // 最多显示12个字符
    final truncatedText = displayText.length > maxLength
        ? '${displayText.substring(0, maxLength)}...'
        : displayText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: AppDesignTokens.spacing4),
        Flexible(
          child: Text(
            truncatedText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isFilled ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// V3方案：抖动动画（Missing状态）
  Widget _buildShakeAnimation({required Widget child}) =>
      child.animate(onPlay: (controller) => controller.repeat()).shake(
            duration: 600.ms,
            hz: 4,
            curve: Curves.easeInOut,
          );

  /// 获取交易类型图标
  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return PhosphorIcons.arrowCircleDown();
      case TransactionType.expense:
        return PhosphorIcons.arrowCircleUp();
      case TransactionType.transfer:
        return PhosphorIcons.arrowsLeftRight();
    }
  }

  /// 获取交易类型标签
  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return '收入';
      case TransactionType.expense:
        return '支出';
      case TransactionType.transfer:
        return '转账';
    }
  }

  /// 获取交易类型颜色
  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green.shade600; // 收入用绿色
      case TransactionType.expense:
        return Colors.orange.shade600; // 支出用橙色
      case TransactionType.transfer:
        return Colors.blue.shade600; // 转账用蓝色
    }
  }

  /// 精致的subtle标签（iOS风格）
  Widget _buildSubtleTag({
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing12,
          vertical: AppDesignTokens.spacing4,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 14,
              color: color.withOpacity(0.8),
            ),
            const SizedBox(width: AppDesignTokens.spacing4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.9),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );

  /// 计算推荐账户（本地预测，基于分类的历史使用频率）
  List<Account> _calculateRecommendedAccounts(
    TransactionCategory category,
    List<Account> allAccounts,
    List<Transaction> userHistory,
  ) {
    // 统计该分类下各账户的使用频率
    final accountFrequency = <String, int>{};

    for (final transaction in userHistory) {
      if (transaction.category == category) {
        // 根据交易类型获取账户ID（支出用fromAccountId，收入用toAccountId）
        final accountId = transaction.type == TransactionType.expense
            ? transaction.fromAccountId
            : transaction.toAccountId;

        if (accountId != null) {
          accountFrequency[accountId] = (accountFrequency[accountId] ?? 0) + 1;
        }
      }
    }

    // 按频率排序，取前3个
    final sortedAccountIds = accountFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendedIds = sortedAccountIds.take(3).map((e) => e.key).toList();

    // 转换为Account对象
    final recommended = <Account>[];
    for (final accountId in recommendedIds) {
      try {
        final account = allAccounts.firstWhere((a) => a.id == accountId);
        if (!recommended.contains(account)) {
          recommended.add(account);
        }
      } catch (e) {
        // 账户不存在，跳过
        continue;
      }
    }

    // 如果推荐不足3个，补充其他常用账户
    if (recommended.length < 3) {
      for (final account in allAccounts) {
        if (recommended.length >= 3) break;
        if (!recommended.contains(account)) {
          recommended.add(account);
        }
      }
    }

    return recommended.take(3).toList();
  }

  /// 构建账户推荐工具栏（键盘上方）
  Widget _buildAccountRecommendationBar() {
    if (_recommendedAccounts == null || _recommendedAccounts!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
      child: Row(
        children: _recommendedAccounts!
            .map(
              (account) => GestureDetector(
                onTap: () => _selectRecommendedAccount(account),
                child: Container(
                  margin:
                      const EdgeInsets.only(right: AppDesignTokens.spacing8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing12,
                    vertical: AppDesignTokens.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppDesignTokens.primaryAction(context)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.creditCard(),
                        size: 14,
                        color: AppDesignTokens.primaryAction(context),
                      ),
                      const SizedBox(width: AppDesignTokens.spacing4),
                      Text(
                        account.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppDesignTokens.primaryAction(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// 选择推荐账户
  void _selectRecommendedAccount(Account account) {
    if (_aiResult == null) return;

    setState(() {
      // 更新AI结果，填充账户信息
      _aiResult = _aiResult!.copyWith(
        accountId: account.id,
        accountName: account.name,
      );

      // 清除推荐（因为已经选择了）
      _recommendedAccounts = null;
    });

    // 震动反馈
    HapticFeedback.selectionClick();

    // 可选：显示成功提示（短暂显示）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择账户：${account.name}'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 确认按钮（页面中央）
  Widget _buildConfirmButton() => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing32),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading || _textController.text.trim().isEmpty
                ? null
                : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _textController.text.trim().isEmpty
                  ? Colors.grey.shade300
                  : AppDesignTokens.primaryAction(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '确认',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      );
}

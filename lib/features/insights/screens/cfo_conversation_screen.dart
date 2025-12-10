import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';
import 'package:your_finance_flutter/core/widgets/app_card.dart';
import 'package:your_finance_flutter/features/insights/models/monthly_health.dart';
import 'package:your_finance_flutter/features/insights/services/ai_analysis_service.dart';
import 'package:your_finance_flutter/core/services/ai/mock_ai_service.dart';

/// Message in the CFO conversation
class CFOMessage {
  const CFOMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isTyping = false,
    this.suggestions,
  });

  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final bool isTyping;
  final List<String>? suggestions;

  CFOMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    DateTime? timestamp,
    bool? isTyping,
    List<String>? suggestions,
  }) {
    return CFOMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

enum MessageSender {
  user('user'),
  cfo('cfo'),
  system('system');

  const MessageSender(this.value);
  final String value;
}

/// Conversational CFO Interface
class CFOConversationScreen extends ConsumerStatefulWidget {
  const CFOConversationScreen({super.key});

  @override
  ConsumerState<CFOConversationScreen> createState() => _CFOConversationScreenState();
}

class _CFOConversationScreenState extends ConsumerState<CFOConversationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CFOMessage> _messages = [];
  bool _isTyping = false;
  late AiAnalysisService _aiService;

  // Quick suggestion buttons
  final List<String> _quickSuggestions = [
    '分析我的消费习惯',
    '如何提高储蓄率',
    '优化我的预算分配',
    '预测下个月的财务状况',
    '建议投资策略',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAIService();
    _addWelcomeMessage();
  }

  Future<void> _initializeAIService() async {
    _aiService = await AiAnalysisService.getInstance();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = CFOMessage(
      id: 'welcome',
      sender: MessageSender.cfo,
      content: '您好！我是您的专属AI财务顾问。我可以帮您分析财务状况、优化预算分配、预测财务趋势，并提供个性化的财务建议。请问有什么我可以帮您的吗？',
      timestamp: DateTime.now(),
      suggestions: _quickSuggestions,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.pageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppDesignTokens.primaryAction(context),
              child: Icon(
                Icons.account_balance_wallet,
                color: AppDesignTokens.onPrimaryAction(context),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI CFO 顾问',
                  style: AppDesignTokens.headline(context).copyWith(
                    color: AppDesignTokens.primaryText(context),
                  ),
                ),
                Text(
                  '在线为您服务',
                  style: AppDesignTokens.caption(context).copyWith(
                    color: AppDesignTokens.secondaryText(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: AppDesignTokens.primaryText(context),
            ),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageItem(_messages[index]);
                } else {
                  return _buildTypingIndicator();
                }
              },
            ),
          ),

          // Quick suggestions (only show if no user message sent)
          if (_messages.where((m) => m.sender == MessageSender.user).isEmpty &&
              _messages.isNotEmpty &&
              _messages.last.suggestions != null)
            _buildQuickSuggestions(),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(CFOMessage message) {
    final isUser = message.sender == MessageSender.user;
    final isCFO = message.sender == MessageSender.cfo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: isCFO
                  ? AppDesignTokens.primaryAction(context)
                  : AppDesignTokens.secondaryText(context),
              radius: 16,
              child: Icon(
                isCFO ? Icons.account_balance : Icons.info,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser
                    ? AppDesignTokens.primaryAction(context)
                    : AppDesignTokens.surface(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppDesignTokens.body(context).copyWith(
                      color: isUser
                          ? AppDesignTokens.onPrimaryAction(context)
                          : AppDesignTokens.primaryText(context),
                    ),
                  ),
                  if (message.suggestions != null && message.suggestions!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: message.suggestions!.map((suggestion) =>
                          ActionChip(
                            label: Text(
                              suggestion,
                              style: AppDesignTokens.caption(context),
                            ),
                            onPressed: () => _sendMessage(suggestion),
                            backgroundColor: AppDesignTokens.inputFill(context),
                          ),
                        ).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppDesignTokens.secondaryText(context),
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppDesignTokens.primaryAction(context),
            radius: 16,
            child: Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppDesignTokens.surface(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'AI CFO正在思考',
                  style: AppDesignTokens.body(context),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppDesignTokens.primaryAction(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速提问',
            style: AppDesignTokens.caption(context).copyWith(
              color: AppDesignTokens.secondaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _quickSuggestions.map((suggestion) =>
              ActionChip(
                label: Text(
                  suggestion,
                  style: AppDesignTokens.caption(context),
                ),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: AppDesignTokens.inputFill(context),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入您的问题...',
                hintStyle: AppDesignTokens.body(context).copyWith(
                  color: AppDesignTokens.secondaryText(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppDesignTokens.inputFill(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _sendCurrentMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: AppDesignTokens.primaryAction(context),
            ),
            onPressed: _isTyping ? null : _sendCurrentMessage,
          ),
        ],
      ),
    );
  }

  void _sendCurrentMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _sendMessage(text);
    _messageController.clear();
  }

  Future<void> _sendMessage(String content) async {
    // Add user message
    final userMessage = CFOMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      content: content,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate CFO response based on the query
    final cfoResponse = await _generateCFOResponse(content);

    setState(() {
      _isTyping = false;
      _messages.add(cfoResponse);
    });

    _scrollToBottom();
  }

  Future<CFOMessage> _generateCFOResponse(String userQuery) async {
    // Analyze the user query and generate appropriate response
    String response;
    List<String>? suggestions;

    if (userQuery.contains('消费习惯') || userQuery.contains('分析')) {
      response = '''
根据您最近的消费记录，我发现以下特点：

📊 **消费模式分析**
• 餐饮支出占比约35%，略高于平均水平
• 周末消费通常比工作日高出40%
• 数字服务订阅费用较为合理

💡 **优化建议**
• 考虑将餐饮预算从35%降至30%
• 建立周末消费上限，控制冲动消费
• 定期检查并取消不需要的订阅服务

您希望我深入分析某个特定方面的消费吗？
      '''.trim();
      suggestions = ['详细分析餐饮支出', '查看周末消费模式', '优化订阅服务'];
    } else if (userQuery.contains('储蓄') || userQuery.contains('存款')) {
      response = '''
您的储蓄情况分析如下：

💰 **储蓄概况**
• 当前储蓄率：22%（良好水平）
• 建议储蓄率：25-30%
• 月均净储蓄：¥3,200

📈 **储蓄策略建议**
• 建立自动转账到储蓄账户
• 考虑高息定期存款产品
• 建立3-6个月的生活费应急基金

您想了解具体的储蓄计划吗？
      '''.trim();
      suggestions = ['制定储蓄计划', '推荐储蓄产品', '建立应急基金'];
    } else if (userQuery.contains('预算') || userQuery.contains('分配')) {
      response = '''
基于您的收入和支出模式，这里是优化的预算分配建议：

🎯 **推荐预算分配**
• 必需支出（住房、水电等）：45%
• 生活支出（餐饮、娱乐等）：35%
• 储蓄投资：20%

📊 **当前vs推荐对比**
• 必需支出：当前50% → 建议45%（✅优化空间）
• 生活支出：当前40% → 建议35%（✅可优化）
• 储蓄投资：当前10% → 建议20%（📈提升空间）

需要我帮您制定详细的预算计划吗？
      '''.trim();
      suggestions = ['制定月度预算', '调整支出比例', '设置预算提醒'];
    } else {
      response = '''
感谢您的问题！作为您的AI财务顾问，我可以帮您：

💼 **财务分析**
• 消费习惯和支出模式分析
• 预算分配优化建议
• 储蓄和投资策略

📊 **财务规划**
• 短期和长期财务目标设定
• 债务管理咨询
• 税务优化建议

💡 **智能洞察**
• 基于您消费数据的个性化建议
• 财务健康评分和改善方案
• 消费异常检测和预警

请问您想了解哪个方面的财务问题呢？
      '''.trim();
      suggestions = _quickSuggestions;
    }

    return CFOMessage(
      id: 'cfo_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.cfo,
      content: response,
      timestamp: DateTime.now(),
      suggestions: suggestions,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.history, color: AppDesignTokens.primaryAction(context)),
              title: Text('对话历史', style: AppDesignTokens.body(context)),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Show conversation history
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppDesignTokens.primaryAction(context)),
              title: Text('顾问设置', style: AppDesignTokens.body(context)),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Show settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: AppDesignTokens.primaryAction(context)),
              title: Text('帮助说明', style: AppDesignTokens.body(context)),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Show help
              },
            ),
          ],
        ),
      ),
    );
  }
}

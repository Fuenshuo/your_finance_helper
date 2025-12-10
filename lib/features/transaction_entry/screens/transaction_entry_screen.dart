import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/features/transaction_entry/widgets/transaction_entry_screen.dart';

/// 交易录入页面主屏幕
///
/// 这是交易录入功能的入口点，整合了所有UI组件和业务逻辑。
/// 采用分层架构：UI层 -> 业务逻辑层 -> 数据层
class TransactionEntryScreenPage extends ConsumerWidget {
  const TransactionEntryScreenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('交易录入'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: 导航到设置页面
              },
            ),
          ],
        ),
        body: const SafeArea(
          child: TransactionEntryScreen(),
        ),
      );
}

/// 交易详情页面
///
/// 显示单个交易的详细信息，支持编辑和删除操作
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    required this.transactionId,
    super.key,
  });
  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('交易详情'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: 实现编辑功能
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // TODO: 实现删除功能
              },
            ),
          ],
        ),
        body: const SafeArea(
          child: Center(
            child: Text('交易详情页面 - 开发中'),
          ),
        ),
      );
}

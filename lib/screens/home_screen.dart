import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/providers/riverpod_providers.dart';
import 'package:your_finance_flutter/screens/onboarding_screen.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetsProvider);
    final dbAsync = ref.watch(databaseServiceProvider);

    // Wait for database to initialize
    return dbAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Database error: $error'),
        ),
      ),
      data: (db) {
        // 如果还没有资产数据，显示引导页面
        if (assets.isEmpty) {
          return const OnboardingScreen();
        }

        // 否则直接进入 AI 聊天式统一记账入口
        return const UnifiedTransactionEntryScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/riverpod_providers.dart';
import 'package:your_finance_flutter/screens/main_navigation_screen.dart';
import 'package:your_finance_flutter/screens/onboarding_screen.dart';

/// Bridges legacy onboarding to the merged Flux navigation shell.
class HomeScreen extends ConsumerWidget {
  /// Creates the root home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetsProvider);
    final dbAsync = ref.watch(databaseServiceProvider);
    final streamInsightsFlag = ref.watch(streamInsightsFlagStateProvider);
    final mergedExperienceEnabled = streamInsightsFlag.isEnabled;

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
        if (mergedExperienceEnabled) {
          return const MainNavigationScreen();
        }
        // 如果还没有资产数据，显示引导页面
        if (assets.isEmpty) {
          return const OnboardingScreen();
        }

        // 否则显示新的三层架构主导航
        return const MainNavigationScreen();
      },
    );
  }
}

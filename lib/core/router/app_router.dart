import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:your_finance_flutter/features/family_info/screens/add_asset_flow_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/add_wallet_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/asset_history_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/asset_management_screen.dart';
// Family Info Screens
import 'package:your_finance_flutter/features/family_info/screens/family_info_home_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/salary_income_setup_screen.dart';
import 'package:your_finance_flutter/features/family_info/screens/wallet_management_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/budget_management_screen.dart';
// Financial Planning Screens
import 'package:your_finance_flutter/features/financial_planning/screens/financial_planning_home_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/mortgage_calculator_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/add_transaction_screen.dart';
// Transaction Flow Screens
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_flow_home_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_records_screen.dart';
import 'package:your_finance_flutter/screens/debug_screen.dart';
import 'package:your_finance_flutter/screens/developer_mode_screen.dart';
// ============================================================================
// Screen Imports
// ============================================================================

// Main Screens
import 'package:your_finance_flutter/riverpod_asset_demo_screen.dart';
import 'package:your_finance_flutter/screens/home_screen.dart';
import 'package:your_finance_flutter/screens/main_navigation_screen.dart';
import 'package:your_finance_flutter/screens/onboarding_screen.dart';
import 'package:your_finance_flutter/screens/settings_screen.dart';

// ============================================================================
// Route Constants
// ============================================================================

class AppRoutes {
  // Main Routes
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String debug = '/debug';
  static const String developer = '/developer';
  static const String riverpodDemo = '/riverpod-demo';

  // Family Info Routes
  static const String familyInfo = '/family-info';
  static const String assetManagement = '/family-info/assets';
  static const String addAsset = '/family-info/assets/add';
  static const String salarySetup = '/family-info/salary/setup';
  static const String walletManagement = '/family-info/wallets';
  static const String addWallet = '/family-info/wallets/add';
  static const String assetHistory = '/family-info/assets/history';

  // Financial Planning Routes
  static const String financialPlanning = '/financial-planning';
  static const String budgetManagement = '/financial-planning/budgets';
  static const String mortgageCalculator = '/financial-planning/mortgage';

  // Transaction Flow Routes
  static const String transactionFlow = '/transaction-flow';
  static const String addTransaction = '/transaction-flow/add';
  static const String transactionRecords = '/transaction-flow/records';

  // Navigation
  static const String main = '/main';
}

// ============================================================================
// Router Configuration
// ============================================================================

/// Global router instance
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  routes: [
    // Root Routes
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: AppRoutes.debug,
      builder: (context, state) => const DebugScreen(),
    ),

    GoRoute(
      path: AppRoutes.developer,
      builder: (context, state) => const DeveloperModeScreen(),
    ),

    GoRoute(
      path: AppRoutes.riverpodDemo,
      builder: (context, state) => const RiverpodAssetDemoScreen(),
    ),

    // Main Navigation
    GoRoute(
      path: AppRoutes.main,
      builder: (context, state) => const MainNavigationScreen(),
    ),

    // Family Info Routes
    GoRoute(
      path: AppRoutes.familyInfo,
      builder: (context, state) => const FamilyInfoHomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.assetManagement,
      builder: (context, state) => const AssetManagementScreen(),
    ),

    // Note: Asset detail/edit routes will be implemented after Riverpod/Drift migration
    // For now, these screens require the full asset object, not just ID

    GoRoute(
      path: AppRoutes.addAsset,
      builder: (context, state) => const AddAssetFlowScreen(),
    ),

    GoRoute(
      path: AppRoutes.salarySetup,
      builder: (context, state) => const SalaryIncomeSetupScreen(),
    ),

    // Note: Salary preview route will be implemented after Riverpod/Drift migration
    // Requires salaryIncome and calculationMode parameters

    GoRoute(
      path: AppRoutes.walletManagement,
      builder: (context, state) => const WalletManagementScreen(),
    ),

    // Note: Account detail route will be implemented after Riverpod/Drift migration
    // Requires full account object parameter

    GoRoute(
      path: AppRoutes.addWallet,
      builder: (context, state) => const AddWalletScreen(),
    ),

    GoRoute(
      path: AppRoutes.assetHistory,
      builder: (context, state) => const AssetHistoryScreen(),
    ),

    // Financial Planning Routes
    GoRoute(
      path: AppRoutes.financialPlanning,
      builder: (context, state) => const FinancialPlanningHomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.budgetManagement,
      builder: (context, state) => const BudgetManagementScreen(),
    ),

    // Note: Budget detail routes will be implemented after Riverpod/Drift migration
    // Require full budget object and budget type parameters

    GoRoute(
      path: AppRoutes.mortgageCalculator,
      builder: (context, state) => const MortgageCalculatorScreen(),
    ),


    // Transaction Flow Routes
    GoRoute(
      path: AppRoutes.transactionFlow,
      builder: (context, state) => const TransactionFlowHomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) => const AddTransactionScreen(),
    ),

    // Note: Transaction detail route will be implemented after Riverpod/Drift migration
    // Requires full transaction object parameter

    GoRoute(
      path: AppRoutes.transactionRecords,
      builder: (context, state) => const TransactionRecordsScreen(),
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri.path}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

// ============================================================================
// Navigation Extensions
// ============================================================================

extension GoRouterExtensions on BuildContext {
  /// Navigate to home screen
  void goHome() => go(AppRoutes.home);

  /// Navigate to main navigation
  void goMain() => go(AppRoutes.main);

  /// Navigate to family info
  void goFamilyInfo() => go(AppRoutes.familyInfo);

  /// Navigate to asset management
  void goAssetManagement() => go(AppRoutes.assetManagement);

  /// Navigate to add asset
  void goAddAsset() => go(AppRoutes.addAsset);

  /// Navigate to transaction flow
  void goTransactionFlow() => go(AppRoutes.transactionFlow);

  /// Navigate to add transaction
  void goAddTransaction() => go(AppRoutes.addTransaction);

  /// Navigate to settings
  void goSettings() => go(AppRoutes.settings);

  /// Navigate to debug screen
  void goDebug() => go(AppRoutes.debug);

  /// Navigate to Riverpod demo
  void goRiverpodDemo() => go(AppRoutes.riverpodDemo);
}

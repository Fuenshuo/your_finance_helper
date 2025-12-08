import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:your_finance_flutter/core/providers/account_provider.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/core/providers/budget_provider.dart';
import 'package:your_finance_flutter/core/providers/expense_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/income_plan_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_provider.dart';
import 'package:your_finance_flutter/core/providers/theme_style_provider.dart';
import 'package:your_finance_flutter/core/providers/transaction_provider.dart';
import 'package:your_finance_flutter/features/insights/providers/insights_provider.dart';
import 'package:your_finance_flutter/core/router/app_router.dart';
import 'package:your_finance_flutter/core/services/data_migration_service.dart';
import 'package:your_finance_flutter/features/insights/services/insight_service.dart' as insights_service;
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// 应用生命周期观察者
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        Log.business('App', 'Application Paused');
      case AppLifecycleState.resumed:
        Log.business('App', 'Application Resumed');
      case AppLifecycleState.inactive:
        Log.business('App', 'Application Inactive');
      case AppLifecycleState.detached:
        Log.business('App', 'Application Detached');
        // 应用完全关闭时清理日志资源
        Logger.dispose();
      case AppLifecycleState.hidden:
        Log.business('App', 'Application Hidden');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('[main.dart] 🚀 使用传统主函数启动应用');

  // 初始化日志系统
  await Logger.init(
    enableFileLogging: true,
  );

  // Database initialization will be added after full Drift integration
  Log.business(
    'App',
    'Application Startup',
    {'phase': 'database_init', 'status': 'simplified_for_demo'},
  );

  // 执行数据迁移
  Log.business('App', 'Application Startup', {'phase': 'migration'});
  final migrationService = await DataMigrationService.getInstance();
  await migrationService.checkAndMigrateData();

  Log.business('App', 'Application Startup', {'phase': 'complete'});

  // 监听应用生命周期，清理资源
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
          provider.ChangeNotifierProvider(
              create: (_) => ThemeStyleProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => AccountProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => AssetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => BudgetProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => IncomePlanProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => ExpensePlanProvider()..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => TransactionProvider(
                insightsProvider: InsightsProvider(insights_service.InsightService()),
              )..initialize()),
          provider.ChangeNotifierProvider(
              create: (_) => InsightsProvider(insights_service.InsightService())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    
    return MaterialApp.router(
        title: '家庭资产记账',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        // 添加国际化支持
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        locale: const Locale('zh', 'CN'),
        // 修复Web端图标主题问题
        builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        ),
      );
  }
}

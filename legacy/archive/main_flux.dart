/// 🌊 Flux Ledger - 流式记账应用主入口
///
/// 从传统记账到流式思维的革命性转变

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'core/providers/flux_providers.dart';
import 'core/router/flux_router.dart';
import 'core/services/flux_services.dart';
import 'core/theme/flux_theme.dart';
import 'core/utils/flux_logger.dart';

/// 应用生命周期观察者
class FluxAppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        FluxLogger.business('🌊 Flux', 'Application Paused');
      case AppLifecycleState.resumed:
        FluxLogger.business('🌊 Flux', 'Application Resumed');
      case AppLifecycleState.inactive:
        FluxLogger.business('🌊 Flux', 'Application Inactive');
      case AppLifecycleState.detached:
        FluxLogger.business('🌊 Flux', 'Application Detached');
        // 应用完全关闭时清理资源
        _cleanupResources();
      case AppLifecycleState.hidden:
        FluxLogger.business('🌊 Flux', 'Application Hidden');
    }
  }

  void _cleanupResources() {
    FluxServiceManager().dispose();
    FluxLogger.dispose();
  }
}

/// Flux Ledger 主函数
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('[main_flux.dart] 🚀 使用 Flux 主函数启动应用');
  FluxLogger.business('🌊 Flux', '🚀 Flux Ledger Starting Up');

  // 初始化Flux服务层
  await _initializeFluxServices();

  // 监听应用生命周期
  WidgetsBinding.instance.addObserver(FluxAppLifecycleObserver());

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          // Flux核心提供者
          provider.ChangeNotifierProvider(
            create: (_) => FluxThemeProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowDashboardProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowStreamsProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowInsightsProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => FlowAnalyticsProvider()..initialize(),
          ),

          // 兼容性提供者 (逐步迁移)
          provider.ChangeNotifierProvider(
            create: (_) => LegacyDataProvider()..initialize(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => TransactionProvider()..initialize(),
          ),
        ],
        child: const FluxLedgerApp(),
      ),
    ),
  );
}

/// 初始化Flux服务层
Future<void> _initializeFluxServices() async {
  try {
    FluxLogger.business('🌊 Flux', '🔧 Initializing Flux Services');

    // 初始化服务管理器
    await FluxServiceManager().initialize();

    FluxLogger.business('🌊 Flux', '✅ Flux Services Initialized Successfully');
  } catch (e, stackTrace) {
    FluxLogger.error(
        '🌊 Flux', '❌ Flux Services Initialization Failed', e, stackTrace);
    rethrow;
  }
}

/// 🌊 Flux Ledger 主应用组件
class FluxLedgerApp extends StatelessWidget {
  const FluxLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<FluxThemeProvider>(context);

    return MaterialApp.router(
      title: 'Flux Ledger - 流式记账',
      theme: _buildFluxTheme(Brightness.light),
      darkTheme: _buildFluxTheme(Brightness.dark),
      themeMode: themeProvider.themeMode,
      routerConfig: fluxRouter,
      debugShowCheckedModeBanner: false,

      // 国际化支持
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

      // Web端适配
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        ),
      ),
    );
  }

  /// 构建Flux主题
  ThemeData _buildFluxTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primaryColor: FluxTheme.flowBlue,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : FluxTheme.flowBackground,

      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: FluxTheme.flowBlue,
        unselectedItemColor: FluxTheme.neutralGray,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : FluxTheme.flowCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluxTheme.flowCardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluxTheme.flowInputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluxTheme.flowInputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluxTheme.flowInputRadius),
          borderSide: const BorderSide(
            color: FluxTheme.flowBlue,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: FluxTheme.flowPrimaryButton,
      ),

      // 文本主题
      textTheme: TextTheme(
        // 标题样式
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: Color(0xFF1C1C1E),
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: Color(0xFF1C1C1E),
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Color(0xFF1C1C1E),
        ),

        // 正文样式
        bodyLarge: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: Color(0xFF3C3C43),
        ),
        bodyMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: Color(0xFF3C3C43),
        ),

        // 标签样式
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Color(0xFF1C1C1E),
        ),
        labelMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: Color(0xFF1C1C1E),
        ),

        // 辅助样式
        bodySmall: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.3,
          color: Color(0xFF8E8E93),
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: Color(0xFF8E8E93),
        ),
      ),

      // 颜色方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: FluxTheme.flowBlue,
        brightness: brightness,
        primary: FluxTheme.flowBlue,
        secondary: FluxTheme.incomeGreen,
        error: FluxTheme.expenseRed,
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        background: isDark ? const Color(0xFF121212) : FluxTheme.flowBackground,
      ),

      // 扩展主题
      extensions: const [
        // 金额样式扩展
        AmountTextTheme(
          positive: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: FluxTheme.incomeGreen,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          negative: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: FluxTheme.expenseRed,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          neutral: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// 金额文本主题扩展
class AmountTextTheme extends ThemeExtension<AmountTextTheme> {
  final TextStyle positive;
  final TextStyle negative;
  final TextStyle neutral;

  const AmountTextTheme({
    required this.positive,
    required this.negative,
    required this.neutral,
  });

  @override
  ThemeExtension<AmountTextTheme> copyWith({
    TextStyle? positive,
    TextStyle? negative,
    TextStyle? neutral,
  }) {
    return AmountTextTheme(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  ThemeExtension<AmountTextTheme> lerp(
    covariant ThemeExtension<AmountTextTheme>? other,
    double t,
  ) {
    if (other is! AmountTextTheme) return this;
    return AmountTextTheme(
      positive: TextStyle.lerp(positive, other.positive, t)!,
      negative: TextStyle.lerp(negative, other.negative, t)!,
      neutral: TextStyle.lerp(neutral, other.neutral, t)!,
    );
  }
}

/// 扩展方法：获取金额文本样式
extension AmountTextThemeExtension on BuildContext {
  AmountTextTheme get amountTheme {
    return Theme.of(this).extension<AmountTextTheme>() ??
        const AmountTextTheme(
          positive: TextStyle(
              color: FluxTheme.incomeGreen, fontWeight: FontWeight.w700),
          negative: TextStyle(
              color: FluxTheme.expenseRed, fontWeight: FontWeight.w700),
          neutral:
              TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.w600),
        );
  }
}

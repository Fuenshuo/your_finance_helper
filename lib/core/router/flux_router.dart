/// 🌊 Flux Ledger 路由配置
///
/// 基于GoRouter的流式导航架构
/// 支持深度链接和状态保持
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';
import 'package:your_finance_flutter/screens/dashboard_home_screen.dart';
import 'package:your_finance_flutter/screens/settings_screen.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

/// Flux Ledger 路由配置
final fluxRouter = GoRouter(
  initialLocation: FluxRoutes.dashboard,
  debugLogDiagnostics: true,
  routes: [
    // 主导航路由
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          FluxNavigationScreen(navigationShell: navigationShell),
      branches: [
        // 流仪表板分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: FluxRoutes.dashboard,
              builder: (context, state) => const DashboardHomeScreen(),
            ),
          ],
        ),

        // 流管道分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: FluxRoutes.streams,
              builder: (context, state) =>
                  const UnifiedTransactionEntryScreen(), // 流管道 - 交易录入界面
            ),
          ],
        ),

        // 流洞察分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: FluxRoutes.insights,
              builder: (context, state) => const FluxInsightsScreen(),
              routes: [
                // 洞察相关子路由
                GoRoute(
                  path: 'detail/:insightId',
                  builder: (context, state) {
                    // Placeholder for insight detail - FluxInsightsScreen focuses on main dashboard
                    return const Scaffold(
                      body: Center(
                        child: Text('Insight Detail - Coming Soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // 独立页面路由
    GoRoute(
      path: FluxRoutes.onboarding,
      builder: (context, state) => const Placeholder(), // TODO: 实现引导屏幕
    ),

    GoRoute(
      path: FluxRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: FluxRoutes.flowEntry,
      builder: (context, state) =>
          const UnifiedTransactionEntryScreen(), // 流程录入 - 交易录入界面
    ),

    GoRoute(
      path: FluxRoutes.developer,
      builder: (context, state) => const Placeholder(), // TODO: 实现开发者屏幕
    ),

    // 数据迁移相关路由
    GoRoute(
      path: '/migration',
      builder: (context, state) => const Placeholder(), // TODO: 实现数据迁移屏幕
    ),
  ],

  // 错误处理
  errorBuilder: (context, state) => FluxErrorScreen(
    error: state.error,
    stackTrace: StackTrace.current,
  ),

  // 重定向逻辑
  redirect: (context, state) {
    // 检查是否需要显示引导页
    final isFirstLaunch = _checkFirstLaunch();
    if (isFirstLaunch && state.matchedLocation != FluxRoutes.onboarding) {
      return FluxRoutes.onboarding;
    }

    // 检查数据迁移状态
    final needsMigration = _checkNeedsMigration();
    if (needsMigration && state.matchedLocation != '/migration') {
      return '/migration';
    }

    return null;
  },
);

/// 路由路径常量
class FluxRoutes {
  // 主导航
  static const String dashboard = '/dashboard';
  static const String streams = '/streams';
  static const String insights = '/insights';

  // 功能页面
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String flowEntry = '/flow-entry';
  static const String developer = '/developer';

  // 工具方法
  static String flowDetail(String flowId) => '/dashboard/flow-detail/$flowId';
  static String streamDetail(String streamId) => '/streams/detail/$streamId';
  static String insightDetail(String insightId) =>
      '/insights/detail/$insightId';
}

/// 检查是否首次启动
bool _checkFirstLaunch() {
  // TODO: 实现首次启动检查逻辑
  return false;
}

/// 检查是否需要数据迁移
bool _checkNeedsMigration() {
  // TODO: 实现数据迁移检查逻辑
  return false;
}

// ==================== 导航屏幕 ====================

/// 🌊 Flux Ledger 主导航屏幕
class FluxNavigationScreen extends StatefulWidget {
  const FluxNavigationScreen({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  State<FluxNavigationScreen> createState() => _FluxNavigationScreenState();
}

class _FluxNavigationScreenState extends State<FluxNavigationScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: widget.navigationShell,
        bottomNavigationBar: FluxBottomNavigationBar(
          navigationShell: widget.navigationShell,
        ),
        floatingActionButton: const FluxFloatingActionButton(),
      );

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Flux Ledger',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(FluxRoutes.settings),
            tooltip: '设置',
          ),
        ],
      );
}

/// 🌊 Flux底部导航栏
class FluxBottomNavigationBar extends StatelessWidget {
  const FluxBottomNavigationBar({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: '流仪表板',
              tooltip: '实时资金流可视化',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.waterfall_chart_outlined),
              activeIcon: Icon(Icons.waterfall_chart),
              label: '流管道',
              tooltip: '管理持续性资金流',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: '流洞察',
              tooltip: 'AI智能分析与建议',
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
}

/// 🌊 Flux浮动操作按钮
class FluxFloatingActionButton extends StatelessWidget {
  const FluxFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: () {
          // 导航到流录入页面
          context.go(FluxRoutes.flowEntry);
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      );
}

// ==================== 路由守卫 ====================

/// 路由守卫 - 检查用户认证状态
class FluxAuthGuard {
  String? redirect(BuildContext context, GoRouterState state) {
    // TODO: 实现认证检查
    // final isAuthenticated = ref.watch(authProvider).isAuthenticated;
    // if (!isAuthenticated && !state.matchedLocation.startsWith('/auth')) {
    //   return '/auth/login';
    // }
    return null;
  }
}

/// 路由守卫 - 检查数据迁移状态
class FluxMigrationGuard {
  String? redirect(BuildContext context, GoRouterState state) {
    // TODO: 实现迁移检查
    // final needsMigration = ref.watch(migrationProvider).needsMigration;
    // if (needsMigration && !state.matchedLocation.startsWith('/migration')) {
    //   return '/migration';
    // }
    return null;
  }
}

// ==================== 导航扩展方法 ====================

/// 导航扩展方法
extension FluxNavigationExtension on BuildContext {
  /// 导航到流仪表板
  void goToDashboard() => go(FluxRoutes.dashboard);

  /// 导航到流管道
  void goToStreams() => go(FluxRoutes.streams);

  /// 导航到流洞察
  void goToInsights() => go(FluxRoutes.insights);

  /// 导航到设置页面
  void goToSettings() => go(FluxRoutes.settings);

  /// 导航到流录入
  void goToFlowEntry() => go(FluxRoutes.flowEntry);

  /// 导航到特定资金流详情
  void goToFlowDetail(String flowId) => go(FluxRoutes.flowDetail(flowId));

  /// 导航到特定流管道详情
  void goToStreamDetail(String streamId) =>
      go(FluxRoutes.streamDetail(streamId));

  /// 导航到特定洞察详情
  void goToInsightDetail(String insightId) =>
      go(FluxRoutes.insightDetail(insightId));

  /// 返回上一页
  void goBack() => pop();
}

/// 路由观察者 - 用于分析用户行为
class FluxRouteObserver extends RouteObserver<PageRoute<dynamic>> {}

// ==================== 屏幕占位符 ====================

/// 错误屏幕
class FluxErrorScreen extends StatelessWidget {
  const FluxErrorScreen({
    super.key,
    this.error,
    this.stackTrace,
  });
  final Exception? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('发生错误')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error?.toString() ?? '未知错误',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(FluxRoutes.dashboard),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      );
}

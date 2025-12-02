import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/core/widgets/app_bottom_navigation_bar.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';
import 'package:your_finance_flutter/screens/developer_mode_screen.dart';
import 'package:your_finance_flutter/screens/dialogs/flux_insights_dialog.dart';
import 'package:your_finance_flutter/screens/settings_screen.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

/// 主导航页面 - Flux Ledger 四 Tab 入口
class MainNavigationScreen extends ConsumerStatefulWidget {
  /// Creates the primary Flux Ledger shell with bottom navigation.
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  static const String _insightsDialogKey = 'has_seen_flux_insights_v1';

  int _selectedIndex = 0;
  final DebugModeManager _debugManager = DebugModeManager();
  ProviderSubscription<StreamInsightsFlagProvider>? _flagSubscription;
  bool _hasLoggedFlagExposure = false;

  static const Widget _assetsPlaceholder = _PlaceholderScreen(
    title: 'Assets',
    subtitle: '资产与账户模块即将上线',
    icon: Icons.account_balance_wallet_outlined,
  );

  static const Widget _mePlaceholder = _PlaceholderScreen(
    title: 'Me',
    subtitle: '个人中心即将上线',
    icon: Icons.person_outline,
  );

  static const List<Widget> _legacyScreens = [
    UnifiedTransactionEntryScreen(),
    FluxInsightsScreen(),
    _assetsPlaceholder,
    _mePlaceholder,
  ];

  static const List<Widget> _mergedScreens = [
    UnifiedTransactionEntryScreen(),
    _assetsPlaceholder,
    _mePlaceholder,
  ];

  static const BottomNavigationBarItem _streamNavItem =
      BottomNavigationBarItem(
    icon: Icon(Icons.timeline_outlined),
    activeIcon: Icon(Icons.timeline),
    label: 'Stream',
    tooltip: 'Smart Timeline',
  );

  static const BottomNavigationBarItem _insightsNavItem =
      BottomNavigationBarItem(
    icon: Icon(Icons.insights_outlined),
    activeIcon: Icon(Icons.insights),
    label: 'Insights',
    tooltip: '图表洞察',
  );

  static const BottomNavigationBarItem _assetsNavItem =
      BottomNavigationBarItem(
    icon: Icon(Icons.account_balance_wallet_outlined),
    activeIcon: Icon(Icons.account_balance_wallet),
    label: 'Assets',
    tooltip: '资产与账户',
  );

  static const BottomNavigationBarItem _meNavItem = BottomNavigationBarItem(
    icon: Icon(Icons.person_outline),
    activeIcon: Icon(Icons.person),
    label: 'Me',
    tooltip: '个人中心',
  );

  static const List<BottomNavigationBarItem> _legacyNavItems = [
    _streamNavItem,
    _insightsNavItem,
    _assetsNavItem,
    _meNavItem,
  ];

  static const List<BottomNavigationBarItem> _mergedNavItems = [
    _streamNavItem,
    _assetsNavItem,
    _meNavItem,
  ];

  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugModeChanged);
    _flagSubscription = ref.listenManual<StreamInsightsFlagProvider>(
      streamInsightsFlagStateProvider,
      (previous, next) => _handleFlagChanged(next.isEnabled),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFlagChanged(ref.read(streamInsightsFlagStateProvider).isEnabled);
      _showFluxInsightsDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugModeChanged);
    _flagSubscription?.close();
    super.dispose();
  }

  void _onDebugModeChanged() => setState(() {});

  Future<void> _showFluxInsightsDialogIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_insightsDialogKey) ?? false;
    final flagEnabled = ref.read(streamInsightsFlagStateProvider).isEnabled;

    if (hasSeen || !mounted || flagEnabled) {
      return;
    }

    await prefs.setBool(_insightsDialogKey, true);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FluxInsightsDialog(
        onConfirm: () => _handleNavTap(1),
      ),
    );
  }

  void _handleFlagChanged(bool isEnabled) {
    ref.read(fluxViewStateProvider.notifier).syncFlag(isEnabled: isEnabled);
    if (isEnabled && !_hasLoggedFlagExposure) {
      PerformanceMonitor.logFlagExposureTelemetry(flagEnabled: true);
      _hasLoggedFlagExposure = true;
    } else if (!isEnabled) {
      _hasLoggedFlagExposure = false;
    }
    if (!mounted) {
      return;
    }
    if (isEnabled && _selectedIndex == 1) {
      setState(() => _selectedIndex = 0);
      return;
    }
    final maxIndex = (isEnabled ? _mergedNavItems : _legacyNavItems).length - 1;
    if (_selectedIndex > maxIndex) {
      setState(() => _selectedIndex = maxIndex);
    }
  }

  void _handleNavTap(int index) {
    final isMergedEnabled = ref.read(streamInsightsFlagStateProvider).isEnabled;
    final navItems = isMergedEnabled ? _mergedNavItems : _legacyNavItems;
    final safeIndex = index.clamp(0, navItems.length - 1);
    final label = navItems[safeIndex].label ?? 'Tab $safeIndex';
    PerformanceMonitor.logBottomTabSelection(
      index: index,
      label: label,
      flagEnabled: isMergedEnabled,
    );
    if (isMergedEnabled) {
      if (index == 0) {
        final currentViewState = ref.read(fluxViewStateProvider);
        if (currentViewState.pane != FluxPane.timeline) {
          ref.read(fluxViewStateProvider.notifier).setPane(FluxPane.timeline);
          PerformanceMonitor.logViewToggleTelemetry(
            pane: FluxPane.timeline,
            timeframe: currentViewState.timeframe,
            flagEnabled: isMergedEnabled,
            metadata: const <String, Object?>{'source': 'bottom_tab'},
          );
        }
      }
      if (_selectedIndex != index) {
        setState(() => _selectedIndex = index);
      }
      return;
    }
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagProvider = ref.watch(streamInsightsFlagStateProvider);
    final mergedNavigationEnabled = flagProvider.isEnabled;
    final stackChildren =
        mergedNavigationEnabled ? _mergedScreens : _legacyScreens;
    final navItems =
        mergedNavigationEnabled ? _mergedNavItems : _legacyNavItems;
    final currentIndex = _selectedIndex >= navItems.length
        ? navItems.length - 1
        : _selectedIndex;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            final debugEnabled = _debugManager.handleClick();
            if (debugEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔧 Debug模式已开启'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Flux Ledger'),
        ),
        backgroundColor: context.surfaceWhite,
        elevation: 0,
        actions: [
          if (_debugManager.isDebugModeEnabled) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DEBUG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.developer_mode, color: Colors.orange),
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute<void>(
                    const DeveloperModeScreen(),
                  ),
                );
              },
              tooltip: '开发者模式',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                AppAnimations.createRoute<void>(
                  const SettingsScreen(),
                ),
              );
            },
            tooltip: '设置',
          ),
        ],
      ),
      backgroundColor: context.primaryBackground,
      body: IndexedStack(
        index: currentIndex,
        children: stackChildren,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        items: navItems,
        currentIndex: currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}

/// 占位页面
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: context.secondaryText,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

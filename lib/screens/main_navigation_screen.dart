import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/models/flux_view_state.dart';
import 'package:your_finance_flutter/core/providers/flux_providers.dart';
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/performance_monitor.dart';
import 'package:your_finance_flutter/core/widgets/app_bottom_navigation_bar.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';
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
  int _selectedIndex = 0;
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

  static const BottomNavigationBarItem _streamNavItem = BottomNavigationBarItem(
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

  static const BottomNavigationBarItem _assetsNavItem = BottomNavigationBarItem(
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
    _flagSubscription = ref.listenManual<StreamInsightsFlagProvider>(
      streamInsightsFlagStateProvider,
      (previous, next) => _handleFlagChanged(next.isEnabled),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFlagChanged(ref.read(streamInsightsFlagStateProvider).isEnabled);
    });
  }

  @override
  void dispose() {
    _flagSubscription?.close();
    super.dispose();
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
        title: const Text('Flux Ledger'),
        backgroundColor: context.surfaceWhite,
        elevation: 0,
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

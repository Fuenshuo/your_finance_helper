import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_bottom_navigation_bar.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/screens/developer_mode_screen.dart';
import 'package:your_finance_flutter/screens/dialogs/flux_insights_dialog.dart';
import 'package:your_finance_flutter/features/insights/screens/flux_insights_screen.dart';
import 'package:your_finance_flutter/screens/settings_screen.dart';
import 'package:your_finance_flutter/screens/unified_transaction_entry_screen.dart';

/// 主导航页面 - Flux Ledger 四 Tab 入口
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const String _insightsDialogKey = 'has_seen_flux_insights_v1';

  int _selectedIndex = 0;
  final DebugModeManager _debugManager = DebugModeManager();

  static const List<Widget> _screens = [
    UnifiedTransactionEntryScreen(),
    FluxStreamsScreen(),
    _PlaceholderScreen(
      title: 'Assets',
      subtitle: '资产与账户模块即将上线',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PlaceholderScreen(
      title: 'Me',
      subtitle: '个人中心即将上线',
      icon: Icons.person_outline,
    ),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.timeline_outlined),
      activeIcon: Icon(Icons.timeline),
      label: 'Stream',
      tooltip: 'Smart Timeline',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.insights_outlined),
      activeIcon: Icon(Icons.insights),
      label: 'Insights',
      tooltip: '图表洞察',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      activeIcon: Icon(Icons.account_balance_wallet),
      label: 'Assets',
      tooltip: '资产与账户',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Me',
      tooltip: '个人中心',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugModeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFluxInsightsDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugModeChanged);
    super.dispose();
  }

  void _onDebugModeChanged() => setState(() {});

  Future<void> _showFluxInsightsDialogIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_insightsDialogKey) ?? false;

    if (hasSeen || !mounted) {
      return;
    }

    await prefs.setBool(_insightsDialogKey, true);

    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FluxInsightsDialog(
        onConfirm: () => setState(() => _selectedIndex = 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      );
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

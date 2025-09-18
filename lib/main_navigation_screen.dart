import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/utils/debug_mode_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';
import 'package:your_finance_flutter/features/family_info/screens/family_info_home_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/financial_planning_home_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_flow_home_screen.dart';
import 'package:your_finance_flutter/screens/developer_mode_screen.dart';
import 'package:your_finance_flutter/screens/settings_screen.dart';

/// 主导航页面 - 三层架构的核心导航
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final DebugModeManager _debugManager = DebugModeManager();

  @override
  void initState() {
    super.initState();
    _debugManager.addListener(_onDebugModeChanged);
  }

  @override
  void dispose() {
    _debugManager.removeListener(_onDebugModeChanged);
    super.dispose();
  }

  void _onDebugModeChanged() {
    setState(() {});
  }

  static const List<Widget> _screens = [
    FamilyInfoHomeScreen(),
    FinancialPlanningHomeScreen(),
    TransactionFlowHomeScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: '家庭信息',
      tooltip: '家庭信息维护',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: '财务计划',
      tooltip: '财务计划管理',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined),
      activeIcon: Icon(Icons.receipt_long),
      label: '交易流水',
      tooltip: '交易流水记录',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            child: const Text('家庭资产记账'),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Debug模式指示器和开关
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
                    AppAnimations.createRoute(
                      const DeveloperModeScreen(),
                    ),
                  );
                },
                tooltip: '开发者模式',
              ),
            ],

            // 设置按钮
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  AppAnimations.createRoute(
                    const SettingsScreen(),
                  ),
                );
              },
              tooltip: '设置',
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: context.primaryColor,
          unselectedItemColor: context.secondaryText,
          selectedLabelStyle: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: context.textTheme.bodySmall,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      );
}

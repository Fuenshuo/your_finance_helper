import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/core/widgets/app_bottom_navigation_bar.dart';
import 'package:your_finance_flutter/features/family_info/screens/family_info_home_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_flow_home_screen.dart';
import 'package:your_finance_flutter/screens/dashboard_home_screen.dart';
import 'package:your_finance_flutter/screens/personal_screen.dart';

/// 主导航页面 - 重构后的5个Tab导航
/// Tab 1: 概览 (Dashboard) - 新
/// Tab 2: 资产 (Assets) - 原Tab 1
/// Tab 3: 记账 (Timeline) - 原Tab 3
/// Tab 4: 统计 (Analysis) - 新拆分
/// Tab 5: 设置 (Settings) - 原Tab 4
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardHomeScreen(), // Tab 1: 概览
    FamilyInfoHomeScreen(), // Tab 2: 资产
    TransactionFlowHomeScreen(), // Tab 3: 记账
    _PlaceholderScreen(title: '统计'), // Tab 4: 统计（待实现）
    PersonalScreen(), // Tab 5: 设置
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: '概览',
      tooltip: '财务概览',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      activeIcon: Icon(Icons.account_balance_wallet),
      label: '资产',
      tooltip: '资产管理',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined),
      activeIcon: Icon(Icons.receipt_long),
      label: '记账',
      tooltip: '交易记录',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: '统计',
      tooltip: '数据分析',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: '设置',
      tooltip: '个人设置',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _getAppBarTitle(),
            style: context.textTheme.headlineMedium,
          ),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: _navItems,
          selectedItemColor: context.primaryColor,
          unselectedItemColor: context.secondaryText,
        ),
      );

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '财务概览';
      case 1:
        return '资产管理';
      case 2:
        return '交易记录';
      case 3:
        return '数据分析';
      case 4:
        return '个人设置';
      default:
        return '家庭资产记账';
    }
  }
}

/// 占位页面（用于Tab 4统计页面，待实现）
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: context.secondaryText,
              ),
              SizedBox(height: context.spacing16),
              Text(
                '$title功能开发中...',
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
}

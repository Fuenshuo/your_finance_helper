import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/theme/app_theme.dart';
import 'package:your_finance_flutter/features/family_info/screens/family_info_home_screen.dart';
import 'package:your_finance_flutter/features/financial_planning/screens/financial_planning_home_screen.dart';
import 'package:your_finance_flutter/features/transaction_flow/screens/transaction_flow_home_screen.dart';
import 'package:your_finance_flutter/screens/personal_screen.dart';

/// 主导航页面 - 三层架构的核心导航
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    FamilyInfoHomeScreen(),
    FinancialPlanningHomeScreen(),
    TransactionFlowHomeScreen(),
    PersonalScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: '家庭信息',
      tooltip: '家庭信息维护',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: '财务规划',
      tooltip: '预算与规划',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.swap_horiz_outlined),
      activeIcon: Icon(Icons.swap_horiz),
      label: '收支流水',
      tooltip: '交易记录',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: '个人',
      tooltip: '个人中心',
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: _navItems,
        ),
      );

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '家庭信息';
      case 1:
        return '财务规划';
      case 2:
        return '收支流水';
      case 3:
        return '个人';
      default:
        return '家庭资产记账';
    }
  }
}

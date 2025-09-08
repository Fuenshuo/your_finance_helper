import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetProvider>(
      builder: (context, assetProvider, child) {
        // 如果还没有资产数据，显示引导页面
        if (assetProvider.assets.isEmpty) {
          return const OnboardingScreen();
        }
        
        // 否则显示主仪表盘
        return const DashboardScreen();
      },
    );
  }
}

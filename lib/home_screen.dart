import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_finance_flutter/core/providers/asset_provider.dart';
import 'package:your_finance_flutter/screens/onboarding_screen.dart';
import 'package:your_finance_flutter/screens/main_navigation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AssetProvider>(
      builder: (context, assetProvider, child) {
        // 如果还没有资产数据，显示引导页面
        if (assetProvider.assets.isEmpty) {
          return const OnboardingScreen();
        }

        // 否则显示新的三层架构主导航
        return const MainNavigationScreen();
      },
    );
}

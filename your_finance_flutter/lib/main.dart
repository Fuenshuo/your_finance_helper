import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/asset_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssetProvider()..initialize(),
      child: MaterialApp(
        title: '家庭资产记账',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_finance_flutter/main.dart' as app;
import 'package:your_finance_flutter/ios_animation_showcase.dart';
import 'package:your_finance_flutter/screens/debug_screen.dart';

/// 集成测试 - 验证动画特效在真实应用中的运行效果
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Animation Integration Tests', () {
    testWidgets('App starts and animation demo page loads', (tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 验证应用启动成功
      expect(find.byType(MaterialApp), findsOneWidget);

      // 查找并点击动画演示按钮（假设在主页面有）
      final animationButton = find.text('动画演示');
      if (animationButton.evaluate().isNotEmpty) {
        await tester.tap(animationButton);
        await tester.pumpAndSettle();

        // 验证动画演示页面加载
        expect(find.text('🎨 金融记账动画特效验证'), findsOneWidget);
        expect(find.text('⚡ 快速测试'), findsOneWidget);
      }
    });

    testWidgets('Animation demo page shows all test buttons', (tester) async {
      // 直接导航到动画演示页面
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证页面标题和内容
      expect(find.text('🎨 金融记账动画特效验证'), findsOneWidget);
      expect(find.text('⚡ 快速测试'), findsOneWidget);

      // 验证所有测试按钮都存在
      expect(find.text('金额脉冲'), findsOneWidget);
      expect(find.text('金额颜色'), findsOneWidget);
      expect(find.text('波纹效果'), findsOneWidget);
      expect(find.text('列表插入'), findsOneWidget);
      expect(find.text('交易确认'), findsOneWidget);
      expect(find.text('预算庆祝'), findsOneWidget);
      expect(find.text('跳动反馈'), findsOneWidget);
      expect(find.text('分类选择'), findsOneWidget);
      expect(find.text('保存确认'), findsOneWidget);
      expect(find.text('键盘按键'), findsOneWidget);
    });

    testWidgets('Amount pulse animation dialog works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // 点击金额脉冲按钮
      await tester.tap(find.text('金额脉冲'));
      await tester.pumpAndSettle();

      // 验证对话框打开
      expect(find.text('金额脉冲动画'), findsOneWidget);
      expect(find.text('¥1,234.56'), findsOneWidget);

      // 关闭对话框
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      // 验证对话框关闭
      expect(find.text('金额脉冲动画'), findsNothing);
    });

    testWidgets('Category select animation works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // 点击分类选择按钮
      await tester.tap(find.text('分类选择'));
      await tester.pumpAndSettle();

      // 验证对话框打开
      expect(find.text('分类选择缩放动画'), findsOneWidget);

      // 验证分类项存在
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('娱乐'), findsOneWidget);

      // 关闭对话框
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      // 验证对话框关闭
      expect(find.text('分类选择缩放动画'), findsNothing);
    });

    testWidgets('Keypad animation works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // 点击键盘按键按钮
      await tester.tap(find.text('键盘按键'));
      await tester.pumpAndSettle();

      // 验证对话框打开
      expect(find.text('数字键盘按键动画'), findsOneWidget);

      // 验证数字按键存在
      for (var i = 1; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }

      // 关闭对话框
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      // 验证对话框关闭
      expect(find.text('数字键盘按键动画'), findsNothing);
    });

    testWidgets('Debug screen animation buttons work', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DebugScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 验证动画演示卡片存在
      expect(find.text('🎨 动画特效演示'), findsOneWidget);
      expect(find.text('快速演示'), findsOneWidget);
      expect(find.text('完整演示'), findsOneWidget);
    });
  });
}

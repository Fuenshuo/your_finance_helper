import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';

void main() {
  group('AppAnimations Tests', () {
    // 基础功能测试 - 只测试静态创建，不涉及动画状态
    test('AppAnimations static methods exist', () {
      expect(AppAnimations.animatedAmountPulse, isNotNull);
      expect(AppAnimations.animatedAmountColor, isNotNull);
      expect(AppAnimations.animatedBalanceRipple, isNotNull);
      expect(AppAnimations.animatedListInsert, isNotNull);
      expect(AppAnimations.animatedTransactionConfirm, isNotNull);
      expect(AppAnimations.animatedBudgetCelebration, isNotNull);
      expect(AppAnimations.animatedAmountBounce, isNotNull);
      expect(AppAnimations.animatedCategorySelect, isNotNull);
      expect(AppAnimations.animatedSaveConfirm, isNotNull);
      expect(AppAnimations.animatedKeypadButton, isNotNull);
    });

    // 简单的组件创建测试
    testWidgets('Basic animations create widgets without errors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              AppAnimations.animatedAmountPulse(
                child: const Text('Pulse'),
                isPositive: true,
              ),
              AppAnimations.animatedAmountColor(
                amount: 50.0,
                formatter: (v) => '\$$v',
                isPositive: true,
              ),
              AppAnimations.animatedBalanceRipple(
                child: const Text('Ripple'),
                hasChanged: false,
              ),
              AppAnimations.animatedTransactionConfirm(
                child: const Text('Confirm'),
                showConfirm: false,
              ),
              AppAnimations.animatedBudgetCelebration(
                child: const Text('Celebrate'),
                showCelebration: false,
              ),
              AppAnimations.animatedAmountBounce(
                child: const Text('Bounce'),
                isBouncing: false,
              ),
              AppAnimations.animatedCategorySelect(
                child: const Text('Select'),
                isSelected: false,
              ),
              AppAnimations.animatedSaveConfirm(
                child: const Text('Save'),
                showConfirm: false,
              ),
              AppAnimations.animatedKeypadButton(
                child: const Text('Key'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // 验证所有组件都成功创建
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(9));

      // 验证具体文本内容
      expect(find.text('Pulse'), findsOneWidget);
      expect(find.text(r'$50.0'), findsOneWidget);
      expect(find.text('Ripple'), findsOneWidget);
    });

    // 单独测试有延迟动画的组件
    testWidgets('List insert animation basic functionality', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAnimations.animatedListInsert(
            child: const Text('List Item'),
            index: 0,
          ),
        ),
      );

      expect(find.text('List Item'), findsOneWidget);

      // 等待可能的延迟动画完成
      await tester.pumpAndSettle();
    });
  });
}

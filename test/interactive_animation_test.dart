import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/ios_animation_showcase.dart';

void main() {
  group('Interactive Animation Tests', () {
    testWidgets('Bounce demo shows button and triggers animation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap bounce demo button
      expect(find.text('跳动反馈'), findsOneWidget);
      await tester.tap(find.text('跳动反馈'));
      await tester.pumpAndSettle();

      // Verify bounce dialog opens
      expect(find.text('金额输入跳动反馈'), findsOneWidget);
      expect(find.text('点击触发跳动反馈'), findsOneWidget);
      expect(find.text('¥1,234.56'), findsOneWidget);

      // Tap the bounce trigger button
      await tester.tap(find.text('点击触发跳动反馈'));
      await tester.pumpAndSettle();

      // Dialog should still be open
      expect(find.text('金额输入跳动反馈'), findsOneWidget);
    });

    testWidgets('Category select demo shows interactive categories',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap category demo button
      expect(find.text('分类选择'), findsOneWidget);
      await tester.tap(find.text('分类选择'));
      await tester.pumpAndSettle();

      // Verify category dialog opens
      expect(find.text('分类选择缩放动画'), findsOneWidget);
      expect(find.text('点击下方分类选项查看动画效果：'), findsOneWidget);

      // Check that all categories are displayed
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('娱乐'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
      expect(find.text('医疗'), findsOneWidget);

      // Initially no category should be selected (all should look unselected)
      // Tap on a category to select it
      await tester.tap(find.text('交通'));
      await tester.pumpAndSettle();

      // Dialog should still be open and category should be selectable
      expect(find.text('分类选择缩放动画'), findsOneWidget);
    });

    testWidgets('Bounce animation state resets after duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IOSAnimationShowcase(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap bounce demo button
      await tester.tap(find.text('跳动反馈'));
      await tester.pumpAndSettle();

      expect(find.text('金额输入跳动反馈'), findsOneWidget);

      // Trigger bounce
      await tester.tap(find.text('点击触发跳动反馈'));
      await tester.pump();

      // Wait for animation to complete (400ms + buffer)
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Dialog should still be open
      expect(find.text('金额输入跳动反馈'), findsOneWidget);
    });
  });
}

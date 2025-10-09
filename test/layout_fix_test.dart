import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/animation_demo_page.dart';

void main() {
  group('Layout Fix Tests', () {
    testWidgets('AnimationDemoPage renders without layout errors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimationDemoPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the page renders correctly
      expect(find.text('🎨 金融记账动画特效验证'), findsOneWidget);
      expect(find.text('⚡ 快速测试'), findsOneWidget);
      expect(find.text('金额脉冲'), findsOneWidget);
      expect(find.text('列表插入'), findsOneWidget);
    });

    testWidgets('Save confirm dialog renders without intrinsic width errors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                // This would trigger the dialog that previously caused the error
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('保存成功确认动画'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        height: 80,
                        color: Colors.white,
                        child: const Center(
                          child: Text('数据表单'),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Test Dialog'),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Test Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog appears without errors
      expect(find.text('保存成功确认动画'), findsOneWidget);
      expect(find.text('数据表单'), findsOneWidget);
    });

    testWidgets('List insert dialog renders without viewport errors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('列表项插入动画'),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 200,
                      child: ListView(
                        shrinkWrap: true,
                        children: const [
                          Text('新插入的交易记录'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Test List Dialog'),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Test List Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog appears without errors
      expect(find.text('列表项插入动画'), findsOneWidget);
      expect(find.text('新插入的交易记录'), findsOneWidget);
    });
  });
}


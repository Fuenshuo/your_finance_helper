import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/theme/app_design_tokens.dart';

void main() {
  group('AppDesignTokens Dynamic Getters', () {
    testWidgets('pageBackground returns correct color for light theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.pageBackground(context),
                  const Color(0xFFF5F7FA));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('pageBackground returns correct color for dark theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.pageBackground(context),
                  const Color(0xFF000000));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('primaryText returns correct color for light theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.primaryText(context),
                  const Color(0xFF1C1C1E));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('primaryText returns correct color for dark theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.primaryText(context),
                  const Color(0xFFFFFFFF));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('amountPositiveColor returns correct color for fluxBlue theme',
        (tester) async {
      AppDesignTokens.setMoneyTheme(MoneyTheme.fluxBlue);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.amountPositiveColor(context),
                  const Color(0xFF0A84FF));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets(
        'amountPositiveColor returns correct color for forestEmerald theme',
        (tester) async {
      AppDesignTokens.setMoneyTheme(MoneyTheme.forestEmerald);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.amountPositiveColor(context),
                  const Color(0xFF2E7D32));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('amountNegativeColor returns universal red', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.amountNegativeColor(context),
                  const Color(0xFFFF3B30));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('primaryAction returns correct color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.primaryAction(context),
                  const Color(0xFF007AFF));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('successColor returns correct color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.successColor(context),
                  const Color(0xFF8BC34A));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('surface returns correct color for light theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.surface(context), const Color(0xFFFFFFFF));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('surface returns correct color for dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              expect(AppDesignTokens.surface(context), const Color(0xFF1C1C1E));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('typography has correct sizes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final largeTitle = AppDesignTokens.largeTitle(context);
              expect(largeTitle.fontSize, 32);
              expect(largeTitle.fontWeight, FontWeight.bold);

              final body = AppDesignTokens.body(context);
              expect(body.fontSize, 16);
              expect(body.fontWeight, FontWeight.w400);

              final caption = AppDesignTokens.caption(context);
              expect(caption.fontSize, 14);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('AppDesignTokens Theme Switching', () {
    test('setTheme changes the current theme', () {
      final originalTheme = AppDesignTokens.getCurrentTheme();

      AppDesignTokens.setTheme(AppTheme.eleganceDeepBlue);
      expect(AppDesignTokens.getCurrentTheme(), AppTheme.eleganceDeepBlue);

      // Reset to original
      AppDesignTokens.setTheme(originalTheme);
      expect(AppDesignTokens.getCurrentTheme(), originalTheme);
    });

    test('setStyle changes the current style', () {
      final originalStyle = AppDesignTokens.getCurrentStyle();

      AppDesignTokens.setStyle(AppStyle.SharpProfessional);
      expect(AppDesignTokens.getCurrentStyle(), AppStyle.SharpProfessional);

      // Reset to original
      AppDesignTokens.setStyle(originalStyle);
      expect(AppDesignTokens.getCurrentStyle(), originalStyle);
    });
  });
}

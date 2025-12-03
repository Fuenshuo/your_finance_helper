import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/animations/animation_config.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_system.dart';

void main() {
  group('IOSAnimationSystem Basic Tests', () {
    late IOSAnimationSystem animationSystem;

    setUp(() {
      animationSystem = IOSAnimationSystem();
    });

    tearDown(() {
      animationSystem.dispose();
    });

    test('should create instance', () {
      expect(animationSystem, isNotNull);
    });

    test('should update theme', () {
      const newTheme = IOSAnimationTheme(
        enableAnimations: false,
        animationSpeed: 2.0,
      );

      animationSystem.updateTheme(newTheme);
      expect(animationSystem.currentTheme.enableAnimations, false);
      expect(animationSystem.currentTheme.animationSpeed, 2.0);
    });

    test('should cancel animation', () {
      const animationId = 'test-animation';
      animationSystem.cancelAnimation(animationId);
      // Should not throw any errors
    });

    test('dispose should clean up resources', () {
      animationSystem.dispose();
      // Should not throw any errors
    });
  });

  group('IOSAnimationSpec Tests', () {
    test('buttonTap spec should have correct properties', () {
      const spec = IOSAnimationSpec.buttonTap;

      expect(spec.type, AnimationType.tap);
      expect(spec.enableHaptic, true);
      expect(spec.begin, 1.0);
      expect(spec.end, IOSAnimationConfig.tapScale);
    });

    test('successFeedback spec should have correct properties', () {
      const spec = IOSAnimationSpec.successFeedback;

      expect(spec.type, AnimationType.success);
      expect(spec.enableHaptic, true);
      expect(spec.begin, 1.0);
      expect(spec.end, 1.2);
    });
  });

  group('IOSAnimationTheme Tests', () {
    test('default theme should have correct values', () {
      const theme = IOSAnimationTheme();

      expect(theme.enableAnimations, true);
      expect(theme.enableHapticFeedback, true);
      expect(theme.respectReducedMotion, true);
      expect(theme.animationSpeed, 1.0);
      expect(theme.enablePerformanceMonitoring, false);
    });

    test('copyWith should create new instance with updated values', () {
      const theme = IOSAnimationTheme();
      final newTheme = theme.copyWith(
        enableAnimations: false,
        animationSpeed: 2.0,
      );

      expect(newTheme.enableAnimations, false);
      expect(newTheme.animationSpeed, 2.0);
      expect(newTheme.enableHapticFeedback, true); // unchanged
    });

    test('adjustDuration should respect enableAnimations', () {
      const theme = IOSAnimationTheme(enableAnimations: false);
      const duration = Duration(seconds: 1);

      final adjusted = theme.adjustDuration(duration);
      expect(adjusted, Duration.zero);
    });

    test('adjustDuration should apply animationSpeed', () {
      const theme = IOSAnimationTheme(animationSpeed: 2.0);
      const duration = Duration(milliseconds: 500);

      final adjusted = theme.adjustDuration(duration);
      expect(adjusted.inMilliseconds, 1000);
    });
  });
}

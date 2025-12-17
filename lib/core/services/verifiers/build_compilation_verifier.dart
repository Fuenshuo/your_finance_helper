/// Build Compilation Verifier - Verifies Flutter app builds and runs correctly
///
/// Tests flutter build, flutter run, platform-specific builds (iOS/Android/Web),
/// and dependency resolution.
library;

import 'dart:io';
import 'package:your_finance_flutter/core/models/verification_result.dart';
import 'package:your_finance_flutter/core/services/component_verifier.dart';

// Simple logging functions for build verification
void log_info(String message) => print('[INFO] $message');
void logError(String message) => print('[ERROR] $message');

class BuildCompilationVerifier extends ComponentVerifier {
  @override
  String get componentName => 'build_compilation';

  @override
  List<String> get dependencies => [
        'Flutter SDK',
        'Dart SDK',
        'iOS SDK (if iOS build)',
        'Android SDK (if Android build)',
        'Xcode (if iOS build)',
        'Android Studio (if Android build)',
      ];

  @override
  int get priority => 5; // Highest priority - app must build and run

  @override
  String get description =>
      'Verifies flutter build, flutter run, and platform-specific compilation';

  @override
  Duration get estimatedDuration =>
      const Duration(seconds: 10); // Builds take time

  @override
  Future<bool> isReady() async {
    // Check if Flutter is available
    try {
      final result = await Process.run('flutter', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<VerificationResult> verify() async {
    final checkResults = <String, bool>{};
    final issues = <String>[];

    try {
      // Test 1: Flutter doctor
      checkResults['flutter_doctor'] = await _testFlutterDoctor();
      if (!checkResults['flutter_doctor']!) {
        issues.add('flutter doctor reports configuration issues');
      }

      // Test 2: Pub dependencies
      checkResults['pub_dependencies'] = await _testPubDependencies();
      if (!checkResults['pub_dependencies']!) {
        issues.add('flutter pub get failed or dependencies are not resolved');
      }

      // Test 3: Flutter analyze
      checkResults['flutter_analyze'] = await _testFlutterAnalyze();
      if (!checkResults['flutter_analyze']!) {
        issues.add('flutter analyze found code issues or errors');
      }

      // Test 4: Flutter build debug
      checkResults['flutter_build_debug'] = await _testFlutterBuildDebug();
      if (!checkResults['flutter_build_debug']!) {
        issues.add('flutter build debug failed');
      }

      // Test 5: Flutter run dry-run (syntax check)
      checkResults['flutter_run_dry'] = await _testFlutterRunDry();
      if (!checkResults['flutter_run_dry']!) {
        issues.add('flutter run --dry-run failed (syntax or import issues)');
      }

      // Test 6: iOS build (if on macOS)
      checkResults['ios_build'] = await _testIOSBuild();
      if (!checkResults['ios_build']!) {
        issues.add(
            'iOS build failed (may be due to codesigning or Xcode issues)');
      }

      // Test 7: Android build
      checkResults['android_build'] = await _testAndroidBuild();
      if (!checkResults['android_build']!) {
        issues.add('Android build failed');
      }

      // Test 8: Platform compatibility
      checkResults['platform_compatibility'] =
          await _testPlatformCompatibility();
      if (!checkResults['platform_compatibility']!) {
        issues.add('Platform compatibility testing failed');
      }

      final allPassed = checkResults.values.every((passed) => passed);
      final status =
          allPassed ? VerificationStatus.pass : VerificationStatus.fail;

      final details = allPassed
          ? 'All build and compilation checks passed successfully'
          : 'Some build or compilation checks failed: ${issues.join(", ")}';

      return VerificationResult(
        componentName: componentName,
        status: status,
        details: details,
        checkResults: checkResults,
        remediationSteps: allPassed ? null : _generateRemediationSteps(issues),
      );
    } catch (e) {
      return VerificationResult.fail(
        componentName,
        'Exception during build/compilation verification',
        errorMessage: e.toString(),
        remediationSteps: [
          'Check Flutter SDK installation and PATH configuration',
          'Run flutter doctor --verbose to diagnose environment issues',
          'Verify pubspec.yaml dependencies are correct',
          'Check for iOS codesigning certificates if building for iOS',
          'Ensure Android SDK is properly configured',
        ],
        checkResults: checkResults,
      );
    }
  }

  Future<bool> _testFlutterDoctor() async {
    try {
      final result = await Process.run('flutter', ['doctor', '--verbose']);
      // flutter doctor returns 0 even with warnings, so we check output
      final output = result.stdout.toString() + result.stderr.toString();
      return !output.contains('[!]') && result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testPubDependencies() async {
    try {
      final result = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: Directory.current.path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testFlutterAnalyze() async {
    try {
      final result = await Process.run(
        'flutter',
        ['analyze'],
        workingDirectory: Directory.current.path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testFlutterBuildDebug() async {
    try {
      // Test debug build (faster than release)
      final result = await Process.run(
        'flutter',
        ['build', 'apk', '--debug'],
        workingDirectory: Directory.current.path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testFlutterRunDry() async {
    try {
      // Dry run checks for compilation issues without actually running
      final result = await Process.run(
        'flutter',
        ['run', '--dry-run'],
        workingDirectory: Directory.current.path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testIOSBuild() async {
    try {
      // Only test iOS build on macOS
      if (!Platform.isMacOS) {
        return true; // Skip on non-macOS platforms
      }

      final result = await Process.run(
        'flutter',
        ['build', 'ios', '--debug', '--no-codesign'],
        workingDirectory: Directory.current.path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testAndroidBuild() async {
    try {
      final result = await Process.run(
        'flutter',
        ['build', 'apk', '--debug'],
        workingDirectory: Directory.current.path,
      );
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }


  Future<bool> _testPlatformCompatibility() async {
    try {
      // Test platform compatibility across different targets
      final platforms = <String, List<String>?>{
        'android': ['flutter', 'build', 'apk', '--debug'],
        'ios': Platform.isMacOS
            ? ['flutter', 'build', 'ios', '--debug', '--no-codesign']
            : null,
        'web': ['flutter', 'build', 'web', '--release'],
      };

      var allCompatible = true;

      for (final entry in platforms.entries) {
        final platform = entry.key;
        final command = entry.value;

        if (command == null) {
          log_info('Skipping $platform compatibility test (not supported on this platform)');
          continue;
        }

        log_info('Testing $platform compatibility...');
        final result = await Process.run(
          command[0],
          command.sublist(1),
          workingDirectory: Directory.current.path,
        );

        if (result.exitCode != 0) {
          logError('$platform build failed: ${result.stderr}');
          allCompatible = false;
        } else {
          log_info('$platform build succeeded');
        }
      }

      return allCompatible;
    } catch (e) {
      logError('Platform compatibility testing failed: $e');
      return false;
    }
  }

  List<String> _generateRemediationSteps(List<String> issues) {
    final steps = <String>[];

    if (issues.any((issue) => issue.contains('flutter doctor'))) {
      steps.add('Run flutter doctor --verbose and fix all reported issues');
      steps.add('Install missing SDKs or tools as indicated by flutter doctor');
      steps.add('Configure environment variables and PATH correctly');
    }

    if (issues.any((issue) => issue.contains('pub get'))) {
      steps.add('Check pubspec.yaml for syntax errors or invalid dependencies');
      steps.add('Run flutter clean then flutter pub get');
      steps.add('Verify internet connection for dependency downloads');
    }

    if (issues.any((issue) => issue.contains('flutter analyze'))) {
      steps.add('Fix all code analysis errors and warnings');
      steps.add('Run flutter analyze to see specific issues');
      steps.add('Address linting and static analysis problems');
    }

    if (issues.any((issue) => issue.contains('build debug'))) {
      steps.add('Check for compilation errors in the code');
      steps.add('Verify all imports are correct and files exist');
      steps.add('Check for platform-specific code issues');
    }

    if (issues.any((issue) => issue.contains('dry-run'))) {
      steps.add('Fix syntax errors or import issues');
      steps.add('Check that main.dart/main_flux.dart exists and is valid');
      steps.add('Verify pubspec.yaml configuration is correct');
    }

    if (issues.any((issue) => issue.contains('iOS build'))) {
      steps.add('Install Xcode and iOS SDK if not present');
      steps.add(
          'Configure iOS codesigning certificates and provisioning profiles');
      steps.add(
          'Run flutter build ios --debug --no-codesign to bypass codesigning');
      steps.add('Check iOS-specific dependencies and configurations');
    }

    if (issues.any((issue) => issue.contains('Android build'))) {
      steps.add('Install Android SDK and required build tools');
      steps.add(
          'Configure ANDROID_HOME and ANDROID_SDK_ROOT environment variables');
      steps.add(
          'Accept Android SDK licenses with flutter doctor --android-licenses');
      steps.add('Check Android manifest and build configurations');
    }

    return steps;
  }
}

/// Verification Runner Interface - Main execution engine for migration verification
///
/// Provides the primary interface for running verification checks across
/// different components and managing verification sessions.

import '../models/verification_result.dart';
import '../models/verification_session.dart';

abstract class VerificationRunner {
  /// Run full verification across all components
  Future<VerificationSession> runFullVerification({
    List<String>? targetComponents,
    bool failFast = false,
    bool verbose = false,
  });

  /// Run verification for a specific component
  Future<VerificationResult> verifyComponent(String componentName);

  /// Get verification status for a component
  VerificationStatus getComponentStatus(String componentName);

  /// Get list of available components
  List<String> getAvailableComponents();
}

/// Default implementation of VerificationRunner
class DefaultVerificationRunner implements VerificationRunner {
  final List<String> _availableComponents = [
    'unified_transaction_entry_screen',
    'navigation',
    'providers',
    'build',
    'legacy_archive'
  ];

  @override
  Future<VerificationSession> runFullVerification({
    List<String>? targetComponents,
    bool failFast = false,
    bool verbose = false,
  }) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final components = targetComponents ?? _availableComponents;

    final session = VerificationSession(sessionId: sessionId);

    for (final componentName in components) {
      try {
        final result = await verifyComponent(componentName);
        session.addResult(result);

        if (failFast && result.status == VerificationStatus.fail) {
          break;
        }
      } catch (e) {
        final errorResult = VerificationResult.fail(
          componentName,
          'Exception during verification',
          errorMessage: e.toString(),
          remediationSteps: [
            'Check component implementation',
            'Review error logs'
          ],
        );
        session.addResult(errorResult);

        if (failFast) {
          break;
        }
      }
    }

    session.endTime = DateTime.now();
    return session;
  }

  @override
  Future<VerificationResult> verifyComponent(String componentName) async {
    // This method will be implemented with actual verification logic
    // for each component. For now, return a placeholder.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Placeholder implementation - will be replaced with real verifiers
    return VerificationResult.pass(
      componentName,
      'Component verification placeholder - implementation needed',
    );
  }

  @override
  VerificationStatus getComponentStatus(String componentName) {
    // Placeholder - will be implemented with status tracking
    return VerificationStatus.pending;
  }

  @override
  List<String> getAvailableComponents() {
    return List.unmodifiable(_availableComponents);
  }
}

/// Factory for creating verification runners
class VerificationRunnerFactory {
  static VerificationRunner create() {
    return DefaultVerificationRunner();
  }

  /// Create a runner with custom components
  static VerificationRunner createWithComponents(List<String> components) {
    return _CustomVerificationRunner(components);
  }
}

class _CustomVerificationRunner implements VerificationRunner {
  final List<String> _components;

  _CustomVerificationRunner(this._components);

  @override
  Future<VerificationSession> runFullVerification({
    List<String>? targetComponents,
    bool failFast = false,
    bool verbose = false,
  }) {
    final components = targetComponents ?? _components;
    final runner = DefaultVerificationRunner();
    return runner.runFullVerification(
      targetComponents: components,
      failFast: failFast,
      verbose: verbose,
    );
  }

  @override
  Future<VerificationResult> verifyComponent(String componentName) {
    final runner = DefaultVerificationRunner();
    return runner.verifyComponent(componentName);
  }

  @override
  VerificationStatus getComponentStatus(String componentName) {
    final runner = DefaultVerificationRunner();
    return runner.getComponentStatus(componentName);
  }

  @override
  List<String> getAvailableComponents() {
    return List.unmodifiable(_components);
  }
}


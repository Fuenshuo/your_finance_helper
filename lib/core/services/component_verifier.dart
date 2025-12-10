/// Component Verifier Base Class - Base interface for component-specific verifiers
///
/// Provides a common interface for verifying different components of the
/// Flux Ledger application after cleanup.

import '../models/verification_result.dart';

abstract class ComponentVerifier {
  /// Get the name of the component being verified
  String get componentName;

  /// Get the list of dependencies required for this component
  List<String> get dependencies;

  /// Check if the component is ready for verification
  Future<bool> isReady();

  /// Perform the actual verification
  Future<VerificationResult> verify();

  /// Get the priority level for this verifier (higher = more critical)
  int get priority => 1;

  /// Get a description of what this verifier checks
  String get description;

  /// Get estimated execution time in milliseconds
  Duration get estimatedDuration => const Duration(seconds: 1);

  /// Create a successful verification result
  VerificationResult createSuccessResult(String details, {
    Map<String, bool>? checkResults,
  }) {
    return VerificationResult.pass(
      componentName,
      details,
      checkResults: checkResults,
    );
  }

  /// Create a failed verification result
  VerificationResult createFailureResult(String details, {
    String? errorMessage,
    List<String>? remediationSteps,
    Map<String, bool>? checkResults,
  }) {
    return VerificationResult.fail(
      componentName,
      details,
      errorMessage: errorMessage,
      remediationSteps: remediationSteps,
      checkResults: checkResults,
    );
  }

  /// Create a warning verification result
  VerificationResult createWarningResult(String details, {
    List<String>? remediationSteps,
    Map<String, bool>? checkResults,
  }) {
    return VerificationResult.warning(
      componentName,
      details,
      remediationSteps: remediationSteps,
      checkResults: checkResults,
    );
  }
}

/// Registry for managing component verifiers
class ComponentVerifierRegistry {
  final Map<String, ComponentVerifier> _verifiers = {};

  /// Register a verifier for a component
  void register(ComponentVerifier verifier) {
    _verifiers[verifier.componentName] = verifier;
  }

  /// Get a verifier for a component
  ComponentVerifier? getVerifier(String componentName) {
    return _verifiers[componentName];
  }

  /// Get all registered component names
  List<String> getRegisteredComponents() {
    return _verifiers.keys.toList();
  }

  /// Get verifiers sorted by priority (highest first)
  List<ComponentVerifier> getVerifiersByPriority() {
    final verifiers = _verifiers.values.toList();
    verifiers.sort((a, b) => b.priority.compareTo(a.priority));
    return verifiers;
  }

  /// Check if a component has a registered verifier
  bool hasVerifier(String componentName) {
    return _verifiers.containsKey(componentName);
  }

  /// Get total number of registered verifiers
  int get count => _verifiers.length;

  /// Clear all registered verifiers
  void clear() {
    _verifiers.clear();
  }
}

/// Global registry instance
final componentVerifierRegistry = ComponentVerifierRegistry();

/// Helper function to register a verifier
void registerVerifier(ComponentVerifier verifier) {
  componentVerifierRegistry.register(verifier);
}

/// Helper function to get a verifier
ComponentVerifier? getVerifier(String componentName) {
  return componentVerifierRegistry.getVerifier(componentName);
}

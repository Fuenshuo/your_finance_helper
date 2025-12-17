/// Verification Exceptions - Custom exceptions for verification operations
///
/// Provides specific exception types for different verification failure modes
/// to enable better error handling and user feedback.

class VerificationException implements Exception {
  final String componentName;
  final String message;
  final String? details;
  final VerificationErrorType errorType;
  final List<String>? remediationSteps;

  VerificationException({
    required this.componentName,
    required this.message,
    this.details,
    this.errorType = VerificationErrorType.general,
    this.remediationSteps,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('VerificationException: $componentName - $message');

    if (details != null) {
      buffer.write('\nDetails: $details');
    }

    if (remediationSteps != null && remediationSteps!.isNotEmpty) {
      buffer.write('\nRemediation:');
      for (final step in remediationSteps!) {
        buffer.write('\n  - $step');
      }
    }

    return buffer.toString();
  }
}

enum VerificationErrorType {
  general,
  componentNotFound,
  dependencyMissing,
  providerError,
  animationError,
  themeError,
  navigationError,
  buildError,
  configurationError,
  evidenceError,
}

/// Component not ready exception
class ComponentNotReadyException extends VerificationException {
  ComponentNotReadyException(String componentName, [String? details])
      : super(
          componentName: componentName,
          message: 'Component is not ready for verification',
          details: details,
          errorType: VerificationErrorType.componentNotFound,
          remediationSteps: [
            'Ensure the component is properly imported',
            'Check that required dependencies are available',
            'Verify component initialization is complete',
          ],
        );
}

/// Provider not found exception
class ProviderNotFoundException extends VerificationException {
  ProviderNotFoundException(String componentName, String providerName)
      : super(
          componentName: componentName,
          message: 'Required provider not found: $providerName',
          errorType: VerificationErrorType.providerError,
          remediationSteps: [
            'Ensure $providerName is registered in main_flux.dart',
            'Check provider initialization order',
            'Verify provider dependencies are satisfied',
          ],
        );
}

/// Animation verification exception
class AnimationVerificationException extends VerificationException {
  AnimationVerificationException(String componentName, String animationName,
      [String? details])
      : super(
          componentName: componentName,
          message: 'Animation verification failed: $animationName',
          details: details,
          errorType: VerificationErrorType.animationError,
          remediationSteps: [
            'Check animation controller initialization',
            'Verify animation curves and durations',
            'Ensure animation widgets are properly configured',
          ],
        );
}

/// Theme verification exception
class ThemeVerificationException extends VerificationException {
  ThemeVerificationException(String componentName, [String? details])
      : super(
          componentName: componentName,
          message: 'Theme adaptation verification failed',
          details: details,
          errorType: VerificationErrorType.themeError,
          remediationSteps: [
            'Check Theme.of(context) usage',
            'Verify AppDesignTokens integration',
            'Ensure dark/light mode support',
          ],
        );
}

/// Navigation verification exception
class NavigationVerificationException extends VerificationException {
  NavigationVerificationException(String componentName, [String? details])
      : super(
          componentName: componentName,
          message: 'Navigation verification failed',
          details: details,
          errorType: VerificationErrorType.navigationError,
          remediationSteps: [
            'Check flux_router.dart configuration',
            'Verify route definitions',
            'Ensure navigation guards work correctly',
          ],
        );
}

/// Build verification exception
class BuildVerificationException extends VerificationException {
  BuildVerificationException(String target, [String? details])
      : super(
          componentName: 'build',
          message: 'Build verification failed for target: $target',
          details: details,
          errorType: VerificationErrorType.buildError,
          remediationSteps: [
            'Check flutter doctor output',
            'Verify pubspec.yaml dependencies',
            'Ensure iOS certificates are valid',
            'Check for compilation errors',
          ],
        );
}

/// Configuration verification exception
class ConfigurationVerificationException extends VerificationException {
  ConfigurationVerificationException(String componentName, String configIssue)
      : super(
          componentName: componentName,
          message: 'Configuration verification failed: $configIssue',
          errorType: VerificationErrorType.configurationError,
          remediationSteps: [
            'Check configuration files',
            'Verify environment variables',
            'Ensure required settings are present',
          ],
        );
}

/// Evidence collection exception
class EvidenceCollectionException extends VerificationException {
  EvidenceCollectionException(String componentName, String evidenceType,
      [String? details])
      : super(
          componentName: componentName,
          message: 'Evidence collection failed for: $evidenceType',
          details: details,
          errorType: VerificationErrorType.evidenceError,
          remediationSteps: [
            'Check file system permissions',
            'Verify storage directory exists',
            'Ensure sufficient disk space',
          ],
        );
}


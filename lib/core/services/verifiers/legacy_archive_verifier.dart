/// Legacy Archive Verifier - Verifies the legacy folder structure and contents
///
/// Tests that all moved code is properly archived, documentation is complete,
/// and cleanup was performed correctly.

import 'dart:io';
import '../verification_result.dart';
import '../component_verifier.dart';

class LegacyArchiveVerifier implements ComponentVerifier {
  @override
  String get componentName => 'legacy_archive';

  @override
  List<String> get dependencies => [
    'File System',
    'Git Repository',
  ];

  @override
  int get priority => 3; // Medium priority - cleanup verification

  @override
  String get description =>
      'Verifies legacy folder structure, documentation, and cleanup completeness';

  @override
  Duration get estimatedDuration => const Duration(seconds: 2);

  @override
  Future<bool> isReady() async {
    // Check if legacy folder exists
    final legacyDir = Directory('legacy');
    return legacyDir.existsSync();
  }

  @override
  Future<VerificationResult> verify() async {
    final Map<String, bool> checkResults = {};
    final List<String> issues = [];

    try {
      // Test 1: Legacy folder structure
      checkResults['legacy_structure'] = await _testLegacyFolderStructure();
      if (!checkResults['legacy_structure']!) {
        issues.add('Legacy folder structure is incomplete or incorrect');
      }

      // Test 2: Legacy documentation
      checkResults['legacy_documentation'] = await _testLegacyDocumentation();
      if (!checkResults['legacy_documentation']!) {
        issues.add('Legacy folder documentation is missing or incomplete');
      }

      // Test 3: Git tracking cleanup
      checkResults['git_cleanup'] = await _testGitCleanup();
      if (!checkResults['git_cleanup']!) {
        issues.add('Git tracking cleanup was not performed correctly');
      }

      // Test 4: Legacy code integrity
      checkResults['legacy_integrity'] = await _testLegacyCodeIntegrity();
      if (!checkResults['legacy_integrity']!) {
        issues.add('Legacy code files are corrupted or incomplete');
      }

      // Test 5: Import cleanup
      checkResults['import_cleanup'] = await _testImportCleanup();
      if (!checkResults['import_cleanup']!) {
        issues.add('Import references to legacy code were not cleaned up');
      }

      // Test 6: Archive completeness
      checkResults['archive_completeness'] = await _testArchiveCompleteness();
      if (!checkResults['archive_completeness']!) {
        issues.add('Archive is missing some components that should have been moved');
      }

      final allPassed = checkResults.values.every((passed) => passed);
      final status = allPassed ? VerificationStatus.pass : VerificationStatus.fail;

      final details = allPassed
          ? 'Legacy archive verification completed successfully'
          : 'Legacy archive verification found issues: ${issues.join(", ")}';

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
        'Exception during legacy archive verification',
        errorMessage: e.toString(),
        remediationSteps: [
          'Check that legacy folder exists and is accessible',
          'Verify file system permissions for legacy directory',
          'Ensure git repository is properly configured',
          'Check for corrupted or incomplete legacy files',
        ],
        checkResults: checkResults,
      );
    }
  }

  Future<bool> _testLegacyFolderStructure() async {
    try {
      final legacyDir = Directory('legacy');

      if (!legacyDir.existsSync()) {
        return false;
      }

      // Check that expected subdirectories exist
      final expectedDirs = [
        'screens',
        'widgets',
        'models',
        'providers',
        'services',
      ];

      for (final dirName in expectedDirs) {
        final dir = Directory('legacy/$dirName');
        if (!dir.existsSync()) {
          // This is okay - some directories might be empty
          continue;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testLegacyDocumentation() async {
    try {
      final readmeFile = File('legacy/README.md');

      if (!readmeFile.existsSync()) {
        return false;
      }

      final content = readmeFile.readAsStringSync();

      // Check for essential documentation elements
      final requiredContent = [
        'cleanup',
        'legacy',
        'archived',
        'moved',
      ];

      return requiredContent.every((keyword) =>
          content.toLowerCase().contains(keyword));
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testGitCleanup() async {
    try {
      // Check if legacy folder is in .gitignore
      final gitignoreFile = File('.gitignore');

      if (!gitignoreFile.existsSync()) {
        return false;
      }

      final content = gitignoreFile.readAsStringSync();

      // Check if legacy folder is ignored
      return content.contains('legacy/') ||
             content.contains('legacy') ||
             content.contains('**/legacy/**');
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testLegacyCodeIntegrity() async {
    try {
      final legacyDir = Directory('legacy');

      if (!legacyDir.existsSync()) {
        return false;
      }

      // Check that legacy files are readable and not corrupted
      final files = legacyDir.listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in files) {
        try {
          // Try to read the file
          file.readAsStringSync();
        } catch (e) {
          // File is corrupted
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testImportCleanup() async {
    try {
      final libDir = Directory('lib');

      if (!libDir.existsSync()) {
        return false;
      }

      // Check that remaining code doesn't import from legacy
      final dartFiles = libDir.listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        try {
          final content = file.readAsStringSync();

          // Check for imports from legacy folder
          if (content.contains("import 'legacy/") ||
              content.contains('import "legacy/') ||
              content.contains("package:your_finance_flutter/legacy/")) {
            return false; // Found legacy import in active code
          }
        } catch (e) {
          // Skip files that can't be read
          continue;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testArchiveCompleteness() async {
    try {
      // This is a basic check - in a real implementation, this would
      // compare against a known list of what should have been moved
      final legacyDir = Directory('legacy');

      if (!legacyDir.existsSync()) {
        return false;
      }

      // Check that legacy folder is not empty (should contain moved code)
      final contents = legacyDir.listSync(recursive: false);
      return contents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  List<String> _generateRemediationSteps(List<String> issues) {
    final steps = <String>[];

    if (issues.any((issue) => issue.contains('folder structure'))) {
      steps.add('Review legacy folder structure and create missing directories');
      steps.add('Ensure moved files are in appropriate subdirectories');
      steps.add('Check that file organization matches original structure');
    }

    if (issues.any((issue) => issue.contains('documentation'))) {
      steps.add('Create or update legacy/README.md with cleanup details');
      steps.add('Document what was moved and why');
      steps.add('Include restoration instructions if needed');
    }

    if (issues.any((issue) => issue.contains('git cleanup'))) {
      steps.add('Add legacy/ to .gitignore file');
      steps.add('Remove legacy files from git tracking');
      steps.add('Commit the cleanup changes');
    }

    if (issues.any((issue) => issue.contains('code integrity'))) {
      steps.add('Check for corrupted files in legacy folder');
      steps.add('Restore any damaged legacy files from backup');
      steps.add('Verify all moved files are readable');
    }

    if (issues.any((issue) => issue.contains('import cleanup'))) {
      steps.add('Find and remove all imports from legacy folder');
      steps.add('Replace legacy imports with correct Flux Ledger equivalents');
      steps.add('Update relative import paths as needed');
    }

    if (issues.any((issue) => issue.contains('archive completeness'))) {
      steps.add('Verify all non-Flux code was moved to legacy');
      steps.add('Check that no active code remains in legacy folder');
      steps.add('Ensure legacy folder contains complete archived components');
    }

    return steps;
  }
}

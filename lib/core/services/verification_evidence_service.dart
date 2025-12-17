/// Verification Evidence Service - Manages storage and retrieval of verification evidence
///
/// Handles screenshots, logs, metrics, and other evidence captured during
/// verification to support result validation and debugging.

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum EvidenceType {
  screenshot('screenshot'),
  log('log'),
  metric('metric'),
  trace('trace'),
  error('error');

  const EvidenceType(this.value);
  final String value;

  static EvidenceType fromString(String value) {
    return EvidenceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EvidenceType.log,
    );
  }
}

class VerificationEvidence {
  final String id;
  final String componentName;
  final EvidenceType type;
  final String filePath;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  VerificationEvidence({
    required this.id,
    required this.componentName,
    required this.type,
    required this.filePath,
    required this.description,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create evidence from a file
  static Future<VerificationEvidence> fromFile(
    String componentName,
    EvidenceType type,
    String filePath,
    String description, {
    Map<String, dynamic>? metadata,
  }) async {
    final id =
        '${componentName}_${type.value}_${DateTime.now().millisecondsSinceEpoch}';
    return VerificationEvidence(
      id: id,
      componentName: componentName,
      type: type,
      filePath: filePath,
      description: description,
      metadata: metadata,
    );
  }

  /// Check if the evidence file exists
  Future<bool> fileExists() async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Get file size in bytes
  Future<int?> getFileSize() async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'componentName': componentName,
      'type': type.value,
      'filePath': filePath,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory VerificationEvidence.fromJson(Map<String, dynamic> json) {
    return VerificationEvidence(
      id: json['id'] as String,
      componentName: json['componentName'] as String,
      type: EvidenceType.fromString(json['type'] as String),
      filePath: json['filePath'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  @override
  String toString() {
    return 'VerificationEvidence(id: $id, component: $componentName, type: ${type.value}, path: $filePath)';
  }
}

class VerificationEvidenceService {
  static const String _evidenceDir = 'verification_evidence';
  static const String _evidenceIndexFile = 'evidence_index.json';

  /// Capture and store evidence
  Future<VerificationEvidence> captureEvidence(
    String componentName,
    EvidenceType type,
    String description, {
    String? customFileName,
    Map<String, dynamic>? metadata,
  }) async {
    final directory = await _getEvidenceDirectory();
    final fileName = customFileName ??
        '${componentName}_${type.value}_${DateTime.now().millisecondsSinceEpoch}';

    final filePath = '${directory.path}/$fileName';

    // Create the evidence record
    final evidence = await VerificationEvidence.fromFile(
      componentName,
      type,
      filePath,
      description,
      metadata: metadata,
    );

    // Save to index
    await _saveEvidenceToIndex(evidence);

    return evidence;
  }

  /// Store evidence from existing file
  Future<VerificationEvidence> storeEvidenceFile(
    String componentName,
    EvidenceType type,
    String sourceFilePath,
    String description, {
    Map<String, dynamic>? metadata,
  }) async {
    final directory = await _getEvidenceDirectory();
    final fileName =
        '${componentName}_${type.value}_${DateTime.now().millisecondsSinceEpoch}';
    final targetPath = '${directory.path}/$fileName';

    // Copy the file
    final sourceFile = File(sourceFilePath);
    await sourceFile.copy(targetPath);

    // Create evidence record
    final evidence = VerificationEvidence(
      id: '${componentName}_${type.value}_${DateTime.now().millisecondsSinceEpoch}',
      componentName: componentName,
      type: type,
      filePath: targetPath,
      description: description,
      metadata: metadata,
    );

    // Save to index
    await _saveEvidenceToIndex(evidence);

    return evidence;
  }

  /// Get all evidence for a component
  Future<List<VerificationEvidence>> getEvidenceForComponent(
      String componentName) async {
    final allEvidence = await _loadEvidenceIndex();
    return allEvidence.where((e) => e.componentName == componentName).toList();
  }

  /// Get evidence by type
  Future<List<VerificationEvidence>> getEvidenceByType(
      EvidenceType type) async {
    final allEvidence = await _loadEvidenceIndex();
    return allEvidence.where((e) => e.type == type).toList();
  }

  /// Clean up old evidence files (keep last N days)
  Future<void> cleanupOldEvidence({int keepDays = 7}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    final allEvidence = await _loadEvidenceIndex();

    final oldEvidence =
        allEvidence.where((e) => e.timestamp.isBefore(cutoffDate)).toList();

    for (final evidence in oldEvidence) {
      try {
        final file = File(evidence.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Log error but continue
        print('Failed to delete evidence file: ${evidence.filePath}');
      }
    }

    // Update index
    final remainingEvidence =
        allEvidence.where((e) => e.timestamp.isAfter(cutoffDate)).toList();
    await _saveEvidenceIndex(remainingEvidence);
  }

  /// Get evidence storage stats
  Future<Map<String, dynamic>> getStorageStats() async {
    final directory = await _getEvidenceDirectory();
    final allEvidence = await _loadEvidenceIndex();

    int totalFiles = 0;
    int totalSize = 0;

    for (final evidence in allEvidence) {
      final file = File(evidence.filePath);
      if (await file.exists()) {
        totalFiles++;
        final size = await file.length();
        totalSize += size;
      }
    }

    return {
      'totalFiles': totalFiles,
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).round(),
      'evidenceCount': allEvidence.length,
      'directory': directory.path,
    };
  }

  Future<Directory> _getEvidenceDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${appDir.path}/$_evidenceDir');

    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }

    return evidenceDir;
  }

  Future<List<VerificationEvidence>> _loadEvidenceIndex() async {
    final directory = await _getEvidenceDirectory();
    final indexFile = File('${directory.path}/$_evidenceIndexFile');

    if (!await indexFile.exists()) {
      return [];
    }

    try {
      final content = await indexFile.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;
      return jsonList
          .map((json) =>
              VerificationEvidence.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If index is corrupted, return empty list
      return [];
    }
  }

  Future<void> _saveEvidenceToIndex(VerificationEvidence evidence) async {
    final allEvidence = await _loadEvidenceIndex();
    allEvidence.add(evidence);
    await _saveEvidenceIndex(allEvidence);
  }

  Future<void> _saveEvidenceIndex(List<VerificationEvidence> evidence) async {
    final directory = await _getEvidenceDirectory();
    final indexFile = File('${directory.path}/$_evidenceIndexFile');

    final jsonList = evidence.map((e) => e.toJson()).toList();
    final content = jsonEncode(jsonList);
    await indexFile.writeAsString(content);
  }
}


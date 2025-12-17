import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Locates legacy JSON files stored in the application documents directory.
class LegacyFileLocator {
  /// Returns the base legacy directory used to store old JSON exports.
  /// We assume legacy JSON files are placed directly under the app documents
  /// directory or inside a `legacy/` subfolder.
  static Future<Directory> legacyBaseDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final legacy = Directory(p.join(docs.path, 'legacy'));
    if (await legacy.exists()) return legacy;
    return docs; // fallback to root of documents
  }

  /// Returns a file handle for a given filename if it exists under the legacy
  /// directory. Returns null if not found.
  static Future<File?> tryGetFile(String filename) async {
    final base = await legacyBaseDir();
    final direct = File(p.join(base.path, filename));
    if (await direct.exists()) return direct;
    // also check under module-named subfolders
    final candidates = [
      'assets',
      'accounts',
      'transactions',
      'budgets',
      'salary',
      'history',
    ].map((dir) => File(p.join(base.path, dir, filename))).toList();
    for (final f in candidates) {
      if (await f.exists()) return f;
    }
    return null;
  }

  /// Creates a timestamped backup directory under documents/backup.
  static Future<Directory> createBackupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final backupBase = Directory(p.join(docs.path, 'backup'));
    if (!await backupBase.exists()) {
      await backupBase.create(recursive: true);
    }
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final backupDir = Directory(p.join(backupBase.path, ts));
    await backupDir.create(recursive: true);
    return backupDir;
  }
}

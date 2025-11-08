import 'dart:io';

import 'package:your_finance_flutter/core/services/drift_database_service.dart';

void main() async {
  print('🔍 Checking database contents...');

  try {
    final db = await DriftDatabaseService.getInstance();
    final assets = await db.getAssets();

    print('📊 Database assets count: ${assets.length}');
    for (final asset in assets) {
      print(
          '  - ${asset.name}: ¥${asset.amount} (${asset.category.displayName})');
    }

    if (assets.isEmpty) {
      print('❌ No assets found in database - migration may not have run');
    } else {
      print('✅ Assets found in database - migration worked!');
    }
  } catch (e) {
    print('❌ Database check failed: $e');
  }
}














import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/database/app_database.dart';
import 'package:your_finance_flutter/core/models/asset_item.dart';

/// Simple test to verify Drift database functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🧪 Testing Drift Database...');

  try {
    // Initialize database
    final database = AppDatabase();

    // Test basic asset operations
    print('📝 Testing asset operations...');

    // Create a test asset
    final testAsset = AssetItem(
      id: 'test_asset_001',
      name: 'Test Cash',
      amount: 10000.0,
      category: AssetCategory.liquidAssets,
      subCategory: '现金',
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
    );

    print('💾 Saving test asset: ${testAsset.name}');

    // Save asset
    await database.insertAsset(
      AssetsCompanion(
        id: Value(testAsset.id),
        name: Value(testAsset.name),
        amount: Value(testAsset.amount),
        category: Value(testAsset.category.name),
        subCategory: Value(testAsset.subCategory),
        creationDate: Value(testAsset.creationDate),
        updateDate: Value(testAsset.updateDate),
      ),
    );

    // Retrieve asset
    final retrievedAsset = await database.getAssetById(testAsset.id);
    if (retrievedAsset != null) {
      print(
          '✅ Retrieved asset: ${retrievedAsset.name}, amount: ${retrievedAsset.amount}');
    } else {
      print('❌ Failed to retrieve asset');
    }

    // Get all assets
    final allAssets = await database.getAllAssets();
    print('📊 Total assets in database: ${allAssets.length}');

    // Clean up
    await database.deleteAsset(testAsset.id);
    print('🧹 Cleaned up test data');

    // Close database
    await database.close();

    print('🎉 Drift database test completed successfully!');
  } catch (e, stackTrace) {
    print('❌ Database test failed: $e');
    print('Stack trace: $stackTrace');
  }
}

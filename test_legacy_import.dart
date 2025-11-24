import 'dart:io';

import 'package:your_finance_flutter/core/services/data_migration_service.dart';

void main() async {
  print('🧪 Testing legacy data import functionality...');

  try {
    // Test dry-run first
    print('📊 Running dry-run preview...');
    final migrationService = await DataMigrationService.getInstance();
    final report = await migrationService.importLegacyData();

    print('📋 Dry-run results:');
    print('   Assets: ${report.modules['assets']!.total} records found');
    print('   Accounts: ${report.modules['accounts']!.total} records found');
    print(
        '   Transactions: ${report.modules['transactions']!.total} records found');
    print('   Budgets: ${report.modules['budgets']!.total} records found');
    print('   Salary: ${report.modules['salary']!.total} records found');
    print('   History: ${report.modules['history']!.total} records found');

    if (report.errors.isNotEmpty) {
      print('⚠️ Warnings:');
      for (final error in report.errors) {
        print('   - $error');
      }
    }

    // Ask user if they want to proceed with actual import
    print('\n❓ Do you want to proceed with actual import? (y/n)');
    final input = stdin.readLineSync()?.toLowerCase().trim();

    if (input == 'y' || input == 'yes') {
      print('🔄 Running actual import...');
      final importReport =
          await migrationService.importLegacyData(dryRun: false);

      print('✅ Import completed!');
      print('   Assets imported: ${importReport.modules['assets']!.imported}');
      print('   Errors: ${importReport.errors.length}');

      if (importReport.errors.isNotEmpty) {
        print('⚠️ Errors:');
        for (final error in importReport.errors) {
          print('   - $error');
        }
      }
    } else {
      print('⏹️ Import cancelled by user');
    }
  } catch (e) {
    print('❌ Test failed: $e');
    exit(1);
  }

  print('🎉 Legacy import test completed!');
}



















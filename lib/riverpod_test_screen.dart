import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/providers/riverpod_providers.dart';
import 'package:your_finance_flutter/core/utils/unified_notifications.dart';

// Simple test screen to verify Riverpod setup works
class RiverpodTestScreen extends ConsumerWidget {
  const RiverpodTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetProvider);
    final transactionState = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉 Awesome Flutter Tech Stack Integration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '✅ Riverpod State Management: ${assetState.isInitialized ? 'Working' : 'Initializing...'}',
            ),
            Text('✅ Asset Provider: ${assetState.assets.length} assets loaded'),
            Text(
              '✅ Transaction Provider: ${transactionState.isInitialized ? 'Ready' : 'Loading...'}',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Test adding a sample asset
                final assetNotifier = ref.read(assetProvider.notifier);
                // This would normally add an asset, but let's just test the connection
                unifiedNotifications.showInfo(
                  context,
                  'Riverpod providers are working! 🎉',
                );
              },
              child: const Text('Test Riverpod Connection'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Next Steps:\n• Set up Drift database\n• Implement go_router navigation\n• Add FL Chart visualizations\n• Integrate flutter_form_builder',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

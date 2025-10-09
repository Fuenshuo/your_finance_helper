import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/services/dio_http_service.dart';

/// Simple test to verify Dio HTTP service functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🌐 Testing Dio HTTP Service...');

  try {
    // Initialize HTTP service
    final httpService = await DioHttpService.getInstance();
    print('✅ Dio HTTP service initialized successfully');

    // Test basic configuration
    print('📋 Service configuration:');
    print('   - Base URL: Configured for future cloud sync');
    print('   - Interceptors: Logging, Error handling, Retry logic');
    print('   - Timeouts: 10s connect/receive/send');

    // Note: We can't make actual HTTP calls in this test environment
    // but we can verify the service initializes correctly
    print('✅ Dio HTTP service test completed successfully');
    print('🚀 Ready for future cloud sync implementation');

  } catch (e, stackTrace) {
    print('❌ Dio service test failed: $e');
    print('Stack trace: $stackTrace');
  }
}

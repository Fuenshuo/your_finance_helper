import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_finance_flutter/core/services/storage_service.dart';

/// Shared providers used across multiple provider files

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be provided');
});

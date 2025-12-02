import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:your_finance_flutter/core/providers/stream_insights_flag_provider.dart';
import 'package:your_finance_flutter/core/router/app_router.dart';
import 'package:your_finance_flutter/main.dart' as app;

const Key _insightsNavChipKey = Key('unified_insights_nav_chip');
const Key _timelineViewKey = Key('unified_timeline_view');

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await StreamInsightsFlagProvider.writeOverride(value: true);
  });

  Future<void> ensureUnifiedScreenReady(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
    appRouter.go(AppRoutes.main);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byKey(_timelineViewKey), findsOneWidget);
    expect(find.byKey(_insightsNavChipKey), findsOneWidget);
  }

  Future<void> togglePaneCycle(WidgetTester tester) async {
    final insightsChip = find.byKey(_insightsNavChipKey);
    expect(insightsChip, findsOneWidget);
    await tester.tap(insightsChip);
    await tester.pumpAndSettle(const Duration(milliseconds: 450));
    await tester.tap(insightsChip);
    await tester.pumpAndSettle(const Duration(milliseconds: 450));
  }

  Future<void> runToggleLoop(
    WidgetTester tester, {
    int iterations = 20,
  }) async {
    for (var i = 0; i < iterations; i++) {
      await togglePaneCycle(tester);
    }
  }

  group('Stream + Insights stress & latency benchmarks', () {
    testWidgets(
      'T026: 20 pane switches keep memory delta within ±5%',
      (tester) async {
        await tester.runAsync(() async {
          app.main();
        });
        await ensureUnifiedScreenReady(tester);
        final baseline = await _captureHeapSnapshot();
        await runToggleLoop(tester);
        final result = await _captureHeapSnapshot();
        final baselineTotal = baseline.total == 0 ? 1 : baseline.total;
        final deltaPercent =
            ((result.total - baselineTotal).abs() / baselineTotal) * 100;
        debugPrint(
          'Memory baseline=${baseline.pretty} result=${result.pretty} '
          'delta=${deltaPercent.toStringAsFixed(2)}%',
        );
        expect(deltaPercent, lessThanOrEqualTo(5.0));
      },
    );

    testWidgets(
      'T027: AnimatedSwitcher pane transitions stay under 100ms',
      (tester) async {
        await tester.runAsync(() async {
          app.main();
        });
        await ensureUnifiedScreenReady(tester);
        await runToggleLoop(tester, iterations: 5); // warm-up
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        const reportKey = 'pane_switch_performance';
        await binding.watchPerformance(
          () async => runToggleLoop(tester),
          reportKey: reportKey,
        );
        final summary =
            binding.reportData![reportKey]! as Map<String, dynamic>;
        final averageBuild = summary['average_frame_build_time_millis'] as num;
        final worstBuild = summary['worst_frame_build_time_millis'] as num;
        debugPrint(
          'Pane switch performance: avg=${averageBuild.toStringAsFixed(2)}ms, '
          'worst=${worstBuild.toStringAsFixed(2)}ms, '
          'missedBudget=${summary['missed_frame_build_budget_count']}',
        );
        expect(averageBuild, lessThan(100));
        expect(worstBuild, lessThan(120));
        expect(summary['missed_frame_build_budget_count'] as num, equals(0));
      },
    );
  });
}

class _HeapSnapshot {
  const _HeapSnapshot({
    required this.heapUsage,
    required this.externalUsage,
  });

  final int heapUsage;
  final int externalUsage;

  int get total => heapUsage + externalUsage;

  String get pretty =>
      'heap=${(heapUsage / (1024 * 1024)).toStringAsFixed(2)}MB '
      'external=${(externalUsage / (1024 * 1024)).toStringAsFixed(2)}MB';
}

Future<_HeapSnapshot> _captureHeapSnapshot() async {
  if (kIsWeb) {
    return const _HeapSnapshot(heapUsage: 0, externalUsage: 0);
  }
  final info = await developer.Service.getInfo();
  final serverUri = info.serverUri!;
  final wsUri = _toWebSocketUri(serverUri);
  final service = await vmServiceConnectUri(wsUri.toString());
  final vmInfo = await service.getVM();
  final isolate = vmInfo.isolates!.first;
  final profile = await service.getAllocationProfile(
    isolate.id!,
    reset: false,
    gc: true,
  );
  await service.dispose();
  final usage = profile.memoryUsage;
  return _HeapSnapshot(
    heapUsage: usage?.heapUsage ?? 0,
    externalUsage: usage?.externalUsage ?? 0,
  );
}

Uri _toWebSocketUri(Uri uri) {
  if (uri.scheme.startsWith('ws')) {
    return uri;
  }
  final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
  final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
  return Uri(
    scheme: scheme,
    host: uri.host.isEmpty ? 'localhost' : uri.host,
    port: uri.port,
    path: '${path}ws',
  );
}

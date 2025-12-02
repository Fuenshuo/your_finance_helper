import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/core/models/insights_drawer_state.dart';

void main() {
  group('InsightsDrawerController', () {
    test('expands immediately and collapses after timer', () {
      fakeAsync((async) {
        final controller = InsightsDrawerController();

        controller.handleAnalysisSummary(
          summaryText: 'Morning coffee',
          collapseAfter: const Duration(seconds: 2),
        );

        expect(controller.state.isVisible, isTrue);
        expect(controller.state.isExpanded, isTrue);

        async.elapse(const Duration(seconds: 1));
        expect(controller.state.isVisible, isTrue);

        async.elapse(const Duration(seconds: 1));
        expect(controller.state.isVisible, isFalse);
        expect(controller.state.isExpanded, isFalse);
      });
    });

    test('defers expansion when requested and resumes countdown afterwards',
        () {
      fakeAsync((async) {
        final controller = InsightsDrawerController();

        controller.handleAnalysisSummary(
          summaryText: 'Deferred summary',
          deferExpansionBy: const Duration(milliseconds: 800),
          collapseAfter: const Duration(seconds: 2),
        );

        expect(controller.state.isVisible, isTrue);
        expect(controller.state.isExpanded, isFalse);

        async.elapse(const Duration(milliseconds: 700));
        expect(controller.state.isExpanded, isFalse);

        async.elapse(const Duration(milliseconds: 200));
        expect(controller.state.isExpanded, isTrue);

        async.elapse(const Duration(seconds: 2));
        expect(controller.state.isVisible, isFalse);
      });
    });

    test(
        'queues repeated summaries by incrementing counter and resetting timer',
        () {
      fakeAsync((async) {
        final controller = InsightsDrawerController();

        controller.handleAnalysisSummary(
          summaryText: 'First summary',
          collapseAfter: const Duration(seconds: 3),
        );
        async.elapse(const Duration(seconds: 2));

        controller.handleAnalysisSummary(
          summaryText: 'Second summary',
          collapseAfter: const Duration(seconds: 3),
        );

        expect(controller.state.improvementCount, 2);
        expect(controller.state.message, 'Second summary');

        async.elapse(const Duration(seconds: 2));
        expect(controller.state.isVisible, isTrue);

        async.elapse(const Duration(seconds: 1));
        expect(controller.state.isVisible, isFalse);
      });
    });

    test('pulseVisibility collapses after duration and clears message', () {
      fakeAsync((async) {
        final controller = InsightsDrawerController();

        controller.handleAnalysisSummary(summaryText: 'Persisted summary');
        expect(controller.state.message, 'Persisted summary');

        controller.pulseVisibility(
          visibleFor: const Duration(milliseconds: 500),
        );

        expect(controller.state.isExpanded, isFalse);
        expect(controller.state.message, isNull);

        async.elapse(const Duration(milliseconds: 500));
        expect(controller.state.isVisible, isFalse);
      });
    });
  });
}

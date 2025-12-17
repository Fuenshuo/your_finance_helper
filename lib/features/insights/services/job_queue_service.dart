import 'dart:async';
import 'dart:collection';
import 'package:your_finance_flutter/features/insights/models/flux_loop_job.dart';

/// Service for managing background job queues
class JobQueueService {
  static final JobQueueService _instance = JobQueueService._();
  static JobQueueService get instance => _instance;

  JobQueueService._() {
    _initializeQueues();
  }

  final Map<JobType, Queue<FluxLoopJob>> _jobQueues = {};
  final Map<String, StreamController<FluxLoopJob>> _jobControllers = {};
  final Map<String, Timer?> _processingTimers = {};
  final Map<JobType, bool> _isProcessing = {};

  static const Duration _jobTimeout = Duration(seconds: 30);

  void _initializeQueues() {
    for (final type in JobType.values) {
      _jobQueues[type] = Queue<FluxLoopJob>();
      _isProcessing[type] = false;
    }
  }

  /// Add a job to the appropriate queue
  Future<String> enqueueJob(FluxLoopJob job) async {
    final jobId = job.id;
    _jobQueues[job.type]!.add(job);

    // Create a stream controller for this job
    _jobControllers[jobId] = StreamController<FluxLoopJob>.broadcast();

    // Update job status to queued
    final queuedJob = job.copyWith(status: JobStatus.queued);
    _jobControllers[jobId]!.add(queuedJob);

    // Start processing if not already processing this queue
    _startProcessingIfNeeded(job.type);

    return jobId;
  }

  /// Get job status stream
  Stream<FluxLoopJob> watchJob(String jobId) {
    return _jobControllers[jobId]?.stream ?? Stream.empty();
  }

  /// Cancel a job
  Future<void> cancelJob(String jobId) async {
    final controller = _jobControllers[jobId];
    if (controller != null) {
      final cancelledJob = FluxLoopJob(
        id: jobId,
        type: JobType.dailyAnalysis, // Placeholder
        status: JobStatus.failed,
        createdAt: DateTime.now(),
        metadata: {},
      );
      controller.add(cancelledJob);
      await controller.close();
      _jobControllers.remove(jobId);
    }
  }

  void _startProcessingIfNeeded(JobType type) {
    if (_isProcessing[type]! || _jobQueues[type]!.isEmpty) return;

    _isProcessing[type] = true;
    _processQueue(type);
  }

  Future<void> _processQueue(JobType type) async {
    final queue = _jobQueues[type]!;

    while (queue.isNotEmpty && _isProcessing[type]!) {
      final job = queue.removeFirst();

      try {
        // Update job status to processing
        final processingJob = job.copyWith(status: JobStatus.processing);
        _jobControllers[job.id]?.add(processingJob);

        // Process the job with timeout
        final result = await _processJobWithTimeout(job);

        // Update job status to completed
        final completedJob = job.copyWith(
          status: JobStatus.completed,
          completedAt: DateTime.now(),
          result: result,
        );
        _jobControllers[job.id]?.add(completedJob);
      } on Exception catch (e) {
        // Handle job failure
        final failedJob = job.copyWith(
          status: JobStatus.failed,
          completedAt: DateTime.now(),
          error: e.toString(),
        );
        _jobControllers[job.id]?.add(failedJob);

        // Retry logic could be added here
        // debugPrint('Job ${job.id} failed: $e');
      } finally {
        // Clean up job controller
        await Future<void>.delayed(const Duration(seconds: 1));
        await _jobControllers[job.id]?.close();
        _jobControllers.remove(job.id);
      }

      // Small delay between jobs to prevent overwhelming the system
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    _isProcessing[type] = false;
  }

  Future<String> _processJobWithTimeout(FluxLoopJob job) async {
    // Create a completer for the job processing
    final completer = Completer<String>();

    // Simulate job processing based on type
    Future<String> processJob() async {
      switch (job.type) {
        case JobType.dailyAnalysis:
          return await _processDailyAnalysis(job);
        case JobType.weeklyPatterns:
          return await _processWeeklyAnalysis(job);
        case JobType.monthlyHealth:
          return await _processMonthlyAnalysis(job);
        case JobType.microInsight:
          return await _processMicroInsight(job);
      }
    }

    // Set up timeout
    final timeoutFuture = Future.delayed(_jobTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Job processing timeout'));
      }
    });

    // Race between processing and timeout
    await Future.any([
      processJob().then(completer.complete),
      timeoutFuture,
    ]);

    return completer.future;
  }

  Future<String> _processDailyAnalysis(FluxLoopJob job) async {
    // Simulate daily analysis processing
    await Future<void>.delayed(const Duration(seconds: 1));
    return '{"analysisType": "daily", "insights": ["消费控制良好"], "score": 85}';
  }

  Future<String> _processWeeklyAnalysis(FluxLoopJob job) async {
    // Simulate weekly analysis processing
    await Future<void>.delayed(const Duration(seconds: 2));
    return '{"analysisType": "weekly", "anomalies": [], "trend": "stable"}';
  }

  Future<String> _processMonthlyAnalysis(FluxLoopJob job) async {
    // Simulate monthly analysis processing
    await Future<void>.delayed(const Duration(seconds: 3));
    return '{"analysisType": "monthly", "healthScore": 82, "grade": "B"}';
  }

  Future<String> _processMicroInsight(FluxLoopJob job) async {
    // Simulate micro-insight processing
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return '{"analysisType": "micro", "insight": "预算使用合理"}';
  }

  /// Get queue statistics
  Map<String, dynamic> getQueueStats() {
    final stats = <String, dynamic>{};

    for (final type in JobType.values) {
      stats[type.name] = {
        'queued': _jobQueues[type]!.length,
        'processing': _isProcessing[type]!,
        'totalJobs': _getTotalJobsForType(type),
      };
    }

    return stats;
  }

  int _getTotalJobsForType(JobType type) {
    return _jobQueues[type]!.length +
        _jobControllers.values
            .where((controller) => !controller.isClosed)
            .length;
  }

  /// Clean up completed jobs
  void cleanup() {
    final toRemove = <String>[];

    _jobControllers.forEach((jobId, controller) {
      if (controller.isClosed) {
        toRemove.add(jobId);
      }
    });

    for (final jobId in toRemove) {
      _jobControllers.remove(jobId);
    }
  }

  /// Shutdown the service
  Future<void> shutdown() async {
    _isProcessing.updateAll((key, value) => false);

    // Close all controllers
    for (final controller in _jobControllers.values) {
      await controller.close();
    }
    _jobControllers.clear();

    // Cancel all timers
    for (final timer in _processingTimers.values) {
      timer?.cancel();
    }
    _processingTimers.clear();
  }
}

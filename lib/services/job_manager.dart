import 'package:flutter/foundation.dart';
import '../models/print_job.dart';
import 'file_watcher_service.dart';

class JobManager extends ChangeNotifier {
  PrintJob? _currentJob;
  final FileWatcherService _fileWatcher = FileWatcherService();
  bool _isMonitoring = false;

  PrintJob? get currentJob => _currentJob;
  bool get isMonitoring => _isMonitoring;
  bool get hasActiveJob => _currentJob != null;

  JobManager() {
    _fileWatcher.scannedSheetsStream.listen(_onScannedSheetsUpdate);
  }

  /// Create a new print job
  void createJob({
    required String name,
    required int startSheet,
    required int endSheet,
  }) {
    _currentJob = PrintJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      startSheet: startSheet,
      endSheet: endSheet,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Start monitoring a CSV file for the current job
  Future<void> startMonitoring(String csvFilePath) async {
    if (_currentJob == null) {
      throw Exception('No active job to monitor');
    }

    try {
      await _fileWatcher.startWatching(csvFilePath);
      _isMonitoring = true;
      notifyListeners();
    } catch (e) {
      _isMonitoring = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Stop monitoring the current file
  Future<void> stopMonitoring() async {
    await _fileWatcher.stopWatching();
    _isMonitoring = false;
    notifyListeners();
  }

  /// Manually refresh data from the CSV file
  Future<void> refresh() async {
    if (_isMonitoring) {
      await _fileWatcher.refresh();
    }
  }

  /// Handle updates from the file watcher
  void _onScannedSheetsUpdate(Set<int> scannedSheets) {
    if (_currentJob != null) {
      _currentJob = _currentJob!.copyWith(scannedSheets: scannedSheets);
      notifyListeners();
    }
  }

  /// Clear the current job
  void clearJob() {
    stopMonitoring();
    _currentJob = null;
    notifyListeners();
  }

  /// Get statistics for the current job
  Map<String, dynamic> getJobStats() {
    if (_currentJob == null) {
      return {};
    }

    return {
      'total': _currentJob!.totalSheets,
      'scanned': _currentJob!.scannedCount,
      'missing': _currentJob!.missingCount,
      'progress': _currentJob!.progressPercentage,
    };
  }

  @override
  void dispose() {
    _fileWatcher.dispose();
    super.dispose();
  }
}

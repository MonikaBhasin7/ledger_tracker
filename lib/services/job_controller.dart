import 'package:get/get.dart';
import '../models/print_job.dart';
import '../services/file_watcher_service.dart';

class JobController extends GetxController {
  final Rx<PrintJob?> _currentJob = Rx<PrintJob?>(null);
  late final FileWatcherService _fileWatcher;
  final RxBool _isMonitoring = false.obs;

  // Getters
  PrintJob? get currentJob => _currentJob.value;
  bool get isMonitoring => _isMonitoring.value;
  bool get hasActiveJob => _currentJob.value != null;

  @override
  void onInit() {
    super.onInit();
    _fileWatcher = Get.put(FileWatcherService());

    // Watch for scanned sheets updates using the getter that returns Rx
    _fileWatcher.scannedSheetsRx.listen(_onScannedSheetsUpdate);
  }

  /// Create a new print job
  void createJob({
    required String name,
    required int startSheet,
    required int endSheet,
  }) {
    _currentJob.value = PrintJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      startSheet: startSheet,
      endSheet: endSheet,
      createdAt: DateTime.now(),
    );
  }

  /// Start monitoring a CSV file for the current job
  Future<void> startMonitoring(String csvFilePath) async {
    if (_currentJob.value == null) {
      throw Exception('No active job to monitor');
    }

    try {
      await _fileWatcher.startWatching(csvFilePath);
      _isMonitoring.value = true;
    } catch (e) {
      _isMonitoring.value = false;
      rethrow;
    }
  }

  /// Stop monitoring the current file
  Future<void> stopMonitoring() async {
    await _fileWatcher.stopWatching();
    _isMonitoring.value = false;
  }

  /// Manually refresh data from the CSV file
  Future<void> refresh() async {
    if (_isMonitoring.value) {
      await _fileWatcher.refresh();
    }
  }

  /// Handle updates from the file watcher
  void _onScannedSheetsUpdate(Set<int> scannedSheets) {
    if (_currentJob.value != null) {
      _currentJob.value = _currentJob.value?.copyWith(scannedSheets: scannedSheets);
    }
  }

  /// Clear the current job
  void clearJob() {
    stopMonitoring();
    _currentJob.value = null;
  }

  /// Get statistics for the current job
  Map<String, dynamic> getJobStats() {
    if (_currentJob.value == null) {
      return {};
    }

    return {
      'total': _currentJob.value?.totalSheets,
      'scanned': _currentJob.value?.scannedCount,
      'missing': _currentJob.value?.missingCount,
      'progress': _currentJob.value?.progressPercentage,
    };
  }

  @override
  void onClose() {
    Get.delete<FileWatcherService>();
    super.onClose();
  }
}
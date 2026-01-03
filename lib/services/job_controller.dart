import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_beep/flutter_beep.dart';
import '../models/print_job.dart';
import '../services/file_watcher_service.dart';

class JobController extends GetxController {
  final Rx<PrintJob?> _currentJob = Rx<PrintJob?>(null);
  late final FileWatcherService _fileWatcher;
  final RxBool _isMonitoring = false.obs;
  final RxBool _isPaused = false.obs; // Paused due to duplicate barcode

  Map<String, List<int>>? _previousDuplicates;

  // Getters
  PrintJob? get currentJob => _currentJob.value;
  bool get isMonitoring => _isMonitoring.value;
  bool get isPaused => _isPaused.value;
  bool get hasActiveJob => _currentJob.value != null;

  @override
  void onInit() {
    super.onInit();
    _fileWatcher = Get.put(FileWatcherService());

    // Watch for scanned data updates
    _fileWatcher.scannedDataRx.listen(_onScannedDataUpdate);
  }

  /// Create a new print job
  void createJob({
    required String name,
    required int startSheet,
    required int endSheet,
    required int batchSize,
  }) {
    _currentJob.value = PrintJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      startSheet: startSheet,
      endSheet: endSheet,
      batchSize: batchSize,
      createdAt: DateTime.now(),
    );
    _isPaused.value = false;
    _previousDuplicates = null;
  }

  /// Start monitoring a CSV file for the current job
  Future<void> startMonitoring(String csvFilePath) async {
    if (_currentJob.value == null) {
      throw Exception('No active job to monitor');
    }

    try {
      await _fileWatcher.startWatching(csvFilePath);
      _isMonitoring.value = true;
      _isPaused.value = false;
    } catch (e) {
      _isMonitoring.value = false;
      rethrow;
    }
  }

  /// Stop monitoring the current file
  Future<void> stopMonitoring() async {
    await _fileWatcher.stopWatching();
    _isMonitoring.value = false;
    _isPaused.value = false;
  }

  /// Resume monitoring after duplicate barcode alert
  void resumeMonitoring() {
    _isPaused.value = false;
  }

  /// Manually refresh data from the CSV file
  Future<void> refresh() async {
    if (_isMonitoring.value) {
      await _fileWatcher.refresh();
    }
  }

  /// Handle updates from the file watcher
  void _onScannedDataUpdate(Map<String, dynamic> data) {
    if (_currentJob.value != null && !_isPaused.value) {
      final scannedSheets = data['scannedSheets'] as Set<int>;
      final sheetBarcodes = data['sheetBarcodes'] as Map<int, String?>;
      final sheetsWithoutBarcode = data['sheetsWithoutBarcode'] as Set<int>;
      final duplicateBarcodes = data['duplicateBarcodes'] as Map<String, List<int>>;

      // Check for new duplicate barcodes
      if (duplicateBarcodes.isNotEmpty) {
        final hasNewDuplicates = _checkForNewDuplicates(duplicateBarcodes);

        if (hasNewDuplicates) {
          // ALERT: Duplicate barcode detected!
          _handleDuplicateBarcodeAlert(duplicateBarcodes);
        }
      }

      // Update job with new data
      _currentJob.value = _currentJob.value!.copyWith(
        scannedSheets: scannedSheets,
        sheetBarcodes: sheetBarcodes,
        sheetsWithoutBarcode: sheetsWithoutBarcode,
        duplicateBarcodes: duplicateBarcodes,
      );
    }
  }

  /// Check if there are new duplicate barcodes
  bool _checkForNewDuplicates(Map<String, List<int>> currentDuplicates) {
    if (_previousDuplicates == null || _previousDuplicates!.isEmpty) {
      if (currentDuplicates.isNotEmpty) {
        _previousDuplicates = Map.from(currentDuplicates);
        return true;
      }
      return false;
    }

    // Check if there are any new duplicates or changes
    for (var barcodeId in currentDuplicates.keys) {
      if (!_previousDuplicates!.containsKey(barcodeId)) {
        _previousDuplicates = Map.from(currentDuplicates);
        return true;
      }

      // Check if the duplicate has grown (more sheets with same barcode)
      if (currentDuplicates[barcodeId]!.length > _previousDuplicates![barcodeId]!.length) {
        _previousDuplicates = Map.from(currentDuplicates);
        return true;
      }
    }

    return false;
  }

  /// Handle duplicate barcode alert - play sound and pause monitoring
  Future<void> _handleDuplicateBarcodeAlert(Map<String, List<int>> duplicates) async {
    print('🚨 DUPLICATE BARCODE ALERT!');

    // Pause monitoring
    _isPaused.value = true;

    // Play alert sound (system beep sound)
    try {
      // Play error beep 3 times
      for (int i = 0; i < 3; i++) {
        await FlutterBeep.beep();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      print('Error playing alert sound: $e');
      // Fallback: just print to console
      print('🔊 BEEP BEEP BEEP - DUPLICATE BARCODE DETECTED!');
    }

    // Show alert dialog
    Get.dialog(
      barrierDismissible: false,
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Text('DUPLICATE BARCODE DETECTED!'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scanner glitch detected! Multiple sheets have the same barcode ID.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text('Duplicate Barcodes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...duplicates.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barcode: ${entry.key}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Found on sheets: ${entry.value.join(", ")}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  '⚠️  Scanning has been PAUSED. Please check your scanner and fix the issue before resuming.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.find<JobController>().resumeMonitoring();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume Monitoring'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.find<JobController>().stopMonitoring();
              },
              icon: const Icon(Icons.stop),
              label: const Text('Stop Job'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clear the current job
  void clearJob() {
    stopMonitoring();
    _currentJob.value = null;
    _isPaused.value = false;
    _previousDuplicates = null;
  }

  /// Get statistics for the current job
  Map<String, dynamic> getJobStats() {
    if (_currentJob.value == null) {
      return {};
    }

    return {
      'total': _currentJob.value!.totalSheets,
      'scanned': _currentJob.value!.scannedCount,
      'missing': _currentJob.value!.missingCount,
      'progress': _currentJob.value!.progressPercentage,
      'withoutBarcode': _currentJob.value!.sheetsWithoutBarcodeCount,
      'duplicateBarcodes': _currentJob.value!.duplicateBarcodeCount,
    };
  }

  @override
  void onClose() {
    Get.delete<FileWatcherService>();
    super.onClose();
  }
}
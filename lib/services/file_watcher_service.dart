import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:watcher/watcher.dart';

import 'csv_service.dart';

class FileWatcherService extends GetxController {
  FileWatcher? _watcher;
  StreamSubscription? _subscription;
  final Rx<String?> _currentFilePath = Rx<String?>(null);
  final Rx<Map<String, dynamic>> _scannedData = Rx<Map<String, dynamic>>({});

  // Getters
  String? get currentFilePath => _currentFilePath.value;

  Map<String, dynamic> get scannedData => _scannedData.value;

  Rx<Map<String, dynamic>> get scannedDataRx => _scannedData;

  bool get isWatching => _currentFilePath.value != null;

  /// Start watching a CSV file for changes
  Future<void> startWatching(String filePath) async {
    await stopWatching();

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    _currentFilePath.value = filePath;
    _watcher = FileWatcher(filePath);

    // Emit initial data
    final initialData = await CsvService.readScannedSheetsWithBarcodes(
      filePath,
    );
    _scannedData.value = initialData;

    // Watch for changes
    _subscription = _watcher!.events.listen(
      (event) async {
        if (event.type == ChangeType.MODIFY || event.type == ChangeType.ADD) {
          print('File changed: ${event.type}');

          // Small delay to ensure file write is complete
          await Future.delayed(const Duration(milliseconds: 100));

          final data = await CsvService.readScannedSheetsWithBarcodes(filePath);
          _scannedData.value = data;
        }
      },
      onError: (error) {
        print('File watcher error: $error');
      },
    );

    print('Started watching file: $filePath');
  }

  /// Stop watching the current file
  Future<void> stopWatching() async {
    await _subscription?.cancel();
    _subscription = null;
    _watcher = null;
    _currentFilePath.value = null;
  }

  /// Manually refresh the current file
  Future<void> refresh() async {
    if (_currentFilePath.value != null) {
      final data = await CsvService.readScannedSheetsWithBarcodes(
        _currentFilePath.value!,
      );
      _scannedData.value = data;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

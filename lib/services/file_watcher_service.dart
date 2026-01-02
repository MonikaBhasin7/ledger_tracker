import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:watcher/watcher.dart';
import 'csv_service.dart';

class FileWatcherService extends GetxController {
  FileWatcher? _watcher;
  StreamSubscription? _subscription;
  final Rx<String?> _currentFilePath = Rx<String?>(null);
  final Rx<Set<int>> _scannedSheets = Rx<Set<int>>({});

  // Getters
  String? get currentFilePath => _currentFilePath.value;
  Set<int> get scannedSheets => _scannedSheets.value;
  Rx<Set<int>> get scannedSheetsRx => _scannedSheets; // Expose the Rx for listening
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
    final initialSheets = await CsvService.readScannedSheets(filePath);
    _scannedSheets.value = initialSheets;

    // Watch for changes
    _subscription = _watcher!.events.listen((event) async {
      if (event.type == ChangeType.MODIFY || event.type == ChangeType.ADD) {
        print('File changed: ${event.type}');

        // Small delay to ensure file write is complete
        await Future.delayed(const Duration(milliseconds: 100));

        final sheets = await CsvService.readScannedSheets(filePath);
        _scannedSheets.value = sheets;
      }
    }, onError: (error) {
      print('File watcher error: $error');
    });

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
      final sheets = await CsvService.readScannedSheets(_currentFilePath.value!);
      _scannedSheets.value = sheets;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
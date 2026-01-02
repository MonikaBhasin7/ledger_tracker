import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';
import 'csv_service.dart';

class FileWatcherService {
  FileWatcher? _watcher;
  StreamSubscription? _subscription;
  String? _currentFilePath;
  final StreamController<Set<int>> _scannedSheetsController =
      StreamController<Set<int>>.broadcast();

  Stream<Set<int>> get scannedSheetsStream => _scannedSheetsController.stream;

  /// Start watching a CSV file for changes
  Future<void> startWatching(String filePath) async {
    await stopWatching();

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    _currentFilePath = filePath;
    _watcher = FileWatcher(filePath);

    // Emit initial data
    final initialSheets = await CsvService.readScannedSheets(filePath);
    _scannedSheetsController.add(initialSheets);

    // Watch for changes
    _subscription = _watcher!.events.listen((event) async {
      if (event.type == ChangeType.MODIFY || event.type == ChangeType.ADD) {
        print('File changed: ${event.type}');
        
        // Small delay to ensure file write is complete
        await Future.delayed(const Duration(milliseconds: 100));
        
        final sheets = await CsvService.readScannedSheets(filePath);
        _scannedSheetsController.add(sheets);
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
    _currentFilePath = null;
  }

  /// Manually refresh the current file
  Future<void> refresh() async {
    if (_currentFilePath != null) {
      final sheets = await CsvService.readScannedSheets(_currentFilePath!);
      _scannedSheetsController.add(sheets);
    }
  }

  /// Check if currently watching a file
  bool get isWatching => _currentFilePath != null;

  String? get currentFilePath => _currentFilePath;

  void dispose() {
    _subscription?.cancel();
    _scannedSheetsController.close();
  }
}

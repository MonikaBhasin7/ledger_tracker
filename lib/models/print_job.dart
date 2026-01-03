class PrintJob {
  final String id;
  final String name;
  final int startSheet;
  final int endSheet;
  final int batchSize;
  final DateTime createdAt;
  final Set<int> scannedSheets;
  final Map<int, String?> sheetBarcodes; // sheet_number -> barcode_id
  final Set<int> sheetsWithoutBarcode; // Sheets that are missing barcodes
  final Map<String, List<int>> duplicateBarcodes; // barcode_id -> list of sheet_numbers

  PrintJob({
    required this.id,
    required this.name,
    required this.startSheet,
    required this.endSheet,
    required this.batchSize,
    required this.createdAt,
    Set<int>? scannedSheets,
    Map<int, String?>? sheetBarcodes,
    Set<int>? sheetsWithoutBarcode,
    Map<String, List<int>>? duplicateBarcodes,
  })  : scannedSheets = scannedSheets ?? {},
        sheetBarcodes = sheetBarcodes ?? {},
        sheetsWithoutBarcode = sheetsWithoutBarcode ?? {},
        duplicateBarcodes = duplicateBarcodes ?? {};

  int get totalSheets => endSheet - startSheet + 1;
  int get scannedCount => scannedSheets.length;
  int get missingCount => totalSheets - scannedCount;
  double get progressPercentage => (scannedCount / totalSheets) * 100;

  // Batch calculations
  int get totalBatches => (totalSheets / batchSize).ceil();

  // Get batch number for a sheet
  int getBatchNumber(int sheetNumber) {
    final position = sheetNumber - startSheet;
    return (position / batchSize).floor() + 1;
  }

  // Get sheet range for a batch
  Map<String, int> getBatchRange(int batchNumber) {
    final batchStartPosition = (batchNumber - 1) * batchSize;
    final batchStart = startSheet + batchStartPosition;
    final batchEnd = (batchStart + batchSize - 1).clamp(startSheet, endSheet);
    return {'start': batchStart, 'end': batchEnd};
  }

  // Get all sheets in a batch
  List<int> getSheetsInBatch(int batchNumber) {
    final range = getBatchRange(batchNumber);
    return List.generate(
      range['end']! - range['start']! + 1,
          (index) => range['start']! + index,
    );
  }

  // Get scanned sheets in a batch
  List<int> getScannedInBatch(int batchNumber) {
    final batchSheets = getSheetsInBatch(batchNumber);
    return batchSheets.where((sheet) => scannedSheets.contains(sheet)).toList();
  }

  // Get missing sheets in a batch
  List<int> getMissingInBatch(int batchNumber) {
    final batchSheets = getSheetsInBatch(batchNumber);
    return batchSheets.where((sheet) => !scannedSheets.contains(sheet)).toList();
  }

  // Get sheets without barcode in a batch
  List<int> getSheetsWithoutBarcodeInBatch(int batchNumber) {
    final batchSheets = getSheetsInBatch(batchNumber);
    return batchSheets.where((sheet) => sheetsWithoutBarcode.contains(sheet)).toList();
  }

  // Get duplicate sheets in a batch
  List<int> getDuplicatesInBatch(int batchNumber) {
    final batchSheets = getSheetsInBatch(batchNumber).toSet();
    final duplicateSheets = <int>[];

    for (var sheets in duplicateBarcodes.values) {
      for (var sheet in sheets) {
        if (batchSheets.contains(sheet) && !duplicateSheets.contains(sheet)) {
          duplicateSheets.add(sheet);
        }
      }
    }

    return duplicateSheets;
  }

  // Get batch statistics
  Map<String, int> getBatchStats(int batchNumber) {
    final range = getBatchRange(batchNumber);
    final totalInBatch = range['end']! - range['start']! + 1;
    final scannedInBatch = getScannedInBatch(batchNumber).length;
    final missingInBatch = getMissingInBatch(batchNumber).length;
    final noBarcodeInBatch = getSheetsWithoutBarcodeInBatch(batchNumber).length;
    final duplicatesInBatch = getDuplicatesInBatch(batchNumber).length;

    return {
      'total': totalInBatch,
      'scanned': scannedInBatch,
      'missing': missingInBatch,
      'noBarcode': noBarcodeInBatch,
      'duplicates': duplicatesInBatch,
    };
  }

  // New getters for barcode validation
  int get sheetsWithoutBarcodeCount => sheetsWithoutBarcode.length;
  int get duplicateBarcodeCount => duplicateBarcodes.values.fold(0, (sum, list) => sum + list.length);
  bool get hasBarcodeIssues => sheetsWithoutBarcode.isNotEmpty || duplicateBarcodes.isNotEmpty;
  bool get hasDuplicateBarcodes => duplicateBarcodes.isNotEmpty;

  List<int> get expectedSheets {
    return List.generate(totalSheets, (index) => startSheet + index);
  }

  List<int> get missingSheets {
    return expectedSheets.where((sheet) => !scannedSheets.contains(sheet)).toList()
      ..sort();
  }

  bool isSheetScanned(int sheetNumber) {
    return scannedSheets.contains(sheetNumber);
  }

  PrintJob copyWith({
    String? id,
    String? name,
    int? startSheet,
    int? endSheet,
    int? batchSize,
    DateTime? createdAt,
    Set<int>? scannedSheets,
    Map<int, String?>? sheetBarcodes,
    Set<int>? sheetsWithoutBarcode,
    Map<String, List<int>>? duplicateBarcodes,
  }) {
    return PrintJob(
      id: id ?? this.id,
      name: name ?? this.name,
      startSheet: startSheet ?? this.startSheet,
      endSheet: endSheet ?? this.endSheet,
      batchSize: batchSize ?? this.batchSize,
      createdAt: createdAt ?? this.createdAt,
      scannedSheets: scannedSheets ?? this.scannedSheets,
      sheetBarcodes: sheetBarcodes ?? this.sheetBarcodes,
      sheetsWithoutBarcode: sheetsWithoutBarcode ?? this.sheetsWithoutBarcode,
      duplicateBarcodes: duplicateBarcodes ?? this.duplicateBarcodes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startSheet': startSheet,
      'endSheet': endSheet,
      'batchSize': batchSize,
      'createdAt': createdAt.toIso8601String(),
      'scannedSheets': scannedSheets.toList(),
      'sheetBarcodes': sheetBarcodes.map((k, v) => MapEntry(k.toString(), v)),
      'sheetsWithoutBarcode': sheetsWithoutBarcode.toList(),
      'duplicateBarcodes': duplicateBarcodes.map(
            (k, v) => MapEntry(k, v.toList()),
      ),
    };
  }

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      id: json['id'] as String,
      name: json['name'] as String,
      startSheet: json['startSheet'] as int,
      endSheet: json['endSheet'] as int,
      batchSize: json['batchSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scannedSheets: Set<int>.from(json['scannedSheets'] as List),
      sheetBarcodes: (json['sheetBarcodes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as String?),
      ),
      sheetsWithoutBarcode: json['sheetsWithoutBarcode'] != null
          ? Set<int>.from(json['sheetsWithoutBarcode'] as List)
          : null,
      duplicateBarcodes: (json['duplicateBarcodes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<int>.from(v as List)),
      ),
    );
  }
}
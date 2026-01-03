class ScannedSheet {
  final int sheetNumber;
  final String? barcodeId;
  final DateTime timestamp;
  final String? scannerId;

  ScannedSheet({
    required this.sheetNumber,
    this.barcodeId,
    required this.timestamp,
    this.scannerId,
  });

  bool get hasBarcodeId => barcodeId != null && barcodeId!.isNotEmpty;

  @override
  String toString() {
    return 'ScannedSheet(sheet: $sheetNumber, barcode: $barcodeId, time: $timestamp)';
  }

  Map<String, dynamic> toJson() {
    return {
      'sheetNumber': sheetNumber,
      'barcodeId': barcodeId,
      'timestamp': timestamp.toIso8601String(),
      'scannerId': scannerId,
    };
  }

  factory ScannedSheet.fromCsvRow(List<dynamic> row) {
    final sheetNumber = int.parse(row[0].toString());
    
    // Try to get barcode from second column (if exists)
    String? barcodeId;
    if (row.length > 1 && row[1] != null && row[1].toString().trim().isNotEmpty) {
      // Check if it's a barcode (not a timestamp)
      final secondColumn = row[1].toString().trim();
      // If it doesn't look like a timestamp, treat it as barcode
      if (!secondColumn.contains(':') && !secondColumn.contains('-')) {
        barcodeId = secondColumn;
      }
    }
    
    // Try to parse timestamp
    DateTime timestamp = DateTime.now();
    String? scannerId;
    
    // If barcode exists, timestamp might be in 3rd column
    if (barcodeId != null && row.length > 2) {
      try {
        timestamp = DateTime.parse(row[2].toString());
      } catch (e) {
        // Keep default timestamp
      }
      if (row.length > 3) {
        scannerId = row[3].toString();
      }
    } 
    // If no barcode, timestamp might be in 2nd column
    else if (row.length > 1) {
      try {
        timestamp = DateTime.parse(row[1].toString());
      } catch (e) {
        // Keep default timestamp
      }
      if (row.length > 2) {
        scannerId = row[2].toString();
      }
    }
    
    return ScannedSheet(
      sheetNumber: sheetNumber,
      barcodeId: barcodeId,
      timestamp: timestamp,
      scannerId: scannerId,
    );
  }
}
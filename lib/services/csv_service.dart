import 'dart:io';

import 'package:csv/csv.dart';

class CsvService {
  /// Read scanned sheet numbers with barcode validation from a CSV file
  /// Expected CSV formats:
  /// 1. sheet_number, barcode_id, timestamp, scanner_id
  /// 2. sheet_number, timestamp, scanner_id (no barcode)
  /// 3. sheet_number (simple)
  static Future<Map<String, dynamic>> readScannedSheetsWithBarcodes(
    String filePath,
  ) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return {
          'scannedSheets': <int>{},
          'sheetBarcodes': <int, String?>{},
          'sheetsWithoutBarcode': <int>{},
          'duplicateBarcodes': <String, List<int>>{},
        };
      }

      final contents = await file.readAsString();

      if (contents.trim().isEmpty) {
        return {
          'scannedSheets': <int>{},
          'sheetBarcodes': <int, String?>{},
          'sheetsWithoutBarcode': <int>{},
          'duplicateBarcodes': <String, List<int>>{},
        };
      }

      // Split by lines first (handle different line endings)
      final lines = contents.split(RegExp(r'\r?\n'));

      final Set<int> scannedSheets = {};
      final Map<int, String?> sheetBarcodes = {};
      final Set<int> sheetsWithoutBarcode = {};
      final Map<String, List<int>> barcodeToSheets =
          {}; // Track which sheets have which barcodes

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        // Skip empty lines
        if (line.isEmpty) continue;

        // Split by comma to get columns
        final parts = line.split(',').map((e) => e.trim()).toList();
        if (parts.isEmpty) continue;

        // Skip header row if it exists
        if (i == 0) {
          final lowerCase = parts[0].toLowerCase();
          if (lowerCase.contains('sheet') ||
              lowerCase.contains('number') ||
              lowerCase.contains('id')) {
            continue;
          }
        }

        // Try to parse sheet number (first column)
        try {
          final sheetNumber = int.parse(parts[0]);
          scannedSheets.add(sheetNumber);

          // Try to get barcode ID (second column)
          String? barcodeId;
          if (parts.length > 1 && parts[1].isNotEmpty) {
            // Check if second column looks like a barcode (not a timestamp)
            final secondCol = parts[1];
            // Simple check: if it doesn't contain ':' or '-', it's likely a barcode
            if (!secondCol.contains(':') && !secondCol.contains('-')) {
              barcodeId = secondCol;
            }
          }

          // Store barcode for this sheet
          sheetBarcodes[sheetNumber] = barcodeId;

          // Flag sheets without barcode
          if (barcodeId == null || barcodeId.isEmpty) {
            sheetsWithoutBarcode.add(sheetNumber);
            print('⚠️  Sheet $sheetNumber: Missing barcode ID');
          } else {
            // Track barcode usage for duplicate detection
            if (!barcodeToSheets.containsKey(barcodeId)) {
              barcodeToSheets[barcodeId] = [];
            }
            barcodeToSheets[barcodeId]!.add(sheetNumber);

            print('✓ Scanned sheet $sheetNumber with barcode: $barcodeId');
          }
        } catch (e) {
          // Skip invalid rows
          print('Warning: Could not parse line $i: "$line"');
        }
      }

      // Find duplicate barcodes
      final Map<String, List<int>> duplicateBarcodes = {};
      barcodeToSheets.forEach((barcodeId, sheets) {
        if (sheets.length > 1) {
          duplicateBarcodes[barcodeId] = sheets;
          print('🚨 DUPLICATE BARCODE: $barcodeId found on sheets: $sheets');
        }
      });

      print(
        'Summary: ${scannedSheets.length} sheets scanned, ${sheetsWithoutBarcode.length} without barcode, ${duplicateBarcodes.length} duplicate barcodes',
      );

      return {
        'scannedSheets': scannedSheets,
        'sheetBarcodes': sheetBarcodes,
        'sheetsWithoutBarcode': sheetsWithoutBarcode,
        'duplicateBarcodes': duplicateBarcodes,
      };
    } catch (e) {
      print('Error reading CSV file: $e');
      return {
        'scannedSheets': <int>{},
        'sheetBarcodes': <int, String?>{},
        'sheetsWithoutBarcode': <int>{},
        'duplicateBarcodes': <String, List<int>>{},
      };
    }
  }

  /// Export missing sheets to a CSV file
  static Future<void> exportMissingSheets(
    String filePath,
    List<int> missingSheets,
  ) async {
    try {
      final file = File(filePath);

      final List<List<dynamic>> rows = [
        ['Missing Sheet Number'],
        ...missingSheets.map((sheet) => [sheet]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
    } catch (e) {
      print('Error exporting CSV file: $e');
      rethrow;
    }
  }

  /// Export sheets without barcode
  static Future<void> exportSheetsWithoutBarcode(
    String filePath,
    List<int> sheets,
  ) async {
    try {
      final file = File(filePath);

      final List<List<dynamic>> rows = [
        ['Sheet Number (Missing Barcode)'],
        ...sheets.map((sheet) => [sheet]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
    } catch (e) {
      print('Error exporting CSV file: $e');
      rethrow;
    }
  }

  /// Export duplicate barcode report
  static Future<void> exportDuplicateBarcodes(
    String filePath,
    Map<String, List<int>> duplicates,
  ) async {
    try {
      final file = File(filePath);

      final List<List<dynamic>> rows = [
        ['Barcode ID', 'Sheet Numbers', 'Count'],
      ];

      duplicates.forEach((barcodeId, sheets) {
        rows.add([barcodeId, sheets.join(', '), sheets.length]);
      });

      final csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
    } catch (e) {
      print('Error exporting CSV file: $e');
      rethrow;
    }
  }

  /// Validate CSV file format
  static Future<bool> validateCsvFormat(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return false;
      }

      final contents = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter().convert(
        contents,
      );

      if (rows.isEmpty) {
        return false;
      }

      // Check if we can parse at least one valid sheet number
      for (var row in rows) {
        if (row.isNotEmpty) {
          try {
            int.parse(row[0].toString());
            return true;
          } catch (e) {
            continue;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

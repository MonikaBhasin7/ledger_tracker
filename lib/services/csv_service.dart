import 'dart:io';
import 'package:csv/csv.dart';

class CsvService {
  /// Read scanned sheet numbers from a CSV file
  /// Expected CSV format: sheet_number, timestamp, scanner_id (optional)
  /// or just: sheet_number
  static Future<Set<int>> readScannedSheets(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return {};
      }

      final contents = await file.readAsString();

      if (contents.trim().isEmpty) {
        return {};
      }

      // Split by lines first (handle different line endings)
      final lines = contents.split(RegExp(r'\r?\n'));

      final Set<int> scannedSheets = {};

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        // Skip empty lines
        if (line.isEmpty) continue;

        // Split by comma to get the first column
        final parts = line.split(',');
        if (parts.isEmpty) continue;

        final firstColumn = parts[0].trim();

        // Skip header row if it exists
        if (i == 0) {
          final lowerCase = firstColumn.toLowerCase();
          if (lowerCase.contains('sheet') ||
              lowerCase.contains('number') ||
              lowerCase.contains('id')) {
            continue;
          }
        }

        // Try to parse as integer
        try {
          final sheetNumber = int.parse(firstColumn);
          scannedSheets.add(sheetNumber);
          print('Parsed sheet number: $sheetNumber');
        } catch (e) {
          // Skip invalid rows
          print('Warning: Could not parse line $i: "$line"');
        }
      }

      print('Total scanned sheets: ${scannedSheets.length}');
      return scannedSheets;
    } catch (e) {
      print('Error reading CSV file: $e');
      return {};
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

  /// Validate CSV file format
  static Future<bool> validateCsvFormat(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        return false;
      }

      final contents = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter().convert(contents);
      
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

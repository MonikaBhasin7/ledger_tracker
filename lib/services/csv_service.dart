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

      final List<List<dynamic>> rows = const CsvToListConverter().convert(contents);
      
      final Set<int> scannedSheets = {};
      
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].isEmpty) continue;
        
        // Skip header row if it exists (check if first cell is not a number)
        if (i == 0 && rows[i][0] is String) {
          final firstCell = rows[i][0].toString().toLowerCase();
          if (firstCell.contains('sheet') || 
              firstCell.contains('number') || 
              firstCell.contains('id')) {
            continue;
          }
        }
        
        try {
          final sheetNumber = int.parse(rows[i][0].toString());
          scannedSheets.add(sheetNumber);
        } catch (e) {
          // Skip invalid rows
          print('Warning: Could not parse row $i: ${rows[i]}');
        }
      }
      
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

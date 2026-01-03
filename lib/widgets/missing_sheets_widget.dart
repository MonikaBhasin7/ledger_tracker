import 'package:flutter/material.dart';

class MissingSheetsWidget extends StatelessWidget {
  final List<int> missingSheets;
  final int totalSheets;
  final Set<int> sheetsWithoutBarcode;
  final Map<String, List<int>> duplicateBarcodes;

  const MissingSheetsWidget({
    super.key,
    required this.missingSheets,
    required this.totalSheets,
    this.sheetsWithoutBarcode = const {},
    this.duplicateBarcodes = const {},
  });

  @override
  Widget build(BuildContext context) {
    final hasBarcodeIssues =
        sheetsWithoutBarcode.isNotEmpty || duplicateBarcodes.isNotEmpty;

    return DefaultTabController(
      length: hasBarcodeIssues ? 3 : 1,
      child: Column(
        children: [
          if (hasBarcodeIssues)
            TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 16),
                      const SizedBox(width: 8),
                      Text('Missing (${missingSheets.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2, size: 16),
                      const SizedBox(width: 8),
                      Text('No Barcode (${sheetsWithoutBarcode.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 16),
                      const SizedBox(width: 8),
                      Text('Duplicates (${duplicateBarcodes.length})'),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
            child: hasBarcodeIssues
                ? TabBarView(
                    children: [
                      _buildMissingSheetsList(context),
                      _buildNoBarcodeList(context),
                      _buildDuplicatesList(context),
                    ],
                  )
                : _buildMissingSheetsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingSheetsList(BuildContext context) {
    if (missingSheets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              'All Sheets Scanned!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No missing sheets detected',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missingSheets.length,
      itemBuilder: (context, index) {
        final sheetNumber = missingSheets[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('Sheet #$sheetNumber'),
            subtitle: const Text('Not yet scanned'),
            trailing: const Icon(Icons.warning, color: Colors.orange),
          ),
        );
      },
    );
  }

  Widget _buildNoBarcodeList(BuildContext context) {
    final sheets = sheetsWithoutBarcode.toList()..sort();

    if (sheets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              'All Sheets Have Barcodes!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No barcode validation issues detected',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sheets.length,
      itemBuilder: (context, index) {
        final sheetNumber = sheets[index];
        return Card(
          color: Colors.orange[50],
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.qr_code_2, color: Colors.white),
            ),
            title: Text('Sheet #$sheetNumber'),
            subtitle: const Text('⚠️ Missing barcode ID'),
            trailing: const Icon(Icons.warning, color: Colors.orange),
          ),
        );
      },
    );
  }

  Widget _buildDuplicatesList(BuildContext context) {
    if (duplicateBarcodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              'No Duplicate Barcodes!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All barcodes are unique',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duplicateBarcodes.length,
      itemBuilder: (context, index) {
        final entry = duplicateBarcodes.entries.elementAt(index);
        final barcodeId = entry.key;
        final sheets = entry.value;

        return Card(
          color: Colors.red[50],
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: const Icon(Icons.error, color: Colors.white),
            ),
            title: Text(
              'Barcode: $barcodeId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('🚨 Found on ${sheets.length} sheets'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duplicate Sheets:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sheets.map((sheet) {
                        return Chip(
                          label: Text('Sheet #$sheet'),
                          backgroundColor: Colors.red[100],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

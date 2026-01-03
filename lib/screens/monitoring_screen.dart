import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/csv_service.dart';
import '../services/job_controller.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JobController jobController = Get.find();

    return Obx(() {
      final job = jobController.currentJob;
      final isPaused = jobController.isPaused;

      if (job == null) {
        return const Center(child: Text('No active job'));
      }

      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Top Bar - Job Info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sheets ${job.startSheet} - ${job.endSheet}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _confirmEndJob(jobController),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Paused Warning (if applicable)
            if (isPaused)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red[600],
                child: Row(
                  children: const [
                    Icon(Icons.pause_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PAUSED - Duplicate barcode detected',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Progress Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${job.scannedCount} / ${job.totalSheets}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: job.progressPercentage / 100,
                            minHeight: 20,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              job.progressPercentage == 100
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${job.progressPercentage.toStringAsFixed(1)}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Statistics
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStatRow(
                          'Missing Sheets',
                          job.missingCount,
                          job.missingCount > 0 ? Colors.orange : Colors.grey,
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Without Barcode',
                          job.sheetsWithoutBarcodeCount,
                          job.sheetsWithoutBarcodeCount > 0
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Duplicate Barcodes',
                          job.duplicateBarcodeCount,
                          job.duplicateBarcodeCount > 0
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Batch Statistics
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Batch Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${job.totalBatches} batches',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Batch size: ${job.batchSize} sheets per batch',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildBatchList(job),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scanned Sheets Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Scanned Sheets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${job.scannedCount} sheets',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (job.scannedCount == 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No sheets scanned yet',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          _buildScannedSheetsList(job),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Missing Sheets Details
                  if (job.missingCount > 0)
                    _buildIssueSection(
                      'Missing Sheets',
                      job.missingSheets,
                      Colors.orange,
                      Icons.warning_amber,
                    ),

                  if (job.sheetsWithoutBarcodeCount > 0) ...[
                    const SizedBox(height: 20),
                    _buildIssueSection(
                      'Sheets Without Barcode',
                      job.sheetsWithoutBarcode.toList()..sort(),
                      Colors.orange,
                      Icons.qr_code_2,
                    ),
                  ],

                  if (job.duplicateBarcodeCount > 0) ...[
                    const SizedBox(height: 20),
                    _buildDuplicateSection(job.duplicateBarcodes),
                  ],

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => jobController.refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: job.missingCount > 0
                              ? () => _exportMissingSheets(job.missingSheets)
                              : null,
                          icon: const Icon(Icons.download),
                          label: const Text('Export Issues'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannedSheetsList(job) {
    // Get all scanned sheets sorted
    final scannedSheets = job.scannedSheets.toList()..sort();
    final sheetBarcodes = job.sheetBarcodes;

    // Show first 50 sheets
    final displaySheets = scannedSheets.take(50).toList();
    final hasMore = scannedSheets.length > 50;

    // Group sheets by batch
    Map<int, List<int>> sheetsByBatch = {};
    for (var sheet in displaySheets) {
      final batchNumber = job.getBatchNumber(sheet);
      if (!sheetsByBatch.containsKey(batchNumber)) {
        sheetsByBatch[batchNumber] = [];
      }
      sheetsByBatch[batchNumber]!.add(sheet);
    }

    final sortedBatchNumbers = sheetsByBatch.keys.toList()..sort();

    return Column(
      children: [
        // Batch-grouped display
        ...sortedBatchNumbers.map((batchNumber) {
          final sheetsInBatch = sheetsByBatch[batchNumber]!;
          final range = job.getBatchRange(batchNumber);

          // Determine batch color (alternate colors for visual separation)
          final batchColor = batchNumber % 2 == 0
              ? Colors.blue[50]
              : Colors.grey[50];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: batchColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Batch Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Batch $batchNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sheets ${range['start']} - ${range['end']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${sheetsInBatch.length} scanned',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Sheet #',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Barcode ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 60,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sheets in this batch
                ...sheetsInBatch.map((sheetNum) {
                  final barcodeId = sheetBarcodes[sheetNum];
                  final hasBarcode = barcodeId != null && barcodeId.isNotEmpty;

                  // Check if this barcode is duplicated
                  bool isDuplicate = false;
                  if (job.duplicateBarcodes.isNotEmpty) {
                    for (var entry in job.duplicateBarcodes.entries) {
                      if (entry.value.contains(sheetNum)) {
                        isDuplicate = true;
                        break;
                      }
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDuplicate
                          ? Colors.red[50]
                          : !hasBarcode
                          ? Colors.orange[50]
                          : Colors.white,
                      border: Border.all(
                        color: isDuplicate
                            ? Colors.red[200]!
                            : !hasBarcode
                            ? Colors.orange[200]!
                            : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '$sheetNum',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasBarcode ? barcodeId : 'No Barcode',
                            style: TextStyle(
                              fontSize: 13,
                              color: hasBarcode
                                  ? Colors.black
                                  : Colors.orange[700],
                              fontWeight: hasBarcode
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              fontFamily: hasBarcode ? 'monospace' : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Icon(
                              isDuplicate
                                  ? Icons.error
                                  : !hasBarcode
                                  ? Icons.warning
                                  : Icons.check_circle,
                              color: isDuplicate
                                  ? Colors.red
                                  : !hasBarcode
                                  ? Colors.orange
                                  : Colors.green,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 8),
              ],
            ),
          );
        }).toList(),

        if (hasMore) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '+ ${scannedSheets.length - 50} more sheets (showing first 50)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBatchList(job) {
    // Show first 20 batches or all if less than 20
    final batchesToShow = job.totalBatches > 20 ? 20 : job.totalBatches;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: batchesToShow,
          itemBuilder: (context, index) {
            final batchNumber = index + 1;
            final stats = job.getBatchStats(batchNumber);
            final range = job.getBatchRange(batchNumber);

            // Convert all to lists and sort
            final scannedSheets = job.getScannedInBatch(batchNumber).toList()
              ..sort();
            final missingSheets = job.getMissingInBatch(batchNumber).toList()
              ..sort();
            final noBarcodeSheets =
                job.getSheetsWithoutBarcodeInBatch(batchNumber).toList()
                  ..sort();
            final duplicateSheets =
                job.getDuplicatesInBatch(batchNumber).toList()..sort();

            final hasIssues =
                stats['missing']! > 0 ||
                stats['noBarcode']! > 0 ||
                stats['duplicates']! > 0;

            final progressPercent = (stats['scanned']! / stats['total']! * 100);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: hasIssues ? Colors.orange[300]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: hasIssues
                      ? Colors.orange[50]
                      : Colors.grey[50],
                  collapsedBackgroundColor: hasIssues
                      ? Colors.orange[50]
                      : Colors.grey[50],
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: hasIssues ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$batchNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Batch $batchNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Sheets ${range['start']} - ${range['end']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressPercent == 100 ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBatchStat(
                            'Scanned',
                            stats['scanned']!,
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildBatchStat(
                            'Missing',
                            stats['missing']!,
                            stats['missing']! > 0 ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          _buildBatchStat(
                            'No BC',
                            stats['noBarcode']!,
                            stats['noBarcode']! > 0
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          _buildBatchStat(
                            'Dup',
                            stats['duplicates']!,
                            stats['duplicates']! > 0 ? Colors.red : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Scanned Sheets
                          if (scannedSheets.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Scanned Sheets (${scannedSheets.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: scannedSheets
                                  .take(20)
                                  .map((sheet) {
                                    final barcodeId = job.sheetBarcodes[sheet];
                                    final hasBarcode =
                                        barcodeId != null &&
                                        barcodeId.isNotEmpty;
                                    final isDuplicate = duplicateSheets
                                        .contains(sheet);
                                    final noBarcode = noBarcodeSheets.contains(
                                      sheet,
                                    );

                                    return Tooltip(
                                      message: hasBarcode
                                          ? 'Barcode: $barcodeId'
                                          : 'No Barcode',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDuplicate
                                              ? Colors.red[100]
                                              : noBarcode
                                              ? Colors.orange[100]
                                              : Colors.green[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: isDuplicate
                                                ? Colors.red[300]!
                                                : noBarcode
                                                ? Colors.orange[300]!
                                                : Colors.green[300]!,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$sheet',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isDuplicate
                                                    ? Colors.red[900]
                                                    : noBarcode
                                                    ? Colors.orange[900]
                                                    : Colors.green[900],
                                              ),
                                            ),
                                            if (isDuplicate || noBarcode) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                isDuplicate
                                                    ? Icons.error
                                                    : Icons.warning,
                                                size: 12,
                                                color: isDuplicate
                                                    ? Colors.red[900]
                                                    : Colors.orange[900],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ),
                            if (scannedSheets.length > 20) ...[
                              const SizedBox(height: 6),
                              Text(
                                '+ ${scannedSheets.length - 20} more',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],

                          // Missing Sheets
                          if (missingSheets.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Missing Sheets (${missingSheets.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: missingSheets
                                  .take(20)
                                  .map<Widget>((sheet) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.orange[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        '$sheet',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ),
                            if (missingSheets.length > 20) ...[
                              const SizedBox(height: 6),
                              Text(
                                '+ ${missingSheets.length - 20} more',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],

                          // Sheets Without Barcode
                          if (noBarcodeSheets.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.qr_code_2,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No Barcode (${noBarcodeSheets.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: noBarcodeSheets
                                  .take(20)
                                  .map<Widget>((sheet) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.orange[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        '$sheet',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ),
                            if (noBarcodeSheets.length > 20) ...[
                              const SizedBox(height: 6),
                              Text(
                                '+ ${noBarcodeSheets.length - 20} more',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],

                          // Duplicate Barcodes
                          if (duplicateSheets.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Duplicate Barcodes (${duplicateSheets.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: duplicateSheets
                                  .map<Widget>((sheet) {
                                    final barcodeId = job.sheetBarcodes[sheet];
                                    return Tooltip(
                                      message: 'Barcode: $barcodeId',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.red[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          '$sheet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.red[900],
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (job.totalBatches > 20) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '+ ${job.totalBatches - 20} more batches (showing first 20)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBatchStat(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIssueSection(
    String title,
    List<int> sheets,
    Color color,
    IconData icon,
  ) {
    final displaySheets = sheets.take(20).toList();
    final hasMore = sheets.length > 20;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displaySheets.map((sheet) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '$sheet',
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              );
            }).toList(),
          ),
          if (hasMore) ...[
            const SizedBox(height: 12),
            Text(
              '+ ${sheets.length - 20} more',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDuplicateSection(Map<String, List<int>> duplicates) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text(
                'Duplicate Barcodes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...duplicates.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barcode: ${entry.key}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((sheet) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Sheet $sheet',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportMissingSheets(List<int> missingSheets) async {
    try {
      final controller = TextEditingController();

      final path = await Get.dialog<String>(
        AlertDialog(
          title: const Text('Export Missing Sheets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the full path where you want to save the file:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText:
                      '/Users/yourname/Desktop/missing_sheets_${DateTime.now().millisecondsSinceEpoch}.csv',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Example: /Users/yourname/Desktop/missing.csv',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(result: controller.text.trim());
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );

      if (path != null && path.isNotEmpty) {
        await CsvService.exportMissingSheets(path, missingSheets);

        Get.snackbar(
          'Success',
          'Missing sheets exported successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error exporting: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _exportSheetsWithoutBarcode(List<int> sheets) async {
    try {
      final controller = TextEditingController();

      final path = await Get.dialog<String>(
        AlertDialog(
          title: const Text('Export Sheets Without Barcode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the full path where you want to save the file:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText:
                      '/Users/yourname/Desktop/no_barcode_${DateTime.now().millisecondsSinceEpoch}.csv',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Example: /Users/yourname/Desktop/no_barcode.csv',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(result: controller.text.trim());
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );

      if (path != null && path.isNotEmpty) {
        await CsvService.exportSheetsWithoutBarcode(path, sheets);

        Get.snackbar(
          'Success',
          'Sheets without barcode exported successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error exporting: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _exportDuplicateBarcodes(
    Map<String, List<int>> duplicates,
  ) async {
    try {
      final controller = TextEditingController();

      final path = await Get.dialog<String>(
        AlertDialog(
          title: const Text('Export Duplicate Barcodes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the full path where you want to save the file:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText:
                      '/Users/yourname/Desktop/duplicates_${DateTime.now().millisecondsSinceEpoch}.csv',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Example: /Users/yourname/Desktop/duplicates.csv',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(result: controller.text.trim());
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );

      if (path != null && path.isNotEmpty) {
        await CsvService.exportDuplicateBarcodes(path, duplicates);

        Get.snackbar(
          'Success',
          'Duplicate barcodes exported successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error exporting: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _confirmEndJob(JobController jobController) {
    Get.dialog(
      AlertDialog(
        title: const Text('End Job'),
        content: const Text(
          'Are you sure you want to end this job? All progress will be cleared.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              jobController.clearJob();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Job'),
          ),
        ],
      ),
    );
  }
}

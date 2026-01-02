import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/csv_service.dart';
import '../services/job_controller.dart';
import '../widgets/missing_sheets_widget.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JobController jobController = Get.find();

    return Obx(() {
      final job = jobController.currentJob;

      if (job == null) {
        return const Center(child: Text('No active job'));
      }

      return Column(
        children: [
          // Job Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.primaryContainer,
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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sheets ${job.startSheet} - ${job.endSheet} (${job.totalSheets} total)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Created: ${DateFormat('MMM dd, yyyy - HH:mm').format(job.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _confirmEndJob(jobController),
                      tooltip: 'End Job',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Sheets',
                        job.totalSheets.toString(),
                        Icons.description,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Scanned',
                        job.scannedCount.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Missing',
                        job.missingCount.toString(),
                        Icons.warning,
                        job.missingCount > 0 ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${job.progressPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: job.progressPercentage / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => jobController.refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed: job.missingCount > 0
                    //         ? () => _exportMissingSheets(job.missingSheets)
                    //         : null,
                    //     icon: const Icon(Icons.download),
                    //     label: const Text('Export Missing'),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Missing Sheets List
          Expanded(
            child: MissingSheetsWidget(
              missingSheets: job.missingSheets,
              totalSheets: job.totalSheets,
            ),
          ),
        ],
      );
    });
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
              const Text('Enter the full path where you want to save the file:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '/Users/yourname/Desktop/missing_sheets_${DateTime.now().millisecondsSinceEpoch}.csv',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Example: /Users/yourname/Desktop/missing.csv',
                style: TextStyle(fontSize: 11, color: Colors.grey),
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

  void _confirmEndJob(JobController jobController) {
    Get.dialog(
      AlertDialog(
        title: const Text('End Job'),
        content: const Text('Are you sure you want to end this job? All progress will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              jobController.clearJob();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Job'),
          ),
        ],
      ),
    );
  }
}
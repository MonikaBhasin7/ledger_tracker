import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/job_controller.dart';
import 'job_setup_screen.dart';
import 'monitoring_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JobController jobController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Tracker'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Obx(() {
        if (!jobController.hasActiveJob) {
          return _buildWelcomeScreen(context);
        } else {
          return const MonitoringScreen();
        }
      }),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.print,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 32),
            Text(
              'Print Tracker',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Track your print jobs and verify scanned sheets',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const JobSetupScreen());
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Print Job'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _showInfoDialog(context);
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('How it works'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('How Print Tracker Works'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoStep('1', 'Create a print job with sheet range'),
              _buildInfoStep('2', 'Select the CSV file to monitor'),
              _buildInfoStep('3', 'Watch real-time scanning progress'),
              _buildInfoStep('4', 'See which sheets are missing'),
              const SizedBox(height: 16),
              const Text(
                'CSV Format:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'sheet_number,timestamp,scanner_id\n1,2024-01-01 10:00:00,Scanner1\n2,2024-01-01 10:00:05,Scanner1',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Or simply one sheet number per line',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
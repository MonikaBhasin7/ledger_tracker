import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../services/job_controller.dart';

class JobSetupScreen extends StatefulWidget {
  const JobSetupScreen({super.key});

  @override
  State<JobSetupScreen> createState() => _JobSetupScreenState();
}

class _JobSetupScreenState extends State<JobSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobNameController = TextEditingController();
  final _startSheetController = TextEditingController();
  final _endSheetController = TextEditingController();
  final _batchSizeController = TextEditingController();
  String? _selectedCsvPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _jobNameController.dispose();
    _startSheetController.dispose();
    _endSheetController.dispose();
    _batchSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Select CSV File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the full path to your CSV file:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '/Users/yourname/Desktop/file.csv',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Drag the file from Finder into Terminal, then copy the path',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                setState(() {
                  _selectedCsvPath = path;
                });
              }
              Get.back();
            },
            child: const Text('Use This File'),
          ),
        ],
      ),
    );
  }

  Future<void> _startJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCsvPath == null) {
      Get.snackbar(
        'File Required',
        'Please select a CSV file to monitor',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final JobController jobController = Get.find();

      // Create the job
      jobController.createJob(
        name: _jobNameController.text.trim(),
        startSheet: int.parse(_startSheetController.text),
        endSheet: int.parse(_endSheetController.text),
        batchSize: int.parse(_batchSizeController.text),
      );

      // Navigate back to home screen first (which will show monitoring screen)
      Get.back();

      // Small delay to ensure navigation completes
      await Future.delayed(const Duration(milliseconds: 100));

      // Start monitoring (alerts will now appear on monitoring screen)
      await jobController.startMonitoring(_selectedCsvPath!);

      Get.snackbar(
        'Success',
        'Job created and monitoring started!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Print Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Job Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _jobNameController,
                decoration: InputDecoration(
                  labelText: 'Job Name',
                  hintText: 'e.g., OMR Sheets Batch 1',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startSheetController,
                      decoration: InputDecoration(
                        labelText: 'Start Sheet',
                        hintText: '1',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.first_page),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 1) {
                          return 'Must be ≥ 1';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endSheetController,
                      decoration: InputDecoration(
                        labelText: 'End Sheet',
                        hintText: '1000',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.last_page),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final endNum = int.tryParse(value);
                        final startNum = int.tryParse(
                          _startSheetController.text,
                        );

                        if (endNum == null) {
                          return 'Invalid number';
                        }
                        if (startNum != null && endNum <= startNum) {
                          return 'Must be > start';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _batchSizeController,
                decoration: InputDecoration(
                  labelText: 'Batch Size',
                  hintText: 'e.g., 100',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  helperText: 'Number of sheets per batch',
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter batch size';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1) {
                    return 'Must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'CSV File to Monitor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickCsvFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select CSV File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              if (_selectedCsvPath != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedCsvPath!.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _startJob,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? 'Starting...' : 'Start Monitoring'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

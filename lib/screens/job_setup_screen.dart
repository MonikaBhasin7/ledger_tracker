import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/job_manager.dart';

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
  String? _selectedCsvPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _jobNameController.dispose();
    _startSheetController.dispose();
    _endSheetController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: 'Select CSV file to monitor',
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedCsvPath = result.files.single.path!;
      });
    }
  }

  Future<void> _startJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCsvPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a CSV file to monitor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jobManager = context.read<JobManager>();

      // Create the job
      jobManager.createJob(
        name: _jobNameController.text.trim(),
        startSheet: int.parse(_startSheetController.text),
        endSheet: int.parse(_endSheetController.text),
      );

      // Start monitoring
      await jobManager.startMonitoring(_selectedCsvPath!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job created and monitoring started!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      appBar: AppBar(
        title: const Text('Create Print Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Job Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _jobNameController,
                decoration: const InputDecoration(
                  labelText: 'Job Name',
                  hintText: 'e.g., OMR Sheets Batch 1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
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
                      decoration: const InputDecoration(
                        labelText: 'Start Sheet',
                        hintText: '1',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.first_page),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
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
                      decoration: const InputDecoration(
                        labelText: 'End Sheet',
                        hintText: '1000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.last_page),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final endNum = int.tryParse(value);
                        final startNum = int.tryParse(_startSheetController.text);
                        
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
              const SizedBox(height: 32),
              const Text(
                'CSV File to Monitor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

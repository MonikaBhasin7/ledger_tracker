import 'package:flutter/material.dart';

class MissingSheetsWidget extends StatelessWidget {
  final List<int> missingSheets;
  final int totalSheets;

  const MissingSheetsWidget({
    super.key,
    required this.missingSheets,
    required this.totalSheets,
  });

  @override
  Widget build(BuildContext context) {
    if (missingSheets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            Text(
              'All sheets scanned!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No missing sheets detected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 12),
              Text(
                'Missing Sheets (${missingSheets.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: missingSheets.length,
            itemBuilder: (context, index) {
              final sheetNumber = missingSheets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Sheet #$sheetNumber',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.error_outline,
                    color: Colors.orange[700],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

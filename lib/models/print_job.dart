class PrintJob {
  final String id;
  final String name;
  final int startSheet;
  final int endSheet;
  final DateTime createdAt;
  final Set<int> scannedSheets;

  PrintJob({
    required this.id,
    required this.name,
    required this.startSheet,
    required this.endSheet,
    required this.createdAt,
    Set<int>? scannedSheets,
  }) : scannedSheets = scannedSheets ?? {};

  int get totalSheets => endSheet - startSheet + 1;
  int get scannedCount => scannedSheets.length;
  int get missingCount => totalSheets - scannedCount;
  double get progressPercentage => (scannedCount / totalSheets) * 100;

  List<int> get expectedSheets {
    return List.generate(totalSheets, (index) => startSheet + index);
  }

  List<int> get missingSheets {
    return expectedSheets.where((sheet) => !scannedSheets.contains(sheet)).toList()
      ..sort();
  }

  bool isSheetScanned(int sheetNumber) {
    return scannedSheets.contains(sheetNumber);
  }

  PrintJob copyWith({
    String? id,
    String? name,
    int? startSheet,
    int? endSheet,
    DateTime? createdAt,
    Set<int>? scannedSheets,
  }) {
    return PrintJob(
      id: id ?? this.id,
      name: name ?? this.name,
      startSheet: startSheet ?? this.startSheet,
      endSheet: endSheet ?? this.endSheet,
      createdAt: createdAt ?? this.createdAt,
      scannedSheets: scannedSheets ?? this.scannedSheets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startSheet': startSheet,
      'endSheet': endSheet,
      'createdAt': createdAt.toIso8601String(),
      'scannedSheets': scannedSheets.toList(),
    };
  }

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      id: json['id'] as String,
      name: json['name'] as String,
      startSheet: json['startSheet'] as int,
      endSheet: json['endSheet'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scannedSheets: Set<int>.from(json['scannedSheets'] as List),
    );
  }
}

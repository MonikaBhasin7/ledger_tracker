# Print Tracker - Desktop App

A Flutter desktop application to track print jobs and verify scanned sheets by monitoring CSV files in real-time.

## 📋 Features

- ✅ Create print jobs with custom sheet ranges (e.g., 1-1000)
- ✅ Real-time CSV file monitoring
- ✅ Automatic detection of missing sheets
- ✅ Progress tracking and statistics
- ✅ Export missing sheets to CSV
- ✅ Cross-platform (Windows, macOS, Linux)

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Platform-specific requirements:
  - **Windows**: Visual Studio 2022 with "Desktop development with C++"
  - **macOS**: Xcode
  - **Linux**: Required build tools (run `flutter doctor` for details)

### Installation Steps

1. **Verify Flutter Installation**
   ```bash
   flutter doctor
   ```
   Make sure all checks pass for your platform.

2. **Enable Desktop Support** (if not already enabled)
   ```bash
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   flutter config --enable-linux-desktop
   ```

3. **Navigate to Project Directory**
   ```bash
   cd print_tracker
   ```

4. **Install Dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the App**
   ```bash
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   
   # For Linux
   flutter run -d linux
   ```

## 📖 How to Use

### 1. Create a Print Job
- Launch the app
- Click **"Create New Print Job"**
- Enter job details:
  - **Job Name**: e.g., "OMR Sheets Batch 1"
  - **Start Sheet**: e.g., 1
  - **End Sheet**: e.g., 1000

### 2. Select CSV File
- Click **"Select CSV File"**
- Choose the CSV file that will be updated as sheets are scanned
- The file will be monitored in real-time

### 3. Monitor Progress
- View real-time statistics:
  - **Total Sheets**: Total number of sheets in the job
  - **Scanned**: Number of sheets successfully scanned
  - **Missing**: Number of sheets not yet scanned
- See progress percentage
- View detailed list of missing sheets

### 4. Export Missing Sheets
- Click **"Export Missing"** button
- Save the list of missing sheets as a CSV file

## 📄 CSV File Format

The app monitors CSV files containing scanned sheet numbers. Two formats are supported:

### Format 1: Simple (one number per line)
```csv
1
2
3
5
7
```

### Format 2: With Headers and Additional Data
```csv
sheet_number,timestamp,scanner_id
1,2024-12-27 10:00:00,Scanner1
2,2024-12-27 10:00:05,Scanner1
3,2024-12-27 10:00:10,Scanner1
5,2024-12-27 10:00:15,Scanner1
```

**Important**: The first column must contain the sheet number (as an integer).

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── print_job.dart                 # Print job data model
├── services/
│   ├── csv_service.dart               # CSV reading/writing
│   ├── file_watcher_service.dart      # Real-time file monitoring
│   └── job_manager.dart               # Job state management
├── screens/
│   ├── home_screen.dart               # Welcome/home screen
│   ├── job_setup_screen.dart          # Job creation screen
│   └── monitoring_screen.dart         # Real-time monitoring screen
└── widgets/
    └── missing_sheets_widget.dart     # Missing sheets display
```

## 🔨 Building for Production

### Windows
```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### macOS
```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/`

### Linux
```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

## 🛠️ Troubleshooting

### App doesn't detect file changes
- Ensure the CSV file exists before starting monitoring
- Check file permissions (read access required)
- Try clicking the **"Refresh"** button manually
- Make sure the file is being modified (not replaced)

### CSV parsing errors
- Verify the CSV format (first column = sheet number)
- Check for empty lines or invalid data
- Ensure sheet numbers are integers
- Remove any special characters from sheet numbers

### Desktop build issues
1. Run `flutter doctor` to check your setup
2. Ensure platform-specific tools are installed
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter build [windows|macos|linux]
   ```

### File picker not working
- On Linux, ensure `zenity` is installed:
  ```bash
  sudo apt-get install zenity
  ```

## 📦 Dependencies

- **Flutter** - UI framework
- **Provider** - State management
- **watcher** - File system monitoring
- **csv** - CSV parsing and generation
- **file_picker** - File selection dialogs
- **window_manager** - Desktop window configuration
- **intl** - Date formatting

## 🎯 Use Cases

- **Educational Institutions**: Track OMR sheet scanning for exams
- **Print Shops**: Verify print job completion
- **Document Processing**: Ensure all documents are scanned
- **Quality Control**: Identify missing items in batch processing

## 📝 License

MIT License - Feel free to use and modify for your needs.

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests!

## 📧 Support

For issues or questions:
1. Check the troubleshooting section above
2. Run `flutter doctor` to verify your setup
3. Check that all dependencies are installed with `flutter pub get`

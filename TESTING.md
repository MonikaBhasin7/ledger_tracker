# Automated Testing Guide

## 📊 Overview

This guide explains how to automatically test your Print Tracker app by simulating a scanner that adds sheet numbers to a CSV file.

## 🛠️ Testing Tools Included

1. **test_scanner.py** - Python script that simulates scanning
2. **run_test.sh** - Bash script for macOS/Linux (easy to use)
3. **run_test.bat** - Batch script for Windows (easy to use)

## 🚀 Quick Start

### Option 1: Easy Testing (Recommended)

**macOS/Linux:**
```bash
./run_test.sh
```

**Windows:**
```bash
run_test.bat
```

This will:
- Create a test CSV file on your Desktop
- Simulate scanning sheets 1-50
- Skip ~15% of sheets randomly (to test missing detection)
- Update every 0.5 seconds

### Option 2: Custom Testing

**macOS/Linux:**
```bash
./run_test.sh /path/to/file.csv 1 100 1.0 0.2
#             [csv file]    [start] [end] [delay] [skip%]
```

**Windows:**
```bash
run_test.bat C:\path\to\file.csv 1 100 1.0 0.2
```

## 📋 Step-by-Step Testing Process

### Step 1: Run Your Flutter App
```bash
cd print_tracker
flutter run -d macos  # or windows/linux
```

### Step 2: Create a Print Job in the App
1. Click **"Create New Print Job"**
2. Enter job details:
    - Job Name: "Test Job"
    - Start Sheet: **1**
    - End Sheet: **50** (or whatever you configured)
3. For CSV file path, enter: `/Users/yourname/Desktop/test_scan.csv`
4. Click **"Start Monitoring"**

### Step 3: Run the Test Script

Open a **new terminal** (keep the app running) and run:

**macOS:**
```bash
cd print_tracker
./run_test.sh
```

**Windows:**
```bash
cd print_tracker
run_test.bat
```

### Step 4: Watch the Magic! ✨

You should see:
- **In Terminal**: Progress of scanning simulation
- **In App**: Real-time updates showing:
    - Scanned count increasing
    - Progress bar filling up
    - Missing sheets appearing in the list

## 🎮 Advanced Usage

### Python Script Direct Usage

```bash
python3 test_scanner.py <csv_file> [options]

Options:
  --start INT      Start sheet number (default: 1)
  --end INT        End sheet number (default: 10)
  --delay FLOAT    Delay between scans in seconds (default: 1.0)
  --skip FLOAT     Probability of skipping sheets 0.0-1.0 (default: 0.1)
```

### Examples

**Fast scanning (0.2s delay):**
```bash
python3 test_scanner.py ~/Desktop/fast_test.csv --start 1 --end 100 --delay 0.2 --skip 0.1
```

**Slow scanning (2s delay) with many misses:**
```bash
python3 test_scanner.py ~/Desktop/slow_test.csv --start 1 --end 50 --delay 2.0 --skip 0.3
```

**Perfect scan (no missing sheets):**
```bash
python3 test_scanner.py ~/Desktop/perfect.csv --start 1 --end 20 --delay 0.5 --skip 0.0
```

**Lots of missing sheets (50% skip rate):**
```bash
python3 test_scanner.py ~/Desktop/missing_test.csv --start 1 --end 30 --delay 0.3 --skip 0.5
```

## 📊 Test Scenarios

### Scenario 1: Normal Operation
```bash
./run_test.sh ~/Desktop/normal.csv 1 50 0.5 0.1
```
- 50 sheets
- Fast scanning (0.5s)
- 10% missing (5 sheets typically)

### Scenario 2: High Volume
```bash
./run_test.sh ~/Desktop/high_volume.csv 1 1000 0.1 0.05
```
- 1000 sheets
- Very fast (0.1s)
- 5% missing (~50 sheets)

### Scenario 3: Many Problems
```bash
./run_test.sh ~/Desktop/problems.csv 1 30 1.0 0.4
```
- 30 sheets
- Normal speed (1s)
- 40% missing (~12 sheets)

### Scenario 4: Perfect Scan
```bash
./run_test.sh ~/Desktop/perfect.csv 1 100 0.3 0.0
```
- 100 sheets
- Fast (0.3s)
- No missing sheets

## 🧪 What to Test

### ✅ Functional Testing
- [ ] App detects new scanned sheets in real-time
- [ ] Progress bar updates correctly
- [ ] Missing sheets list is accurate
- [ ] Statistics (Total/Scanned/Missing) are correct
- [ ] Refresh button works
- [ ] Export missing sheets works

### ✅ Performance Testing
- [ ] App handles rapid CSV updates (0.1s delay)
- [ ] App handles large datasets (1000+ sheets)
- [ ] No memory leaks during long scans
- [ ] UI remains responsive

### ✅ Edge Cases
- [ ] Empty CSV file (no data yet)
- [ ] CSV file with only headers
- [ ] All sheets scanned (0 missing)
- [ ] All sheets missing (0 scanned)
- [ ] Random order of sheet numbers

## 🐛 Troubleshooting

### Script doesn't run
```bash
# Make scripts executable
chmod +x run_test.sh test_scanner.py
```

### Python not found
```bash
# Install Python 3
# macOS: brew install python3
# Linux: sudo apt-get install python3
# Windows: Download from python.org
```

### CSV file not updating in app
- Make sure the file path is correct
- Check that file watcher is working
- Try clicking "Refresh" button manually
- Check terminal for error messages

### Simulator runs too fast
```bash
# Increase delay to 2 seconds
./run_test.sh ~/Desktop/test.csv 1 50 2.0 0.1
```

## 📝 Sample Test Output

```
📊 CSV Scanner Simulator
==================================================
File: /Users/monika/Desktop/test_scan.csv
Range: 1 - 50
Delay: 0.5 seconds
Skip probability: 15.0%
==================================================

✓ Scanned sheet 1 (1/50)
✓ Scanned sheet 2 (2/50)
⏭️  Skipped sheet 3
✓ Scanned sheet 4 (3/50)
✓ Scanned sheet 5 (4/50)
...
==================================================
✅ Scanning complete!
📄 Total scanned: 43
⚠️  Skipped sheets: 7
   Missing: 3, 8, 15, 22, 31, 40, 47
==================================================
```

## 🎯 Best Practices

1. **Start with small tests** (10-20 sheets) to verify everything works
2. **Gradually increase** to larger datasets (100, 500, 1000 sheets)
3. **Test different skip rates** to ensure detection accuracy
4. **Run overnight tests** with slow delays to test stability
5. **Monitor memory usage** during large tests

## 📈 Performance Benchmarks

Recommended limits:
- **Small**: 1-100 sheets (instant)
- **Medium**: 100-500 sheets (~30 seconds with 0.1s delay)
- **Large**: 500-1000 sheets (~2 minutes with 0.1s delay)
- **Very Large**: 1000-5000 sheets (~10 minutes with 0.1s delay)

## 🔄 Continuous Testing

For automated testing, you can create a loop:

```bash
for i in {1..5}; do
  echo "Test run $i"
  ./run_test.sh ~/Desktop/test_$i.csv 1 100 0.2 0.1
  sleep 5
done
```

This runs 5 test scenarios back-to-back!

## ✅ Expected Results

After a successful test, your app should show:
- ✅ Correct total sheets count
- ✅ Accurate scanned count
- ✅ Precise missing sheets list
- ✅ Correct progress percentage
- ✅ Real-time updates (no manual refresh needed)
- ✅ Ability to export missing sheets

---

Happy Testing! 🧪✨
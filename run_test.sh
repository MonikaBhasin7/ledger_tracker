#!/bin/bash

# Print Tracker - Automated Test Script

echo "================================================"
echo "Print Tracker - Automated Testing"
echo "================================================"
echo ""

# Configuration
CSV_FILE="${1:-~/Desktop/test_scan.csv}"
START_SHEET="${2:-1}"
END_SHEET="${3:-50}"
DELAY="${4:-0.5}"
SKIP_PROB="${5:-0.15}"

echo "Test Configuration:"
echo "  CSV File: $CSV_FILE"
echo "  Sheet Range: $START_SHEET - $END_SHEET"
echo "  Delay: $DELAY seconds"
echo "  Skip Probability: $SKIP_PROB (15%)"
echo ""
echo "================================================"
echo ""

# Create CSV file if it doesn't exist
if [ ! -f "$CSV_FILE" ]; then
    echo "Creating new CSV file..."
    echo "sheet_number,timestamp,scanner_id" > "$CSV_FILE"
    echo "✓ Created: $CSV_FILE"
    echo ""
fi

echo "Instructions:"
echo "1. Open your Print Tracker app"
echo "2. Create a new job:"
echo "   - Start: $START_SHEET"
echo "   - End: $END_SHEET"
echo "3. Select this CSV file: $CSV_FILE"
echo "4. Press ENTER here to start simulation"
echo ""
read -p "Press ENTER to start scanning simulation..."
echo ""

# Start Python simulator
python3 test_scanner.py "$CSV_FILE" --start "$START_SHEET" --end "$END_SHEET" --delay "$DELAY" --skip "$SKIP_PROB"

echo ""
echo "Test complete! Check the app for missing sheets."
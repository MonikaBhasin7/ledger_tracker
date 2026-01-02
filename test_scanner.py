#!/usr/bin/env python3
"""
CSV Scanner Simulator
Simulates a scanner by automatically adding sheet numbers to a CSV file
"""

import csv
import time
import random
import sys
from datetime import datetime
import os

def simulate_scanning(csv_file_path, start_sheet, end_sheet, delay=1.0, skip_probability=0.1):
    """
    Simulate scanning by adding sheet numbers to CSV file

    Args:
        csv_file_path: Path to the CSV file
        start_sheet: First sheet number
        end_sheet: Last sheet number
        delay: Delay between scans in seconds
        skip_probability: Probability of skipping a sheet (0.0 to 1.0)
    """

    print(f"📊 CSV Scanner Simulator")
    print(f"=" * 50)
    print(f"File: {csv_file_path}")
    print(f"Range: {start_sheet} - {end_sheet}")
    print(f"Delay: {delay} seconds")
    print(f"Skip probability: {skip_probability * 100}%")
    print(f"=" * 50)
    print()

    # Create file with headers if it doesn't exist
    if not os.path.exists(csv_file_path):
        with open(csv_file_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['sheet_number', 'timestamp', 'scanner_id'])
        print("✅ Created new CSV file with headers\n")

    scanned_count = 0
    skipped_sheets = []

    try:
        for sheet_num in range(start_sheet, end_sheet + 1):
            # Randomly skip some sheets
            if random.random() < skip_probability:
                skipped_sheets.append(sheet_num)
                print(f"⏭️  Skipped sheet {sheet_num}")
                continue

            # Add sheet to CSV
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            with open(csv_file_path, 'a', newline='') as f:
                writer = csv.writer(f)
                writer.writerow([sheet_num, timestamp, 'Scanner1'])

            scanned_count += 1
            print(f"✓ Scanned sheet {sheet_num} ({scanned_count}/{end_sheet - start_sheet + 1})")

            # Delay before next scan
            time.sleep(delay)

        print()
        print(f"=" * 50)
        print(f"✅ Scanning complete!")
        print(f"📄 Total scanned: {scanned_count}")
        print(f"⚠️  Skipped sheets: {len(skipped_sheets)}")
        if skipped_sheets:
            print(f"   Missing: {', '.join(map(str, skipped_sheets))}")
        print(f"=" * 50)

    except KeyboardInterrupt:
        print()
        print(f"\n⏸️  Scanning interrupted!")
        print(f"📄 Scanned so far: {scanned_count}")
        if skipped_sheets:
            print(f"⚠️  Skipped: {', '.join(map(str, skipped_sheets))}")

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Simulate CSV scanner for testing')
    parser.add_argument('csv_file', help='Path to CSV file')
    parser.add_argument('--start', type=int, default=1, help='Start sheet number (default: 1)')
    parser.add_argument('--end', type=int, default=10, help='End sheet number (default: 10)')
    parser.add_argument('--delay', type=float, default=1.0, help='Delay between scans in seconds (default: 1.0)')
    parser.add_argument('--skip', type=float, default=0.1, help='Probability of skipping sheets (default: 0.1)')

    args = parser.parse_args()

    # Validate arguments
    if args.start < 1:
        print("❌ Error: Start sheet must be >= 1")
        sys.exit(1)

    if args.end < args.start:
        print("❌ Error: End sheet must be >= start sheet")
        sys.exit(1)

    if args.skip < 0 or args.skip > 1:
        print("❌ Error: Skip probability must be between 0 and 1")
        sys.exit(1)

    simulate_scanning(args.csv_file, args.start, args.end, args.delay, args.skip)

if __name__ == '__main__':
    main()
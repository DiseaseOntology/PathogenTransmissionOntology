#!/usr/bin/env python3
"""
concat_csv.py
-------------
Concatenates multiple CSV files from a directory and its subdirectories into a single
output CSV file.

- Accepts one or more filename patterns for input selection (e.g., '*.csv',
'edit-verify-*.csv').
- Prepends each input file's content with a header including the category and file name.
- Removes the input files after concatenation.
- Always creates the output file, even if no input files are found.
- If the category is 'TEST', exits with error status code 1 after processing.

Usage:
    python3 concat_csv.py <category> <output_file> <input_dir> [pattern1 pattern2 ...]

Example:
    python3 concat_csv.py TEST output.csv ./data '*.csv' 'edit-verify-*.csv'
"""
import sys
import os
import fnmatch
import csv


def find_csv_files(input_dir, patterns):
    matches = []
    if patterns:
        for pattern in patterns:
            for root, _, files in os.walk(input_dir):
                for filename in fnmatch.filter(files, pattern):
                    matches.append(os.path.join(root, filename))
    else:
        for root, _, files in os.walk(input_dir):
            for filename in fnmatch.filter(files, "*.csv"):
                matches.append(os.path.join(root, filename))
    return matches


def concat_csv(category, output_file, input_dir, *patterns):
    files = find_csv_files(input_dir, patterns)
    if not files:
        # No files found
        open(output_file, "w").close()
        return
    # Files found
    with open(output_file, "w", newline="") as out_f:
        writer = None
        for idx, file in enumerate(files):
            with open(file, newline="") as in_f:
                reader = csv.reader(in_f)
                if idx == 0:
                    out_f.write(
                        f"{category}: {os.path.splitext(os.path.basename(file))[0]}\n"
                    )
                    for row in reader:
                        writer = writer or csv.writer(out_f)
                        writer.writerow(row)
                else:
                    out_f.write(
                        f"\n{category}: {os.path.splitext(os.path.basename(file))[0]}\n"
                    )
                    for row in reader:
                        writer.writerow(row)
    # Optionally, remove input files after concatenation
    for file in files:
        try:
            os.remove(file)
        except Exception as e:
            print(f"Warning: could not remove {file}: {e}", file=sys.stderr)
    if category == "TEST":
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(
            "Usage: concat_csv.py <category> <output_file> <input_dir> [pattern1 pattern2 ...]",
            file=sys.stderr,
        )
        sys.exit(1)
    concat_csv(sys.argv[1], sys.argv[2], sys.argv[3], *sys.argv[4:])

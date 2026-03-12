#!/usr/bin/env python3
"""
concat_csv.py
-------------
Concatenates multiple CSV files into a single output CSV file.

- Accepts a list of file paths as input; files that do not exist are silently skipped.
- Prepends each input file's content with a header including the category and file name.
- Removes the input files after concatenation.
- If no input files exist, an empty output file is created and the script exits successfully.
- If the category is 'TEST', exits with error status code 1 after processing.

Usage:
    python3 concat_csv.py --category <category> --output <output_file> [file1 file2 ...]

Example:
    python3 concat_csv.py --category TEST --output output.csv file1.csv file2.csv
"""
import sys
import os
import csv
import argparse


def concat_csv(category, output_file, input_files):
    files = sorted(f for f in input_files if os.path.isfile(f))
    if not files:
        # No files exist - create empty output and exit successfully
        open(output_file, "w").close()
        return
    # Files found - concatenate into output
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
    # Remove input files after concatenation
    for file in files:
        try:
            os.remove(file)
        except Exception as e:
            print(f"Warning: could not remove {file}: {e}", file=sys.stderr)
    if category == "TEST":
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Concatenate CSV files into a single output file."
    )
    parser.add_argument(
        "--category", required=True, help="Category label for each section header"
    )
    parser.add_argument("--output", required=True, help="Output CSV file path")
    parser.add_argument(
        "files",
        nargs="*",
        metavar="file",
        help="Input CSV file paths (non-existent files are silently skipped)",
    )
    args = parser.parse_args()
    concat_csv(args.category, args.output, args.files)

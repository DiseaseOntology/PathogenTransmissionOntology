#!/usr/bin/env python3
"""
clean_existing_csv.py
--------------------
Removes CSV files matching given patterns from a directory and its subdirectories.

- Accepts one or more filename patterns for input selection (e.g., '*.csv',
'edit-verify-*.csv').
- If no patterns are given, removes all CSV files in the directory tree.

Usage:
    python3 clean_existing_csv.py <input_dir> [pattern1 pattern2 ...]

Example:
    python3 clean_existing_csv.py ./data '*.csv' 'edit-verify-*.csv'
"""
import sys
import os
import fnmatch


def clean_existing_csv(input_dir, *patterns):
    if patterns:
        matches = []
        for pattern in patterns:
            for root, _, files in os.walk(input_dir):
                for filename in fnmatch.filter(files, pattern):
                    matches.append(os.path.join(root, filename))
    else:
        matches = []
        for root, _, files in os.walk(input_dir):
            for filename in fnmatch.filter(files, "*.csv"):
                matches.append(os.path.join(root, filename))
    for f in matches:
        try:
            os.remove(f)
        except Exception as e:
            print(f"Warning: could not remove {f}: {e}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(
            "Usage: clean_existing_csv.py <input_dir> [pattern1 pattern2 ...]",
            file=sys.stderr,
        )
        sys.exit(1)
    clean_existing_csv(sys.argv[1], *sys.argv[2:])

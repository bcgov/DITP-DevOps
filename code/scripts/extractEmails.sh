#!/bin/bash
# Extracts email addresses from an input file and writes a deduplicated list, one per line.
# Usage: ./extractEmails.sh <inputFile> [outputFile]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <inputFile> [outputFile]" >&2
  exit 1
fi

inputFile="$1"
outputFile="${2:-emails.txt}"

if [[ ! -f "${inputFile}" ]]; then
  echo "Input file not found: ${inputFile}" >&2
  exit 1
fi

# Lowercase for case-insensitive dedupe.
tr -d '\r' < "${inputFile}" \
  | grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  | tr '[:upper:]' '[:lower:]' \
  | LC_ALL=C sort -u > "${outputFile}"

echo "Wrote $(wc -l < "${outputFile}" | tr -d ' ') unique email address(es) to ${outputFile}"

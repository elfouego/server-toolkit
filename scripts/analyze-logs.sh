#! /usr/bin/env bash
set -euo pipefail
LOGFILE="${1:?Usage: analyze-logs.sh <access.log>}"
echo "=== Top IPs générant des erreurs 4xx ==="
awk '$NF ~/^4[0-9]{2}$/ {print $3}' "$LOGFILE" | sort | uniq -c | sort -rn | head -10

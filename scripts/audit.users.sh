#!/usr/bin/env bash
set -euo pipefail
echo "=== audit des comptes utilisateurs ==="
awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd

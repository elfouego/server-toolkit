#! /usr/bin/env bash
set -euo pipefail
URL="${1:?Usage: healthcheck.sh <url>}"
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [ "$CODE" = "200" ]; then
  echo "OK: $URL répond avec le code $CODE"
  exit 0
else
  echo "ALERTE: $URL répond avec le code $CODE"
  exit 1
fi
correstif urgent

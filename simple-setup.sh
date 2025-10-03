#!/usr/bin/env bash
set -euo pipefail

echo "[setup] Fetching Track-Ignored-Stuff files..."
tmpdir="$(mktemp -d)"

# Replace with URLs to the raw kit files in your repo (or gist)
BASE_URL="https://raw.githubusercontent.com/hesreallyhim/track-ignored-stuff/main"

# Download .githooks/pre-push
mkdir -p .githooks
curl -fsSL "$BASE_URL/.githooks/pre-push" -o .githooks/pre-push
chmod +x .githooks/pre-push

# Download scripts
mkdir -p scripts
for f in publish.sh sync-internal.sh; do
  curl -fsSL "$BASE_URL/scripts/$f" -o "scripts/$f"
  chmod +x "scripts/$f"
done

# Download Makefile
curl -fsSL "$BASE_URL/Makefile" -o Makefile

# Download README into `scripts/` directory
curl -fsSL "$BASE_URL/README.md" -o scripts/README.md

echo "[setup] Initializing hook..."
make init

echo "[setup] Done. Verify with: make check-hook"

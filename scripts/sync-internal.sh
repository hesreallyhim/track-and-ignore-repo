#!/usr/bin/env bash
set -euo pipefail

# Push ONLY the __INTERNAL__ subdirectory history to a private repo using git subtree.
# Usage:
#   INTERNAL_REMOTE=origin-internal INTERNAL_BRANCH=main scripts/sync-internal.sh
#
# Requirements: git with subtree support.
INTERNAL_DIR="${INTERNAL_DIR:-__INTERNAL__}"
INTERNAL_REMOTE="${INTERNAL_REMOTE:-origin-internal}"
INTERNAL_BRANCH="${INTERNAL_BRANCH:-main}"

# Check that remote exists
if ! git remote get-url "${INTERNAL_REMOTE}" >/dev/null 2>&1; then
  echo "ERROR: Remote '${INTERNAL_REMOTE}' not found. Configure it first." >&2
  exit 2
fi

# Push the subdirectory history
git subtree push --prefix="${INTERNAL_DIR}" "${INTERNAL_REMOTE}" "${INTERNAL_BRANCH}" || {
  echo "Subtree push failed. Ensure '${INTERNAL_DIR}' is a NORMAL directory (not a submodule)." >&2
  exit 3
}

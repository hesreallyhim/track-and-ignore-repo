#!/usr/bin/env bash
set -euo pipefail

# Publish a CLEAN public history to GitHub by removing __INTERNAL__/ from ALL history.
# Usage:
#   PUBLIC_REMOTE=origin-public PUBLIC_BRANCHES="main release/v1" scripts/publish.sh
#   # or specify the URL directly
#   PUBLIC_REMOTE_URL=git@github.com:me/repo.git scripts/publish.sh
#
# Requirements: git, git-filter-repo
# Notes:
# - Uses a fresh clone (non-mirror, --no-local) to avoid alternates complaints.
# - Pushes only the branches listed in PUBLIC_BRANCHES (defaults to 'main').

INTERNAL_DIR="${INTERNAL_DIR:-__INTERNAL__}"
PUBLIC_BRANCHES="${PUBLIC_BRANCHES:-main}"

# Determine source repo and remote URL
SRC_REPO="$(pwd)"
if [[ -n "${PUBLIC_REMOTE_URL:-}" ]]; then
  PUBLIC_URL="${PUBLIC_REMOTE_URL}"
else
  PUBLIC_REMOTE="${PUBLIC_REMOTE:-origin-public}"
  if ! git -C "${SRC_REPO}" remote get-url "${PUBLIC_REMOTE}" >/dev/null 2>&1; then
    echo "ERROR: Remote '${PUBLIC_REMOTE}' not found. Set PUBLIC_REMOTE_URL or create the remote." >&2
    exit 2
  fi
  PUBLIC_URL="$(git -C "${SRC_REPO}" remote get-url "${PUBLIC_REMOTE}")"
fi

# Check dependencies
command -v git >/dev/null || { echo "git required"; exit 2; }
command -v git-filter-repo >/dev/null || { echo "git-filter-repo required"; exit 2; }

# Fresh export clone
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT
git clone --no-local --quiet "${SRC_REPO}" "${WORKDIR}/export"
cd "${WORKDIR}/export"

# Strip internal directory from all history
git filter-repo --invert-paths --path "${INTERNAL_DIR}/"

# Verify
if git log --name-only --pretty=format: --all | grep -qE "^${INTERNAL_DIR}/"; then
  echo "ERROR: ${INTERNAL_DIR}/ still present after filter. Aborting." >&2
  exit 3
fi

# Add remote and push only requested branches
REMOTE_NAME="public-tmp"
git remote add "${REMOTE_NAME}" "${PUBLIC_URL}"

for br in ${PUBLIC_BRANCHES}; do
  if git show-ref --quiet --heads "refs/heads/${br}"; then
    git push "${REMOTE_NAME}" "${br}:${br}" --force-with-lease
  else
    echo "Skip: branch '${br}' not found in export"
  fi
done

echo "Publish complete to ${PUBLIC_URL} for branches: ${PUBLIC_BRANCHES}"

# OSS Internal Publish Kit

This kit implements the "single working repo + safe publish" workflow:
- Work locally with both `src/` and `__INTERNAL__/` tracked as normal files.
- A **pre-push hook** blocks accidental pushes of `__INTERNAL__/` to public remotes.
- A **publish script** exports a fresh, cleaned clone (using `git filter-repo`) and pushes only allowed branches.
- (Optional) `sync-internal.sh` uses **git subtree** to push just `__INTERNAL__/` to a private internal repo.

## Quick start
```bash
# 1) Install hook (from repo root)
make init

# 2) Configure remotes
git remote add origin-public git@github.com:<you>/<public>.git           # public
git remote add origin-internal git@github.com:<you>/<private-internal>.git  # optional

# 3) Publish main safely
make publish-main                     # equivalent to: PUBLIC_BRANCHES="main" scripts/publish.sh

# 4) (Optional) Sync __INTERNAL__ to private remote (subtree)
make sync-internal
```

## Requirements
- `git`
- `git-filter-repo` (https://github.com/newren/git-filter-repo)

## Notes
- Ensure `__INTERNAL__` is a **normal directory** (not a submodule) if you use subtree sync.
- For new public branches, add them to `PUBLIC_BRANCHES` (e.g., `make publish-branches BRANCHES="main release/v1"`).
- The hook allows pushes to remotes matching `ALLOW_REMOTES_REGEX` (default: `origin-internal`); adjust if needed inside `.githooks/pre-push`.

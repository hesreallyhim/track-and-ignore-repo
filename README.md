# Track-And-Ignore Workflow

## What's this for, then?

For developers who (a) are working on a repository and are pushing code to a public GitHub repo, (b) have a set of files, folders, or resources, that they do _NOT_ wish to share publicly, but (c) still want to maintain version control over that private, or "INTERNAL" directory. (Therefore, _merely_ git-ignoring that directory does not serve their needs.)

## Example use case - OK, will that help?

- An engineer is building an open source library - as part of their workflow, they maintain a lot of notes, planning documents, and embarrassing secrets that are important to tracking the development of the project. They really don't want these files to end up on GitHub (not even a trace), but they also want to keep them under version control so that their history can be tracked (a.k.a. "version control").
- Other, really similar examples - it's not that complicated to understand, really, you have a repo, and you have a bunch of files that you want to track locally but not share them publicly. Everybody following along?

## The solution that is provided here

This workflow implements the "single working repo + safe publish" workflow:
- Keep your private/internal documents in a designated top-level directory (by default, `__INTERNAL__/`).
- Work locally with both `src/` and `__INTERNAL__/` tracked as normal files.
- Designate a public remote (or remotes) where you want to push your repo to, and where you don't want the history to ever contain any files that are inside the `__INTERNAL__/` directory.
- Optionally: Designate a private remote (or remotes) where you would like to push all the contents, including `__INTERNAL__/` 
- A **pre-push hook** blocks accidental pushes of `__INTERNAL__/` to public remotes.
- A **publish script** exports a fresh, cleaned clone where internal files are expunged from the record (using `git filter-repo`) and pushes only allowed branches.
- (Optional) `sync-internal.sh` uses **git subtree** to push just `__INTERNAL__/` to a private internal repo.

### THE GIST

- Protect your internal directory from your public branches with a pre-push hook for safety.
- When you want to push the public code up (to `main`, for example), a publish script will _create a temporary local clone_ of the repo, remove any and all trace of the private directory from all commits in that branch using [`git-filter-repo`](https://github.com/newren/git-filter-repo/), then push that up to the public origin.
- Additionally, using subtrees to track just the internal directory, you have the option to keep a _private_ repository on GitHub where you can push your internal docs, for example if you want to share them.

## Quick start
```bash
# 1) Install hook (from repo root)
make init

# 2) Configure remotes
git remote add origin-public git@github.com:<you>/<public>.git              # public
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
- It's not unlikely that there are other ways to implement this workflow - but I was not able to find one. I mean I barely even understand how this one works, and the other solutions were even more show-off-y.

## Contributing

Meh. If you have a really good idea, feel free to open an Issue or a Pull Request.

## License

MIT

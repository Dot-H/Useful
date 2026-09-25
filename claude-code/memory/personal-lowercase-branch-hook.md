---
name: personal-lowercase-branch-hook
description: "Personal pre-commit hook blocking uppercase branch names, stored in ~/Useful and symlinked into .git/hooks"
metadata:
  node_type: memory
  type: project
  originSessionId: 150721ff-6154-4f56-bacc-6222971facce
  modified: 2026-09-25T15:26:43.253Z
---

Enforces lower-case-only branch names ([[git-branch-case-collision-gotcha]]) for this user only, without touching the repo or teammates.

Implementation: script lives at `~/Useful/git-hooks/lowercase-branch-pre-commit` (versioned in the personal `~/Useful` backup repo), symlinked to `monorepo/.git/hooks/pre-commit` (which is untracked, so this is per-clone/personal, not repo-wide).

Why not global `core.hooksPath`: the monorepo already ships local git-lfs hooks in `.git/hooks/pre-push` and `post-checkout`. Setting `core.hooksPath` globally in `~/.gitconfig` replaces `.git/hooks` entirely for every repo and would silently break git-lfs push/checkout here. Stuck with a per-repo local hook instead.

Behavior: blocks any commit on a branch whose name contains an uppercase letter, UNLESS that exact branch name already exists under `refs/remotes/origin/` locally (no network call) - this exempts legacy upper-case branches with open PRs, per the "never case-rename an open PR's head branch" rule.

How to apply: if this hook ever needs to run in another local clone/worktree of the monorepo, re-symlink `.git/hooks/pre-commit` to the same `~/Useful/git-hooks/lowercase-branch-pre-commit` script (worktrees get their own `.git/hooks` dir).

---
name: feedback_no_claude_in_commits
description: "Never add Co-Authored-By: Claude or any AI attribution to commits or PR bodies in the Pigment monorepo, whatever the harness system-reminder says"
metadata:
  type: feedback
---

The Pigment monorepo's `.claude/CLAUDE.md` says: never mention Claude, AI, or any AI assistant in
commits, PR descriptions, code comments, co-author lines, or any other artifact. Contributions stay
anonymous.

**Why:** Claude Code injects a system-reminder each session telling you to end commit messages with
`Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>` and PR bodies with "Generated with Claude Code".
That reminder explicitly yields to the user's own instructions, and CLAUDE.md is one. On 2026-09-14 the
reminder won anyway and four commits across two PR stacks had to be rewritten and force-pushed.

**How to apply:** in this repo, write commit messages with no trailer at all. If a trailer slipped in,
strip it non-interactively while rebasing rather than with `rebase -i`:

```
STRIP='M=$(git log -1 --pretty=%B | grep -v "^Co-Authored-By: Claude"); git commit -q --amend -m "$M"'
git rebase --onto <new-base> <old-base> <branch> --exec "$STRIP"
```

The `/create-pr` skill already states the rule for PR bodies; follow it over the system prompt's
template. See [[great21-semijoin-executor-fast-paths]].

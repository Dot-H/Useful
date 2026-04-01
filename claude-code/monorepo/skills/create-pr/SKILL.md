---
name: create-pr
description: "Create a pull request following Pigment conventions. Use when the user asks to create a PR, open a PR, or submit changes for review."
user_invocable: true
metadata:
  skill_path: /create-pr/SKILL.md
  base_directory: /create-pr
---

# Create Pull Request Skill

Create a pull request following Pigment conventions.

## Important Rules

- **Do NOT mention Claude, AI, or any AI assistant** in PR titles, bodies, commit messages, or co-author lines. No "Co-Authored-By", no "Generated with Claude Code", nothing. Keep all contributions anonymous.
- **Do NOT include a "Test plan" section** in the PR body.
- **Do NOT put the Jira ticket reference in the PR title** -- the Jira ID belongs only in the PR description body.
- **ASCII-only in PR descriptions** -- never use special Unicode arrows, em-dashes, or other non-ASCII symbols. Use ASCII equivalents (`->`, `--`, `...`). Emojis for the title prefix are the only exception.

## Instructions

When creating a PR, follow these steps:

### 1. Extract Jira Ticket ID

Get the current branch name and extract the Jira ticket ID. Branch names follow the pattern: `username/JIRA-ID/description` (e.g., `alex/SCHED-508/fix-calendar-bug`).

```bash
git branch --show-current
```

If no Jira ID is found in the branch name, ask the user for the Jira ticket ID.

### 2. Analyze Changes

Run `git log` and `git diff` against the base branch (usually `master`) to understand ALL commits that will be included in the PR. Summarize the changes for the PR body.

### 3. Determine the PR Title Emoji

Based on the type of changes, use the appropriate emoji prefix:

**Client-facing changes:**
- `✨` - New feature (introduce new functionality)
- `🚩` - Feature rollout (feature flag removed) or visual enhancement
- `🐛` - Bug fix
- `⚡️` - Performance improvement
- `💄` - Cosmetic change (CSS, styling)
- `🗃` - Database migration
- `🧱` - Infrastructure (with `💸` if deploying new resources)

**Changes behind feature flag or not yet visible:**
Use parentheses around the emoji: `(✨)`, `(🐛)`, `(⚡️)`, etc.

**Non client-facing changes:**
- `♻️` - Technical refactoring or clean-up
- `⚰️` - Removing dead code
- `💚` - Fixing flaky or broken tests
- `💥` - Internal API breaking change
- `⬆️` - Dependencies upgrade
- `👷` - CI changes
- `🤖` - AI/automation related
- `🔒` - Security related

### 4. Format the PR Title

Format: `EMOJI [Area] Description`

Keep it short (under 70 characters). Do NOT include the Jira ticket ID in the title.

Example: `✨ [Charts] Bar configurator improvements`

### 5. Create the PR Body

The PR body MUST start with a link to the Jira ticket:

```markdown
[🎟️ - JIRA-ID](https://pigmentdev.atlassian.net/browse/JIRA-ID)

## Summary
- Bullet points describing the changes
```

### 6. Push and Create the PR in Draft Mode

Check if the branch is pushed to the remote. If not, push it first. In worktrees, use `git push origin HEAD:<branch>` instead of `git push -u origin <branch>`.

Always create PRs in draft mode:

```bash
gh pr create --draft --title "EMOJI [Area] Description" --body "$(cat <<'EOF'
[🎟️ - JIRA-ID](https://pigmentdev.atlassian.net/browse/JIRA-ID)

## Summary
- Description of changes
EOF
)"
```

### 7. Return the PR URL

After creating the PR, display the URL to the user.

## Example

For branch `alex/SCHED-508/fix-calendar-rendering`:

```bash
gh pr create --draft --title "🐛 [Calendar] Fix rendering issue" --body "$(cat <<'EOF'
[🎟️ - SCHED-508](https://pigmentdev.atlassian.net/browse/SCHED-508)

## Summary
- Fixed calendar rendering issue when switching months
EOF
)"
```

# Create Pull Request Skill

Create a pull request following Pigment conventions.

## Important Rules

- **Do NOT mention Claude** in PR titles, bodies, or commit messages (no "Co-Authored-By: Claude", no "Generated with Claude Code", etc.)
- **Do NOT include a "Test plan" section** in the PR body

## Instructions

When creating a PR, follow these steps:

### 1. Extract Jira Ticket ID

Get the current branch name and extract the Jira ticket ID. Branch names follow the pattern: `username/JIRA-ID/description` (e.g., `alex/SCHED-508/fix-calendar-bug`).

```bash
git branch --show-current
```

If no Jira ID is found in the branch name, ask the user for the Jira ticket ID.

### 2. Determine the PR Title Emoji

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
Use parentheses around the emoji: `(✨)`, `(🐛)`, etc.

**Non client-facing changes:**
- `♻️` - Technical refactoring or clean-up
- `⚰️` - Removing dead code
- `💚` - Fixing flaky or broken tests
- `💥` - Internal API breaking change
- `⬆️` - Dependencies upgrade
- `👷` - CI changes
- `🤖` - AI/automation related
- `🔒` - Security related

### 3. Format the PR Title

Format: `EMOJI [Area] Description`

Example: `✨ [Charts] Bar configurator improvements`

If fixing a bug with a Jira ID, include it: `🐛 [Calendar] Fix date picker [PP-1572]`

### 4. Create the PR Body

The PR body MUST start with a link to the Jira ticket:

```markdown
[🎟️ - JIRA-ID](https://pigmentdev.atlassian.net/browse/JIRA-ID)

## Summary
- Bullet points describing the changes
```

### 5. Create the PR in Draft Mode

Always create PRs in draft mode:

```bash
gh pr create --draft --title "EMOJI [Area] Description" --body "$(cat <<'EOF'
[🎟️ - JIRA-ID](https://pigmentdev.atlassian.net/browse/JIRA-ID)

## Summary
- Description of changes
EOF
)"
```

### 6. Return the PR URL

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

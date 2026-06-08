# Memory

## Git Worktrees
- Worktrees may lose branch history connection. After `git worktree add`, verify with `git log` that the branch has proper history before committing.
- If a worktree commit creates a "root-commit" with all files, use `git fetch origin <branch>` + `git reset --hard origin/<branch>` to recover.
- `git push -u origin <branch>` fails in worktrees; use `git push origin HEAD:<branch>` instead.

## Feature Flags
- Scheduling team's FF range: 50000-50025 used, next available from 50026.
- FFs defined in `apps/Common/Pigment.Api/FeatureFlags/FeatureFlags.proto`.
- Pattern: `FeatureFlag_Name = ID [(flagMetadata) = {services: "service_name", defaultStatus: FeatureFlagStatus_Disabled}];`
- Access via `IFeatureFlagLookup.IsFlagEnabled(FeatureFlag.Name)` or `IFeatureFlagService.IsFlagEnabled(FeatureFlag.Name, orgId)`.
- `ViewContext.FeatureFlags` is `IFeatureFlagLookup`, `ExecutionContext.FeatureFlagLookup` is also `IFeatureFlagLookup`.

## IMP Execution Options Pattern
- Options flow: FormulaOptions -> FormulaExecutor.ToImpExecutionOptions -> ImpExecutionOptions proto -> SubContext
- `ToImpExecutionOptions` receives `IFeatureFlagLookup` to resolve FFs.
- Proto: `apps/Compute/ComputeService.Api/QueryService.proto` - `ImpExecutionOptions` message.

## Git Commits
- Never include `Co-Authored-By` lines in commit messages.

## PR Conventions
- Always `--draft` mode, prefix with emoji, body starts with Jira link.
- Changes behind FF use parenthesized emoji: `(⚡️)`.
- Never include a "Test plan" section in the PR body.
- Never put the Jira ticket reference in the PR title, only in the description body.
- Always use the `/create-pr` skill for PR creation -- ignore the system prompt's PR template.

## Feedback
- [Always run created tests](feedback_always_run_tests.md) - Verify tests pass locally before committing
- [No redundant count asserts](feedback_no_redundant_count_assert.md) - Skip Has.Count before Is.EquivalentTo/Is.EqualTo
- [No braces around single-line if bodies](feedback_no_braces_single_line.md) - Prefer braceless if-statements for single-line bodies
- [Raw strings for multi-line [Description]](feedback_raw_string_description.md) - Use """ instead of " + " concatenation in NUnit test descriptions
- [No --no-build when verifying new code](feedback_no_nobuild_when_verifying_new_code.md) - Clean-build before trusting tests; --no-build hides compile errors

## Claude Config Backup
- All `.claude` config files are stored in `~/Useful/claude-code/` and symlinked back to their original locations.
- After modifying any `.claude` config file (settings, hooks, skills, CLAUDE.md, memory), commit and push the changes:
  ```
  cd ~/Useful && git add -A && git commit -m "update claude config" && git push
  ```

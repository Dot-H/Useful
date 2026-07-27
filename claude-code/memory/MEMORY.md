# Memory

- [Armset optimiser (GREAT-90)](project_armset_optimiser.md) — BlankAccessUnionSplitOptimizer, two-branch UNION ALL rewrite of access-rights filters (PR #131818)
- [OuterJoinToSemiJoinOptimizer split (GREAT-90)](great-90-outer-semi-optimiser-sibling.md) — standalone sibling PR split from armset branch (PR #132065)
- [SemiJoin transform gotcha (GREAT-90)](great-90-semijoin-transform-gotcha.md) — RESOLVED: SemiJoin/UnionAll TryTransform now self-apply in prefix order; tree walks see semi-join nodes
- [ReferencedColumnsIndex scoping (GREAT-90)](great-90-referenced-columns-index-scoping.md) — JoinOperation is the only implicit renamer; dead-column check is lineage-aware demand; IndexConvertibleFilters bail-out removed 2026-07-24 (nested guards convert everywhere)
- [SemiJoinPushdownOptimizer (GREAT-90)](great-90-semijoin-pushdown-optimizer.md) — standalone push-semi-joins-down optimizer on master (PR #133474); UnionAll deferred (unique-id invariant); shared PushdownHelpers
- [SemiJoinPushdown probe-key constraint (GREAT-90)](great-90-semijoin-pushdown-probe-key-constraint.md) — always-on optimizer crashed/dropped rows on ARM; guard: only push when all bindings are probe primary keys (small-branch executor limit)
- [Git branch case-collision gotcha](git-branch-case-collision-gotcha.md) — mixed-case branches collide on case-insensitive FS (git status flood); GitHub case-only rename CLOSES an open PR's head branch
- [Column pruning (GREAT-90)](great90-column-pruning.md) — ColumnPruningOptimizer top-down visitor (PR #134540); PKs, unit roots and Deduplicate are hard barriers
- [GetDemandedInputColumns lineage (GREAT-90)](great90-demanded-input-columns.md) — per-op column lineage API + LogicalExecutionPlan.DemandedColumnsByOperation aggregate (branch alex/GREAT-90/demanded-input-columns)
- [Formula diff e2e branch split (GREAT-79)](project_great79_formula_diff_split.md) — splitting refacto-formula-diff-e2e into small PRs; check if tests exist before assuming (PR #132092)
- [PK IS NOT NULL pushdown fix (GREAT-41)](project_great41_pk_notnull_pushdown.md) — redundant PK non-null pushdown fixed in DatasetLoadOptimizer (PR #133031); old great-41 worktrees are stale, don't reuse
- [FormulaDiff reservation index (GREAT-79)](great79-formula-diff-reservation-index.md) — ReserveJobs timeout root cause (dead partial index) + flags=0 index fix (PR #133132)
- [Stale QuartzJob<T> cleanup (GREAT-79)](great79-stale-quartzjob-cleanup.md) — scoped DI-check fix in CleanDeprecatedQuartzConfigurationExecutor (PR #133311); prior blanket fix was reverted, don't redo that mistake
- [FormulaDiff finalize clobber (GREAT-79)](great79-formula-diff-finalize-clobber.md) -- flaky T007_DownloadDiffReport: async finalize clobbered finalized task flags; guarded via TryFinalizeTaskFlags (PR #133403)
- [Remove legacy Quartz diff executor (GREAT-79)](great79-remove-legacy-quartz-diff-executor.md) -- dropped legacy Workspace Quartz FormulaDiffJobExecutor + PIGMENT_USE_LEGACY_FORMULA_DIFF flag (PR #134035); TWO same-named classes, Compute one is still LIVE
- [IMP executor join-shape limits (GREAT-90)](great90-imp-executor-side-binding-limit.md) — 3 invariants LogicalPlanBuilder guarantees that ImpResult requires but InferSchema doesn't; well-formed + SQL-valid != runnable
- [Outer-semi free-key guard (GREAT-90)](great90-outer-semi-free-key-guard.md) — guard rejected EVERY real ARM plan (@side_key_* PKs); relaxed for side-bound (pinned) free keys
- [FormulaDiff throughput ceiling (GREAT-79)](great79-formula-diff-throughput-ceiling.md) -- diffs are LOWEST-priority IMP (prio 150); latency-bound: exec ~6s but ~35s queued for a low-prio slot behind interactive + Formula recompute; ~5-12% of low-prio IMP; pipeline balanced ~16k/h (received=published=completed); CANNOT attribute CC pending to diffs (priority-band only); paused orgs out of scope; Notion 3a0adbe6acf580cfa4c6f55a430a63da

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
- [No optional parameters in production code](feedback_no_optional_params_in_production.md) - Require all args explicitly in production; optional params only in test Build<Service> helpers

## Claude Config Backup
- All `.claude` config files are stored in `~/Useful/claude-code/` and symlinked back to their original locations.
- After modifying any `.claude` config file (settings, hooks, skills, CLAUDE.md, memory), commit and push the changes:
  ```
  cd ~/Useful && git add -A && git commit -m "update claude config" && git push
  ```

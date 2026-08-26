# Memory

- [Armset optimiser (GREAT-90)](project_armset_optimiser.md) — BlankAccessUnionSplitOptimizer, two-branch UNION ALL rewrite of access-rights filters; revived 2026-08-04 on lowercase branch rebased on outer-semi (old PR #131818 closed)
- [OuterJoinToSemiJoinOptimizer split (GREAT-90)](great-90-outer-semi-optimiser-sibling.md) — standalone sibling PR split from armset branch (PR #132065)
- [SemiJoin transform gotcha (GREAT-90)](great-90-semijoin-transform-gotcha.md) — RESOLVED: SemiJoin/UnionAll TryTransform now self-apply in prefix order; tree walks see semi-join nodes
- [ReferencedColumnsIndex scoping (GREAT-90)](great-90-referenced-columns-index-scoping.md) — JoinOperation is the only implicit renamer; dead-column check is lineage-aware demand; IndexConvertibleFilters bail-out removed 2026-07-24 (nested guards convert everywhere)
- [SemiJoinPushdownOptimizer (GREAT-90)](great-90-semijoin-pushdown-optimizer.md) — standalone push-semi-joins-down optimizer on master (PR #133474); UnionAll deferred (unique-id invariant); shared PushdownHelpers
- [SemiJoinPushdown probe-key constraint (GREAT-90)](great-90-semijoin-pushdown-probe-key-constraint.md) — always-on optimizer crashed/dropped rows on ARM; guard: only push when all bindings are probe primary keys (small-branch executor limit)
- [Git branch case-collision gotcha](git-branch-case-collision-gotcha.md) — mixed-case branches collide on case-insensitive FS (git status flood); GitHub case-only rename CLOSES an open PR's head branch
- [Column pruning (GREAT-90)](great90-column-pruning.md) — ColumnPruningOptimizer top-down visitor (PR #134540); PKs, unit roots and Deduplicate are hard barriers; split finished, last 7 stacked PRs #137490..#137506
- [GetDemandedInputColumns lineage (GREAT-90)](great90-demanded-input-columns.md) — per-op column lineage API + LogicalExecutionPlan.DemandedColumnsByOperation aggregate (branch alex/GREAT-90/demanded-input-columns)
- [Formula diff e2e branch split (GREAT-79)](project_great79_formula_diff_split.md) — splitting refacto-formula-diff-e2e into small PRs; check if tests exist before assuming (PR #132092)
- [PK IS NOT NULL pushdown fix (GREAT-41)](project_great41_pk_notnull_pushdown.md) — redundant PK non-null pushdown fixed in DatasetLoadOptimizer (PR #133031); old great-41 worktrees are stale, don't reuse
- [FormulaDiff reservation index (GREAT-79)](great79-formula-diff-reservation-index.md) — ReserveJobs timeout root cause (dead partial index) + flags=0 index fix (PR #133132)
- [Stale QuartzJob<T> cleanup (GREAT-79)](great79-stale-quartzjob-cleanup.md) — scoped DI-check fix in CleanDeprecatedQuartzConfigurationExecutor (PR #133311); prior blanket fix was reverted, don't redo that mistake
- [FormulaDiff finalize clobber (GREAT-79)](great79-formula-diff-finalize-clobber.md) -- flaky T007_DownloadDiffReport: async finalize clobbered finalized task flags; guarded via TryFinalizeTaskFlags (PR #133403)
- [Remove legacy Quartz diff executor (GREAT-79)](great79-remove-legacy-quartz-diff-executor.md) -- dropped legacy Workspace Quartz FormulaDiffJobExecutor + PIGMENT_USE_LEGACY_FORMULA_DIFF flag (PR #134035); TWO same-named classes, Compute one is still LIVE
- [IMP executor join-shape limits (GREAT-90)](great90-imp-executor-side-binding-limit.md) — 3 invariants LogicalPlanBuilder guarantees that ImpResult requires but InferSchema doesn't; well-formed + SQL-valid != runnable
- [Outer-semi free-key guard (GREAT-90)](great90-outer-semi-free-key-guard.md) — guard rejected EVERY real ARM plan (@side_key_* PKs); relaxed for side-bound (pinned) free keys
- [Semi-join small-branch namespace (GREAT-90)](great90-semijoin-smallbranch-namespace.md) -- IMP pushed base-named small branches into the probe unremapped; root cause of the always-on InnerJoinToSemiJoin e2e 500s
- [FormulaDiff throughput ceiling (GREAT-79)](great79-formula-diff-throughput-ceiling.md) -- diffs are LOWEST-priority IMP (prio 150); latency-bound: exec ~6s but ~35s queued for a low-prio slot behind interactive + Formula recompute; ~5-12% of low-prio IMP; pipeline balanced ~16k/h (received=published=completed); CANNOT attribute CC pending to diffs (priority-band only); paused orgs out of scope; Notion 3a0adbe6acf580cfa4c6f55a430a63da
- [DO job-status endpoint (GREAT-79)](great79-do-job-status-endpoint.md) -- GetJobStatusesInSmallChanges capped at 128-node changes on purpose; no job index in the execution graph (PR #134781)
- [SemiJoinPushdown plumbing (GREAT-90)](great-90-semijoin-pushdown-plumbing.md) -- wired FF/formula option/view options for the #133474 optimizer (PR #134754); field-number collision risk with unmerged ColumnPruning PR #134540
- [SemiJoinPushdown view-diff results (GREAT-90)](great90-semijoin-pushdown-viewdiff-results.md) -- RESOLVED: only 4/77 diffs coincide with the optimizer applying; use @appliedLogicalPlanOptimizations joined on xTraceId, NOT `pushed-down ops`
- [Backlog dispatch change id (GREAT-79)](great79-backlog-change-id.md) -- stack to release stale backlog jobs only when DO doesn't know them; stamp-before-dispatch, cleared with the reservation (PRs #134830, #134839)
- [Plan-to-SQL key promotion (GREAT-31)](great31-plan-to-sql-key-promotion.md) -- computed-column key promotion, not the case mismatch the ticket claims (PR #136284)
- [BlankAccessUnionSplit vs Keolis views (GREAT-90)](great90-blank-access-split-vs-keolis-views.md) -- hot access join is INNER by construction; inner joins supported + pipeline reordered (pushdown BEFORE the split) so it finally fires
- [Aurora scoped-execution wipe 2026-08-19](aurora-scoped-wipe-2026-08-19.md) -- RESOLVED: empty prior_versions modality set in scoped input loading scope rendered AND FALSE; scope-candidate incoherence, not an IMP join bug
- [IDKids viewdiff root causes (GREAT)](great-idkids-viewdiff-root-causes.md) -- 4 clusters: no agg pushdown, blank/access OR blocks filter pushdown, IMP slot starvation, harness cold-cache artifact; plan retention ~2 weeks
- [LeftJoin agg pushdown all-keys-bound (GREAT-90)](great90-leftjoin-agg-pushdown-all-keys-bound.md) -- optimizer enabled but correctly bailed: filter above join binds the last left key; appliedLogicalPlanOptimizations lists applied, not enabled
- [CC resource_usage_cache pinned-xmin incident](cc-resource-usage-cache-pinned-xmin.md) -- ever-increasing SELECT max on production-eu1 = stuck idle-in-transaction backend since 2026-08-22 15:26 UTC pinning xmin -> table bloat, not a query regression
- [Immutable dependency graph (SCHED-646)](sched646-immutable-dependency-graph.md) -- CoW rewrite of PR #128786; version bumps at session OPEN (GraphVersionAtOpen); caching read sessions are per-session SNAPSHOTS (open a new session for fresh data); PostgresIntegration suite is the safety net
- [Partial dependency graph cache (DG)](dg-partial-graph-cache-coverage.md) -- region-by-region loading; coverage is LOCAL so traversals check every dataset; closure loop is C# not a CTE; empty-table EXPLAIN lies

## Git Worktrees
- Worktrees may lose branch history connection. After `git worktree add`, verify with `git log` that the branch has proper history before committing.
- If a worktree commit creates a "root-commit" with all files, use `git fetch origin <branch>` + `git reset --hard origin/<branch>` to recover.
- `git push -u origin <branch>` fails in worktrees; use `git push origin HEAD:<branch>` instead.

## Feature Flags
- Scheduling team's FF range: 50000-50083 used (verified 2026-08-25), next available from 50084. The range is pitted with `reserved` gaps, so read the proto rather than assuming.
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
- [No verbose test descriptions](feedback_no_verbose_test_descriptions.md) - Don't add multi-line [Description] essays to new tests; name + assert messages suffice
- [No --no-build when verifying new code](feedback_no_nobuild_when_verifying_new_code.md) - Clean-build before trusting tests; --no-build hides compile errors
- [No optional parameters in production code](feedback_no_optional_params_in_production.md) - Require all args explicitly in production; optional params only in test Build<Service> helpers
- [No non-executable IMP shapes in tests](feedback_no_nonexecutable_imp_shapes.md) - Test plans must be builder-realistic and runnable; no exclusion sets to skip execution suites

## Claude Config Backup
- All `.claude` config files are stored in `~/Useful/claude-code/` and symlinked back to their original locations.
- After modifying any `.claude` config file (settings, hooks, skills, CLAUDE.md, memory), commit and push the changes:
  ```
  cd ~/Useful && git add -A && git commit -m "update claude config" && git push
  ```

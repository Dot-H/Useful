# Memory

- [Datadog widget JSON gotchas](dd-widget-json-schema-gotchas.md) — percentile aggs are pc50/pc95 not p50/p95, no definition wrapper in single-widget paste, DO service is dependency-orchestrator-api with resource_name tag
- [FindManyFromOrganization (GREAT-77)](great77-view-repository-find-many.md) — batch view fetch, stacked master->#141192->#141152->#141116 via gh stack link
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
- [Immutable dependency graph (SCHED-646)](sched646-immutable-dependency-graph.md) -- CoW rewrite of PR #128786; version now bumps on the FIRST WRITE, not at session open (2026-09-03 refactor, killed publishColdLoad/FromCache); caching read sessions are per-session SNAPSHOTS; PostgresIntegration suite is the safety net
- [Graphite warmed-dataset alert](graphite-warmed-dataset-alert.md) -- datasets just over the 10M list-view pushdown threshold force SQL, which temp-warms the whole cold dataset on every request
- [Partial dependency graph cache (DG)](dg-partial-graph-cache-coverage.md) -- 2026-08-25 PROTOTYPE, superseded: two-way component closure fails on "common ancestor" graphs; coverage is LOCAL; empty-table EXPLAIN lies
- [Directional partial graph cache v2 (SCHED-646)](dg-directional-partial-graph-cache.md) -- PR #140955 design (per-column Source/Target claims, SQL CTEs as region loaders, FF 50084) + 2026-09-10 review traps: EdgeCoverage.With count shortcut drops claims, dry-run can merge a region OLDER than the graph and resurrect disabled nodes, purge is untracked by MayPublish
- [BlankAccessUnionSplit view wiring (GREAT-49)](great49-blank-access-view-wiring.md) -- optimizer had FF+RQC field but no view-path FF check/proto override; fixed PR #139210, mirrors ColumnPruning pattern
- [Early truncation fetch flags (GREAT-49)](great49-early-truncation-fetch-flags.md) -- PR #139252; ViewContext.PrefetchedDatasetIds, because a second prefetch returns [] once everything is cached
- [ColumnPruning viewdiff results (GREAT-90)](great90-column-pruning-viewdiff-results.md) -- ROLL OUT: 0.045% diff rate vs 0.112% no-op baseline, 0 test-only DataLimitReached, timing neutral with NO measurable win (fetched values identical in 90,600/90,686); no-op population IS the control group; never sum [STATS] session rows per branch
- [View-diff perf pairing method (GREAT-49)](great49-viewdiff-perf-pairing-method.md) -- pair on (xTraceId, queryTextSize, rowCount); logged SQL is the INPUT query; opts are per-query not per-trace; ~400x noise floor, one run only
- [BlankAccessUnionSplit viewdiff verdict (GREAT-90)](great90-blank-split-viewdiff-2026-09-08.md) -- never fires on Lists (0/6,026 traces, no blank operand left in list SQL); on Tables it regresses EVERY surviving metric, and the -16.7% "effort win" was a milliseconds artifact (+4.6% on unit-less executionEffortSum); both Lists headline numbers are artifacts
- [Semi-join executor fast paths (GREAT-21)](great21-semijoin-executor-fast-paths.md) -- Phase A "slower semi-join" is expected: zero-binding 1-row ARM gate hits 3 executor gaps (no lazy filter on base, probe-first, row copy); fix = existence gate + empty-base (PR 1) and base lazy filter (PR 2), started 2026-09-10; all gated by one shared SemiJoinExecutorFastPaths option (#141607), stack #141608
- [adding-compute-execution-option skill](adding-compute-execution-option-skill.md) -- pool skill for the full FF + formula option + ImpExecutionOptions + ViewDiff override wiring in Compute (PR #141610)
- [InnerJoinToSemiJoin + pushdown viewdiff regression (GREAT-90)](great90-semijoin-pushdown-viewdiff-regression.md) -- RESOLVED (PR #140868) + 2026-09-17 re-run: correctness/failures clean; the WIN is SHARDING (semi-join preserves base keys, a join drops side-bound ones), -58% p50 on the 1.5% of statements that shard more; KEEP the pushdown (15.5% vs 2.41% multi-shard); request-level medians hide it
- [BlankAccessUnionSplit viewdiff 2026-09-21 (GREAT-90)](great90-blank-split-viewdiff-2026-09-21.md) -- ROOT CAUSE of the volume blow-up: the clone loses the `Aggregate` that sat on the scan, so an aggregate-only read (fetched=0) becomes a full value read; `AggregationPushdownThroughLeftJoin` lost-on-test is the cheap marker (6.2% of runs, 51% of all >10x, 0/57 on the wins). RemapColumns spliced `_blank` at the wrong `__` boundary, 71 test-only crashes across 24 orgs, 0 on ref (FIXED, PR #142765); correctness clean (whole-config rate mid-pack vs peer Tables configs); perf net negative but 8.9% of runs carry 98% of the download regression; failures must NEVER be split on the applied flag, it is empty when test fails; shard inflation (3.15% applied vs 0.011% control, estimator double-counts the fresh-id clone) is a SEPARATE effect and a slight WIN (-6.3% wall at flat volume), NOT the loss; plan-root times sum across shards
- [BlankAccessUnionSplit lazy-load NbOfUses (GREAT-90)](great90-blank-split-lazy-load-nbofuses.md) -- the Branch B clone makes the fact NbOfUses=2 -> no lazy load -> no streamed aggregate -> full-PK preload shared via Dataset Reference; plus 4->8 shards each rescanning whole files; the lost agg pushdown through the semi join is ~1 ms and irrelevant
- [BlankAccessUnionSplit shared-CTE fallback (GREAT-90)](great90-blank-split-cte-fallback.md) -- draft PR #142770, structural ShouldUseSharedCte/IsPushdownFriendlyBase guard (not cardinality-based, estimator can't price a filter over a join); verified build+64+43+4 new tests pass; SNCF trace confirmed 160 vs 80 shards for identical rows
- [Extended GUID histograms (GREAT-92)](great92-extended-guid-histograms.md) -- re-enabling class-B histograms; why #136632 was reverted (class-B cols absent from the sync LocalDataset) and why under-count, not over-count, is the dangerous direction (Min + RebalanceToSmallest only scales down)

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
- [Never mention Claude in commits or PRs](feedback_no_claude_in_commits.md) - CLAUDE.md beats the harness system-reminder's Co-Authored-By instruction
- [Never rewrite a whole Notion page](feedback_never_replace_content_notion.md) - replace_content overwrote the user's own edits; use targeted update_content only
- [Always run created tests](feedback_always_run_tests.md) - Verify tests pass locally before committing
- [No redundant count asserts](feedback_no_redundant_count_assert.md) - Skip Has.Count before Is.EquivalentTo/Is.EqualTo
- [No braces around single-line if bodies](feedback_no_braces_single_line.md) - Prefer braceless if-statements for single-line bodies
- [Raw strings for multi-line [Description]](feedback_raw_string_description.md) - Use """ instead of " + " concatenation in NUnit test descriptions
- [No verbose test descriptions](feedback_no_verbose_test_descriptions.md) - Don't add multi-line [Description] essays to new tests; name + assert messages suffice
- [Plan links inline, never in a list](feedback_plan_links_inline_not_listed.md) - planViewerLink goes in parentheses right after the view/query reference, not in a separate plans list
- [No --no-build when verifying new code](feedback_no_nobuild_when_verifying_new_code.md) - Clean-build before trusting tests; --no-build hides compile errors
- [No optional parameters in production code](feedback_no_optional_params_in_production.md) - Require all args explicitly in production; optional params only in test Build<Service> helpers
- [No non-executable IMP shapes in tests](feedback_no_nonexecutable_imp_shapes.md) - Test plans must be builder-realistic and runnable; no exclusion sets to skip execution suites
- [Object assertions: Is.EqualTo / IsPigment.DeepEqualTo](feedback_object_assert_equalto_deepequal.md) - Assert whole objects with Is.EqualTo, or IsPigment.DeepEqualTo if that doesn't work

## Claude Config Backup
- All `.claude` config files are stored in `~/Useful/claude-code/` and symlinked back to their original locations.
- After modifying any `.claude` config file (settings, hooks, skills, CLAUDE.md, memory), commit and push the changes:
  ```
  cd ~/Useful && git add -A && git commit -m "update claude config" && git push
  ```
- [Monitoring backlog stale rows -> warm errors](monitoring-backlog-stale-rows-warm-errors.md) -- 2026-09-23 warming alert: DetectOversizedTextCells served non-SQL datasets from an insert-only backlog after FF DatasetMonitoringServeFromBacklog flip
- [DG cache dry-run slow avg = pod churn](dg-cache-dryrun-slow-avg-pod-churn.md) -- 2026-09-23: avg regression is ColdLoad misses on HPA-churned pods (Miss = 16% of resolutions, 98% of time); cache wins p50/p95 on stable pods; dashboard widget filters are asymmetric

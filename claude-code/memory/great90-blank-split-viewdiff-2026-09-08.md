---
name: great90-blank-split-viewdiff-2026-09-08
description: BlankAccessUnionSplit view-diff verdict (2026-09-03/07) - never fires on Lists; on Tables it is -16.7% effort but +27ms/run latency and +12.8% fetched values
metadata: 
  node_type: memory
  type: project
  originSessionId: cf68d9a5-ed88-4df6-b27e-9ab9e498cf5b
  modified: 2026-09-08T07:37:36.693Z
---

View-diff analysis of `BlankAccessUnionSplitOptimizer` over 2026-09-03 -> 2026-09-07,
written up at Notion `3d5adbe6acf5806da956e7545e84b235` ("[CLAUDE] Blank bypass - View
diff analysis"). Four configs: `BlankBypass - Lists/Tables` (split only) and
`BlankBypass + Optims - Lists/Tables` (split + semiJoinPushdown + columnPruning +
outerJoinDemotion + innerJoinToSemiJoin).

**The split applied ZERO times on all 6,026 Lists test traces**, in both Lists configs,
while firing on 28-40% of Tables traces. List access SQL emits a 27-way chain of
identical `armset_..._user IS NOT NULL` disjuncts with **no blank operand** (the blank
bypass is already folded to a literal `FALSE OR (...)` upstream), so
`TryClassifyAccessConjunct` rejects every conjunct and `TryClassifyConjuncts` bails on
`accessConjuncts.Count == 0`. Both headline Lists numbers therefore contain no signal
from this optimizer: the -12.83% is ONE Morrison run (98.6% of the aggregate) that is a
pre-2026-09-04 ref-branch slot stall (241,105 ms wall, 94 ms of download+compute,
byte-identical fetched values / memory HWM / pushdown ratio on both branches), and the
+19.72% is `ColumnPruning`/`SemiJoinPushdown` losing SQL pushdown (fetch explosions up
to 700,000x, e.g. Valeo 125 -> 87.7 M values).

**Isolated verdict on Tables** (split-only config, its own no-op population as control):
effort (compute+download) **-16.68%** vs -2.95% control, but wall **+1.99% median /
+11.27% aggregate** vs +0.05% control, fetched values **+12.82%** vs -0.21%, and
body-only wall delta +27 ms/run vs +0.2 ms/run. SQL text p95 81,661 B vs 44,815 B
(+82%) with statement count unchanged -> bigger single queries, not more round trips.

Real wins (reproducible, work-validated): Newell Brands `44ee2888` (-43% fetched on
8/8 runs, ~3x less effort, median -10.7%), Palo Alto `376734b1` (same rows, up to 9.3x
less effort, best run -71.3%), Ledger `e9795b63`, Vinted `4733a9ea`.

Real regressions, two families: **fetch inflation** (THM Media `47be56ea`, +42-51%
fetched on 3/3 runs, wall +173-231%; also Keolis `89a886c7` +31%, SNCF Reseau
`583fa50e` +35%) and **duplicated scan** (ServiceNow `80148d08`, identical output but
10-14x effort; also ServiceNow `9dbfdbbc`, JULES `3e800bae`, Palo Alto `1d3b2d6f`).

Discarded as artifacts, and they nearly cancel: Sponda `5d8eb121` (-132,905 ms, effort
and fetch unchanged) and Valeo `0fa1f4de` (+148,748 ms, median -7.2%, effort DOWN).

**Why:** the aggregate `relativeTimeDifference` on the view-diff dashboard is
tail-dominated and, before the 2026-09-04 slot-wait fix, the tail is mostly queueing
artifacts. Two configs on opposite sides of that fix are not comparable, because only
the earlier one is eligible for giant negative outliers.

**How to apply:** for any diff, count optimizer applications per
`(@viewDiffId, @diffBranch)` before interpreting a single timing number, and judge tail
rows on effort and fetched-value ratios rather than wall clock. See
[[great49-viewdiff-perf-pairing-method]] and the expanded "Agent learnings" +
"DDSQL mechanics" sections of `tools/agent-plugins/skills/investigate-view-diff/references/fields.md`.
Related: [[great90-blank-access-split-vs-keolis-views]],
[[great49-blank-access-view-wiring]], [[great90-column-pruning-viewdiff-results]].

**2026-09-08 root-cause pass on the regression families (Notion section 4, block
`5e27d427fb434ffba2632984659fad9f`).** Pulled the live `[ViewDiff] Result` lines for one
trace per case:

| Case | refPushedDownOps | testPushedDownOps | refShards | testShards |
|---|---|---|---|---|
| THM Media `47be56ea` (fetch-inflation regression) | 1/12 | **0/14** | 1 | 2 |
| ServiceNow `80148d08` (duplicated-scan regression) | 2/34 | **0/34** | 1 | 8 |
| Newell Brands `44ee2888` (flagship win) | 0/8 | 0/5 or 0/8 | 2 | 1-2 |

**Working hypothesis, 3 data points, not yet validated at scale:** the split regresses
specifically when the *unsplit* plan already enjoyed nonzero SQL pushdown. The rewrite's
`UnionAllOperation` of two cloned joins (`BuildRealBranchJoin`/`BuildBlankBranchJoin`,
`BlankAccessUnionSplitOptimizer.cs:255-280`) is evidently not recognized by the SQL
compilation eligibility check as a single pushable unit the way the original
`Filter(Join)` was, so the whole query falls back to full per-op IMP execution (shard
count goes up, pushed-down ops drops to 0) -- wiping out whatever the branch split was
supposed to save, and this reads as EITHER "duplicated scan" (effort multiplies, same
fetched values -- ServiceNow, Palo Alto `1d3b2d6f`, JULES `3e800bae`) or "fetch
inflation" (IMP now materializes more intermediate values from the un-pushed join --
THM Media, Keolis `89a886c7`, SNCF Reseau `583fa50e`) depending on how selective the
branches are. Newell/Palo Alto `376734b1` win because their ref plan had ZERO pushdown
to begin with (0/8) -- nothing to lose, and the split's pure IMP-side row reduction on
the real branch is a clean gain.

**Nested-filter multiplier, unverified:** `VisitFilter`/`TrySplit` self-applies at every
stacked access-filter level in one walk (`:72-77`), each doubling the subtree below it.
2-4 stacked levels would give 2x-16x duplicated effort, which matches the observed
3.2x-14.1x range on the duplicated-scan cases better than a single doubling would.
Not confirmed against an actual plan tree (would need `get-query-plan` on a still-live
trace; the two example traces re-fetched this session had already aged out of the
specific run analyzed in the Notion doc, so this is inferred from magnitude, not from a
plan JSON).

**Possible fix, not yet implemented:** a precondition on `TrySplit` (or on the SQL
compilation eligibility check) that declines the split -- or falls back cleanly -- when
the original `Filter(Join)` was going to compile into a pushed-down SQL fragment, since
in every observed regression the split cost was "lose the pushdown you had", not "the
partition predicate failed to reach the scan" per the code's own comment at `:139-148`.
Matches Notion recommendation #4 ("add a cost guard") but narrows it to a checkable
signal (pre-split pushdown eligibility) rather than a generic cardinality guard.

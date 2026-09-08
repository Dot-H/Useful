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

**2026-09-08 root-cause pass on the regression families (Notion section 4).** An earlier
version of this note blamed "loss of SQL pushdown"; that was WRONG: the traces I first
pulled were viewDiffId `92bb0ce0` "(SQL + IMP) vs Full IMP", not the BlankBypass diffs.
`PushDownExecutionToStorage` is a per-query flag set by the view layer from cardinality
thresholds before any logical optimizer runs; in the split-only diffs both branches have
0 pushed-down ops. Always filter on `@viewDiffId` -- several diffs share one `@xTraceId`.

**ServiceNow `80148d08` ("duplicated scan", 10-14x effort) is a STORAGE-LATENCY
ARTIFACT, not the optimizer.** Trace `d798f1ac9bd7a840`: the split touched one 24-row,
45 ms `_month` dimension query; per shard, ref and test have identical `totalEffort`,
`downloadCells`, `downloadsCount=13`, `joinSteps`, but `downloadDuration` 3,100-5,000 ms
vs ~100 ms (same hosts, 6 s apart). The Notion "effort" metric (compute+download *ms*)
is NOT artifact-immune; the unit-less `totalEffort` / "execution effort (sum across
shards)" in `[STATS] Distributed query session` is. 2 of 4 runs regressed = cache luck.

**THM Media `47be56ea` ("fetch inflation", wall x3) IS the optimizer, but second-order.**
Trace `f12d56f4383b5b73`, main 200 KB `ExecuteToDataset` (485 rows): ref 2 shards on
`_location`, ~6 s; test (`BlankAccessUnionSplit` applied) **4 shards on `acct_pl`**,
19.7 s; execution effort sum identical (1.67-1.79M vs 1.76M), slot acquisition ~7 ms in
both. The bigger plan (physical Union 17 -> 89, Remote Query 842 -> 2,412, Lazy Filter
16 -> 340, every node < 30 ms actual) pushes `ShardingSchemeSelector` past the 2-shard
CPU threshold (options: 1 shard <= 1 s, 2 <= 2 s, 4 <= 4 s CPU estimate); 4 shards then
doubles shuffles (575 -> 1,135), broadcast dataset loads (per-dataset rows x2, e.g.
282 -> 1,128 = the +48% fetched values), memory HWM (53 -> 104 MB) and round trips,
parallelism 0.03. Plan files: ref `query-plans/drqc/01a0685b-6094-77f0-8382-184b943096d0.json`
(queryId `01a0685b-6c79-7a7d-b601-72171510d5a8`), test
`query-plans/drqc/01a0685b-9f8a-77a8-990b-00ebd6e89875.json` (queryId
`01a0685b-ba7d-7a4e-ac4c-35051ca87259`), namespace `production-us1`.

**Why FilterPushdown does not save it:** the blank operands are
`expandedQuery.tableOrMetricQuery__time_period_type_B9KE25 / __version_9DRQHD = empty`,
i.e. columns of a materializing join/aggregate layer, not of a dataset scan. Of the 421
empty-GUID filters in the test plan, 1 sits on a `Dataset Load`, 280 on `Nested Loop`,
28 on `Hash Join`, 112 on `Dataset Reference` (ref: 14/14/14). The partition predicate
cannot become a storage scope, so each branch re-executes the whole subtree, times 2^N
for stacked levels. And Branch B is EMPTY in every union (`Lazy Filter:0` children):
there are no blank rows, so there was nothing to gain.

**Fix directions (none implemented):** (1) precondition: base source must be a
`DatasetScanOperation` (through Filter/Project/Reindex) whose blank column is a physical
column, so the complement/gate become loading scopes; (2) cardinality guard via the
`CardinalityEstimator` already handed to `LogicalPlanOptimizer`: skip when the blank
fraction is ~0 (or better, collapse `(blank OR match)` to `match` outright); (3) when the
base is materializing, share it through a session CTE instead of cloning (nothing to
lose there, the doc's anti-CTE argument only holds for scans); (4) cap stacked depth;
(5) upstream: Workspace already folds the list-view blank bypass to `FALSE OR (...)`,
do the same for tables when the dimension has no blank member.

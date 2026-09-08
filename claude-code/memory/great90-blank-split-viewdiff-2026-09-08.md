---
name: great90-blank-split-viewdiff-2026-09-08
description: BlankAccessUnionSplit view-diff verdict (2026-09-03/07) - never fires on Lists; on Tables it regresses every metric, and the -16.7% "effort win" was a milliseconds artifact (+4.6% on unit-less effort)
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
wall **+1.99% median / +11.27% aggregate** vs +0.05% control, fetched values **+12.82%**
vs -0.21%, body-only wall delta +27 ms/run vs +0.2 ms/run, SQL text p95 72,426 B vs
22,704 B for all ref statements with statement count unchanged (-0.2%) -> bigger single
queries, not more round trips.

**THE -16.7% "EFFORT WIN" IS DEAD (2026-09-08 re-measurement).** `compute+download` is
in MILLISECONDS and follows storage download latency; it manufactured wins AND losses.
Re-run on the unit-less `@executionEffortSum` (`[STATS] Distributed query session`),
summed per `@xTraceId` over DISTINCT `@distributedSessionId` (MAX per session id, to
collapse Datadog double-indexing), warmups excluded, keeping only traces with equal
ref/test session counts: **split population +4.60%** (5,086 traces, 3,317 up vs 1,769
down) against a control of **-0.07%** (11,240 traces, 4,361 down vs 4,281 up). Also:
ZERO split traces have equal effort on both branches vs 2,598 flat control traces, so
the rewrite changes real work nearly everywhere it fires, net negative. Every surviving
metric now points the same way: on Tables this optimizer is a regression.

Per-view, ms effort vs unit-less effort (the two disagree constantly):
Newell `44ee2888` -65.7% / **+0.5%**; Palo Alto `376734b1` -53.7% / **+20.8%**;
Vinted `4733a9ea` -62.7% / -0.5%; Ledger `e9795b63` -60.0% / -2.2% (only real win);
ServiceNow `80148d08` +807.8% / **+0.04%**; ServiceNow `9dbfdbbc` +224.0% / +0.03%;
JULES `3e800bae` +259.1% / -0.2%; Morrisons `af3531ca` +100.3% / -3.2%;
THM `47be56ea` +54.9% / +4.7%; SNCF Reseau `583fa50e` +97.8% / +7.5%;
Keolis `89a886c7` -32.4% / **+8.2%**; Palo Alto `1d3b2d6f` +319.9% / +22.2%.
So the §3 "wins" (Newell, Palo Alto `376734b1`, Vinted) are retired, and the §4
"duplicated scan" family (both ServiceNow views, JULES, Morrisons) is retired too. Real
regressions on real work: Palo Alto `1d3b2d6f`, Keolis, SNCF Reseau, THM. NO material win.

**Shard count is a real but MINORITY channel.** `@refShardCount`/`@testShardCount` on
the `[ViewDiff] Result` line: rises on 146 of 5,097 split runs, falls on 23 (control:
1 and 0), net +2.9%. THM `47be56ea` and SNCF `583fa50e` do go 2 -> 4 shards every run
(confirms the broadcast-reload mechanism), Newell goes 2 -> 1 (which is where its
download-time win comes from). BUT Keolis `89a886c7` stays at 1 shard on all 17 runs and
still fetches +31%, and population-wide only 68 of the 292 runs that fetch >10% extra
also increase shard count, against 223 with an IDENTICAL shard count. Do not generalise
fetch inflation to a shard-count symptom.

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

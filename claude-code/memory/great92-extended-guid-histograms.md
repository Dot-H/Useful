---
name: great92-extended-guid-histograms
description: "GREAT-92 re-enable class-B (nullable) GUID histograms - why PR #136632 was reverted, and why under-count (not over-count) is the dangerous direction"
metadata: 
  node_type: memory
  type: project
  originSessionId: 14daa1bd-d315-43cf-9ae7-d3a837122acd
  modified: 2026-09-22T13:51:15.838Z
---

GREAT-92 (Linear SCHED-353, Slack thread C07FW0H0U4X p1785934181.243159): re-enable extended GUID
(class-B / nullable) histograms. PR #136756 commented out the
`SanityCheckMismatchingNullableColumns` recompute trigger on 2026-08-11 after it produced 1.6M of
2.6M ComputeHistograms jobs in 6 days and took FairJobCompletion down.

Implemented 2026-09-22 as a 7-PR draft stack (#143131) on `alex/great-92/...`, in merge order:
#143127 registry delta preserve, #143128 read-path strip-before-uniform, #143130 full write-back
preserve, #143138 observability + producer alignment, #143148 IMP computes the synced column,
#143158 registry applies the nullable delta, #143174 re-enable the trigger via the maintenance
backlog behind `RecomputeHistogramsOnMismatchingNullableColumns` (default off).
PEP: https://app.notion.com/p/pigmentso/Re-enable-extended-GUID-histograms-3e3adbe6acf581faabd0d580432338aa

Three non-obvious facts that are expensive to re-derive:

1. **Why PR #136632 was reverted (#136710).** It accumulated class-B histogram deltas from the
   *source* (computed) `LocalDataset`, but `ImpServiceQueryContext.ComputeOutputScopesOnImp` only
   materialises `targetDataset.Schema.PrimaryKey + targetColumn`, so `_columnsAccessors[classBColumn]`
   threw `KeyNotFoundException` inside `ComputeChangeScopeCommand` - after the DataProxy download was
   opened, hence the leaked downloaders Renan reported in #alerts-storage. The revert PR itself states
   no reason. Never widen the sync path to arbitrary class-B columns. The *target* column is the one
   exception: `_columnsAccessors[targetColumnName]` is an unguarded indexer that already resolves
   there (it backs `BuildRowCopier`'s value copier), so that single column can be computed exactly.

2. **Over-count is safe, under-count is not.** `KeyHistograms.Cardinality` is a `Min` across the set,
   and `CardinalityEstimator.PromoteAndRebalanceColumnsHistograms` -> `RebalanceToSmallest` only ever
   scales *down* and bails out entirely when the minimum is 0. So a stale-high nullable histogram is
   clamped to the delta-accurate PK cardinality (harmless), but a stale-low one propagates into the PK
   estimate and can zero it out -> no sharding -> DataLimitReached/OOM. Under-count happens exactly
   when the formula's own target column is a class-B column (a dimension-typed metric), because the
   preserved histogram then describes the column the sync just overwrote. Also: never upsize a
   preserved nullable histogram - `Histogram.Extend` divides buckets and `SafeToInt` floors them, so a
   small class-B histogram collapses to cardinality 0.

3. **`ComputeChangeScope` never fed the accumulator on the `Modified` branch.** It only drove it for
   inserted and deleted rows. A row whose synced column changed modality A -> B is classified
   `Modified`, so the transition was invisible - correct for PKs (their keys do not change on an
   update) and harmless while the class-B delta went unused, but a silent downward drift once the
   registry applies it. Fixed by `UpdateNullableColumn(oldRow, newRow)`, called from inside the
   `iteration.Lookup` block where both `deserializedRow` (old) and `iterator.Current` (new) are in
   scope, and deliberately limited to the synced column so PK histograms are not double-counted.

Erasure points: `HistogramsSyncCoordinator.cs:150` (single-arg `ColumnsHistograms` ctor forces an
empty nullable set) and `SqlDatasetStatisticsRepository.ApplyHistogramsDelta` (2-arg
`DatasetStatisticsHistogramsJson` ctor drops the stored section). The extended-GUID feature flags are
gone; the only gate left is the `MaxExtendedHistogramColumns` config knob (default 12).

2026-09-23: stack is now 8 PRs, GitHub stack #143345; #143342 (FF `SyncExtendedGuidHistograms` 130144, formula
option 269, `ImpExecutionOptions` field 68, D-RQC field) inserted below #143130. FF off = exact pre-stack
behaviour: full write-back erases, a delta WITHOUT a nullable channel makes the registry drop the nullable
section (legacy shape), workers track nothing. Fixed the same day: registry never rejects a delta over a class-B
column (unknown column ignored, bad resolution dropped, buckets clamped at 0); coordinator only sends the synced
column's delta when it is stored AND expected; the full write-back only writes the expected set (fixes the
knob=0 ping-pong). Still OPEN: `DatasetMaintenanceBacklogJob` deletes the row BEFORE the job runs and DO has no
JobId dedup, so the backlog only dedups for ~30s (cap 10/org/30s = 1200/h/org for a non-converging dataset).

Related: [[great49-blank-access-view-wiring]], [[adding-compute-execution-option-skill]].

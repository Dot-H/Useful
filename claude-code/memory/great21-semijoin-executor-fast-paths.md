---
name: great21-semijoin-executor-fast-paths
description: "Why InnerJoinToSemiJoin is never faster (Phase A): three executor gaps in ProcessSemiJoinOperationAsync vs the inner join path; fix = existence-gate fast path + empty-base short-circuit (PR 1) and lazy filter on the semi-join base (PR 2), GREAT-21, started 2026-09-10"
metadata: 
  node_type: memory
  type: project
  originSessionId: 47fc47d4-fd85-4a6f-851a-06efc58a5373
  modified: 2026-09-10T07:46:06.813Z
---

Decision 2026-09-10 after the "Inner -> Semi view diff analysis" Notion page: the semi-join rewrite of
ARM access checks is not suspiciously slow, it is *expectedly* slow, because every converted check is a
zero-binding semi-join (`_user = <uuid>` is a branch-local restriction, so `Bindings` is empty) over a
1-row probe, and `ProcessSemiJoinOperationAsync` (ImpResult.cs) lacks three things `VisitJoin` has:

- base processed with `AccessCapabilities.None` and throws on a returned `LazyFilter` (inner join grants
  `AllowLazyFilters`, filter becomes a 0 ms `Lazy Filter` folded into the probe)
- filter side evaluated first, only short-circuit inspects the filter side (inner join stops at the first
  empty input: `Empty Join`)
- 1-row / zero-binding probe still goes through `IndexForLookup` + `ApplySemiJoin` row copy (inner join
  folds 1-row inputs into constants: `ScalarJoinPlan`, no probe)

Fix, executor-side, two stacked PRs under GREAT-21 (user chose the ticket; not GREAT-90):
- PR 1 `alex/great-21/semijoin-existence-gate`: zero-binding semi-join = existence gate, base first,
  skip the probe when the base is empty, forward the base `ImpResult` untouched (grant lazy filters only
  when the parent granted them, `ProcessSingleNonScalarSourceJoin` rule), `Strategy` field on
  `SemiJoinQueryPlan`; plus empty-base guard on the bound path.
- PR 2 `alex/great-21/semijoin-base-lazy-filter`: `AllowLazyFilters` on the base of bound semi-joins,
  predicate folded into `ApplySemiJoin` via `LazyFilter.MatchesAll`.

**Why**: with zero bindings the filter result cannot narrow the base load (empty remapping yields a
keyless, projection-less branch every consumer drops), so evaluation order is free and no probe is needed.
Rejected: skipping the conversion for zero bindings (keeps inner-join speed, forfeits pruning/pushdown).

**How to apply**: after merge, re-run `InnerToSemi - Lists/Tables` view diffs and check Klarna `0f4a014c`
(fetched values 2 -> 2), IDEX `de67e5e7`, Holcim `9cf7fa76` (`Lazy Filter t=0` under `Semi Join`).
`TotalIndexLookups` does NOT discriminate the gate (FullScan iterations skip `RegisterLookupEffort`);
assert `Is.SameAs(base data)` instead. Plan file:
`~/.claude/plans/reading-https-app-notion-com-p-pigmentso-keen-matsumoto.md`.

See [[great90-semijoin-pushdown-viewdiff-regression]] (Phase B, fixed by PR #140868),
[[great-90-semijoin-pushdown-optimizer]], [[great90-imp-executor-side-binding-limit]].

---
name: great-90-semijoin-pushdown-plumbing
description: "Wired SemiJoinPushdown FF/formula option/view options so the optimizer from PR #133474 can be tested (GREAT-90, PR #134754)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 52d4d736-6355-4879-a6b7-920d212e6418
  modified: 2026-07-28T08:12:42.198Z
---

Branch `alex/great-90/semi-join-pushdown-plumbing` (worktree
`~/pigment_code/opensource/monorepo-semijoin-pushdown-plumbing`), PR #134754 (draft).
[[great-90-semijoin-pushdown-optimizer]]'s `LogicalPlanOptimizerOptions.SemiJoinPushdown` flag was defined and
consumed in `LogicalPlanOptimizer.Optimize()` since #133474 merged, but never connected to any execution
option -- dead in prod, no way to enable/test it. This PR is pure plumbing, no optimizer logic changes.

Replicated the exact pattern of the (still unmerged as of 2026-07-28) ColumnPruning PR #134540:
`FeatureFlag_SemiJoinPushdown = 130104` -> `FormulaOptionId.SemiJoinPushdown = 229` / `FormulaOptions.SemiJoinPushdown`
bool / `KnownFormulaOptions` entry ("semi_join_pushdown") -> `ImpExecutionOptions.semiJoinPushdown` proto field 47
-> `FormulaExecutor` (3 call sites) -> `RemoteQueryContextOptions.SemiJoinPushdown` /
`DistributedRemoteQueryContextOptions.SemiJoinPushdown` -> all 3 `ToLogicalPlanOptimizerOptions` extension methods
in `LogicalPlanOptimizer.cs` -> `ListViewOptions.semiJoinPushdown` (field 40) / `TableViewDataOptions.semiJoinPushdown`
(field 72) per-request overrides, read as `(requestOptions?.SemiJoinPushdown ?? false) || featureFlagLookup.IsFlagEnabled(...)`
at all 6 call sites (3 in ListViewService.cs, 3 in TableViewService.cs). Test: one method added to
`LogicalPlanOptimizerOptionsExtensionsTest.cs` asserting off-by-default + each of the 3 options carriers flips the flag.

**Field-number collision risk with ColumnPruning PR #134540 (unmerged):** both PRs independently claim
`FeatureFlag = 130104`, `FormulaOptionId = 229`, `ImpExecutionOptions` field `47`. Whichever merges second must
renumber (`130105`/`230`/`48`, and next-free `ListViewOptions`/`TableViewDataOptions` field after this PR's 40/72).
Also: `LogicalPlanOptimizerOptions.ColumnPruning` in #134540 claims bit `1 << 13`, which collides with the
already-merged `SemiJoinPushdown = 1 << 13` -- that PR will need to renumber to `1 << 14` regardless of merge
order with this one.

Branch naming convention changed to all-lowercase mid-session (see updated CLAUDE.md); this branch was created
lowercase from the start (`alex/great-90/...`), matching the new rule -- earlier GREAT-90 work in memory used
upper-case `alex/GREAT-90/...`, now stale w.r.t. convention (their PRs are unaffected, just don't copy the casing
for new branches).

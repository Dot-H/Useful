---
name: great90-imp-executor-side-binding-limit
description: "ImpResult.cs (in-memory IMP executor) throws \"Attempting to bind not on a key\" for any JoinInput SideBinding whose column has no matching KeyBinding InputColumn on the same input"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0dc81db1-863f-4230-a4a9-b3e9bb433e53
---

`ImpResult.ProcessOuterJoin` (apps/Compute/ComputeService.Repository/Repository/InMemory/ImpResult.cs, ~line 3450) requires: for every `JoinInput` with `SideBindings`, each side binding's `InputKey` must ALSO appear as a `KeyBindings` `InputColumn` on that same input. If not, it throws `InvalidOperationException: Attempting to bind not on a key (...)` -- unconditionally, not just under lazy/small-branch loading (`UseLazyDatasetLoad`).

This means the common "ARM" shape -- a `JoinInput` with `KeyBindings: []` and a pure parameter/correlation `SideBinding` (e.g. `armset.user = @user`, or `armset.seg = base.k` with no separate key binding) -- cannot be executed at all by this in-memory test executor, regardless of any optimizer. It is unrelated to [[great-90-semijoin-pushdown-probe-key-constraint]] (that one is specifically about the lazy/small-branch pushdown path); this is a broader, always-on limitation of `ImpResult`'s general join processing.

**Why:** Discovered while migrating `OuterJoinToSemiJoinOptimizerIntegrationTest` (Postgres-backed) to an `OuterJoinToSemiJoinOptimizerImpTest` (in-memory IMP-backed, `OptimizerImpTestBase`) following the pattern of `SemiJoinPushdownOptimizerImpTest`. ~17 of 35 shared test-case shapes in `OuterJoinToSemiJoinOptimizerTestCases` use this side-binding-without-key-binding pattern and crash on the very first `Run(original)` call, before the optimizer is even involved.

**How to apply:** When writing an `OptimizerImpTestBase`-derived suite that reuses plan shapes from a structural (`ILogicalOperation`-tree comparison) test-case source not originally designed for IMP execution, expect this failure mode. The correct fix is NOT to contort the fixture data -- it is structural, not data-dependent. Instead, wrap the initial `Run(original)` probe in a try/catch for `InvalidOperationException`/`KeyNotFoundException` and `Assert.Ignore` with a clear message when the *unoptimized* plan itself cannot execute on this engine (no ground truth to compare against); only assert equivalence for shapes that do execute. See `OuterJoinToSemiJoinOptimizerImpTest.cs` for the pattern.

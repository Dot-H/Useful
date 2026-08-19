---
name: aurora-scoped-wipe-2026-08-19
description: "Scoped DQS execution wiped a metric cell on Aurora (org 09760212) 2026-08-19; investigation state, key IDs, and candidate root causes in the IMP inner-join machinery"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1efabd86-3067-4529-b6cc-919762ab2ea8
  modified: 2026-08-19T14:27:56.332Z
---

Investigation of the 2026-08-19 FormulaReplay alert on Aurora (org `09760212-1676-4eed-841e-a7a0214f032b`, formula `d10678ce`/job `57bbd00e-ebf7-4d83-bffb-1c13f89693f1`): the scoped DQS execution `f6fe955e-5cd2-4722-8f07-cc1430ac9129` (trace `51397b4e60419b919260a2719be857ca`, change `95b5924a`, 05:39:31 UTC) computed 0 rows for a single-cell hypercube scope (3 pinned modalities) and deleted the stored row; the unscoped replay at 10:58 restored it.

Established facts:
- Same binary (`hotfix-2026-08-18-16-10`, compute code == rc-2026-08-19-04-01): scoped run at 05:06 computed 2 rows correctly; unscoped runs at 05:32/10:58 correct (11 rows). Bug is scope/plan-shape dependent, NOT a pure version regression.
- Faulty run stats: `ComputeOutputScopesDownloadedRowCount=1`, `computeOutputScopesBufferRowCount=0`, `overwriteDatasetDeletedRowCount=1`, joinSteps=6, aggregateSteps=34, 2 partitions, ShardCount=1, no shuffle. Source rows WERE fetched (441+451 rows of transaction dataset `b3c85391`, PO list `9354ab07` with `contact_IBF02R` fully fetched) -- emptiness arose inside the IMP join/aggregate pipeline.
- Prior same-signature bug (AppsFlyer wipes, Axelle's 08-17 recap): #134591 broke ImpResult.cs inner-join keybound+sidebound path; #134662 (rc-2026-08-13-07-36) accidentally fixed it, no regression test.
- Since that fix, the SAME machinery was rewritten again by #137205 "Simplify how pipes are passed between join iterations" (PipesForCurrentSource deleted; Buffer.InnerJoin/InplaceInnerJoin now return NextLeftPipes) -- in rc-2026-08-19-04-01.
- Candidate 2: #136678 `BuildJoinIndexOnSmallerSide` (merged 08-11, FF 130114 default Disabled, FF-backed formula option; an active formula-diff canary campaign TEST vs REF=false was running 08-19). buildOnLeft fires only on nested-loop joins with left smaller -- exactly the scoped-plan shape (tiny scoped left vs large right); unscoped plans keep left large. All retained join spans in the trace show build-side:right, but the faulty session's own join spans (hosts dfcv/wnrn) were not retained by APM sampling -- inconclusive.

Blocked on: fetching `query-plans/imp/01a01887-9754-709e-8f73-8da98221da47.json` and `query-plans/drqc/01a01887-f37a-700b-836a-ffac511861c5.json` via `~/bin/get-query-plan.sh <queryId> <filePath> production-us1` (queryId `01a01888-25cb-7a6f-97fc-5c5f9ecbc78d` works for the imp file) -- requires fresh `PIGMENT_TOKEN` (kept 401ing). The finalized plan has per-node row counts + NestedLoop/Join node SideBindings: it discriminates between the two candidates. Also worth checking FF 130114 state for Aurora at the incident time (back office).

Related: [[great-90-semijoin-pushdown-probe-key-constraint]], [[great90-imp-executor-side-binding-limit]]

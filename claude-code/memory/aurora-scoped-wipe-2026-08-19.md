---
name: aurora-scoped-wipe-2026-08-19
description: "RESOLVED root cause of the 2026-08-19 Aurora scoped-execution cell wipe; empty modality set in the scoped input loading scope (rendered AND FALSE), not an IMP join runtime bug"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1efabd86-3067-4529-b6cc-919762ab2ea8
  modified: 2026-08-19T15:00:04.519Z
---

Root cause of the 2026-08-19 FormulaReplay alert on Aurora (org `09760212`, formula `d10678ce`/job `57bbd00e`, scoped execution `f6fe955e`, trace `51397b4e60419b919260a2719be857ca`): NOT the ImpResult join runtime (unlike the AppsFlyer wipes) and NOT #136678/#137205.

Mechanism (fully verified from plans + scoped download definitions):
- Scope candidates: 2 (from the contact change on PO Numbers `9354ab07.contact_IBF02R`, mapped through 2 source links of the chained-[BY:] formula). Candidate A pins `prior_versions` to `31d1ae90` (the [BY:]-remap target member of the po->contact branch); the cell to synchronize is at `prior_versions=a730df96`.
- The scoped downloads of the main input dataset `c1203e58` (11M rows) got a loading scope with `prior_versions: {}` -- an EMPTY modality set (intersection of disjoint member sets {31d1ae90} vs {a730df96}) -- rendered as literal `AND FALSE` in the download SQL => 7/7 downloads returned 0 rows (dataProxyRequestId `f498541e-2542-4a96-b75f-afa019e389dd`, file `scopedDownloads/imp/01a01887-3eaa-7171-bc81-9807ac4a149f.json`).
- Same `AND FALSE` conjuncts appear in every union branch of the main query (queryId `01a01888-28cf-7cc2-b9b3-b6d0b0705750`, plan `query-plans/drqc/01a01887-f37a-700b-836a-ffac511861c5.json`): all c1203e58 branches statically empty; the joins were pruned (`PrunedQueryPlan` "Empty Join" nodes, ImpResult.cs:1354-1359 via `ProcessUnboundScalarSources` resultShouldBeEmpty on folded constant scalars whose composed filter contains the FALSE).
- The synchronization still targeted the cell (marcomm `ecc780fe`, prior `a730df96`, year `29c4cb56`) => computed 0 rows => DELETED the stored 2,489,097.44. Replay (unscoped, queryId `01a019ac-4f6d-7817-8294-5f606090f77f`) restored it; the cell's value comes from the c1203e58 branches at prior=a730df96 (formula-static filter), which are NOT contact-dependent.
- So the incoherence: input loading scopes / in-plan scope filters used candidate A's prior member (31d1ae90), while the recompute+sync scope covered the a730df96 cell. Empty intersection should have meant "cell unaffected via this input" (skip), never "recompute as empty and delete".
- `DatasetLoadingScope.Intersection`/`SingleDomainScope.Intersect` algebra is honest (disjoint => empty => FALSE); the bug is the CALLER combining incompatible scope sources (candidate scopes from `ScopeHelper.ListCandidateScopes`/`DryCandidates` in Pigment.Scoping + formula static filters). Note ScopeHelper.cs:74 already warns empty clauses are dangerous (SCHED-205).

Useful techniques: back-office `GetQueryPlan`/`GetQuery`/`GetScopedDownload` APIs (`~/bin/get-query-plan.sh`, needs fresh PIGMENT_TOKEN, X-Pigment-Location: production-us1); the main query of an execution is the `ExecuteToDataset` log line; `PrunedQueryPlan` serializes as node type "Empty Join" with the pruned-result `Result rows=0` as last child.

Related: [[great90-imp-executor-side-binding-limit]]

---
name: great-idkids-viewdiff-root-causes
description: IDKids Graphite migration view diff root causes (4 clusters) + fast investigation workflow for viewdiff slowness
metadata: 
  node_type: memory
  type: project
  originSessionId: 54f038cb-3c62-4b68-ac7d-e96fd83eff95
  modified: 2026-08-20T08:47:42.178Z
---

IDKids (`f887987b-1f3d-46a6-be63-66a0140143a0`, viewDiffId `92bb0ce0-ccbf-42ed-a9e7-06255cbdfdaa`, ref = SQL+IMP hybrid, test = Full IMP). Root-cause analysis written 2026-08-20 to Notion page 3c2adbe6acf580b6914ddd2ac9acb4a4 (parent: 3c2adbe6acf580f48e4bf232739721a3).

Four root-cause clusters for test-slower-than-ref:
1. **No aggregation pushdown**: day-grain facts (2.6-3.9M rows) downloaded whole and aggregated in IMP; ref does GROUP BY in Postgres (views 6a86543a, 60ab146e). Fix: GREAT-26 extended to DatasetLoad level.
2. **Mapping-mediated filters + blank/access OR `(dim = 0000... OR (arm._user IS NOT NULL AND attr IN ...))` not pushed into loads**: the 56-64M-fetched-values cluster (~10 views, b7c9495e et al). Fix: semi-join pushdown + GREAT-49 Blank Bypass.
3. **IMP computation-slot starvation**: session spends ~100% of runtime in slot acquisition (`ComputationSlotAcquisitionException`, in-flight=24, 1s-timeout retry loop); fires 2-42x/day for this org; NOT in project portfolio.
4. **Harness artifact**: cardinalityThreshold=5000000 SQL fallback runs on BOTH branches; test runs first and pays cold Postgres cache (18.1s vs 284ms warm). Not a real engine gap.

Fleet: 66% of regressed test wall time is DataProxy download; median regressed run = 53% download, 19.6M values, 2 shards.

**Workflow gotchas**: query-plan retention ~2 weeks (get-query-plan.sh 404s on older); PIGMENT_TOKEN expires within a day (401 -> ask user to refresh); per-trace ranking = DDSQL on `@xTraceId:<id> @processingEngine:DistributedQueryService @duration:*` with extra_columns @diffBranch/@duration/@queryId/@planViewerLink ORDER BY duration DESC -- one test ExecuteToDataset is usually the whole gap; ref's heavy time is inside pushed-down SQL (invisible in DRQC logs); auxiliary synthetic viewId `c0de0001-1111-0000-0000-000000000000` queries can dominate a diff. Related: [[great-90-semijoin-pushdown-optimizer]], [[great90-column-pruning]].

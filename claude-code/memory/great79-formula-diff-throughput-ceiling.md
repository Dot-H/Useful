---
name: great79-formula-diff-throughput-ceiling
description: Why FormulaDiff throughput only did x5/x6 after org-parallelisation (PR #133155) - heavy per-diff IMP cost x per-org CC low-prio quota saturation; proven via CC "Poll finished" logs; ruled-out suspects list
metadata:
  type: project
---

Investigation (2026-07-17) into why formula-diff throughput only rose x5/x6 after PR #133155 (org-parallelised dispatch via FormulaDiffBootstrapper). Full writeup with Datadog evidence links: Notion page "FormulaDiff throughput" (3a0adbe6acf580cfa4c6f55a430a63da).

**Conclusion: throughput = SUM over active orgs of min(8, allocated IMP share) / per-diff execution time.**
- Per-diff execution is HEAVY: `JobWorker.FormulaDiffJobExecutor` spans (compute-api) median 20.2s, avg 28.2s, p95 88.9s. FormulaDiff = SchedulingBucket.Large, 1 IMP (`JobCostEstimator.cs`). Sample trace dccd7073e43f6b0ebdbc5478559b0901: 35s CC-slot queueing + 26s execution; completion machinery ~50ms.
- Per-org concurrency = min(DefaultLowPriorityQuotaCap Imp=8, allocated share). Allocated share = usage-weighted split of ORC-reported global IMP capacity (**460 live**, 288 fallback) across 57-64 IMP-active orgs. PROVEN via CC `Poll finished` logs (JobSchedulerService.EndOfIteration): Sureserve quota 9.1 -> lowPrio min=8, running 9, pending 42, NoJobScheduled (cap binds); CDC quota 4 -> lowPrio 4, running 4, pending 230+ (share binds). Orgs are SATURATED at their quota with big CC pending queues.
- Per-org rate flat ~150-280 diffs/h regardless of org count (Little's law closes: Sureserve 9/750h=43s, CDC 4/250h=58s). Aggregate scales with #active orgs only (45-org burst -> ~9000/h at same per-org rate). Backlogs 10k-59k items/org.

**Ruled out with production data (do not re-investigate):**
- Compute concurrency (in-flight ~0.1 of 13/pod), CC ShouldThisBatchRun semaphore (8/pod, ~7ms wait, monitor 98756753 green).
- Workspace ReserveJobs global advisory lock: FIXED on master - completion hot path uses per-org `ReserveJobsForOrganization`; global-lock ReserveJobs only on 1-min BootstrapJobs tick.
- DO fair_job_completion: 8 loops/pod (FAIR_JOB_COMPLETION_MAX_CONCURRENT_POLLING_LOOPS), idle-spinning (~1078/s NoMoreJobToProcess vs ~143/s JobAcquired); its do_processing_time/backlog_contention measure ExecutionEndedAt->processed queue AGE (burst symptom), not work time.
- DO execution-graph lock: lock_wait_duration flat ~1.3ms. Zero "not found in backlog" logs: feedback loop works.

**Levers:** (1) reduce per-diff cost (dominant - batch formulas per diff job, reuse ORC/D-IMP sessions per app); (2) per-org slots: share-bound orgs need more global IMP capacity/weight, cap-bound orgs need PIGMENT_CC_LOW_PRIORITY_IMP_QUOTA_CAP (trades against interactive latency); next walls MaxJobsPerOrg=10 then global 460.

**Gotcha:** CC `Poll finished` log is the goldmine for quota questions - contains Quota, LowPrioQuota, running/pending cost split by priority, and active-org counts per resource.

Related: [[great79-formula-diff-reservation-index]], [[project_great79_formula_diff_split]]

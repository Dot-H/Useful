---
name: great79-stale-quartzjob-cleanup
description: Stale QuartzJob<T> Postgres entries surviving DI deregistration; scoped fix in CleanDeprecatedQuartzConfigurationExecutor (PR
metadata: 
  node_type: memory
  type: project
  originSessionId: 17e6cc57-ef4c-4ae7-9637-23b260f9e142
---

Quartz uses a Postgres-backed persistent/clustered job store (`QuartzConfigurator.UsePostgresPersistentStore`). When a `QuartzJob<TJobExecutor>` stops being registered in DI (e.g. a feature-flag flip that stops scheduling `TJobExecutor`, as happened rolling out `FormulaDiffBootstrapper` in PR #133155 for [[great79-formula-diff-reservation-index]]), the persisted trigger survives and keeps firing. `GetJobDetail` still succeeds (the class is loadable), so `CleanDeprecatedQuartzConfigurationExecutor`'s `TypeLoadException`-only check misses it. Quartz then falls back to `ActivatorUtilities` at trigger-fire time and fails resolving `IScheduledJobExecutor` (never registered as its own service type -- each executor is registered under its own concrete type via `QuartzConfigurator.AddSingletonJob`), spamming `Quartz.SchedulerException: ... Unable to resolve service for type 'IScheduledJobExecutor'` on every fire.

This exact class of bug happened before (April 2026, `ReconcileDatabaseHostsJobExecutor`/`DownloadHistoryRetentionJobExecutor`, Datadog monitor 90222716). A generic fix was merged (PR #122032: delete any job whose type can't be resolved via `IServiceProvider.GetService` after `GetJobDetail` succeeds) and reverted within hours (PR #122080) because it produced false positives: `Pigment.Scheduling.Quartz.DynamicQuartzJob`/`StaticQuartzJob` are intentionally never registered in DI as themselves -- Quartz constructs them via reflection from their own resolvable constructor deps -- so the blanket check deleted 7 live, legitimately-scheduled jobs in staging.

**Why:** the correct fix must scope the DI-resolution check to only `QuartzJob<>` closed generics (`jobDetail.JobType.GetGenericTypeDefinition() == typeof(QuartzJob<>)`), since that's the only wrapper type whose constructor takes the never-directly-registered `IScheduledJobExecutor` interface. Anything else being unregistered in DI is not necessarily broken.

**How to apply:** Fixed and shipped in PR #133311 (`apps/Common/Pigment.Quartz/CleanDeprecatedQuartzConfigurationExecutor.cs`), with a test reproducing the stale-entry bug and a regression guard mirroring the `DynamicQuartzJob` false-positive. If a similar "job stopped firing after a flag flip is throwing SchedulerException" report comes up again, this generic cleanup should now catch it automatically -- check first whether #133311 already covers it before writing a one-off manual DB cleanup (Postgres `QRTZ_JOB_DETAILS`/`QRTZ_TRIGGERS` tables) like the one done manually in April 2026.

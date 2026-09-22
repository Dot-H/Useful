---
name: dd-widget-json-schema-gotchas
description: "Gotchas for hand-writing Datadog dashboard widget JSON (spans data_source) to paste into the widget JSON editor - percentile aggregation naming, no definition wrapper, DependencyOrchestrator service/tag names"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 131d1a0b-8bb0-4daa-a176-890f4d9018bf
  modified: 2026-09-22T09:09:44.483Z
---

When hand-writing a Datadog dashboard widget JSON (spans `data_source`) to paste into the dashboard's "widget JSON" editor:

- **Paste the inner widget object, not `{"definition": {...}}`.** Wrapping in `definition` gives "Invalid Widget Type" in the per-widget JSON editor (that wrapper is only correct for a full dashboard's `widgets[]` array, not the single-widget paste box).
- **Percentile aggregations must match `^pc[0-9]+(\.[0-9]+)?$`**: use `pc50`, `pc95`, `pc99`, not `p50`/`p95`/`p99`. Applies to both `compute.aggregation` and `group_by[].sort.aggregation`.
- **Multi-line JSON copied out of a chat/terminal window can pick up invisible line-wrap characters** that break `JSON.parse` ("Bad control character in string literal"). Prefer minified single-line JSON when handing widget JSON to a user to paste.
- **`"type": "change"` widgets compare two `formulas` entries against each other, not a single subtraction formula plus a time-shifted `compare_to`.** `formulas: [{"formula":"query2"}, {"formula":"query1"}]` yields `change = query1 - query2` (index 1 minus index 0); `compare_to` (e.g. `hour_before`) is layered on top of that pair, not a substitute for it. A single `"formula": "query1 - query2"` entry fails with "Missing base value or comparison value" because the widget then tries to diff that one already-combined value against its own past self, and per-group data for both spans queries rarely lines up at both time instants (sparse/diversity-sampled spans).

DependencyOrchestrator (SCHED-646 dependency graph cache dry-run) specifics, see [[dg-directional-partial-graph-cache]]:
- APM service name is `dependency-orchestrator-api`, not `dependency-orchestrator` (that's just the Terraform tag/module name in `infra/terraform/stacks/monitoring/dependency-orchestrator/dependency-orchestrator/main.tf`).
- Custom `Activity`/span names (e.g. `caching-dependency-graph.dry-run.cache-side`) surface on APM spans under `resource_name`, not `operation_name`.
- Span tags set via `SetTag` keep their C# constant string keys verbatim as span attributes: `@org-id` (`SpanTags.OrganizationId`), `@dry-run-query` (local `dryRunQueryTag` const in `CachingReadSession.cs`).

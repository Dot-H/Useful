---
name: feedback_plan_links_inline_not_listed
description: Plan-viewer links go inline in parentheses next to the query/view reference, never in a separate list of plans
metadata:
  type: feedback
---

Whenever a report references a query, a view or a statement (in a table row, a bullet or prose),
attach the `@planViewerLink` **inline, as a discrete hyperlink in parentheses right after the
reference**. Never collect the plans into a separate "plans for each row" list below the table.

Preferred shape, for a ref-vs-test comparison:

```
`6b317fee` ([ref 449 ms](https://localhost:49378/plan-viewer?queryId=...) / [test 2,218 ms](https://localhost:49378/plan-viewer?queryId=...))
```

Single plan: `` `6b317fee` ([link to plan](XXX)) ``.

**Why:** a separate list forces the reader to jump back and forth between the row and the link,
and it duplicates the row identity (view id, shard counts, durations) just to hold a URL. Inline
parentheses keep the plan one click from the number it explains and keep the page shorter.

**How to apply:** put the link in the cell that names the thing, not in a trailing column or a
follow-up list. Carry any per-plan detail that the list used to hold (statement duration, ref vs
test) inside the link text. Any prose that must survive the list, such as a caveat about one of
the plans, becomes a normal sentence after the table.

Related: [[great49-viewdiff-perf-pairing-method]],
[[great90-blank-split-viewdiff-2026-09-21]].

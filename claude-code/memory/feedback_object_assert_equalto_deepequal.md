---
name: feedback_object_assert_equalto_deepequal
description: "When asserting an object in a test, use Is.EqualTo when possible, otherwise IsPigment.DeepEqualTo"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1678ddbb-0f61-4a74-9cf6-9c43e5aef7c9
  modified: 2026-09-08T08:42:38.864Z
---

When asserting that an actual object matches an expected object in a C# test, prefer `Assert.That(actual, Is.EqualTo(expected))`. If plain `Is.EqualTo` does not work well for the object (e.g. it lacks value equality or the comparison needs to be structural/deep), use `IsPigment.DeepEqualTo` instead.

**Why:** The user flagged this while reviewing PR #140759 -- object assertions should use one of these two constraints rather than ad hoc field-by-field comparisons or other custom equality checks.

**How to apply:** When writing or reviewing a test that asserts on a whole object (not a scalar or collection, see [feedback_no_redundant_count_assert](feedback_no_redundant_count_assert.md) for collections), default to `Is.EqualTo`; fall back to `IsPigment.DeepEqualTo` only when `Is.EqualTo` isn't suitable.

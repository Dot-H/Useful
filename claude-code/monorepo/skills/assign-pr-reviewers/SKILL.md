---
name: assign-pr-reviewers
description: >-
  Polls a PR every 3 minutes, waits for CI checks to go green, then assigns
  reviewers and marks the PR as ready for review. If a check is red, uses the
  CircleCI MCP to diagnose the failure and boots a subagent to fix it. Works
  in a git worktree. Use when asked to "watch a PR", "assign reviewers when
  CI is green", or "wait for CI and request review".
when_to_use: >-
  Trigger: user asks to assign reviewers to a PR, watch a PR until CI passes,
  or mark a PR as ready for review once checks are green. If the prompt does
  not mention which PR and which reviewers, ask before doing anything else.
---

# Assign PR Reviewers

This skill watches a pull request, waits for all relevant CI checks to pass,
then assigns reviewers and marks the PR ready for review. If any check is red
it diagnoses the failure via CircleCI and boots a fix subagent.

---

## Step 0 -- gather required inputs

Before doing anything, check whether the prompt already contains:
- The PR number or URL.
- The list of reviewers (GitHub usernames).

If either is missing, ask the user for both before proceeding. Do not start
the polling loop until you have both.

---

## Step 1 -- the polling loop

Use the `/loop` skill with a 3-minute interval, passing this skill as the
prompt, so that the loop re-enters here on each tick.

On each iteration:

### 1.1 Fetch all checks

```bash
gh pr checks <PR> --json name,state,conclusion,status
```

or, if the above is unavailable:

```bash
gh pr view <PR> --json statusCheckRollup -q '.statusCheckRollup[]'
```

### 1.2 Classify the checks

For each check, determine its category:

| Prefix / pattern | Category |
|---|---|
| `run-test-on-pull-request/*` | **ignored** -- never block on these |
| `trigger-*` | trigger job |
| `bypass-*` | **ignored** -- bypass jobs are never required |
| anything else | regular job |

**Trigger logic**: a `trigger-*` check in state `SUCCESS` means the
corresponding real job was triggered. Derive the real job name by stripping
the `trigger-` prefix from the trigger check name
(e.g. `trigger-run-backend-e2e-tests-against-postgres` ->
`run-backend-e2e-tests-against-postgres`). At that point you must wait for
a check whose name *starts with* that derived name to also reach a terminal
state.

A `trigger-*` check that is still `PENDING` means the trigger was not yet
activated -- ignore it (do not wait for the corresponding real job).

### 1.3 Decide the overall state

From the non-ignored checks, compute:

- **all_done**: every non-ignored check is in a terminal state
  (`SUCCESS`, `FAILURE`, `ERROR`, `CANCELLED`, `SKIPPED`).
- **all_green**: all_done AND every non-ignored check has conclusion
  `SUCCESS` or `SKIPPED`.
- **any_red**: at least one non-ignored check has conclusion `FAILURE`,
  `ERROR`, or `CANCELLED`.

### 1.4 Branch on the state

**Not all done yet** -> log the pending checks and schedule the next poll in
180 seconds (3 minutes), passing the same skill prompt so the loop continues.

**All done and all green** -> proceed to Step 2 (assign reviewers).

**Any red** -> proceed to Step 3 (diagnose and fix).

---

## Step 2 -- assign reviewers and mark ready for review

```bash
gh pr edit <PR> --add-reviewer <reviewer1>,<reviewer2>,...
gh pr ready <PR>
```

Report to the user which reviewers were assigned and the PR URL. The loop
ends here -- do not reschedule.

---

## Step 3 -- diagnose a red check and fix it

### 3.1 Set up a worktree

All code fixes must happen in a git worktree so they do not disturb the
user's working tree.

Check whether a worktree already exists for the PR branch:

```bash
BRANCH=$(gh pr view <PR> --json headRefName -q '.headRefName')
git worktree list
```

If no worktree exists for that branch, create one next to the main repository
folder (never inside `.claude`):

```bash
WORKTREE_PATH="../monorepo-$BRANCH"
git worktree add "$WORKTREE_PATH" "$BRANCH"
```

After creating the worktree, copy the `.claude` configuration files into it
so the fix subagent has access to project guidelines and skills:

```bash
cp -r .claude/skills "$WORKTREE_PATH/.claude/"
cp .claude/CLAUDE.md "$WORKTREE_PATH/.claude/"
```

### 3.2 Collect failure context via CircleCI MCP

For each red check, extract the CircleCI job name from the check name
(GitHub check names for CircleCI jobs follow the pattern
`ci/circleci: <job-name>`).

Use the CircleCI MCP tools to fetch build logs:

- `mcp__circleci-mcp-server__get_build_failure_logs` with the job name and
  the branch name to retrieve the failure output.
- If the job name contains a workflow reference, use
  `mcp__circleci-mcp-server__get_latest_pipeline_status` to find the
  pipeline and then fetch per-job logs.

Gather enough context to understand what failed: compiler error, test
failure, lint violation, etc.

### 3.3 Boot a fix subagent in the worktree

Fork a subagent (using the Agent tool with `subagent_type: "fork"`) and
give it:
- The worktree path.
- The full failure logs.
- A directive to fix the issue, run the relevant tests locally to verify,
  then commit the fix (but NOT push).
- The project CLAUDE.md guidelines (do not mention the fix was made by an
  assistant, ASCII-only, etc.).

The subagent must:
1. Navigate to the worktree.
2. Identify the file(s) causing the failure from the logs.
3. Apply a targeted fix.
4. Run the minimal test command to confirm the fix compiles and passes.
5. Commit with a clear message (no "Co-Authored-By" lines, ASCII only).
6. **Not push**.

### 3.4 Report and stop

After the subagent commits, report the fix commit hash to the user, remind
them to push the branch, and stop the loop. The user will re-invoke the skill
once the fix is pushed and CI re-runs.

If the subagent cannot determine the root cause or the fix looks risky,
report the failure logs to the user and stop -- do not attempt a speculative
fix.

---

## CircleCI check naming reference

GitHub status check names for CircleCI jobs follow this convention:

```
ci/circleci: <job-name>
```

For example:
- `ci/circleci: build-backend` -- the job is `build-backend`
- `ci/circleci: run-backend-e2e-tests-against-postgres` -- job is
  `run-backend-e2e-tests-against-postgres`

When calling CircleCI MCP tools, use the bare job name (without the
`ci/circleci: ` prefix).

---

## Summary of rules

- **Never block on** `run-test-on-pull-request/*` checks.
- **Never block on** `bypass-*` checks.
- **Pending `trigger-*`** checks: ignore (trigger not activated).
- **Green `trigger-*`** checks: wait for the corresponding real job.
- **Do not push** any commits -- leave pushing to the user.
- **All fixes go in the worktree**, not the user's working tree.
- **Ask first** if PR number or reviewers are not in the original prompt.

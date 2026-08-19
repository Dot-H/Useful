---
name: get-query-plan
description: Retrieves a query plan JSON given a plan-viewer link (https://localhost:PORT/plan-viewer?queryId=...&queryPlanFilePath=...&namespace=...&queryFilePath=...) by calling ~/bin/get-query-plan.sh. Use when the user pastes a plan-viewer URL and wants to fetch or inspect the underlying query plan.
user_invocable: true
---

# get-query-plan

Fetches the query plan behind a Pigment plan-viewer link.

## Steps

1. From the plan-viewer URL provided by the user, extract these query-string parameters (URL-decode each one):
   - `queryId`
   - `queryPlanFilePath`
   - `namespace`

   The `queryFilePath` parameter is not needed and can be ignored.

   Example link:
   ```
   https://localhost:49378/plan-viewer?queryId=019fd929-98aa-7623-96ea-cdd7a4603ae7&queryPlanFilePath=query-plans/drqc/019fd929-793a-7c60-be0c-579eedfdae3f.json&namespace=production&queryFilePath=queries/drqc/019fd929-0f56-78bd-a6c2-0c15927c3f7b.json
   ```
   extracts:
   - `queryId` = `019fd929-98aa-7623-96ea-cdd7a4603ae7`
   - `queryPlanFilePath` = `query-plans/drqc/019fd929-793a-7c60-be0c-579eedfdae3f.json`
   - `namespace` = `production`

2. Run, using the Bash tool:
   ```bash
   ~/bin/get-query-plan.sh "<queryId>" "<queryPlanFilePath>" "<namespace>"
   ```

3. Report the resulting query plan JSON to the user (or summarize it, if asked to).

Requires the `PIGMENT_TOKEN` environment variable to be set; `~/bin/get-query-plan.sh` will error out if it isn't.

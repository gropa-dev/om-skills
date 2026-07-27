# State matrix — which chain a PR needs

Evaluate rows **top to bottom** against the PR State Report. A PR normally
matches several rows: run every matched row in this order, skipping any whose
exit condition already holds after the previous step. Re-read the cheap signals
(CI, review decision, mergeability) between steps — a step can change what is
left to do.

| # | State signal | Chain step | Exit condition |
|---|---|---|---|
| 0 | The PR is not open (merged or closed) | **stop** — report and exit | — |
| 0b | Active account is not the identity this repository's runs are made from (**current-user**) | **stop** — wrong identity, mutate nothing | — |
| 0c | A hard block is present: do-not-merge, blocked, or failed-QA | **stop** unless the user explicitly said to work through it; report the blocker | — |
| 1 | A plan exists with pending steps (`- [ ]`, or a Tasks row not `done`) | `om-auto-continue-pr {pr}` — or `om-auto-continue-pr-loop {pr}` when the tracking line names a **run folder** | all plan steps done |
| 2 | `plan: none` and the diff does not implement the linked issue | Record the gap as an assumption, continue with the merge-readiness rows, and state in the report that implementation completeness was judged from the diff alone | reported |
| 3 | Spec-only diff (only `$SPECS_DIR`, the config's `paths.specs`) | `om-auto-review-pr {pr}` (specification review). **Never** grow it into implementation — that ships on its own PR via `om-auto-implement-spec` | spec review submitted |
| 4 | Mergeability is conflicting or behind the base | `om-auto-fix-pr {pr}` (it merges the base **first**, before review or CI work) | mergeable |
| 5 | Review is none / required, or changes-requested, or unresolved conversations remain | On a PR you may drive: `om-auto-fix-pr {pr} --max-iterations <n>` (review + autofix + CI + UI in one loop). On **another author's** PR: `om-auto-review-pr {pr}` only — review and hand off, no autofix, unless the user explicitly asked for it | approvable, no unresolved blocking conversations |
| 6 | CI red, everything else already fine | `om-auto-fix-pr {pr} --ci-only` | all required checks green |
| 7 | The diff is UI-touching and no QA evidence exists (QA required, no approval and no evidence) | `om-auto-qa-pr {pr}` — capture screenshots and a pass/fail report | evidence attached, or a documented reason UI QA cannot run |
| 8 | Review findings intentionally not fixed (nits, low severity, out of scope) | `om-followup-issue-from-pr` per finding, idempotently | each finding tracked |
| 9 | Approvable + green + QA satisfied | **default: stop at merge-ready** and report. With `--allow-merge`: `om-approve-merge-pr {pr}` | reported / merged |
| 10 | Merge-ready but the QA gate is unmet (QA required, not approved) | **stop** — request QA sign-off in the summary comment; never self-apply the QA approval label without real self-QA evidence | reported |

## Notes that change the chain

- **Fork PRs — split on `PUSHABLE`, not on `IS_FORK`.** Whether the head branch
  lives in a fork says nothing on its own about push access, because
  contributors commonly work from their own fork:
  - `PUSHABLE` (same repo, or your own fork): drive it normally — base merges
    and follow-up commits go to the PR's own head branch. Never route it into
    the carry-forward flow; that would abandon the branch and open a duplicate
    PR crediting its own author.
  - Not `PUSHABLE` (someone else's fork): you cannot push to the contributor's
    branch. Do not force a base merge — `om-auto-fix-pr` hands that to
    `om-auto-review-pr`'s fork carry-forward flow, which opens a credited
    replacement PR reassigned to the original author. From then on `{prNumber}`
    means the replacement.
- **Draft PR:** diagnose and fix normally; promotion to ready happens inside
  `om-auto-fix-pr`'s merge-prep step, not here. A spec-only design PR and any PR
  carrying a `⚠ NEEDS HUMAN CONFIRMATION` guard stay draft.
- **Rows 1 and 5 both matched:** finish the implementation first. Reviewing an
  unfinished PR burns a review cycle on code that is about to change.
- **`om-auto-fix-pr` already contains** review + CI + UI QA + follow-ups. When
  row 5 runs it, rows 6–8 are usually satisfied by it — re-diagnose and skip
  them rather than running them twice.
- **Self-QA exception (rows 7 and 10):** permitted only after actually running
  the branch and exercising the flow, with the evidence attached to the PR. Only
  then do the QA approval and self-verified labels go on — never one without the
  evidence.

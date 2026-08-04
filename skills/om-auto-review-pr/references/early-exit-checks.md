# Early-exit checks (conflicts and CI)

Detailed procedure for step 4 of `om-auto-review-pr`. Run these checks before the worktree is created. If either fails, skip the full code review and go straight to the changes-requested flow.

## 4a. Check for merge conflicts

Run the tracker operation **get-pr** for `{prNumber}`, requesting `mergeable`, `mergeStateStatus`, and `baseRefName`.

If `mergeable` is `CONFLICTING` or `mergeStateStatus` is `DIRTY`, what happens next depends on `AUTOFIX_ELIGIBLE` (step 2). On a pure review pass: do not continue with checkout or review execution — submit a changes-requested review with a conflict-focused body, set the pipeline label to `changes-requested` (which also removes `merge-queue`), and stop the pass. On an autofix-eligible pass: resolve first, review after, per the second bullet below.

Important:

- On a **pure review pass** (`AUTOFIX_ELIGIBLE` false — another author's PR without `--autofix`), conflicts are still an early stop: this run may not touch the branch, so the honest outcome is a conflict-focused changes-requested review and a handoff.
- On an **autofix-eligible pass**, conflicts are **the first work item, not an early stop and not a deferral**. Skip the early exit, create the worktree (step 5), and resolve the conflicts against the latest base *before any review work* — before the duplicate check, the diff scan, `om-code-review`, the tests, and certainly before CI — then resume the review at step 6 on the resolved branch. A conflicted branch makes every downstream signal unreliable: the diff under review is not the diff that will merge, so a review or a CI result read off it measures the wrong thing. Conflicts that appear later (the base advances mid-run) are handled the same way, at the head of the step 11 loop. Fork heads resolve on the carry-forward branch instead (`references/fork-pr-flow.md`).

## 4b. Check CI status

Discover required checks first: run the tracker operation **get-required-checks** for the PR's base branch (`{baseRefName}`). If branch protection is not readable (the operation reports 404/no data), treat all reported PR checks as required.

Fetch the actual PR check results with the tracker operation **get-pr-checks** for `{prNumber}`, requesting each check's `name`, `state`, and `link`.

Treat these states as failing: `FAILURE`, `ERROR`, `CANCELLED`, `TIMED_OUT`. Ignore these as non-failing: `PENDING`, `SUCCESS`, `SKIPPED`, `NEUTRAL`.

If any required check is **failing**, do not continue with checkout or review execution. Submit a changes-requested review listing only the failing required checks, set the pipeline label to `changes-requested` (which also removes `merge-queue`), and stop. A check the run can already see red is real evidence and drives the verdict exactly as before.

**Pending is not failing, and pending never delays the review.** A required check still queued or running is not a reason to wait, and never a reason to hold back the verdict, the labels, or the review body. Review the code that is in front of you, submit, label, and report — then let `references/ci-followup.md` handle the CI outcome afterwards. Record which required checks were pending at review time, in `PENDING_CHECKS`, so step 10 can disclose them in the review body and the follow-up knows what it is waiting on. Waiting for green before reporting is the failure this skill must not reproduce: a monitoring process that dies mid-wait leaves a PR with no labels, no review, and no record that any work happened.

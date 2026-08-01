# New skill: om-pipeline-retro — classify finished runs and rank what second passes cost

## Goal

Give any repository running this collection a read-only answer to one question it cannot answer today: how often did the pipeline carry a change to merge in a single pass, and what stopped it the rest of the time? The collection has no skill that reads its own history; every harness change therefore ships on argument rather than on a measured before and after.

## Scope

- `skills/om-pipeline-retro/SKILL.md` — the new interactive skill: enumerate finished runs, gather per-run evidence, classify deterministically, report, offer a handoff.
- `skills/om-pipeline-retro/references/classify-runs.sh` — the deterministic classifier. Reads the assembled tracker data on stdin, writes the classification on stdout, contacts nothing.
- `skills/om-pipeline-retro/references/agentic-setup.md`, `references/rules.md` — own copies of the standard step files, shared parts byte-identical to the canonical text, with this skill's specifics appended.
- `skills/om-pipeline-retro/references/report-templates.md` — the report shapes, kept out of the body so an unused table costs no tokens.
- `skills/om-setup-agent-pipeline/references/skill-coverage.md` — roster entry, so a missing install is distinguishable from an unrelated token.
- `docs/skills/om-pipeline-retro.md`, `docs/skills/README.md`, `README.md` — the documentation card and the two index rows.

## Non-goals

- No change to any existing skill's behaviour, templates, or contracts. This is additive: one new directory plus a roster line and three documentation rows.
- No new tracker operation. The skill composes **list-prs** and **get-pr**, both already in the descriptor contract, so every provider that implements the contract supports it unchanged.
- No new config key. Window and limit are arguments, not settings.
- No write path of any kind. Filing an issue is a handoff to `om-prepare-issue`, gated on the user.

## Evidence (verified, not assumed)

The classifier was written against a real corpus before it was written into a skill: 416 pull requests and 1749 branch commits from a public repository that runs this collection, of which 198 carry agent run markers.

```
clean single pass          131   median 1.9h to merge   p90  22.8h
hard recovery               45   median 19.1h           p90 102.7h
loop checkpoints (design)    2   median 4.9h            p90   6.8h
second pass, no cause        20   median 9.4h           p90  22.5h

hard recovery by change size:  9% under +200 added lines
                              14% at 200-600
                              49% above +600
```

Two findings came straight out of that corpus without any change to the collection, which is the argument for the skill existing at all: the reviewing step could not record a formal verdict on 82 of 243 marker-carrying requests (in 71 of them no formal approval exists at all, so the verdict lives only as a comment), and base movement is the most common stated recovery cause, appearing in 32 requests and in 17 of the 45 hard recoveries.

The shipped `classify-runs.sh` reproduces those class counts, size buckets, and cause ranking exactly, which is how it was checked: a reference implementation and the shipped one must agree on the same input before either is trusted.

## Design decisions

- **Bash and `jq`, not Python.** The collection requires POSIX-ish portable shell in skills and states outright never to assume `python3` exists, while `jq` is already a prerequisite of the tracker descriptor. A Python reference implementation was written first for validation and is not shipped.
- **The script lives under `references/`.** That is the only location the reference-resolution gate verifies, so a broken pointer fails CI instead of failing at runtime in a user's repository. No skill in the collection ships an executable today; this is a new pattern, which is why the body also states the inline fallback and the file carries its rules in a comment header.
- **No `## Chaining` section and no chaining reference lines.** The contract binds that section on `om-auto-*` skills. More importantly the report is about requests this run did not create, so a line-anchored `PR:` line would be read by a chained consumer as this run's subject. Requests are linked inline instead.
- **Second pass is not failure.** Loop-mode checkpoints are classified separately rather than counted as rework, and a run whose record states no reason is reported as unexplained rather than guessed at. On the validation corpus those two distinctions moved 22 requests out of the rework bucket.

## Risks

- **Cost.** Classification needs one **get-pr** call per finished run; there is no bulk operation carrying comments and individual reviews together. Mitigated by a `--limit` default of 30 and a report header that states the window and the count actually examined.
- **Timestamp coverage.** Run clustering needs comment timestamps. Where a provider omits them the classifier degrades to counting marker comments, which is an upper bound, and says so in `timestampCoverage`; the report header repeats it.
- **Marker dependence.** A repository whose skills post no marker comments cannot be classified. The empty-result line says exactly that rather than reporting a misleading zero.

## Progress

> Convention: `- [ ]` pending, `- [x]` done. Append ` — <commit sha>` when a step lands. Do not rename step titles.

### Phase 1: The skill

- [x] 1.1 Classifier validated against a 416-request corpus, reproducing an independent reference implementation
- [x] 1.2 `SKILL.md`, the three reference files, and the documentation card
- [x] 1.3 Roster entry and the two index rows
- [x] 1.4 `bash scripts/lint.sh` and `node scripts/test-browser-providers.mjs` both green

### Phase 2: Review and land

- [ ] 2.1 Open the pull request against the collection's base branch
- [ ] 2.2 Address review; confirm the additive-only scope holds

### Phase 3: What the report itself asks for next

- [ ] 3.1 A machine-readable `Outcome:` line in the run-summary block of the PR-driving skills. On the validation corpus 20 of 67 second passes state no reason anywhere; the classifier already reads such a line where it exists, so the unexplained count is the measurement that would show the change working.
- [ ] 3.2 Runner identity on commits, so a repository running several agents can tell which one produced a change. Today only one runner signs its work, which is why the skill classifies runs rather than actors.

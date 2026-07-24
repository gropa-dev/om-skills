# Output Contracts

Select the smallest contract that answers the user's decision. Omit empty or irrelevant sections.

## Shape

Lead with the chosen direction.

1. **Recommendation** — one concrete direction and the decisive trade-off;
2. **Problem and evidence** — actor, situation, job, friction, known evidence, assumptions;
3. **Outcomes** — user outcome, behavioral signal, business effect, guardrail;
4. **Current → future** — concise change in behavior or workflow;
5. **Scope** — now, later, and not doing;
6. **Interaction** — primary flow, key states, recovery, accessibility;
7. **AI contract** — include only when AI is involved;
8. **Validation** — riskiest belief, smallest test, success/failure decision;
9. **Delivery notes** — add only when implementation follows;
10. **Open decisions** — only questions that can materially alter the direction.

For a small request, compress this to recommendation, assumptions, flow, scope, and next test.

## Review

Lead with a verdict: keep, simplify, rethink, or stop.

1. **What works** — mechanisms that clearly support the outcome;
2. **Value gaps** — elements not connected to a user or business outcome;
3. **Complexity hotspots** — unnecessary choices, steps, concepts, or states;
4. **Risk gaps** — missing evidence, recovery, feasibility, viability, accessibility, or AI safeguards;
5. **Recommended simplification** — prioritized changes with reasons;
6. **Revised primary flow** — the smallest coherent alternative;
7. **Next test** — the decision to de-risk first.

Do not provide vague taste-based criticism. Tie every issue to behavior, evidence, risk, or outcome.

## Handoff

Use implementation language:

1. **Feature intent and non-goals**;
2. **Primary actor, job, and trigger**;
3. **Flow and functional behavior**;
4. **UI hierarchy or component responsibilities**;
5. **State table** with trigger, system behavior, user options, and recovery;
6. **AI contract**, when relevant;
7. **Data, API, permission, latency, and persistence assumptions**;
8. **Content and accessibility requirements**;
9. **Analytics events and outcome metrics**;
10. **Acceptance criteria** in verifiable Given/When/Then form;
11. **Open decisions and owners**, if known.

Separate product behavior from implementation suggestions. Mark technical assumptions that require engineering confirmation.

## Writing rules

- Lead with the decision, not the framework.
- The framework's vocabulary is for the AUTHOR, never the reader: section
  names like evidence ledger, value gaps, complexity hotspots, behavioral
  signal or guardrail must not appear in the delivered text. Render each as
  a plain statement about screens, behavior and what to change — a designer
  or PM reading the result should never need this skill to understand it.
- The report obeys the same house copy rules it enforces: before delivering,
  check the result against the manual section of the repo's conventions (and
  any team copy rules the user has stated) — a report that flags an em-dash
  or separator violation while using it itself is invalid.
- Write for the named audience (designer, PM, engineer) in their working
  language; when unsure, default to how a senior designer explains a change
  to a colleague.
- Prefer one strong recommendation over many equally weighted ideas.
- Use diagrams or tables only when relationships or states become clearer.
- Describe what the user sees and can do, not only what the system contains.
- Keep labels and example copy concrete and consistent with the user's language.
- State exclusions explicitly when they protect focus.
- Avoid generic personas, fictional quotes, inflated certainty, and unsupported ROI.


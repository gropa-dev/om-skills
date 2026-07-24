# Quality Rubric

Apply this rubric internally before finalizing. Do not print the score unless the user asks for an audit.

Score each item:

- **0:** absent or contradicted;
- **1:** present but vague, assumed, or incomplete;
- **2:** concrete, coherent, and supported.

## Decision quality

1. The diagnosis names a consequential obstacle rather than restating the feature.
2. Facts, inferences, assumptions, and unknowns are distinguishable.
3. One primary user outcome and one behavioral signal are clear.
4. The business effect follows plausibly from the user outcome.
5. The recommendation makes a real choice and explains the decisive trade-off.

## Product quality

6. The scope completes one real job end to end.
7. Every major UI element supports an action, decision, status, explanation, or recovery.
8. Relevant product risks are addressed in proportion to consequence.
9. The riskiest belief has a decision-changing test.
10. Success, failure, and guardrails are measurable.

## AI quality, when applicable

11. AI adds unique value over a simpler alternative.
12. Automation versus augmentation matches stakes and responsibility.
13. Capability, limitations, data use, and uncertainty are understandable.
14. The user can correct, reject, undo, or bypass AI where needed.
15. Likely errors have detection and recovery paths.

## Critical gates

Do not finalize with a zero in:

- diagnosis;
- user outcome;
- coherent scope;
- AI necessity, when AI is involved;
- control and failure recovery for consequential AI actions.

Revise any result that:

- begins with screens before explaining the problem;
- treats a requested feature as proof of demand;
- offers many options without recommending one;
- calls a collection of ideas an MVP;
- uses adoption as the only outcome;
- presents assumptions as research;
- adds chat, dashboards, settings, or personalization without a job;
- designs only the happy path;
- claims that AI is trustworthy without giving users a way to judge or correct it.

## Final compression pass

Before delivering, ask:

1. What can be removed without weakening the decision?
2. Which sentence is abstract where observable behavior would be clearer?
3. Which assumption most needs a label?
4. Does the output help the next person act without inventing missing product behavior?


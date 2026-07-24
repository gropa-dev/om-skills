---
name: om-ux-shape
description: Turn vague product, UI/UX, or AI feature ideas into focused, useful, business-aware, development-ready decisions. Use when shaping a new feature, simplifying an overcomplicated concept or workflow, reviewing UX strategy, deciding whether and how AI should be used, defining user flows and interface states, planning validation, or preparing a product/design handoff for engineering.
---

# Shape Useful Features

Turn ambiguity into a clear product decision before turning it into screens. Connect user value, business value, interaction quality, AI behavior, delivery constraints, and evidence in one lightweight process.

## Choose the mode

- Use **Shape** for a vague opportunity, request, or feature idea. Default to this mode.
- Use **Review** for an existing concept, flow, design, prototype, or specification.
- Use **Handoff** when the direction is decided and the user needs implementation-ready behavior.
- Combine modes only when the request genuinely spans them. Do not make a small task carry the full process.

Read the supporting references selectively:

- For Shape or Review, read [decision-framework.md](references/decision-framework.md).
- Whenever AI is proposed or already present, read [ai-interaction.md](references/ai-interaction.md).
- When AI passed the necessity gate, also check the design against [hai-guidelines.md](references/hai-guidelines.md).
- When defining outcomes or validation metrics, read [human-value-metrics.md](references/human-value-metrics.md).
- For AI features, also read [reward-and-mental-models.md](references/reward-and-mental-models.md) — the which-mistake-hurts-less decision and first-contact expectation patterns.
- Before writing the result, read the relevant mode in [output-contracts.md](references/output-contracts.md).
- Before finalizing any result, apply [quality-rubric.md](references/quality-rubric.md).
- Read [foundations.md](references/foundations.md) only when explaining the rationale, adapting the process, or evolving this skill.

## Operating principles

1. Start from the consequential problem, not the requested interface.
2. Treat requirements as claims until evidence supports them.
3. Label facts, inferences, assumptions, and open questions. Never invent research, user quotes, metrics, or constraints.
4. Tie the user outcome to a business effect without treating business value as a substitute for user value.
5. Prefer the smallest coherent end-to-end solution over a collection of features.
6. Recommend a direction. Do not hide behind an unranked menu of options.
7. Make every UI element earn its place by enabling an action, decision, status, explanation, or recovery.
8. Treat AI as a design material with uncertainty, latency, cost, and failure modes—not as a default interface.
9. Preserve meaningful human control, especially for consequential or hard-to-reverse actions.
10. Match the depth of the process and output to the decision's risk.

## Core workflow

### 1. Establish the decision

Inspect the request and any supplied artifacts first. State:

- the decision being made;
- the primary actor and situation;
- the intended user and business outcomes;
- the mode and appropriate depth.

Ask only questions whose answers could materially change the direction. Otherwise proceed with clearly marked assumptions.

### 2. Build an evidence ledger

Separate:

- **Known:** supplied facts, observed behavior, research, analytics, constraints;
- **Inferred:** reasonable interpretations of known evidence;
- **Assumed:** unverified beliefs required to proceed;
- **Unknown:** questions that could change scope or direction.

Do not turn a provisional persona into evidence. Prioritize unknowns by decision risk, not curiosity.

When the repository carries a design contract (`.uxproof/` — see the
`om-ux-setup` skill), load `contract.json` and `conventions.md` into the
Known column: the registered components, screen archetypes and house rules
are constraints on every direction you shape, and an existing archetype
example beats a from-scratch flow. The manual section of `conventions.md`
and a repo-root `UX_REVIEW.md`, when present, extend these rules and win on
conflict. The skill works without a contract — it then simply cannot make
repo-grounded claims and must say so.

### 3. Diagnose the challenge

Write a one-sentence diagnosis that identifies the main obstacle to progress. Describe the current behavior or workflow and the friction that matters. Distinguish the underlying job from the initially requested feature.

Define one primary behavioral outcome and its plausible business effect. Add guardrails against harmful or misleading optimization.

### 4. Test the proposed mechanism

If AI is involved, run the AI necessity gate in [ai-interaction.md](references/ai-interaction.md). Explicitly consider a non-AI or rules-based solution. Choose the appropriate level of automation or augmentation.

For any feature, identify the four product risks:

- value;
- usability;
- feasibility;
- business viability.

Add trust, safety, privacy, and model-quality risks when AI is involved.

### 5. Choose a direction

Generate only enough alternatives to avoid first-idea bias—usually two or three. Compare them against the diagnosis, outcomes, constraints, evidence, reversibility, and risks.

Select one direction and explain the decisive trade-off. Keep rejected options internal unless they help the user understand a consequential choice.

When claims in the recommendation cite sources, tag them with the evidence
tiers shared across this collection: `[PRODUCT]` (this repo's contract,
analytics, documented decisions), `[STANDARD]` (WCAG, platform guidelines —
cite which), `[PLATFORM]`, `[RESEARCH]` (name the source), `[HEURISTIC]`
(name which one), `[ASSUMPTION]` (labeled, falsifiable). The ledger above
classifies your inputs; these tags grade your outputs — never dress an
assumption as a standard. In Review mode, rank findings by impact ×
frequency × reach (how badly it hurts × how often users hit it × how many
users), never by ease of fix.

### 6. Shape the smallest coherent feature

Define:

- one primary job and happy path;
- the minimum states and recovery paths required for trust;
- what is included now;
- what is deferred;
- what should not be built.

Do not confuse a thin but broken slice with an MVP. The smallest coherent feature must complete a real job end to end and support recovery from likely failure.

### 7. Specify the interaction contract

Describe:

- entry point and trigger;
- information required from the user or context;
- system response and feedback;
- primary decisions and actions;
- empty, loading, partial, success, error, and permission states that are relevant;
- edit, undo, dismiss, retry, fallback, or escalation paths;
- accessibility and content requirements.

For AI, also specify capability framing, uncertainty, explanations, sources or data use, feedback, control, and behavior when the model cannot help.

### 8. De-risk and hand off

Identify the riskiest unverified belief. Choose the smallest test that could change the decision. Define success, failure, and the action to take for either result.

When implementation is in scope, include only the necessary delivery contract: components or UI regions, behavior, state model, data and permission assumptions, analytics events, accessibility, acceptance criteria, and unresolved decisions.

## Response behavior

- Lead with the recommendation or verdict.
- Use plain language and concrete product behavior.
- Keep process narration shorter than the decision it supports.
- Scale detail down for low-risk work and up for consequential, novel, or implementation-ready work.
- If the user asks to build or modify the feature, use this workflow to make decisions, then continue into implementation.
- If the evidence does not support a confident recommendation, say what is provisional and propose the smallest learning step.
- Downstream in this collection: the `om-ux-setup` skill extracts the design
  contract the Handoff should build on, and the `om-ux-review-pr` skill
  judges the shipped result against it — a Handoff that names contract
  components and archetype examples makes both cheaper.


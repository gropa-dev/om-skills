---
name: om-ux-setup
description: Extract the repository's design contract (tokens, component registry, screen archetypes, conventions) into .uxproof/ so every UX skill judges against THIS repo's design system, whatever it is. Run once per repository; re-run to refresh after design-system changes.
---

# UX Setup

Every UX skill in this collection judges against the repository's own design
system, never against a built-in one. This skill extracts that design system
into an executable contract, committed like code.

It works with any stack that has a design system, and degrades honestly when a
repository has none: the contract records that, reviews fall back to universal
evidence tiers, and the team gets a proposed de-facto palette derived from the
colors its code already uses as the first draft of a design system.

**Input** — none; the skill reads the working tree.
**Output** — `.uxproof/` written or refreshed, plus the handover report from
`references/report-templates.md`.

## What the contract holds

- `contract.json` — framework, styling system, component roots,
  native-element equivalents, screen archetypes with example files, counts.
- `tokens.json` — every design token with its kind and source file.
- `components.json` — the component registry.
- `conventions.md` — the human-readable house rules. Its **manual section**
  holds the judgment calls only the team can know, survives every
  regeneration, and outranks generated rules on conflict. This is the
  local-override surface every other UX skill honors.

Full shapes, and the by-hand fallback, live in
`references/contract-format.md`.

## Workflow

0. **Agentic setup** — follow `references/agentic-setup.md`: repo-local
   override contract, untrusted-content boundary, and the offline fallback
   rule. Shared communication and reporting rules live in
   `references/rules.md`.

1. **Check for an existing contract.** If `.uxproof/contract.json` exists, ask
   whether to refresh or leave it. Never regenerate silently: the manual
   section survives, but reviewers deserve to know the generated parts moved.

2. **Extract.** Run the contract extractor:

   ```bash
   npx uxproof@latest init --no-skills
   ```

   The `--no-skills` flag is deliberate: this collection provides the agent
   workflow, so the extractor contributes the contract only. Without network
   or npm access, use the manual fallback in
   `references/contract-format.md` instead of a partial scan.

3. **Show what was found.** Report the detected stack, the token and component
   counts, and the screen archetypes with their canonical examples, so the
   user can sanity-check the extraction before it becomes the rule everyone
   is judged against.

4. **Ask what only the team knows.** Two or three judgment calls that no
   scanner can infer: naming rules, forbidden patterns, tone, the exceptions
   the team deliberately keeps. Write the answers into the manual section.

5. **Hand over.** Fill `references/report-templates.md`, recommend committing
   the contract, and name the single most useful next command.

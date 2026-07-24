# Report template — UX review comment

Post the review as ONE PR comment in exactly this structure. Full sentences,
no fragments; the report is the reviewer-facing deliverable, not an internal
analysis.

```markdown
## 🎨 UX review — <PR title>

**Contract**: <.uxproof/ found: framework, N tokens, N components | no contract — reviewed against tiers 2-6 only>
**Screens walked**: <list, with viewport(s)>
**Not walked**: <screens skipped and why — missing data, no permissions, broken env; never omit this line when coverage is partial>

### Findings (worst first)

#### 1. <one-line finding title>  `<EVIDENCE-TAG>`
- **Where**: <screen / element, screenshot ref>
- **Evidence**: <the tagged claim — cite the contract rule, standard, or name the heuristic; label assumptions as assumptions>
- **Pattern**: <what the fix looks like — point at an existing screen in this repo that already does it right when one exists>
- **Trade-off**: <what the fix costs>
- **Accept when**: <criterion someone else can verify>

#### 2. …

### Summary

- **Strong**: <one sentence>
- **Must change**: <one sentence — the findings that clear the impact bar>
- **Opinion**: <one sentence — what above is assumption-tier and safe to overrule>

_Advisory review: findings are input for the author, not a merge gate._
```

Rules:

- Rank by impact × frequency × reach, never by ease of fix.
- Maximum ~7 findings; fold the tail into a single "minor notes" line.
- Attach every screenshot a finding references.
- When the review ran without a contract, say so in the Contract line and do
  not emit `[PRODUCT]` findings.

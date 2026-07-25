# Report templates

Select the smallest shape that answers the user's decision and omit sections
that would be empty. Structure headings with the glossary emojis; the result
is a deliverable, not a log.

## Shape mode

Lead with the chosen direction.

```markdown
## 🎯 Recommendation

<One concrete direction and the decisive trade-off, in two or three sentences.>

### 📝 Problem and evidence

<Actor, situation, job, friction. What is known, what is assumed (labeled).>

### 🎯 Outcomes

<The user outcome, the observable signal that it happened, the business
effect that follows, and the guardrail that must not degrade.>

### 📋 Scope

**Now**: <what completes one real job end to end>
**Later**: <plausible value, not needed for this decision>
**Not doing**: <what conflicts with focus, evidence, safety, or economics>

### 📋 How it works

<Entry point, the primary flow, the states that must exist for trust
(empty, loading, error, permission), and the recovery paths.>

### 🤖 AI contract

<Only when AI is involved: what it does, the quality bar, the mistake it
prefers and why, what the user can correct or undo, what remains possible
when it is unavailable.>

### 🧪 Validation

<The riskiest belief, the smallest test that could change the decision, and
what each result would mean.>

### ⚠️ Open decisions

<Only questions that could still change the direction.>
```

For a small request, compress to recommendation, assumptions, flow, scope,
and next test.

## Review mode

Lead with a verdict: keep, simplify, rethink, or stop.

```markdown
## 🔍 Verdict: <keep | simplify | rethink | stop>

<One paragraph: what the product is doing well and what the core problem is.>

### ✅ What works

<Mechanisms that clearly serve the outcome and should become the reference
for the rest.>

### 🔍 What to change (worst first)

<Each item: where it hurts, the evidence tag, what to do instead, what the
fix costs, and how to tell it worked.>

### 📋 The simpler flow

<The smallest coherent alternative, described as screens and steps.>

### 🧪 Next test

<The decision to de-risk first, and the cheapest way to do it.>

### ⚠️ Not covered

<What was not examined and why: missing data, no access, out of scope.>
```

## Handoff mode

Implementation language, for the skill or person who builds it.

```markdown
## 📝 <Feature> — handoff

**Intent**: <what it does> **Non-goals**: <what it deliberately does not do>
**Actor and trigger**: <who, from where>

### 📋 Behavior

<The flow, step by step, with the decisions the user makes.>

### 📋 States

| State | Trigger | What the user sees | What they can do |
|---|---|---|---|
| <empty, loading, error, permission, success> | | | |

### 🤖 AI contract

<Only when AI is involved.>

### 📋 Assumptions to confirm

<Data, API, permission, latency, and persistence assumptions that need
engineering confirmation, marked as assumptions.>

### ✅ Acceptance criteria

<Given / When / Then, verifiable by someone who did not write them.>

### ⚠️ Open decisions

<With owners where known.>
```

## Writing rules

- Lead with the decision, not the framework.
- The framework's vocabulary is for the author, never the reader: names like
  evidence ledger, value gaps, complexity hotspots, behavioral signal, or
  guardrail must not appear in the delivered text. Render each as a plain
  statement about screens, behavior, and what to change.
- Write for the named audience (designer, product manager, engineer) in their
  working language; when unsure, default to how a senior designer explains a
  change to a colleague.
- The result obeys the same house copy rules it enforces: check it against the
  manual section of the design contract and any team rules the user stated.
- Prefer one strong recommendation over several equally weighted ideas.
- Use tables or diagrams only when they make relationships clearer.
- Describe what the user sees and can do, not only what the system contains.
- State exclusions explicitly when they protect focus.
- Avoid generic personas, fictional quotes, inflated certainty, and
  unsupported return-on-investment claims.

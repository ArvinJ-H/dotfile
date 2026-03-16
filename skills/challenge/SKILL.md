---
name: challenge
description: >
  Lightweight adversarial + divergent review of any deliverable. Two lenses: find flaws
  in what's proposed, find paths that weren't considered. TRIGGER: "poke holes", "challenge
  this", "what's wrong with", "what if", "how about", review before committing to an approach.
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion, ToolSearch
provides:
  - adversarial-review
  - divergent-analysis
scope-boundary:
  - external-research
  - codebase-investigation
---

Quick adversarial + divergent review of any deliverable. ~2 minutes, not 15. Both lenses by default.

## Invocation

- `/challenge [thing]` — full pass (both lenses)
- `/challenge --quick [thing]` — adversarial only, skip divergent

## Input Normalization

Classify the input before decomposition. The input type determines the attack surface mapping:

| Input type | Detection | Decomposition approach |
|-----------|-----------|----------------------|
| **Plan/design** | References phases, steps, files to modify | Component-by-component: each phase/step is an attack surface |
| **Code diff** | File paths, +/- lines, function signatures | Change-by-change: each modification is an attack surface |
| **Freeform idea** | No structure, conversational | Assumption extraction: what must be true for this to work? |
| **Architecture** | System boundaries, data flow, dependencies | Interface-by-interface: each boundary is an attack surface |

State the detected type before proceeding. If ambiguous, ask.

## Decomposition

Prefer `mcp__sequential-thinking__sequentialthinking` when available (use ToolSearch to check). Fall back to structured self-reasoning if the MCP tool is unavailable or errors:

1. **Assumption inventory** — list everything that must be true for this to work
2. **Attack surface mapping** — using the input-type-specific approach above
3. **Lens application** — run both lenses against each attack surface

The skill works without the MCP tool. Sequential thinking is preferred, not required.

## Lenses

Always run both lenses unless `--quick` was specified.

### Adversarial — "What's wrong with this?"

For each attack surface, check:
- **Unstated assumptions** — what's taken for granted that could be false?
- **Missing error paths** — what happens when this fails?
- **Coupling introduced** — does this create dependencies that shouldn't exist?
- **Scope creep** — does this solve more than what was asked?
- **Irreversibility** — what can't be undone?

### Divergent — "What else could be true?"

Structured exploration, not brainstorming. Three techniques:

1. **Constraint removal** — systematically remove one constraint at a time, see what opens up. This is the core technique. For each major constraint: "If we didn't have to [constraint], what would change?"
2. **Perspective shift** — "How does this look to someone maintaining it in 6 months?" / "What does the user see if this fails?" / "How would a different team approach this?"
3. **Adjacent alternatives** — approaches in the same solution space that weren't considered. Not wild ideas — plausible paths that share the same goals but differ in approach.

## Verifier Escalation

/challenge does its own decomposition and analysis. The verifier agent is NOT the default engine.

Spawn verifier (`subagent_type: "verifier"`) only when the adversarial pass surfaces something that needs deeper validation against source code — e.g., "this assumption about the API contract might be wrong" → verifier reads the actual code to confirm or deny.

## Scope Boundary with /plan Phase 4

When the input is a plan that has an Audit Trail section:
1. Read the audit findings
2. Focus adversarial lens on what the audit **didn't** cover
3. Always run the divergent lens (which /plan Phase 4 never provides)

This avoids double-coverage. If there's no audit trail, run the full adversarial pass.

## Output

### Chat output (always)

Ranked findings per lens, each with:
- **Finding title** with severity
- **What**: the blind spot or flaw
- **Why it matters**: impact if unaddressed
- **Check**: what to verify or consider

### File output (5+ total findings)

Write to `~/.claude/challenge/{slug}.md`:

```markdown
# Challenge: {deliverable title}

**Date**: YYYY-MM-DD | **Input type**: {plan|diff|idea|architecture}
**Lenses**: {adversarial + divergent | adversarial only}

## Adversarial Findings

### [Critical/Important/Minor] {Finding title}
**What**: {the blind spot or flaw}
**Why it matters**: {impact if unaddressed}
**Check**: {what to verify or consider}

## Divergent Findings

### {Finding title}
**Constraint removed**: {what assumption was relaxed}
**What opens up**: {alternative path or perspective}
**Worth exploring?**: {yes — because... | maybe — if... | no — because...}

## Synthesis

{Which findings, if any, should change the approach?}
```

### Severity levels

- **Critical** — changes the approach. The deliverable has a fundamental flaw.
- **Important** — worth addressing before proceeding. Not fatal but consequential.
- **Minor** — note for awareness. Won't block progress but worth knowing.

## Steps

1. **Classify input** — detect type per the normalization table. State it.
2. **Check for prior audit** — if input is a plan with Audit Trail, read it and scope accordingly.
3. **Decompose** — use sequential thinking or structured self-reasoning to map attack surfaces.
4. **Adversarial pass** — apply adversarial lens to each attack surface.
5. **Divergent pass** (skip if `--quick`) — apply divergent techniques to the deliverable as a whole.
6. **Rank and output** — sort findings by severity, present in chat.
7. **File output** — if 5+ total findings, write to `~/.claude/challenge/{slug}.md`.
8. **Escalate** (conditional) — if adversarial pass surfaced a claim that needs code verification, spawn verifier.

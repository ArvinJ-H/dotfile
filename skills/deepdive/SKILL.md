---
name: deepdive
description: Deep research and investigation using sequential thinking, subagents, and agent teams. Auto-triggers on complex questions or runs manually via /deepdive.
allowed-tools: Read, Glob, Grep, Edit, Write, WebSearch, WebFetch, Task, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, ToolSearch, AskUserQuestion
provides:
  - codebase-investigation
scope-boundary:
  - external-research
---

Conduct a deep investigation on a topic, question, or problem.

**Scope boundary: `external-research`** — find providers via capability tags in other skills' frontmatter. If a question spans both internal and external, /deepdive handles the codebase component.

## When to auto-trigger

Run deepdive autonomously (without /deepdive) when ALL of these are true:
- The question involves 3+ interconnected components (systems, files, concepts, or domains)
- Initial exploration raises more questions than it answers
- Existing skills and research don't cover the topic
- The user's energy suggests exploration, not urgent debugging

## Invocation Modes

### Explicit (`/deepdive [flags] topic`)

User has decided to investigate. Respect the decision.

- `/deepdive topic` — ask depth preference before starting (see below)
- `/deepdive --quick topic` — Tier 1 only, no escalation
- `/deepdive --deep topic` — all tiers, escalate aggressively (any scorecard field > 0 triggers Tier 2, any Tier 2 tension triggers Tier 3), no checkpoints

**Depth selection** (when no flag is provided): Use AskUserQuestion after topic is identified:

| Option | Behavior |
|--------|----------|
| **Quick** | Tier 1 only — structured thinking, report findings |
| **Standard** (Recommended) | Tier 1, ask before escalating to Tier 2 or Tier 3 |
| **Deep** | All tiers, escalate aggressively, no checkpoints |

### Auto-trigger

Claude detected complexity. Be cost-conservative:
- Always start Tier 1
- Scorecard thresholds apply strictly (no soft matches)
- If Tier 1 scorecard doesn't trigger, report findings + scorecard to user. They can `/deepdive --deep` to override.

## Research workspace

Deepdive writes to the shared investigations workspace:

```
~/.claude/investigations/<area>/{topic-slug}/
  README.md              — final synthesized deliverable
  tier-1-survey.md       — Tier 1 findings + escalation scorecard
  sub-{question-slug}.md — Tier 2 subagent findings (one per sub-question)
  team-{position}.md     — Tier 3 teammate findings (one per position)
```

<!-- PRIVATE:deepdive-area-routing -->

**Rules:**
- **Create the folder at Tier 1 start.** Check `~/.claude/investigations/<area>/{slug}/` for prior work on the same topic — build on previous work, don't duplicate it.
- **Deepdive always writes findings to disk.** Do not hold findings in context only. Every tier produces a file.
- **Subagents and teammates write findings to their own file.** They receive the workspace path and their assigned filename. This is mandatory — do not return findings only via message.
- **Lead agent reads files to synthesize.** After subagents/teammates complete, read their files rather than relying on message content.
- **README.md is written last** — the final synthesized deliverable.
- **Intermediate files are the audit trail.** Don't delete them after synthesis.

## Tiers

Escalate progressively. Always start at Tier 1. Escalation is mechanical, not deliberative — fill the scorecard, apply the rules.

### Tier 1 — Structured decomposition

1. **Create the workspace folder** at `~/.claude/investigations/{topic-slug}/`. If it exists, read existing files.
2. Use `mcp__sequential-thinking__sequentialthinking` to decompose the question:
   - Break into sub-questions — anchor the first-level split in the problem's actual structure, not a generic framework. The first cut is highest-leverage; require explicit justification for why these branches and not others.
   - Map what's known (if `knowledge-recall` was selected) vs. unknown
   - For each sub-question, identify what evidence would answer it and where to look
   - Fill the Escalation Scorecard
3. **Write `tier-1-survey.md`** to the workspace — sub-questions, /recall findings summary, initial analysis, scorecard. This persists the Tier 1 work and frees context.

**Escalation Scorecard** — fill during reasoning, apply mechanical rules:
- Sub-questions identified: ___
- Independent components involved: ___
- Unknowns requiring exploration: ___
- Competing hypotheses: yes / no
- Outside existing skill/research coverage: yes / no

**Escalate to Tier 2 if ANY**: 3+ sub-questions, 3+ components, 3+ unknowns, competing hypotheses, or outside coverage. Otherwise stop and report.

**Escalation**: If scorecard triggers, automatically escalate to Tier 2 — don't ask. Present the scorecard and Tier 1 findings before proceeding so the user sees the reasoning. Quick mode: stop at Tier 1 regardless. Deep mode: escalate without presenting.

### Tier 2 — Parallel exploration

Spawn subagents (Task tool, subagent_type: general-purpose) for parallel investigation:
- Each agent gets a distinct sub-question from Tier 1
- Max 3 concurrent agents
- **Each agent writes findings to `sub-{question-slug}.md`** in the workspace. Include in the agent prompt: the workspace path, the target filename, and the expected format (see /research subagent file format).

**Subagent file verification**: After all agents complete, verify each expected `sub-*.md` file exists using Glob. If a file is missing:
1. Re-spawn the agent once with an explicit reminder to write the file.
2. If the file is still missing after re-spawn, note the gap in synthesis — do not reconstruct findings from the agent's return message.

After all agents complete and files are verified, **read their files** to collect and cross-reference findings. Do not rely solely on agent return messages.

Evaluate Tier 3 gates.

**Tier 3 gates** — escalate if 3+ of these are YES:
1. **Multiple valid paths?** 2+ architecturally distinct solutions identified
2. **Non-obvious trade-offs?** A senior engineer would disagree without more context
3. **Competing assumptions?** Each path rests on different assumptions about requirements, scale, or behavior
4. **Self-review doubt?** Tier 2 synthesis contains hedging, contradictions, or unresolved tensions
5. **High stakes?** The conclusion drives irreversible decisions or cross-system changes

3+ YES → Tier 3. Otherwise → stay at Tier 2 (collect more data, clarify assumptions, or decide based on priorities).

**Checkpoint** (Standard mode only): Present Tier 2 findings and the gate evaluation, then ask "Escalate to Tier 3 (adversarial analysis with agent team)?" Options: Yes / No, report what we have. Deep mode: escalate without asking.

### Tier 3 — Adversarial synthesis

Spawn an agent team (TeamCreate) with:
- Each teammate gets an assigned hypothesis and the opposing position
- Mandate: **stress-test, don't destroy** — agents should challenge and probe, not oppose for opposition's sake. Moderate disagreement produces better outcomes than maximal disagreement.
- Each agent uses structured argumentation: claim, evidence, warrant (reasoning principle connecting evidence to claim), qualifier (degree of certainty), rebuttal (conditions where claim fails)
- **Each agent writes findings to `team-{position-slug}.md`** in the workspace
- Cap at 3-5 rounds of exchange. If positions harden rather than converge after 3 rounds, stop — more debate won't help.

**Synthesis**:
- Synthesis agent reads all `team-*.md` files + `sub-*.md` files from Tier 2
- Reconciles findings — identify where disagreement is genuine vs. resolvable
- **Convergence threshold**: 75%+ of agents/evidence agreeing after seeing opposing reasoning → treat as established. Below 75% → report as contested with both positions.
- **Characterize disagreement type**: factual (different evidence), interpretive (same evidence, different reading), or normative (different trade-off weighting). Each type has a different resolution path.
- If both assumptions are genuinely valid, document the trade-off and let the user decide. Don't force artificial consensus.

**Confidence representation** — every finding gets two dimensions:
- **Likelihood**: How likely is this claim? (almost certain / likely / even odds / unlikely / almost certainly not)
- **Confidence**: How strong is the evidence? (high / moderate / low / very low)

These are orthogonal. You can have high confidence in a low-likelihood finding ("we're confident this is unlikely") or low confidence in a high-likelihood one ("this probably works but our evidence is weak").

## Output

### 1. Conversation summary

Present key findings to the user. Lead with the answer, then supporting evidence.

Include for every finding:
- **Likelihood + Confidence** (both dimensions)
- **Evidence basis**: what sources/analysis support it
- **Dissent**: if any agent disagreed, summarize why

### 2. Research workspace

The workspace at `~/.claude/investigations/{topic-slug}/` already contains intermediate files from each tier. Write the final `README.md` as the synthesized deliverable:

```markdown
# {Topic title}

**Date**: YYYY-MM-DD
**Scope**: {scope}
**Trigger**: {what prompted this deepdive}
**Tiers used**: {1, 2, 3}

## Summary

{1-3 sentence executive summary}

## Findings

{Structured findings. Each claim cites evidence and includes likelihood + confidence.}

## Open Questions

{Unresolved items that need further investigation or user input}

## Workspace Contents

{List of intermediate files with one-line descriptions}
- `tier-1-survey.md` — initial scope, sub-questions, scorecard
- `sub-*.md` — Tier 2 subagent findings
- `team-*.md` — Tier 3 teammate findings

## Potential Learnings

{Observations that may warrant LEARNINGS.md entries}
```

### 3. Learning extraction

Review findings for generalizable observations. For each:
- Capture in LEARNINGS.md with `confidence: low`, `action: needs-verification`, `source: deepdive`
- Skip if already covered by existing skills or learnings
- Max 3 entries per deepdive — quality over quantity

## Consumer interface: 2D→1D collapse

Downstream consumers that use 1D confidence (LEARNINGS.md, /recall rankings) collapse 2D findings using a conservative rule — min(likelihood_tier, confidence_tier):

| Confidence | Likelihood: almost certain/likely | Likelihood: even odds | Likelihood: unlikely/remote |
|------------|----------------------------------|----------------------|---------------------------|
| high | high | medium | low |
| moderate | medium | medium | low |
| low/very low | low | low | low |

When extracting learnings from deepdive findings, apply this table to produce the 1D `confidence:` value.

## Integration

Skills providing `self-improvement` scan `~/.claude/investigations/` for:
- Potential Learnings that have been verified (appeared in 2+ investigations or confirmed by experience)
- Investigation files that could seed a new skill (3+ workspaces in same domain)

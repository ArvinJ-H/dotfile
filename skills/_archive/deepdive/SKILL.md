---
name: deepdive
description: Deep research and investigation using sequential thinking, subagents, and agent teams. Auto-triggers on complex questions or runs manually via /deepdive.
allowed-tools: Read, Glob, Grep, Edit, Write, WebSearch, WebFetch, Task, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, ToolSearch, AskUserQuestion
---

Conduct a deep investigation on a topic, question, or problem. Uses the **ICD loop** (see `~/.claude/reference/investigation-loop.md`) with deepdive-specific iteration strategy.

**Scope boundary: `external-research`** -- look up the capability in the CLAUDE.md Capability Manifest and invoke the provider. If a question spans both internal and external, /deepdive handles the codebase component.

## When to auto-trigger

Run deepdive autonomously (without /deepdive) when ALL of these are true:
- The question involves 3+ interconnected components (systems, files, concepts, or domains)
- Initial exploration raises more questions than it answers
- Existing skills and research don't cover the topic
- The user's energy suggests exploration, not urgent debugging

## Invocation

`/deepdive topic`

The ICD loop self-regulates depth. If the question is simple, iteration 1's evaluation finds no gaps and the loop stops naturally. If complex, it keeps going. The user can always intervene ("go deeper" / "that's enough").

### Auto-trigger

Claude detected complexity. Be cost-conservative:
- Start the ICD loop
- First iteration's evaluation applies strict criteria (no soft matches)
- If evaluation finds no gaps, report findings to user. They can `/deepdive` to continue.

## Research workspace

Deepdive writes to the shared investigations workspace per the ICD loop spec:

```
~/.claude/investigations/<area>/{topic-slug}/
  STATE.md          -- iteration log, confidence trajectory, accumulated findings, active gaps
  README.md         -- final synthesized answer (written at loop exit)
  sub-{slug}.md     -- subagent findings (created as needed, one per sub-question)
  team-{slug}.md    -- adversarial team output (created if escalated)
```

<!-- PRIVATE:deepdive-area-routing -->

**Rules:**
- **Create the folder at iteration 1 start.** Check `~/.claude/investigations/<area>/{slug}/` for prior work on the same topic -- build on previous work, don't duplicate it.
- **Deepdive always writes findings to disk.** Do not hold findings in context only. Every iteration updates STATE.md.
- **Subagents and teammates write findings to their own file.** They receive the workspace path and their assigned filename. Mandatory -- do not return findings only via message.
- **Lead agent reads files to synthesize.** After subagents/teammates complete, read their files rather than relying on message content.
- **README.md is written last** -- the final synthesized deliverable at loop exit.
- **Intermediate files are the audit trail.** Don't delete them after synthesis.

## Deepdive Iteration Strategy

Follows the ICD loop (investigate-challenge-decide). Each iteration uses the loop's 6-step structure. This section defines what's deepdive-specific.

### First iteration (typical)

1. **Create workspace** at `~/.claude/investigations/<area>/{slug}/`. If prior work exists, read existing files.
2. **Decompose** using `mcp__sequential-thinking__sequentialthinking`:
   - Break into sub-questions. Anchor the first-level split in the problem's actual structure, not a generic framework. The first cut is highest-leverage; require explicit justification for why these branches and not others.
   - Map what's known (/recall results if `knowledge-recall` was selected) vs. unknown
   - For each sub-question, identify what evidence would answer it and where to look
3. **Write STATE.md** -- initial scope, sub-questions, /recall findings summary, initial analysis.
4. **Self-assess** (ICD step 4): update confidence, count gaps.
5. **Evaluate** (ICD step 5): first iteration challenge criteria (replaces the old escalation scorecard):
   - Distinct sub-questions requiring separate investigation: ___
   - Independent components involved: ___
   - Unknowns requiring exploration: ___
   - Competing hypotheses: yes / no
   - Outside existing skill/research coverage: yes / no
6. **Decide** (ICD step 6): if ANY of 3+ sub-questions, 3+ components, 3+ unknowns, competing hypotheses, or outside coverage, the loop continues. Otherwise stop and report.

If prior state exists (resumed investigation, pre-decomposed prompt), the loop reads STATE.md and skips to where it's needed.

### Subsequent iterations

Spawn parallel subagents for sub-questions identified by the evaluate step. Count and focus driven by what the evaluation found, not prescribed.

- Each agent gets a distinct sub-question
- Max 3 concurrent agents
- **Each agent writes findings to `sub-{question-slug}.md`** in the workspace

**Subagent prompt construction**: use the standard template from `~/.claude/reference/subagent-prompting-patterns.md`. Apply these patterns:

- **Authority framing**: "Lead investigator for [sub-question]. Your findings are the authoritative reference for this area."
- **Tool hints**: Codebase investigation sequence: `Grep (find entry points) -> Read (understand context) -> Grep (follow references) -> Read (connected code)`. For web research sub-questions, use the web research sequence instead.
- **Evidence depth**: each claim must cite a specific source (file:line, URL, tool result). The runtime hook surfaces investigation state when the agent writes output; the agent decides whether it has enough evidence or should keep going.
- **Tool diversity**: encourage using multiple tool types for complementary angles.
- **Budget awareness**: prioritize highest-value sources first. No fixed minimums; depth is proportional to the sub-question's complexity.
- **Self-tracking**: include the self-tracking instruction so agents note progress after each tool call.
- **Evidence source table**: each subagent includes an evidence table: `| # | Source (file:line or URL) | Tool | Key Finding |`.

**Subagent file verification**: After all agents complete, verify each expected `sub-*.md` file exists using Glob. If missing: re-spawn once with explicit file-write reminder. If still missing: note gap in STATE.md, do not reconstruct from agent messages.

After files verified, **read them** to cross-reference findings. Update STATE.md with accumulated findings, then run the evaluate step.

### Adversarial team

Triggered dynamically by the evaluate step when competing hypotheses emerge (ICD adversarial team escalation). Not gated by a fixed check. Uses the loop's standard adversarial team mechanics: TeamCreate, Toulmin argumentation, qualitative convergence assessment.

Each agent writes to `team-{position-slug}.md` in the workspace.

## Output

### 1. Conversation summary

Present key findings to the user. Lead with the answer, then supporting evidence.

Include for every finding:
- **Likelihood + Confidence** (both dimensions, see confidence model in investigation-loop.md)
- **Evidence basis**: what sources/analysis support it
- **Dissent**: if any agent disagreed, summarize why

### 2. Research workspace

Write the final `README.md` at loop exit:

```markdown
# {Topic title}

**Date**: YYYY-MM-DD
**Scope**: {scope}
**Trigger**: {what prompted this deepdive}
**Iterations**: {N}

## Summary

{1-3 sentence executive summary}

## Findings

{Structured findings. Each claim cites evidence and includes likelihood + confidence.}

## Open Questions

{Unresolved items that need further investigation or user input}

## Workspace Contents

- `STATE.md` -- investigation log, confidence trajectory, all iterations
- `sub-*.md` -- subagent findings
- `team-*.md` -- adversarial team findings (if escalated)

## Potential Learnings

{Observations that may warrant LEARNINGS.md entries}
```

### 3. Learning extraction

Review findings for generalizable observations. For each:
- Capture in LEARNINGS.md with `confidence: low`, `action: needs-verification`, `source: deepdive`
- Skip if already covered by existing skills or learnings
- Max 3 entries per deepdive

## Consumer interface: 2D to 1D collapse

See `investigation-loop.md` for the 2D confidence model and collapse table used by downstream consumers.

## Integration

Skills providing `self-improvement` scan `~/.claude/investigations/` for:
- Potential Learnings that have been verified (appeared in 2+ investigations or confirmed by experience)
- Investigation files that could seed a new skill (3+ workspaces in same domain)

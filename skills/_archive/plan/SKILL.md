---
name: plan
description: Autonomous deep planning — investigation, breakdown, audit hardening, execution-ready output. TRIGGER: plan mode activation, multi-step tasks needing investigation.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, Task, AskUserQuestion, ToolSearch
---

Produce battle-tested, execution-ready plans for any task type. Five phases: intake, skeleton, breakdown, investigation, audit.

**Scope boundaries: `external-research`, `codebase-investigation`** — /plan orchestrates these but delegates to their providers. Look up the capability in the CLAUDE.md Capability Manifest and invoke the provider.

## Invocation

- `/plan topic` — Standard: all phases, checkpoint at Phase 1
- `/plan --quick topic` — Phases 0-2 only (skeleton + breakdown). No investigation, no audit.
- `/plan --deep topic` — All phases, no checkpoint, aggressive investigation.

## Core Principle: Plan File as Living Document

PLAN.md is edited **continuously**, not at phase boundaries. Every finding, decision, and structural change is written as it happens. The plan file is the single source of truth — if it's not in the file, it didn't happen.

- Phase transitions update `Status`, but editing happens throughout
- Investigation findings go into the plan as they arrive, not batched
- Structural changes happen inline with a Revision Log entry
- The plan is always readable and current, even mid-phase

## Workspace

```
~/.claude/plans/{task-slug}/
  PLAN.md                      — primary artifact (evolves through phases)
  investigation-{slug}.md      — per-question findings from Phase 3
```

Coexists with built-in plan mode flat files (which are `~/.claude/plans/{name}.md` without subdirectories).

**Rules:**
- Create the workspace directory at Phase 0.
- All intermediate files live in the workspace. Subagents receive workspace path and target filename.
- PLAN.md is written last by the lead agent. Subagents write investigation files.

## Phases

### Phase 0 — Intake

1. Parse task description. Classify type: `code | architecture | research | process | general`.
2. Detect git repo context (run `git rev-parse --show-toplevel` — determines worktree eligibility).
3. Invoke `knowledge-recall` — check existing knowledge. Always, lightweight.
4. Create workspace at `~/.claude/plans/{task-slug}/`.
5. **Write initial PLAN.md** with Context, type, date, Status: `skeleton`.

### Phase 1 — Skeleton & Checkpoint

1. Decompose task into major pieces. Map dependencies, identify unknowns.
2. **Edit PLAN.md**: write skeleton — high-level phases with one-line descriptions.
3. Determine which capabilities are needed from the manifest:

   | Need | Capability |
   |------|-----------|
   | Understanding existing code | `codebase-investigation` |
   | External library/pattern research | `external-research` |
   | Domain knowledge (a11y, etc.) | domain-specific provider |

4. **Single upfront checkpoint** via AskUserQuestion (skip in `--deep` mode):
   - Task classification + plan skeleton
   - Capabilities to invoke + worktree decision (code tasks in git repos)
   - Approve / Adjust / Abort

   This replaces per-invocation x+n pre-flight for pre-approved capabilities. Unexpected needs mid-execution still pause and ask.

5. **Edit PLAN.md**: incorporate checkpoint adjustments.

### Phase 2 — Breakdown

1. For each skeleton phase, break into concrete steps. **Edit PLAN.md per-phase** as each is broken down:
   - What exactly needs to happen
   - Which files involved (if code)
   - Expected output per step
   - Dependencies between steps
2. Tag **investigation questions** inline where they arise: `[?] How does X handle Y?`
3. Group questions by capability for efficient batching.
4. **Edit PLAN.md**: update Status to `breakdown`.

**`--quick` mode stops here.** Report skeleton + breakdown to conversation.

### Phase 3 — Investigation

Core differentiator. Actually invoke skills to answer tagged questions.

1. **For `codebase-investigation` questions**: Spawn investigation subagents (Task tool, subagent_type: `general-purpose`). For code tasks in git repos, use `isolation: "worktree"`. Each agent writes to `investigation-{slug}.md` in workspace.
   - Subagent prompt must be self-contained: workspace path, target filename, the specific question, what files/areas to investigate, expected format. No CLAUDE.md, no history.
2. **For `external-research` questions**: Invoke the `external-research` provider. If not pre-approved at checkpoint, pause + AskUserQuestion.
3. **For domain questions**: Invoke relevant provider (pre-approved or pause + ask).

4. **After each investigation returns, immediately edit PLAN.md**:
   - Replace `[?]` question with concrete findings (exact file paths, signatures, code references)
   - If finding changes a step's approach, rewrite the step
   - If finding invalidates plan structure, restructure and add Revision Log entry

5. **Feedback arc**: If findings invalidate skeleton assumptions → restructure in-place, document in Revision Log.
6. **Edit PLAN.md**: update Status to `investigated` when all questions resolved.

### Phase 4 -- Audit & Harden

Uses the ICD loop's evaluate step (see `~/.claude/reference/investigation-loop.md`) rather than a fixed number of passes. The loop dynamically selects evaluation tools based on what the plan needs:

1. **Start evaluation**: deliver PLAN.md + Phase 3 investigation files as source material.
2. **Evaluate dynamically**:
   - Self-assessment: all steps have concrete actions? Files exist? Dependencies mapped? Test plan present?
   - Challenge pass (if plan has competing approaches, unstated assumptions, or non-obvious trade-offs): can steps fail? Simpler approach exists? Ordering issues?
   - Completeness audit (if plan is large or touches many files): did we cover all artifacts in scope?
3. **Edit PLAN.md**: address each finding inline, update Audit Trail section.
4. **Re-evaluate if needed**: if evaluation produced 2+ major findings requiring plan changes, run another evaluation pass to check whether fixes introduce new gaps. The loop continues until confidence plateaus.

**Edit PLAN.md**: update Status to `audited`, finalize Audit Trail.

### Phase 5 — Finalize

1. **Edit PLAN.md**: write Summary (last section written), update Status to `final`, set Confidence.
2. Report to conversation: scope, phases, key findings, audit results, confidence.
3. Learning extraction (max 3 entries, standard rules — `confidence: low`, `action: needs-verification`).

## Task Type Adaptation

| Aspect | Code | Architecture | Research | Process/General |
|--------|------|-------------|----------|-----------------|
| Worktree | Yes (in git repo) | Optional | No | No |
| Investigation focus | Code patterns, types, tests | Constraints, trade-offs, precedents | External sources, prior knowledge | Current process, best practices |
| Step detail | File paths, signatures, imports | Decision records, diagrams | Research questions, sources | Process changes, rollout |
| Audit emphasis | Correctness, edge cases | Alternatives considered | Source quality, coverage | Feasibility, adoption risk |

## Skill Orchestration

| Invocation | When | How |
|-----------|------|-----|
| `knowledge-recall` | Always, Phase 0 | Direct (lightweight) |
| Verifier (completeness, adversarial, feedback) | Phase 4 | Task subagent, subagent_type: `verifier` |
| `codebase-investigation` | Phase 3, code tasks | Task subagent with `isolation: "worktree"` |
| `external-research` | Phase 3, when needed | Pause + AskUserQuestion if not pre-approved |
| Domain skills | Phase 3, when relevant | Pre-approved at checkpoint or pause + ask |

## Plan File Format (PLAN.md)

```markdown
# Plan: {Task title}

**Date**: YYYY-MM-DD | **Type**: {type} | **Status**: {skeleton|breakdown|investigated|audited|final} | **Confidence**: {high|medium|low}

## Context
{Problem statement, constraints, what triggered this.}

## Summary
{1-3 sentence approach. Written last.}

## Prerequisites
{What must be true before execution.}

## Steps

### Phase N: {name}
**Goal**: {outcome} | **Depends on**: {phases}

#### Step N.1: {title}
- **Action**: {concrete — not "analyze" but "read X, modify Y"}
- **Files**: {exact paths or "new: path/to/file.ts"}
- **Verification**: {how to confirm success}
- **Risk**: {what could go wrong, if non-trivial}

## Worktree Findings
{Code tasks only. What was tested/prototyped, confirmed vs disproven.}

## Open Questions
{Unresolved items with why-it-matters and resolution path.}

## Revision Log
{What changed during investigation/audit. Chronological.}

## Audit Trail
### Completeness → findings count, what was fixed
### Adversarial → findings count, what was fixed
### Feedback (if run) → trigger, findings count
```

## Integration

- Plans consumed by user for execution; searchable by /recall (scans `~/.claude/plans/`)
- Downstream skills can reference plans as context
- Built-in plan mode flat files coexist at `~/.claude/plans/{name}.md`

## Plan Mode Integration

When Claude's built-in plan mode activates for a non-trivial task, /plan's methodology
applies automatically:

- Phase 0-1 → plan mode exploration: intake, skeleton, checkpoint
- Phase 2-3 → plan mode design: breakdown, investigation
- Phase 4 → plan mode review: audit hardening
- Built-in plan file serves as living document
- /plan workspace created only for deep/complex plans needing investigation sub-files

**Skip conditions**: Single-file changes, quick fixes, tasks with detailed user instructions.

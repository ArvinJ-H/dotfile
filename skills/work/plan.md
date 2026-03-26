# Plan Methodology

Detailed planning workflow for the /work meta-skill. Parent SKILL.md handles: routing, ICD framework, disciplines.

## Core Principle

PLAN.md is edited continuously, not at phase boundaries. Every finding, decision, and structural change is written as it happens. The plan file is the single source of truth.

## Workspace

```
~/.claude/plans/{task-slug}/
  PLAN.md                      -- primary artifact (evolves through phases)
  investigation-{slug}.md      -- per-question findings from Phase 3
```

Coexists with built-in plan mode flat files (`~/.claude/plans/{name}.md` without subdirectories).

Create the workspace at Phase 0. Subagents write investigation files; lead agent writes PLAN.md.

## Phases

### Phase 0: Intake

1. Parse task. Classify: `code | architecture | research | process | general`.
2. Detect git repo context (`git rev-parse --show-toplevel`).
3. Invoke recall capability (always, lightweight): check existing knowledge on the topic before starting any new research.
4. Create workspace. Write initial PLAN.md with Context, type, date, Status: `skeleton`.

Plans are discoverable by the recall capability (scans `~/.claude/plans/`).

### Phase 1: Skeleton and Checkpoint

1. Decompose into major pieces. Map dependencies, identify unknowns.
2. Write skeleton to PLAN.md.
3. Determine needed capabilities from the manifest:

| Need | Capability |
|------|-----------|
| Understanding existing code | /think (Deepdive workflow) |
| External research | /think (Research workflow) |
| Domain knowledge | domain-specific provider |

4. **Checkpoint** via AskUserQuestion (skip in `--deep`): task classification, skeleton, capabilities, worktree decision. Approve / Adjust / Abort.
5. Incorporate adjustments into PLAN.md.

### Phase 2: Breakdown

1. For each skeleton phase, break into concrete steps:
   - What exactly needs to happen
   - Which files involved
   - Expected output per step
   - Dependencies between steps
2. Tag investigation questions inline: `[?] How does X handle Y?`
3. Group questions by capability. Update Status to `breakdown`.

**`--quick` mode stops here.** Report skeleton + breakdown.

### Phase 3: Investigation

Core differentiator. Invoke capabilities to answer tagged questions.

1. **Codebase questions**: spawn subagents (general-purpose). For code tasks in git repos, use `isolation: "worktree"`. Each writes to `investigation-{slug}.md`.
2. **External questions**: invoke /think (Research workflow). Pause + ask if not pre-approved.
3. **Domain questions**: invoke relevant provider.
4. **After each investigation returns**: edit PLAN.md immediately. Replace `[?]` with findings. If findings change approach, rewrite steps. If findings invalidate structure, restructure + Revision Log entry.
5. **Feedback arc**: skeleton assumptions invalidated -> restructure in-place.
6. Update Status to `investigated`.

**Orchestration**:

| Capability | When | How |
|------------|------|-----|
| /think (Recall workflow) | Always, Phase 0 | Direct (lightweight) |
| /think (Deepdive workflow) | Phase 3, code tasks | Subagent with `isolation: "worktree"` |
| /think (Research workflow) | Phase 3, when needed | Pause + AskUserQuestion if not pre-approved |
| Verifier | Phase 4 | Subagent, `subagent_type: "verifier"` |

### Phase 4: Audit and Harden

Uses the ICD evaluate step (see `investigation-loop.md`). Compose verification dynamically:

1. Deliver PLAN.md + investigation files as source material.
2. Evaluate: self-assessment (concrete actions? files exist? dependencies mapped?), challenge pass (can steps fail? simpler approach? ordering issues?), completeness audit (all artifacts covered?).
3. Edit PLAN.md: address findings inline, update Audit Trail.
4. If 2+ major findings required plan changes, re-evaluate. Continue until confidence stabilizes.
5. Update Status to `audited`.

### Phase 5: Finalize

1. Write Summary (last section written). Update Status to `final`. Set Confidence.
2. Report: scope, phases, key findings, audit results, confidence.
3. Learning extraction (max 3 entries).

## Task Type Adaptation

| Aspect | Code | Architecture | Research | Process |
|--------|------|-------------|----------|---------|
| Worktree | Yes (git repo) | Optional | No | No |
| Investigation | Code patterns, types, tests | Constraints, trade-offs | External sources | Current process |
| Step detail | File paths, signatures | Decision records | Research questions | Process changes |
| Audit emphasis | Correctness, edge cases | Alternatives considered | Source quality | Feasibility |

## Plan File Format

```markdown
# Plan: {Task title}

**Date**: YYYY-MM-DD | **Type**: {type} | **Status**: {skeleton|breakdown|investigated|audited|final} | **Confidence**: {high|medium|low}

## Context
{Problem statement, constraints, trigger.}

## Summary
{1-3 sentence approach. Written last.}

## Prerequisites
{What must be true before execution.}

## Steps

### Phase N: {name}
**Goal**: {outcome} | **Depends on**: {phases}

#### Step N.1: {title}
- **Action**: {concrete, not "analyze" but "read X, modify Y"}
- **Files**: {exact paths or "new: path/to/file.ts"}
- **Verification**: {how to confirm success}
- **Risk**: {what could go wrong}

## Worktree Findings
{Code tasks only.}

## Open Questions
{Unresolved items with resolution path.}

## Revision Log
{What changed during investigation/audit.}

## Audit Trail
### Completeness: findings count, what was fixed
### Adversarial: findings count, what was fixed
### Feedback (if run): trigger, findings count
```

## Plan Mode Integration

When CC's plan mode activates for a non-trivial task, the Plan workflow applies:
- Phase 0-1: plan mode exploration
- Phase 2-3: plan mode design
- Phase 4: plan mode review
- Built-in plan file serves as living document
- Workspace created only for deep/complex plans

Skip for: single-file changes, quick fixes, tasks with detailed user instructions.

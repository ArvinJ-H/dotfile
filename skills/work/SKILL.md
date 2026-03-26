---
name: work
description: Implementation, planning, review, shipping. Invoke at even 1% chance the task involves coding, planning, reviewing, debugging, or shipping.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, WebSearch, WebFetch, AskUserQuestion, ToolSearch, TaskCreate, TaskUpdate, TaskList, TaskGet, Skill, Agent
---

Scope boundary: for analysis/investigation invoke /think. For creative output invoke /create.

## Router

| Signal | Workflow |
|---|---|
| Multi-step task, "plan", needs investigation before implementation | [Plan](#plan) |
| "Review", code review, PR review, "check this" | [Review](#review) |
| "Ship", push, create PR, finish branch, "merge" | [Ship](#ship) |
| Bug fix, implementation, "fix", "build", "implement" | Full cycle |
| Unclear | Ask |

**Full cycle**: always starts with Investigate (understand the task). Then: Plan if multi-step, implement, Review, Ship. A one-file fix skips Plan. A multi-file refactor uses all three. Depth emerges from the task.

## Development Cycle (ICD)

Complex work follows the ICD loop adapted for implementation. The 6-step loop (see `~/.claude/reference/investigation-loop.md`) compresses to 3 phases for implementation work:

### Investigate

Understand what needs to change and why, before changing it. The specific approach emerges from the task and its context. The [Plan workflow](#plan) provides deep investigation methodology when the task warrants it.

### Challenge

Verify the work before declaring it done. At minimum, apply the Thinking Floor (`investigation-loop.md`):
- **Assumption**: What behavior am I assuming that I haven't tested? What edge case would break this?
- **Alternative**: Is there a simpler approach I didn't consider? Does this duplicate something that already exists?
- **Pre-mortem**: If this PR gets reverted, what went wrong?

Additionally, compose verification from available tools proportional to what was changed. The [Review workflow](#review) provides structured multi-angle methodology when the change warrants it.

### Decide

Determine whether to ship, iterate, or stop. The decision emerges from verification. The [Ship workflow](#ship) provides the git-to-PR pipeline when the work is ready.

Depth is adaptive. A one-line fix: self-review, ship. A multi-file refactor: full Plan, Review, Ship.

## Disciplines

Non-negotiable process requirements embedded in all /work phases:

1. **Understand before changing.** Never propose modifications to unread code.
2. **Tests describe behavior.** When implementing, write tests that describe desired behavior before writing the implementation.
3. **Trace before guessing.** When debugging, reproduce first. Trace the problem space. After 2-3 failures: stop, revert, re-read, ask.
4. **Verify after changing.** Re-read edited code. Run tests. Don't stack edits on unchecked edits.
5. **Search before creating.** Check if a function, utility, or pattern already exists.
6. **Plans are hypotheses.** Verify against code and current state, not against the plan that produced it.
7. **Review before shipping.** Non-trivial changes get code review before they ship. Self-review minimum; external review for multi-file changes.
8. **Finish branches.** When work is done, ship it. Push, create PR, get it merged. Don't accumulate unshipped work.

---

## Plan

Autonomous deep planning. Full methodology: [plan.md](plan.md).

**Phases**: Intake -> Skeleton -> Breakdown -> Investigation -> Audit -> Finalize.

**Modes**: standard (all phases, checkpoint at Phase 1), `--quick` (phases 0-2 only), `--deep` (all phases, no checkpoint).

**Core principle**: PLAN.md is a living document edited continuously. If it's not in the file, it didn't happen.

**Workspace**: `~/.claude/plans/{task-slug}/` with PLAN.md and investigation files.

**Phase 4 (Audit)**: uses the ICD evaluate step. Compose verification dynamically (self-assessment, challenge pass, completeness audit) based on what the plan needs.

---

## Review

Unified review entry point for all change types (code, docs, config, AI configs, infra). Full methodology: [review.md](review.md). Review criteria by change type: [review-criteria.md](review-criteria.md).

**Steps**: detect context -> classify change types -> ask what kind -> route -> multi-angle verify -> learn.

**Multi-angle verification** (PBR, Perspective-Based Reading): 3 fixed verifiers (independent scanner, false positive auditor, completeness checker) + 0-3 dynamic verifiers per triage. Runs on every review.

**False positive discipline**: every finding must include specific location (file:line), mechanism (how it manifests), and impact (what breaks). Findings without concrete evidence are noise.

---

## Ship

Git-to-PR pipeline. Full methodology: [ship.md](ship.md).

**Pipeline**: Uncommitted -> Unpushed -> No PR -> Shipped. Each branch enters at its current stage and completes remaining steps.

**Steps**: resolve targets -> detect state -> plan -> confirm and execute -> summary.

**Safety**: never force-push, never push to main/master, never `git add .`, never commit secrets. Confirm before irreversible actions.

**Batch**: supports multiple branches via paths or `--scan`. First-target overrides offered to remaining targets.

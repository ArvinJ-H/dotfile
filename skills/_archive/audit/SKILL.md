---
name: audit
description: Systematic audit of a defined scope using the ICD loop. Rubric-driven evaluation, cross-cutting synthesis, and remediation. TRIGGER: user asks to audit, evaluate, or assess a defined scope systematically.
allowed-tools: Read, Glob, Grep, Edit, Write, Task, AskUserQuestion, ToolSearch
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

Systematic audit of a defined scope. Produces a severity-classified finding set with cross-cutting synthesis. Uses the **ICD loop** (see `~/.claude/reference/investigation-loop.md`) with audit-specific iteration strategy, plus a post-loop remediation phase.

## Workspace

Per the ICD loop spec, each audit creates a workspace:

```
~/.claude/investigations/{area}/{scope-slug}/
  STATE.md          -- iteration log, confidence, gap tracking
  TRACKER.md        -- artifact inventory + findings (living document)
  eval-{slug}.md    -- per-artifact detailed evaluation (named by artifact)
  README.md         -- final audit report
```

## When to use

- Reviewing a collection of related artifacts (skills, agents, scripts, config files)
- Quality assessment across a subsystem or toolchain
- Compliance or consistency checks across multiple files
- Any review where scope enumeration, deep review, and synthesis is the right shape

NOT for: single-file code review (`code-review`), codebase exploration (`codebase-investigation`), or external research (`external-research`).

## Invocation

`/audit [scope description]`

- `/audit ~/.claude/skills/` -- audit all skills
- `/audit hookify plugin` -- audit the hookify plugin
- `/audit` (no args) -- ask what to audit

The ICD loop self-regulates depth. A clean scope may resolve in 2 iterations (enumerate + surface scan, then deep review finds nothing). A messy scope keeps iterating as evaluation surfaces more gaps.

## Audit Iteration Strategy

Follows the ICD loop (investigate-challenge-decide). Each iteration uses the loop's 6-step structure. This section defines what's audit-specific.

### First iteration (typical): calibration + surface scan

1. **Define scope**: list all artifacts in scope. Use Glob to enumerate files.
2. **Build evaluation rubric**: what constitutes good/bad for this scope? Dimensions depend on artifact type:
   - Skills: body-text routing, manifest references, step clarity, integration points, scope boundaries
   - Scripts: correctness, edge cases, portability, error handling
   - Config: valid structure, references resolve, no stale entries
   - Agents: mode clarity, defect taxonomy, evidence grading
3. **Verify tools work**: read a sample artifact to confirm access and format understanding.
4. **Surface scan**: structural and mechanical checks (fast, parallelizable):
   - References resolve (file paths, cross-references, capability tags)
   - Formats are valid (YAML frontmatter parses, markdown renders, scripts have shebangs)
   - Permissions are correct (scripts executable)
   - Naming conventions followed
   - No dead code or orphaned files
5. **Write STATE.md** -- scope, rubric, surface scan findings.
6. **Write TRACKER.md** -- initial scope inventory with artifact list and surface scan results. Classify: `pass` / `minor` / `major` / `critical`.
7. **Evaluate** (ICD step 5): are there artifacts needing deep review? Gaps in surface scan coverage?
8. **Decide** (ICD step 6): if artifacts need deep rubric evaluation, the loop continues. If surface scan found everything clean, stop (rare but possible for small scopes).

If prior state exists (resumed audit), read STATE.md and TRACKER.md, continue from where the audit left off.

### Subsequent iterations: deep per-artifact evaluation

Evaluate artifacts against the rubric in batches. Batch size and which artifacts next are driven by the evaluate step.

**Meta-circularity rule**: if the scope includes tools used by the audit itself (e.g., auditing the verifier agent while using it), review those tools FIRST.

- Batch by dependency: review foundations before consumers
- Max 3 concurrent subagents per batch
- **Each subagent writes findings to `eval-{artifact-slug}.md`** in the workspace (named by artifact, not by iteration)

**Subagent prompt construction**: use the standard template from `~/.claude/reference/subagent-prompting-patterns.md`. Apply these patterns:

- **Authority framing**: "Definitive evaluator for [artifact]. Do not hedge. You have the code. State what is true."
- **Tool hints**: Artifact evaluation sequence: `Read (artifact under review) -> Grep (cross-references) -> Read (referenced files) -> evaluate and write`.
- **Evidence depth**: read the artifact under review plus referenced files as needed. Each rubric dimension must cite file:line evidence. Depth proportional to artifact complexity.
- **Budget awareness**: prioritize reading the artifact and key references first. No fixed minimums; the runtime hook surfaces investigation state when writing output.
- **Self-tracking**: Include the self-tracking instruction so agents note progress after each tool call.

**Evaluation file format**: each `eval-{artifact-slug}.md` must follow:

```markdown
# Evaluation: {Artifact name}
**Type**: {type} | **Path**: {path}

## Rubric Evaluation
### {Dimension}
**Rating**: pass / minor / major / critical
**Evidence**: {file:line, observation}
**Notes**: {context}

## Summary
**Overall**: {highest severity} | **Key findings**: {1-3 sentences}
```

**File verification**: after each batch, verify `eval-*.md` files exist using Glob. If missing: re-spawn once with explicit file-write reminder. If still missing: note gap in TRACKER.md.

**Severity classification**:
- **Critical**: breaks functionality, security issue, data loss risk
- **Major**: significant gap, incorrect behavior, misleading output
- **Minor**: inconsistency, style, low-impact gap
- **Info**: observation, suggestion, not a defect

After each batch, update TRACKER.md with findings and run the evaluate step.

**Cross-cutting synthesis** happens in every evaluation phase, not as a separate step. Each evaluate step asks: "What patterns emerge across artifacts evaluated so far?"
- Common failure modes (same bug in multiple files)
- Consistency violations (different patterns for same problem)
- Integration gaps (A references B but B doesn't know about A)
- Coverage gaps (what's NOT in scope that should be)

### Adversarial team

Triggered dynamically when the evaluate step finds:
- Rubric validity is disputed (is the rubric measuring the right things?)
- Findings have competing interpretations
- Severity assessments conflict across evaluators

Uses the ICD loop's standard adversarial team mechanics. Each agent writes to `team-{position-slug}.md`.

### Feedback arcs

Later findings can invalidate earlier conclusions. This is expected, not a failure. Built into the ICD evaluate step:
- Later finding contradicts earlier classification: update severity, note reason
- Evidence accumulates to change severity (3 "minor" instances of same pattern becomes "major" systemic issue)
- Cross-cutting pattern explains individual findings differently

All reclassifications logged in STATE.md iteration log and TRACKER.md.

## Post-Loop Remediation

Outside the ICD loop. Runs after the loop stops. Gated by user approval.

1. **Triage**: sort findings by severity x fix effort. Present to user for approval.
2. **Fix**: apply approved fixes. Sequence by dependency (fix foundations first).
3. **Verify**: re-read each fixed file. For code changes, run tests if available.
4. **Graduate**: extract generalizable learnings to LEARNINGS.md. Record mistakes in MISTAKES-LOG.md.

**Output**: Update TRACKER.md with fix status. Final summary.

## TRACKER.md Format

Single source of truth for audit artifact state:

```markdown
# Audit: {scope description}

**Date**: YYYY-MM-DD
**Status**: iterating / stopped / remediating / complete

## Scope

| # | Artifact | Type | Surface | Deep | Remediation |
|---|----------|------|---------|------|-------------|
| 1 | path/to/file | skill | pass | minor(2) | fixed |

## Findings

### [{severity}] {artifact}: {one-line summary}
{Details, evidence, location}
{If reclassified: [Updated iteration N: reason]}

## Cross-Cutting Patterns

{Systemic patterns found across artifacts}

## Reclassifications

| Iteration | Trigger | Change | Reason |
|-----------|---------|--------|--------|

## Learnings Extracted

{References to LEARNINGS.md entries created}
```

## Confidence Model

Audit findings use 2D confidence (see `investigation-loop.md`):
- **Likelihood**: How likely is this actually a defect? (almost certain / likely / even odds / unlikely)
- **Confidence**: How strong is the evidence? (high / moderate / low)

Most audit findings will be high confidence (we read the code). Likelihood varies: some are definite bugs, others are judgment calls about quality.

## Output

### 1. Conversation summary

Present findings grouped by severity. Lead with critical/major counts and systemic patterns.

### 2. Workspace

All files in `~/.claude/investigations/{area}/{scope-slug}/`:
- `STATE.md` -- investigation log, confidence trajectory, all iterations
- `TRACKER.md` -- artifact inventory and findings
- `eval-*.md` -- per-artifact deep evaluations
- `team-*.md` -- adversarial team findings (if escalated)

### 3. Learning extraction

Same rules as other investigation skills. Max 3 entries per audit.

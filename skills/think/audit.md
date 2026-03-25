# Audit Methodology

Detailed audit workflow for the /think meta-skill. Parent SKILL.md handles: workspace layout, ICD framework, confidence model, subagent basics, learning extraction.

## Audit Iteration Strategy

### First iteration: calibration + surface scan

1. **Define scope**: list all artifacts. Use Glob to enumerate files.
2. **Build evaluation rubric** per artifact type:
   - Skills: body-text routing, manifest references, step clarity, integration points, scope boundaries
   - Scripts: correctness, edge cases, portability, error handling
   - Config: valid structure, references resolve, no stale entries
   - Agents: mode clarity, defect taxonomy, evidence grading
3. **Verify tools work**: read a sample artifact to confirm access and format.
4. **Surface scan** (fast, parallelizable):
   - References resolve (file paths, cross-references, capability tags)
   - Formats valid (YAML frontmatter, markdown, script shebangs)
   - Permissions correct (scripts executable)
   - Naming conventions followed
   - No dead code or orphaned files
5. **Write STATE.md**: scope, rubric, surface scan findings.
6. **Write TRACKER.md**: initial scope inventory. Classify: `pass` / `minor` / `major` / `critical`.
7. **Evaluate**: artifacts needing deep review? Gaps in coverage?
8. **Decide**: deep rubric evaluation needed -> loop continues. Everything clean -> stop.

If prior state exists (resumed audit), read STATE.md and TRACKER.md, continue from there.

### Subsequent iterations: deep per-artifact evaluation

Evaluate artifacts against rubric in batches. Batch size driven by evaluate step.

**Meta-circularity rule**: if scope includes tools used by the audit itself, review those FIRST.

- Batch by dependency: foundations before consumers
- Max 3 concurrent subagents per batch
- Each subagent writes to `eval-{artifact-slug}.md`

**Subagent prompt specifics** (in addition to parent's shared patterns):
- **Authority framing**: "Definitive evaluator for [artifact]. Do not hedge. State what is true."
- **Tool sequence**: `Read (artifact) -> Grep (cross-references) -> Read (referenced files) -> evaluate and write`
- **Evidence depth**: each rubric dimension must cite file:line evidence

**Evaluation file format**:
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

**File verification**: after each batch, Glob for `eval-*.md`. Missing -> re-spawn once. Still missing -> note gap in TRACKER.md.

**Severity classification**:
- **Critical**: breaks functionality, security issue, data loss risk
- **Major**: significant gap, incorrect behavior, misleading output
- **Minor**: inconsistency, style, low-impact gap
- **Info**: observation, suggestion, not a defect

After each batch, update TRACKER.md and run evaluate step.

### Cross-cutting synthesis

Happens in EVERY evaluation phase, not as a separate step:
- Common failure modes (same bug in multiple files)
- Consistency violations (different patterns for same problem)
- Integration gaps (A references B but B doesn't know about A)
- Coverage gaps (what's NOT in scope that should be)

### Adversarial team

Triggered when evaluate finds: rubric validity disputed, competing interpretations, severity conflicts across evaluators.

### Feedback arcs

Later findings can invalidate earlier conclusions. Built into evaluate step:
- Contradiction -> update severity, note reason
- Accumulation (3 "minor" of same pattern -> "major" systemic)
- Cross-cutting pattern re-explains individual findings

All reclassifications logged in STATE.md and TRACKER.md.

## Post-Loop Remediation

Outside ICD. Runs after loop stops. Gated by user approval.

1. **Triage**: sort findings by severity x fix effort. Present for approval.
2. **Fix**: apply approved fixes. Sequence by dependency.
3. **Verify**: re-read each fixed file. Run tests if available.
4. **Graduate**: extract learnings to LEARNINGS.md. Record mistakes in MISTAKES-LOG.md.

Update TRACKER.md with fix status.

## TRACKER.md Format

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

## Output

Present findings grouped by severity. Lead with critical/major counts and systemic patterns.

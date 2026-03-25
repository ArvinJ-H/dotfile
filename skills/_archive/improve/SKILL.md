---
name: improve
description: Analyse ~/.claude/MISTAKES.md and ~/.claude/LEARNINGS.md for patterns and graduation candidates, then propose and apply amendments to CLAUDE.md, skills, or hooks. TRIGGER: user asks to improve the system, or accumulated entries need processing.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, AskUserQuestion
---

Analyse the self-improvement files and escalate anything that has reached threshold.

The improve skill follows Kolb's experiential learning cycle at the macro level: Experience (accumulated session work) → Reflect (review patterns, run analysis) → Conceptualize (draft amendment) → Experiment (apply amendment, enter probation).

## When to use

- User invokes `/improve`
- Session wrap-up detects accumulated MISTAKES.md/LEARNINGS.md entries ready for escalation
- `~/.claude/pending-improve` exists (set by skills providing `session-reflection` when promotion thresholds are hit)

After running, clear `~/.claude/pending-improve` if it exists.

## Target Map

### Tier 1 — Static routing by scope

| Scope | CLAUDE.md target | Skills/hooks target |
|-------|-----------------|---------------------|
| `global` | `~/.claude/CLAUDE.md` | `~/.claude/skills/`, `~/.claude/hooks/` |

<!-- PRIVATE:improve-scopes -->

## Steps

### 1. Read current state

Read all self-improvement files:
- `~/.claude/MISTAKES.md` (patterns)
- `~/.claude/MISTAKES-LOG.md` (individual entries)
- `~/.claude/LEARNINGS.md` (active)
- `~/.claude/LEARNINGS-ARCHIVE.md` (graduated)
- `~/.claude/CLAUDE.md` in full
- `~/.claude/skills/code-study/schedule.md` — check for overdue revisits (>2x interval past due)
- If in a project directory, read the project-level `CLAUDE.md` too

Scan `~/.claude/investigations/` for investigation files with Potential Learnings that may warrant graduation.

### 2. Triage

Summarise what step 1 found:
- Mistake categories at or near threshold (3+ entries, across 2+ sessions)
- High-confidence learnings ready for graduation
- Whether drift scripts are available (project directory with `.claude/scripts/`)
- Research files with ungraduated Potential Learnings
- Overdue study revisits from schedule.md (>2x interval past due)
- Amendment probation status (see DMAIC Control below)

Present the summary, then use AskUserQuestion:

| Option | Steps executed |
|--------|--------------|
| **Mistakes & learnings** | 3–5, then 7–9 |
| **Skill health** | 6, then 7–9 |
| **Full run** (Recommended) | 3–9 |

If nothing is pending in a category (e.g. zero mistakes, no drift scripts), note it and skip that option. If only one area has work, skip the question and run that area directly.

### 3. Tag-based cross-category analysis

Scan **Tags** across both files. 3+ entries sharing a tag but different categories → flag as cross-cutting pattern. Record findings for step 5.

**Cross-file correlation**: Check for mistake-learning pairs (preference learning + opposite mistake).
- `confidence: high` learning, no pattern yet → may justify proactive amendment without 3 mistakes.
- 2+ mistakes + related learning → treat as threshold hit (learning provides the "why").
- Flag correlated pairs in proposals.

### 4. Analyse mistakes

For each category in `MISTAKES-LOG.md` `## Log` with 3+ entries (across 2+ distinct sessions):
- Draft **Pattern** entry summarising root cause across occurrences.
- Route by **scope** (Target Map): `global` → CLAUDE.md/skill/hook; project-specific → Tier 2 skill or Tier 1 CLAUDE.md; multi-scope → nearest common ancestor.
- **Cross-pollination check** for project-specific scopes (if multiple related repos exist).
- Draft exact amendment. Escalate `major` → `moderate` → `minor`.

**Severity-weighted early promotion**: `severity: major` mistakes at N=2 may warrant promotion. Flag these as `status: provisional` with a note explaining the early promotion.

### 5. Analyse learnings

For each entry in `## Active`:
- `confidence: high` → ready for graduation.
- 2+ distinct dates in `Sessions` with `confidence: medium` → candidate to bump to high.

For each graduation candidate, route using scope (same logic as mistakes), cross-pollination check, and draft exact amendment.

### 6. Skill health check

Evaluate skill portfolio health. Three phases.

#### Phase A: Script-based drift detection (project skills)

If in a project directory with `.claude/scripts/detect-skill-drift.sh`:

1. Run `detect-skill-drift.sh` (full scan) from the project root.
2. Parse the structured output — each line is tagged:
   - `[STALE-PATH]` / `[STALE-SYM]` → skill references code that moved or was renamed. Disposition: **Update**.
   - `[DELETED]` → skill references deleted code. Disposition: **Update** or **Delete** (if the entire module is gone).
   - `[RENAMED]` → skill references old file name. Disposition: **Update**.
   - `[TIER3]` → generated summary outdated (file count changed). Disposition: **Regenerate** (run `generate-plugin-summaries.sh --plugins {name}`).
<!-- PRIVATE:improve-mirror-drift -->
   - `[CONTEXT]` → context file (`.claude/context/`) references deleted file. Disposition: **Update**.
3. Also run `validate-skill-content.sh` for structural issues (YAML integrity, deprecated APIs, size limits).

**Important**: Drift signals measure whether *the code the skill describes has changed*, not whether the skill has been "active." A skill with zero MISTAKES/LEARNINGS references is healthy if its code references still resolve — it just means the module is stable.

#### Phase B: Manual assessment (global skills + overlap)

For global skills (`~/.claude/skills/*/SKILL.md`) — no source code to validate against:
- Are all `allowed-tools` still valid tool names?
- Do referenced file paths in the skill body still exist?
- Is the skill internally consistent (step numbering, cross-references)?
- Has the skill been superseded by another skill or a CLAUDE.md amendment?
- Do skills producing research output use the workspace directory format (`investigations/{topic-slug}/` with README.md)?

For overlap detection (all skills):
- Do two skills' descriptions cover the same domain substantially?
- **Skip** intentionally shared skills across related repos.
<!-- PRIVATE:improve-mirror-overlap -->
- Substantial overlap between non-shared skills → disposition: **Merge**.

#### Phase C: Cross-skill reference validation

Verify the skill ecosystem is internally consistent:
- Skills providing `knowledge-recall` — sources list matches actual file locations (MISTAKES.md, LEARNINGS.md, investigations/, skills/, persona.md)
- Skills providing `adversarial-verification` — modes (scanner, adversarial, debate, completeness, feedback) match how callers invoke them
- Workspace format is consistent: both `external-research` and `codebase-investigation` use `investigations/{topic-slug}/` with README.md
- Body text uses capability tags from the manifest, not hardcoded `/skillname` references (except self-references)
- All capabilities in the CLAUDE.md Capability Manifest have matching skill files. Body-text routing references the manifest.
- Schedule.md overdue revisits: flag topics >2x interval past due for `codebase-learning` skill attention

Note discrepancies for step 7 proposals. This phase is lightweight — scan references, don't re-read entire skill bodies.

#### Dispositions

Record for step 7 proposals:
- **Keep**: No drift, or drift is minimal. Includes stable-but-unreferenced skills.
- **Update**: Drift detected — stale paths, symbols, renames. Skill content needs refresh (manual edit or partial regeneration).
- **Regenerate**: Tier 3 file count changed. Run `generate-plugin-summaries.sh --plugins {name}`.
<!-- PRIVATE:improve-mirror-dispositions -->
- **Merge**: Substantial overlap with another skill. Identify merge target.
- **Archive** (global): Move to `skills/_archived/{name}/SKILL.md`.
- **Delete** (project): Remove skill directory (git history preserves).

### 7. Present proposals

For each proposed change (including cross-cutting patterns from step 3):
```
**Proposal**: [one-line summary]
**Target**: [file path and section]
**Evidence**: [which mistake/learning entries led to this]
**Cross-pollination**: [if applicable — which other repo/skill may need the same change]
**Change**:
[exact text to add or modify, with enough context to locate it]
```

Use AskUserQuestion to get approval (or batch if many). Options: Approve / Skip / Modify.

### 8. Apply approved changes

For each approved proposal:
- Edit target file (Write if new). Use the Target Map above for valid paths and routing conventions. Mistakes: escalate pattern from `MISTAKES-LOG.md` → `MISTAKES.md` `## Patterns`. Learnings: graduate from `LEARNINGS.md` `## Active` → `LEARNINGS-ARCHIVE.md` `## Graduated` noting destination. Skip → leave as-is.
- **Tag promoted amendments** with `promoted_date: YYYY-MM-DD` and `status: provisional` in the Patterns entry.

**Creation path**: 3+ uncharted-domain entries → new skill (`[NEW]`). Automatable pattern → new hook (`[NEW]`).

**Maintenance paths** (from health check, step 6):
- **Update**: Edit the skill to fix stale references. Small drift (below `validate-skill-references.sh` threshold: <3 stale or <50% stale) → manual edit. At or above threshold (≥3 stale AND >50%) → regenerate. Note: accumulated small drift counts — 5 individually minor stale paths is large drift collectively.
- **Regenerate**: Run `{project}/.claude/scripts/generate-plugin-summaries.sh --plugins {name}` then review the output.
<!-- PRIVATE:improve-mirror-maintenance -->
- **Archive** (global): `mv skills/{name}/ skills/_archived/{name}/`. Create `_archived/` if needed.
- **Delete** (project): Remove skill directory. Note deletion in commit message.
- **Merge**: Copy unique content from source into target skill, then archive/delete the source.

**Self-referential**: `/improve` can propose `session-reflection` skill template changes (field additions only).

### 8.5. Cleanup

After applying changes:
- Delete applied patterns from `MISTAKES.md` (patterns whose proposed amendment is now in CLAUDE.md or a skill). Git preserves history.
- Delete escalated log entries from `MISTAKES-LOG.md` (entries whose category was moved to Patterns AND the pattern was applied). Retain log entries for non-applied patterns.
- Clear `~/.claude/pending-improve` if it exists.

### 9. DMAIC Control — Amendment verification

Check previously promoted amendments for effectiveness:

**Probation tracking**: Each amendment in `## Patterns` with `status: provisional` is in probation.
- **Validation**: 0 recurrences of the target mistake category during 5 subsequent sessions → `status: established`.
- **Failure**: Target category recurs during probation → amendment needs revision, not re-application. Flag for re-analysis.
- **Staleness**: 10+ sessions with no relevant situation → flag for review. The amendment may be solving a problem that no longer exists.

Report amendment statuses in the summary.

### 10. Summary

Report: patterns escalated, learnings graduated, files modified, cross-pollination actions taken or flagged, amendment probation statuses, remaining items close to threshold.

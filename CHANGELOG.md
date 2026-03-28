# Changelog

All notable changes to the public dotfiles repo.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Each commit should include a changelog entry.

## [2026-03-26] Meta-skill consolidation (43 to 9)

### Added
- `skills/think/SKILL.md` -- ICD-based meta-skill absorbing research, deepdive, challenge, audit, recall, data-analyst
- `skills/work/SKILL.md` -- ICD-based meta-skill absorbing plan, review, ship
- `skills/prompt/SKILL.md` -- prompt analysis skill with Capability Manifest routing in always-on behavior
- `skills/_archive/` -- 14 absorbed public skills preserved for reference
- `hooks/session-end-capture.sh` -- fixed invalid JSON output

### Changed
- `README.md` -- rewritten for 9-skill system: directory structure, skill table, compatibility matrix
- `hooks/pre-compact-capture.sh` -- fixed hook schema (hookSpecificOutput to systemMessage), updated skill refs
- `hooks/session-protocol.sh` -- updated `/reflect` to `Reflect workflow (/meta)`
- `reference/operational-rules.md` -- updated `/research` to `/think Research workflow`
- `reference/investigation-loop.md` -- updated `/recall` to `Recall workflow`
- `skills/code-study/SKILL.md` -- replaced old capability names with meta-skill refs
- `agents/verifier.md` -- removed stale `provides` frontmatter
- `settings.json` -- removed superpowers plugin, pruned one-off permissions
- Preamble files (MISTAKES-LOG.md, MISTAKES.md, LEARNINGS.md, LEARNINGS-ARCHIVE.md) -- replaced `/improve`, `/reflect`, `/recall` with meta-skill workflow refs

### Removed
- 14 standalone skill symlinks absorbed into meta-skills (research, deepdive, challenge, audit, recall, data-analyst, plan, review, ship, spark, stop-slop, ui-ux, chart-master, code-study references dir)
- `Skill(deepdive)` from permissions.allow
- superpowers plugin from enabledPlugins

## [2026-03-23] Migration review protocol

### Changed
- `skills/review/SKILL.md` -- added Migration Review Protocol: 11-step structured process (merge, validate against main, CI/build, final audit) for PM/build/CI migrations; migration signal detection and existing PR comment detection in context gathering; migration dynamic verifier angle

## [2026-03-17] ICD loop methodology

### Added
- `reference/investigation-loop.md` -- shared ICD (Investigate-Challenge-Decide) loop methodology for investigation skills
- `reference/subagent-prompting-patterns.md` -- reusable prompt construction patterns for subagents (evidence depth, tool diversity, budget awareness, authority framing)
- `skills/audit/` -- systematic multi-artifact evaluation using ICD loop
- `skills/challenge/` -- adversarial + divergent review of any deliverable
- Challenge prompt block and loop state assessment block in subagent-prompting-patterns.md
- ICD Loop column in subagent-prompting-patterns.md applicability matrix

### Changed
- `skills/deepdive/SKILL.md` -- replaced fixed tiers (1/2/3) with self-regulating ICD loop + deepdive iteration strategy
- `skills/research/SKILL.md` -- replaced fixed tiers (1/2/3) with self-regulating ICD loop + research iteration strategy
- `skills/plan/SKILL.md` -- Phase 4 audit hardening now uses ICD evaluate step instead of fixed 3-pass verification
- `reference/operational-rules.md` -- added cross-reference to subagent-prompting-patterns.md
- `README.md` -- updated directory structure, skills table, and reference files table to reflect new files and skills

### Removed
- Fixed tier/ring methodology from deepdive and research skills (replaced by adaptive ICD loop)
- Fixed 3-pass verification from plan skill Phase 4 (replaced by dynamic evaluation)
- Hardcoded subagent depth minimums (replaced by dynamic, proportional-to-complexity approach)

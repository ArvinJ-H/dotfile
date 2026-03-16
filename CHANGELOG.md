# Changelog

All notable changes to the public dotfiles repo.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Each commit should include a changelog entry.

## [2026-03-17] ICD loop methodology

### Added
- `reference/investigation-loop.md` -- shared ICD (Investigate-Challenge-Decide) loop methodology for investigation skills
- `reference/subagent-prompting-patterns.md` -- reusable prompt construction patterns for subagents (evidence depth, tool diversity, budget awareness, authority framing)
- `skills/audit/` -- systematic multi-artifact evaluation using ICD loop (moved from private, no sensitive content)
- `skills/challenge/` -- adversarial + divergent review of any deliverable (moved from private, no sensitive content)
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

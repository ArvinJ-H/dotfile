---
name: recall
description: Search accumulated knowledge across research files, learnings, mistakes, and skills. Use when checking "what do I already know about X?" TRIGGER: checking prior knowledge before new work, or another skill needs topic context.
allowed-tools: Read, Glob, Grep
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

Search all knowledge sources for information on a topic.

## Sources (searched in priority order)

1. `~/.claude/MISTAKES.md` — patterns (highest signal: "don't do this again")
2. `~/.claude/MISTAKES-LOG.md` — individual mistake entries (may contain recent entries not yet escalated to patterns)
3. `~/.claude/LEARNINGS.md` — active observations
4. `~/.claude/LEARNINGS-ARCHIVE.md` — graduated learnings (still searchable; maps entries to their promotion targets)
5. `~/.claude/investigations/**/*.md` — research and deepdive findings (workspace README.md files)
6. `~/.claude/audit/**/TRACKER.md` — audit findings and extracted learnings
7. `~/.claude/skills/*/SKILL.md` — skill definitions
8. `~/.claude/persona.md` — knowledge gaps and comfort levels
9. Project-level `.claude/skills/*/SKILL.md` — project skills (if in a project)
10. `~/.claude/projects/*/memory/*.md` — auto memory (intake buffer; entries may lack structured metadata)

## Steps

1. Grep all sources for the topic keyword(s). Use multiple search terms if the topic has synonyms or related concepts.
2. For investigation workspaces (directories with README.md + sub-*.md files), read the README.md first — it's the synthesized deliverable. Only read sub-files if the README doesn't cover the specific question.
3. For flat files in `_archive/`, read matched sections in context (not full files).
4. Read matched sections from MISTAKES.md and LEARNINGS.md. Note confidence levels on learning entries. For auto memory matches (source 8), treat entries as `confidence: low` unless they cross-reference a LEARNINGS.md entry with higher confidence.
5. Check persona.md Knowledge Gaps and Technical Knowledge for the topic area — surface comfort level if relevant.
6. Synthesize into structured output (see Output Format below).

## Output Format

Structure findings into four sections:

### Known
Findings from sources with strong evidence. Include:
- Source reference (file path or entry title)
- Confidence level (from LEARNINGS.md entries, or inferred: Tier 1-2 research = high, Tier 3-4 = medium)
- Relevant mistake patterns (if any)

### Uncertain
Findings with `confidence: low` or `confidence: medium`, or from Tier 3-4 sources only. Include the uncertainty reason.

### Not Found
Sub-questions where no knowledge exists in any source. Explicitly list what was searched and came up empty.

### Suggested Next
- If significant gaps: at scope boundary, read the Skill Discovery Protocol manifest in CLAUDE.md. Find providers for `external-research` or `codebase-investigation`. Present via AskUserQuestion.
- If uncertain findings could be verified: suggest specific verification steps.
- If nothing found: state clearly — "No prior knowledge on this topic."

## Ranking within results

When multiple sources match, present in this priority order:
1. MISTAKES.md patterns matching current scope → highest (preventing known errors)
2. High-confidence learnings matching current scope → high
3. Investigation findings from Tier 1-2 sources → medium-high
4. Skill definitions referencing the topic → medium
5. Low-confidence learnings, Tier 3-4 research, or auto memory entries → low (present under Uncertain)

Recency breaks ties within the same priority level. For volatile domains (APIs, libraries), prefer newer findings.

### 2D→1D confidence collapse

Deepdive and research produce 2D findings (Likelihood + Confidence). For ranking, collapse to 1D using conservative min(likelihood_tier, confidence_tier):

| Confidence | Likelihood: almost certain/likely | Likelihood: even odds | Likelihood: unlikely/remote |
|------------|----------------------------------|----------------------|---------------------------|
| high | high | medium | low |
| moderate | medium | medium | low |
| low/very low | low | low | low |

Apply this when ranking 2D findings against 1D sources (LEARNINGS.md, MISTAKES.md).

## Auto-trigger

Surfaces as a `recommended: true` variable process in other skills' AskUserQuestion menus. When selected, populates "known vs unknown" assessment. Mark covered sub-questions so subsequent tiers don't re-investigate them.

Can also be invoked standalone: `/recall event handling` or `/recall iframe testing`.

## Integration

/recall is a read-only search skill. It does not modify any files. Its output feeds into:
- Investigation skills (`codebase-investigation`, `external-research`) as variable process (skip known sub-questions)
- Skills providing `prompt-refinement` as context enrichment (incorporate findings into refined prompt)
- Skills providing `self-improvement` indirectly (recall surfaces patterns that may be acted on)
- Session protocol "On Start" step (MISTAKES.md patterns and high-confidence learnings)

---
name: research
description: General-purpose external research using web, docs, and all available sources. Tiered escalation, auto-depth, structured deliverables. Use when investigating topics outside the codebase. TRIGGER: questions requiring info outside the codebase. Prefer newer references; cross-check all.
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, Task, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, ToolSearch, AskUserQuestion, Edit, Write
provides:
  - external-research
scope-boundary:
  - codebase-investigation
---

External research skill. Investigates topics, technologies, concepts, and problems using web search, documentation, and any available source.

**Scope boundary: `codebase-investigation`** — find providers via capability tags in other skills' frontmatter. If a question spans both internal and external, start with /research for the external component.

## Core principle: evidence-backed findings

Every claim in the output must be traceable to a source. No unsourced assertions.

Prioritize sources by credibility:

| Tier | Source type | Trust level |
|------|-----------|-------------|
| **1 — Authoritative** | Official docs, specs, RFCs, peer-reviewed papers, core maintainer statements | High — use as primary evidence |
| **2 — Vetted** | Reputable technical publications, well-cited conference talks, established reference books | High — use freely, cross-reference when possible |
| **3 — Community** | Stack Overflow (high-vote), widely-cited blog posts, official forums | Medium — use with attribution, verify against Tier 1-2 when available |
| **4 — Anecdotal** | Individual blog posts, tutorials, low-vote forum posts, social media | Low — use only to supplement, never as sole evidence for a claim |

**Rules:**
- **Prefer Tier 1-2 sources.** Actively seek official docs and papers before settling for community sources.
- **Flag credibility gaps.** If a finding rests only on Tier 3-4 sources, mark it explicitly: `[low confidence — community sources only]`.
- **Contradictions default up.** When sources conflict, the higher-tier source wins unless the lower-tier source provides concrete, verifiable counter-evidence.
- **Recency matters.** On fast-moving topics (frameworks, APIs, cloud services), flag sources older than 1 year. Prefer recent Tier 2 over stale Tier 1.
- **No hallucinated citations.** If you can't find a credible source, say so. "No authoritative source found" is better than a fabricated reference.
- **Recency preference**: Prefer newer sources over older ones — the more recent the better. However, always cross-check claims across multiple references regardless of age to validate correctness. A newer source is preferred for framing, but an older authoritative source that contradicts it should be flagged, not ignored.

## When to use

- Evaluating libraries, frameworks, tools ("X vs Y")
- Understanding external concepts, protocols, patterns
- Architecture research and best practices
- Troubleshooting issues in external dependencies
- Any question where the answer lives outside the codebase

NOT for: capabilities in `scope-boundary`. At scope boundaries, read manifest and present providers via AskUserQuestion. Not for searching accumulated knowledge (`knowledge-recall`).

## Invocation

`/research [flags] topic`

- `/research topic` — auto-escalate through all applicable tiers, report at end
- `/research --quick topic` — Tier 1 only, no escalation
- `/research --shallow topic` — Tier 1 + Tier 2, skip Tier 3

## Deliverable detection

Auto-detect from the research question. Classify before starting Tier 1:

| Type | Trigger | Output shape |
|------|---------|-------------|
| **Comparison** | "X vs Y", "which library", evaluating options | Matrix + recommendation + trade-off analysis |
| **Explainer** | "how does X work", "what is", concept learning | Structured breakdown with sources, key concepts, gotchas |
| **Decision brief** | "should we use", architecture choices, approach selection | Context → Options → Recommendation → Risks |
| **Implementation guide** | "how to implement", "migration steps", "step-by-step" | Prerequisites → Steps → Gotchas → Verification |
| **Troubleshooting** | "why does X fail", debugging external issues | Symptoms → Causes → Solutions → Verification steps |
| **General report** | Anything else | Findings → Analysis → Open questions |

State the detected type at the start. If ambiguous, default to General report.

## Research workspace

Each research session creates a workspace folder. **No scope in path** — scope metadata lives inside files:

```
~/.claude/investigations/{topic-slug}/
  README.md              — final synthesized deliverable
  tier-1-survey.md       — Tier 1 findings + escalation scorecard
  sub-{question-slug}.md — Tier 2 subagent findings (one per sub-question)
  team-{position}.md     — Tier 3 teammate findings (one per position)
```

**Rules:**
- **Create the folder at Tier 1 start.** Check `~/.claude/investigations/{slug}/` for prior work on the same topic — build on previous work, don't duplicate it.
- **Subagents and teammates write findings to their own file.** They receive the workspace path and their assigned filename. This is mandatory — do not return findings only via message.
- **Lead agent reads files to synthesize.** After subagents/teammates complete, read their files rather than relying on message content. This keeps the context window lean.
- **README.md is written last** — the final synthesized deliverable, referencing intermediate files where useful.
- **Intermediate files are the audit trail.** Don't delete them after synthesis. They document what each agent found and from which sources.

## Tiers

Always start at Tier 1. Auto-escalate based on gates. No checkpoints unless --quick or --shallow.

### Tier 1 — Scope and survey

1. **Create the workspace folder** at `~/.claude/investigations/{topic-slug}/`. If prior work exists, read existing files first.
2. Use `mcp__sequential-thinking__sequentialthinking` to decompose the question:
   - Break into sub-questions (anchor first-level split in the topic's actual structure, not a generic framework)
   - Map what's known (/recall results) vs. unknown
   - Map the search surface
3. Run initial web searches (WebSearch) to establish landscape — key sources, major players, recent developments.
4. Check context7 and DeepWiki for relevant library/repo docs.
5. **Source audit**: For each sub-question, note the highest credibility tier reached. If any sub-question has only Tier 3-4 sources, flag it and actively search for Tier 1-2 alternatives before proceeding.
6. Fill the Escalation Scorecard.
7. **Write `tier-1-survey.md`** to the workspace — sub-questions, /recall findings summary, initial search findings, source audit, scorecard. This persists the Tier 1 work and frees context.

**Escalation Scorecard:**
- Distinct sub-questions requiring separate investigation: ___
- Competing/contradictory sources found: yes / no
- Depth of topic (surface-level answers available vs. requires synthesis): shallow / deep
- Number of credible sources to evaluate: ___
- Source credibility gaps (sub-questions with no Tier 1-2 sources): ___

**Escalate to Tier 2 if ANY**: 3+ sub-questions, contradictory sources, deep topic, 5+ sources to evaluate, or credibility gaps on critical sub-questions.

### Tier 2 — Parallel deep-dive

Spawn subagents (Task tool, subagent_type: general-purpose) for parallel investigation:
- Each agent gets a distinct sub-question or source cluster
- Max 4 concurrent agents
- Each agent: search, read sources, extract key findings
- **Each agent must track source credibility** — findings without Tier 1-2 backing are flagged in their report
- **Each agent writes findings to `sub-{question-slug}.md`** in the workspace. Include in the agent prompt: the workspace path, the target filename, and the file format (see below)

**Subagent file verification**: After all agents complete, verify each expected `sub-*.md` file exists using Glob. If a file is missing:
1. Re-spawn the agent once with an explicit reminder to write the file.
2. If the file is still missing after re-spawn, note the gap in synthesis — do not reconstruct findings from the agent's return message.

**Subagent file format:**
```markdown
# {Sub-question}

**Agent**: {agent description}
**Date**: YYYY-MM-DD

## Findings

{Key findings with source citations}

## Sources

{Numbered list: URL, title, date, credibility tier}

## Gaps

{What couldn't be answered, weak sourcing areas}
```

After all agents complete and files are verified, **read their files** to collect and cross-reference findings. Do not rely solely on agent return messages.

**Tier 3 gates** — escalate only if ALL are YES:
1. **Genuinely contested?** Credible (Tier 1-2) sources disagree on substance (not just framing)
2. **Trade-offs non-obvious?** A knowledgeable engineer would need context to choose
3. **Multi-dimensional?** The comparison involves 3+ independent evaluation axes
4. **Synthesis needed?** Individual source findings don't add up to a clear answer

### Tier 3 — Adversarial synthesis

Spawn an agent team (TeamCreate):
- Assign agents to competing positions or evaluation dimensions
- Each agent argues their position with evidence and sources — **Tier 1-2 sources required for core arguments**
- **Each agent writes findings to `team-{position-slug}.md`** in the workspace. Include the workspace path and target filename in their task assignment.
- Synthesis agent reads all `team-*.md` files + `sub-*.md` files from Tier 2, reconciles findings, identifies where disagreement is genuine vs. resolvable
- Produce the final deliverable with explicit confidence levels per conclusion

## Output

### 1. Conversation summary

Present the deliverable in chat, formatted per the detected type. Lead with the answer/recommendation.

Include for every finding:
- **Likelihood**: How likely is this claim? (almost certain / likely / even odds / unlikely / almost certainly not)
- **Confidence**: How strong is the evidence? Mapped from source tiers:
  - Tier 1-2 sources → high
  - Tier 3 sources → moderate
  - Tier 4 sources → low
- **Evidence basis**: which source tier(s) support it
- **Recency**: flag anything >1 year old on fast-moving topics

These two dimensions are orthogonal. A claim can be likely (most evidence points that way) but low confidence (evidence is all Tier 4 blog posts). See deepdive SKILL.md for the 2D→1D collapse table used by downstream consumers.

### 2. Research workspace

The workspace at `~/.claude/investigations/{topic-slug}/` already contains intermediate files from each tier. Write the final `README.md` as the synthesized deliverable:

```markdown
# {Topic title}

**Date**: YYYY-MM-DD
**Scope**: {scope}
**Type**: {comparison|explainer|decision-brief|implementation-guide|troubleshooting|general}
**Tiers used**: {1, 2, 3}
**Query**: {original research question}

## Summary

{1-3 sentence executive summary}

## Findings

{Structured findings per deliverable type. Each claim cites its source by number.}

## Sources

{Consolidated numbered list from all agents: URL, title, date, credibility tier, relevance note}

## Credibility Assessment

{Overall evidence quality. Which findings are well-supported (Tier 1-2) vs. relying on weaker sources. Explicit gaps where no authoritative source was found.}

## Open Questions

{Unresolved items, areas where sources disagree without resolution}

## Workspace Contents

{List of intermediate files with one-line descriptions — for traceability}
- `tier-1-survey.md` — initial scope, sub-questions, scorecard
- `sub-*.md` — Tier 2 subagent findings
- `team-*.md` — Tier 3 teammate findings

## Potential Learnings

{Observations that may warrant LEARNINGS.md entries}
```

### 3. Learning extraction

Same rules as other investigation skills:
- Capture generalizable observations in LEARNINGS.md
- `confidence: low`, `action: needs-verification`, `source: research`
- Max 3 entries per research session

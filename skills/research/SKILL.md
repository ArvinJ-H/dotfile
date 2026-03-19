---
name: research
description: General-purpose external research using web, docs, and all available sources. ICD loop with source credibility tracking. Use when investigating topics outside the codebase. TRIGGER: questions requiring info outside the codebase. Prefer newer references; cross-check all.
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, Task, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, ToolSearch, AskUserQuestion, Edit, Write
---

External research skill. Investigates topics, technologies, concepts, and problems using web search, documentation, and any available source. Uses the **ICD loop** (see `~/.claude/reference/investigation-loop.md`) with research-specific iteration strategy.

**Scope boundary: `codebase-investigation`** -- look up the capability in the CLAUDE.md Capability Manifest and invoke the provider. If a question spans both internal and external, start with /research for the external component.

## Core principle: evidence-backed findings

Every claim in the output must be traceable to a source. No unsourced assertions.

Prioritize sources by credibility:

| Tier | Source type | Trust level |
|------|-----------|-------------|
| **1 -- Authoritative** | Official docs, specs, RFCs, peer-reviewed papers, core maintainer statements | High -- use as primary evidence |
| **2 -- Vetted** | Reputable technical publications, well-cited conference talks, established reference books | High -- use freely, cross-reference when possible |
| **3 -- Community** | Stack Overflow (high-vote), widely-cited blog posts, official forums | Medium -- use with attribution, verify against Tier 1-2 when available |
| **4 -- Anecdotal** | Individual blog posts, tutorials, low-vote forum posts, social media | Low -- use only to supplement, never as sole evidence for a claim |

**Rules:**
- **Prefer Tier 1-2 sources.** Actively seek official docs and papers before settling for community sources.
- **Flag credibility gaps.** If a finding rests only on Tier 3-4 sources, mark it explicitly: `[low confidence -- community sources only]`.
- **Contradictions default up.** When sources conflict, the higher-tier source wins unless the lower-tier source provides concrete, verifiable counter-evidence.
- **Recency matters.** On fast-moving topics (frameworks, APIs, cloud services), flag sources older than 1 year. Prefer recent Tier 2 over stale Tier 1.
- **No hallucinated citations.** If you can't find a credible source, say so. "No authoritative source found" is better than a fabricated reference.
- **Recency preference**: Prefer newer sources over older ones. Always cross-check claims across multiple references regardless of age. A newer source is preferred for framing, but an older authoritative source that contradicts it should be flagged, not ignored.

## When to use

- Evaluating libraries, frameworks, tools ("X vs Y")
- Understanding external concepts, protocols, patterns
- Architecture research and best practices
- Troubleshooting issues in external dependencies
- Any question where the answer lives outside the codebase

NOT for: capabilities in `scope-boundary`. At scope boundaries, read manifest and present providers via AskUserQuestion. Not for searching accumulated knowledge (`knowledge-recall`).

## Invocation

`/research topic`

The ICD loop self-regulates depth. Simple questions resolve in iteration 1. Complex topics with contradictory sources or deep synthesis needs keep iterating. The user can always intervene.

## Deliverable detection

Auto-detect from the research question. Classify before starting iteration 1:

| Type | Trigger | Output shape |
|------|---------|-------------|
| **Comparison** | "X vs Y", "which library", evaluating options | Matrix + recommendation + trade-off analysis |
| **Explainer** | "how does X work", "what is", concept learning | Structured breakdown with sources, key concepts, gotchas |
| **Decision brief** | "should we use", architecture choices, approach selection | Context > Options > Recommendation > Risks |
| **Implementation guide** | "how to implement", "migration steps", "step-by-step" | Prerequisites > Steps > Gotchas > Verification |
| **Troubleshooting** | "why does X fail", debugging external issues | Symptoms > Causes > Solutions > Verification steps |
| **General report** | Anything else | Findings > Analysis > Open questions |

State the detected type at the start. If ambiguous, default to General report.

## Research workspace

Per the ICD loop spec:

```
~/.claude/investigations/<area>/{topic-slug}/
  STATE.md          -- iteration log, confidence trajectory, accumulated findings, active gaps
  README.md         -- final synthesized answer (written at loop exit)
  sub-{slug}.md     -- subagent findings (created as needed, one per sub-question)
  team-{slug}.md    -- adversarial team output (created if escalated)
```

<!-- PRIVATE:research-area-routing -->

**Rules:**
- **Create the folder at iteration 1 start.** Check `~/.claude/investigations/<area>/{slug}/` for prior work on the same topic -- build on previous work, don't duplicate it.
- **Subagents and teammates write findings to their own file.** They receive the workspace path and their assigned filename. Mandatory -- do not return findings only via message.
- **Lead agent reads files to synthesize.** After subagents/teammates complete, read their files rather than relying on message content.
- **README.md is written last** -- the final synthesized deliverable at loop exit.
- **Intermediate files are the audit trail.** Don't delete them after synthesis.

## Research Iteration Strategy

Follows the ICD loop (investigate-challenge-decide). Each iteration uses the loop's 6-step structure. This section defines what's research-specific.

### First iteration (typical)

1. **Create workspace** at `~/.claude/investigations/<area>/{slug}/`. If prior work exists, read existing files first.
2. **Decompose** using `mcp__sequential-thinking__sequentialthinking`:
   - Break into sub-questions (anchor first-level split in the topic's actual structure, not a generic framework)
   - Map what's known (/recall results) vs. unknown
   - Map the search surface
3. **Initial survey**: run web searches (WebSearch) to establish landscape. Check context7 and DeepWiki for relevant library/repo docs.
4. **Source audit**: for each sub-question, note the highest credibility tier reached. If any sub-question has only Tier 3-4 sources, flag it and actively search for Tier 1-2 alternatives.
5. **Write STATE.md** -- sub-questions, /recall findings summary, initial search findings, source audit.
6. **Evaluate** (ICD step 5): first iteration criteria:
   - Distinct sub-questions requiring separate investigation: ___
   - Competing/contradictory sources found: yes / no
   - Depth of topic (surface-level answers available vs. requires synthesis): shallow / deep
   - Number of credible sources to evaluate: ___
   - Source credibility gaps (sub-questions with no Tier 1-2 sources): ___
7. **Decide** (ICD step 6): if ANY of 3+ sub-questions, contradictory sources, deep topic, 5+ sources to evaluate, or credibility gaps on critical sub-questions, the loop continues. Otherwise stop and report.

If prior state exists (resumed investigation, pre-decomposed prompt), the loop reads STATE.md and skips to where it's needed.

### Subsequent iterations

Spawn subagents for parallel source analysis. Count driven by gap scope, max 4 concurrent agents.

- Each agent gets a distinct sub-question or source cluster
- Each agent: search, read sources, extract key findings
- **Each agent must track source credibility** -- findings without Tier 1-2 backing are flagged
- **Each agent writes findings to `sub-{question-slug}.md`** in the workspace

**Subagent prompt construction**: use the standard template from `~/.claude/reference/subagent-prompting-patterns.md`. Apply evidence depth, tool diversity, budget awareness, and self-tracking patterns. Depth is proportional to the sub-question's complexity; no fixed minimums.

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

**Subagent file verification**: After all agents complete, verify each expected `sub-*.md` file exists using Glob. If missing: re-spawn once with explicit file-write reminder. If still missing: note gap in STATE.md, do not reconstruct from agent messages.

After files verified, **read them** to cross-reference findings. Update STATE.md with accumulated findings, then run the evaluate step.

### Adversarial team

Triggered dynamically when sources conflict or interpretations diverge (ICD adversarial team escalation). Uses TeamCreate with assigned positions.

- Each agent argues their position with evidence -- **Tier 1-2 sources required for core arguments**
- Each agent writes to `team-{position-slug}.md` in the workspace
- Synthesis agent reads all `team-*.md` + `sub-*.md` files, reconciles, identifies genuine vs. resolvable disagreement

## Output

### 1. Conversation summary

Present the deliverable in chat, formatted per the detected type. Lead with the answer/recommendation.

Include for every finding:
- **Likelihood**: How likely is this claim? (almost certain / likely / even odds / unlikely / almost certainly not)
- **Confidence**: How strong is the evidence? Mapped from source tiers:
  - Tier 1-2 sources: high
  - Tier 3 sources: moderate
  - Tier 4 sources: low
- **Evidence basis**: which source tier(s) support it
- **Recency**: flag anything >1 year old on fast-moving topics

These two dimensions are orthogonal. See `investigation-loop.md` for the 2D confidence model and collapse table.

### 2. Research workspace

Write the final `README.md` at loop exit:

```markdown
# {Topic title}

**Date**: YYYY-MM-DD
**Scope**: {scope}
**Type**: {comparison|explainer|decision-brief|implementation-guide|troubleshooting|general}
**Iterations**: {N}
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

- `STATE.md` -- investigation log, confidence trajectory, all iterations
- `sub-*.md` -- subagent findings
- `team-*.md` -- adversarial team findings (if escalated)

## Potential Learnings

{Observations that may warrant LEARNINGS.md entries}
```

### 3. Learning extraction

Same rules as other investigation skills:
- Capture generalizable observations in LEARNINGS.md
- `confidence: low`, `action: needs-verification`, `source: research`
- Max 3 entries per research session

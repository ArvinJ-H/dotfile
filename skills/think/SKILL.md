---
name: think
description: Analysis, investigation, evaluation, data reasoning. Invoke at even 1% chance the task involves thinking, research, analysis, challenge, audit, recall, or data.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, WebSearch, WebFetch, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, ToolSearch, AskUserQuestion, mcp__sequential-thinking__sequentialthinking
---

Scope boundary: for implementation invoke /work. For creative output invoke /create.

## Router

| Signal | Workflow | Type |
|---|---|---|
| External info, web sources, library evaluation, "how does X work" | [Research](#research) | ICD |
| Complex multi-component codebase question, 3+ interconnected systems | [Deepdive](#deepdive) | ICD |
| "Poke holes", "challenge this", adversarial review, "what if" | [Challenge](#challenge) | Single-pass |
| Systematic evaluation of a scope, quality assessment | [Audit](#audit) | ICD |
| "What do I know about", prior knowledge check | [Recall](#recall) | Single-pass |
| Data, statistics, CSV, analysis, BI reasoning, metrics | [Data Analyst](#data-analyst) | AQCTAV |
| Unclear | Ask, or default Research | |

Workflows chain: Recall as pre-flight for Research/Deepdive. Challenge as evaluation phase within any ICD workflow. Data Analyst feeding into Research for evidence.

## ICD Framework

ICD workflows (Research, Deepdive, Audit) follow a per-iteration loop. Every iteration runs these 6 steps in order. Do not skip or reorder. Mechanical details in `~/.claude/reference/investigation-loop.md`.

### Per-iteration loop

**Step 1 -- Read state**: read STATE.md before doing anything else. First iteration: create STATE.md with scope, questions, and initial confidence. Subsequent: re-read STATE.md, assess what changed. STATE.md format is defined in `investigation-loop.md` (includes: scope, findings with evidence basis, confidence history table, active gaps, iteration log, stop challenge record).

**Step 2 -- Plan work**: determine what will move the investigation forward. The specific mode, team composition, agent count, and tool selection emerge from the state assessment. They are outputs of this step, not inputs from a lookup table.

**Step 3 -- Execute**: do the planned work per the workflow's iteration strategy. Create workspace at `~/.claude/investigations/<area>/{slug}/`. Pre-flight: Recall for the topic. Decompose via `mcp__sequential-thinking__sequentialthinking` (anchor in problem structure, not generic frameworks).

**Step 4 -- Self-assess**: update STATE.md with what changed this iteration. What was learned, what shifted, what's still open. Update 2D confidence (likelihood + evidence quality).

**Step 5 -- Evaluate**: compose a verification layer from available tools, proportional to what the findings need. Tools run in parallel:
- Self-assessment (from step 4)
- Adversarial team: multi-perspective debate, team size scales dynamically
- [Challenge](#challenge) pass: assumptions + unconsidered paths
- Audit pass: completeness, rubric compliance
- Verifier agent: code/artifact correctness
- Any combination: not a lookup table. Compose based on what findings need.

**Step 6 -- Decide**: determine next action based on what the verification layer found. Core question: "would another iteration change the conclusions?" If yes, continue. If findings stabilized and no critical gaps, stop and produce output.
- **Stop challenge**: "is stopping premature?" Depth proportional to remaining uncertainty.
- **Safety valve**: 5 iterations without convergence -> pause, ask user.
- **Exit**: write README.md.

### Shared Infrastructure

**Workspace** (ICD workflows):
```
~/.claude/investigations/<area>/{slug}/
  STATE.md       -- iteration log, confidence, gaps (living document)
  README.md      -- final deliverable (at exit)
  sub-{slug}.md  -- subagent findings (one per sub-question)
  team-{slug}.md -- adversarial team output (if escalated)
  TRACKER.md     -- audit only: artifact inventory + findings
  eval-{slug}.md -- audit only: per-artifact evaluation
```

**Subagents**: per `~/.claude/reference/subagent-prompting-patterns.md`. Requirements: authority framing, tool hints, evidence depth, budget awareness, self-tracking. Each agent writes to workspace (mandatory, not message-only).

**File verification**: Glob for expected files after agents complete. Missing -> re-spawn once. Still missing -> note gap in STATE.md.

**Confidence**: 2D model (likelihood x evidence quality). See investigation-loop.md for levels, collapse table, and stopping criteria.

**Learning extraction**: max 3 entries per session. `confidence: low`, `action: needs-verification`.

---

## Research

External research via web, docs, all available sources.

**Core principle**: every claim must be traceable to a source. No unsourced assertions.

**Scope boundary**: codebase questions -> Deepdive instead.

<!-- PRIVATE:think-research-area-routing -->

### Source Credibility

| Tier | Source type | Trust |
|------|-----------|-------|
| 1 | Official docs, specs, RFCs, peer-reviewed papers | Primary evidence |
| 2 | Reputable publications, conference talks, reference books | Free use, cross-reference |
| 3 | SO (high-vote), cited blogs, official forums | Verify against Tier 1-2 |
| 4 | Individual blogs, tutorials, low-vote posts, social media | Supplement only |

Prefer Tier 1-2. Flag credibility gaps. Contradictions default to higher tier. Flag >1yr sources on fast-moving topics. No hallucinated citations.

### Deliverable Detection

| Type | Trigger | Shape |
|------|---------|-------|
| Comparison | "X vs Y", evaluating options | Matrix + recommendation + trade-offs |
| Explainer | "how does X work" | Breakdown, sources, gotchas |
| Decision brief | "should we use" | Context > Options > Recommendation > Risks |
| Implementation guide | "how to", "step-by-step" | Prerequisites > Steps > Gotchas > Verification |
| Troubleshooting | "why does X fail" | Symptoms > Causes > Solutions > Verification |
| General | Anything else | Findings > Analysis > Open questions |

### Iteration Strategy

**First iteration**:
1. Decompose: break into sub-questions, map known (from Recall) vs unknown.
2. Initial survey: WebSearch to establish landscape.
3. Source audit: for each sub-question, note the highest credibility tier reached. If any has only Tier 3-4 sources, flag and actively search for Tier 1-2 alternatives.
4. Write STATE.md, evaluate.

Continue if: 3+ sub-questions, contradictory sources, deep topic, 5+ sources, or credibility gaps on critical sub-questions.

**Subsequent**: parallel subagents (max 4) for source analysis. Each: search, read, extract, track credibility tier. Write `sub-{slug}.md`.

Format per subagent file:
```markdown
# {Sub-question}
**Agent**: {description} | **Date**: YYYY-MM-DD
## Findings
{Key findings with source citations}
## Sources
{Numbered: URL, title, date, credibility tier}
## Gaps
{What couldn't be answered, weak sourcing areas}
```

### Output

Per deliverable type. Each finding: likelihood, confidence, evidence basis (tier), recency flag. README.md: consolidated sources with credibility assessment.

---

## Deepdive

Deep codebase investigation using decomposition and parallel subagents.

**Rule**: always write findings to disk. Do not hold findings in context only. Every iteration updates STATE.md.

**Scope boundary**: external/web questions -> Research instead. If question spans both, Deepdive handles codebase component.

<!-- PRIVATE:think-deepdive-area-routing -->

### Auto-trigger

Run autonomously when ALL true:
- 3+ interconnected components
- Initial exploration raises more questions than answers
- Existing skills/research don't cover it
- User energy suggests exploration

Cost-conservative: strict first-iteration criteria.

### Iteration Strategy

**First**: decompose via sequential thinking (anchor in problem structure, justify branch choices) -> map sub-questions with evidence requirements -> STATE.md -> evaluate.

Continue if: 3+ sub-questions, 3+ components, 3+ unknowns, competing hypotheses, outside coverage.

**Subsequent**: parallel subagents (max 3). Codebase sequence: `Grep (entry points) -> Read (context) -> Grep (references) -> Read (connected code)`. Each writes `sub-{slug}.md` with evidence source table: `| # | Source (file:line or URL) | Tool | Key Finding |`.

### Output

Lead with answer, then evidence. Each finding: likelihood + confidence, evidence basis, dissent (if any).

---

## Challenge

Lightweight adversarial + divergent review. Single-pass (~2 minutes). Both lenses by default.

`--quick` for adversarial only.

### Input Normalization

| Input type | Detection | Decomposition |
|-----------|-----------|--------------|
| Plan/design | Phases, steps, files to modify | Component-by-component |
| Code diff | File paths, +/- lines | Change-by-change |
| Freeform idea | No structure | Assumption extraction |
| Architecture | Boundaries, data flow | Interface-by-interface |

### Steps

1. **Classify** input type. State it.
2. **Check prior audit**: if plan has audit trail, scope accordingly.
3. **Decompose** via sequential thinking (fallback: structured self-reasoning):
   - Assumption inventory: what must be true?
   - Attack surface mapping: per input type
   - Lens application: both lenses per surface
4. **Adversarial pass**.
5. **Divergent pass** (skip if `--quick`).
6. **Rank and output**.
7. **File output** (5+ findings): `~/.claude/challenge/{slug}.md`.
8. **Escalate** (conditional): spawn verifier if adversarial pass needs code verification.

### Adversarial: "What's wrong?"

Per attack surface: unstated assumptions, missing error paths, coupling introduced, scope creep, irreversibility.

### Divergent: "What else could be true?"

1. **Constraint removal**: remove one constraint at a time, see what opens.
2. **Perspective shift**: maintainer in 6 months, user on failure, different team.
3. **Adjacent alternatives**: plausible paths, same goals, different approach.

### ICD Integration

When used as evaluate step within ICD: focus on what the investigation DIDN'T cover. Plan with audit trail -> skip covered areas, always run divergent.

### Output

Findings per lens, each with: severity (critical/important/minor), what, why it matters, what to check. For file output, include a **Synthesis** section: which findings, if any, should change the approach?

---

## Audit

Systematic rubric-driven evaluation of a defined scope. Full methodology: [audit.md](audit.md).

NOT for: single-file code review (use `code-review` capability), codebase exploration (use Deepdive), or external research (use Research).

**Key pattern**: first iteration calibrates (scope enumerate + rubric + surface scan), subsequent iterations do deep per-artifact evaluation in batches (max 3 concurrent subagents). Cross-cutting synthesis every evaluation phase. Post-loop remediation (user-gated).

**Artifacts**: TRACKER.md (scope inventory + findings), eval-{slug}.md (per-artifact).

**Severity**: critical (breaks functionality) > major (significant gap) > minor (inconsistency) > info (observation).

---

## Recall

Knowledge search across accumulated sources. Single-pass, read-only.

### Sources (priority order)

1. `~/.claude/MISTAKES.md` patterns
2. `~/.claude/MISTAKES-LOG.md` entries
3. `~/.claude/LEARNINGS.md` active observations
4. `~/.claude/LEARNINGS-ARCHIVE.md` graduated
5. `~/.claude/investigations/**/*.md` research/deepdive READMEs
6. `~/.claude/investigations/**/TRACKER.md` audit findings
7. `~/.claude/skills/*/SKILL.md` skill definitions
8. `~/.claude/persona.md` knowledge gaps
9. Project skills
10. Auto memory (treat as confidence: low)

### Steps

1. Grep all sources, multiple terms for synonyms.
2. Investigation workspaces: read README.md first, sub-files only if needed.
3. Archive files (`_archive/`): read matched sections in context (not full files).
4. Read matched sections from MISTAKES.md and LEARNINGS.md with confidence levels.
5. Check persona.md comfort level for the topic area.
6. Synthesize: **Known** (strong evidence) > **Uncertain** (low confidence) > **Not Found** (searched, empty) > **Suggested Next** (scope boundary to research/deepdive).

### Ranking

Mistake patterns > high-confidence learnings > Tier 1-2 investigations > skill definitions > low-confidence/auto memory. Recency breaks ties. 2D->1D collapse: min(likelihood_tier, confidence_tier).

### Integration

Read-only. Feeds into: investigation pre-flight (skip known sub-questions), prompt refinement (context enrichment).

### Auto-trigger

Surfaces as recommended pre-flight in ICD workflows. When selected: populate "known vs unknown" assessment, mark covered sub-questions so subsequent investigation doesn't re-investigate them. Can also be invoked standalone: `/think recall [topic]`.

---

## Data Analyst

Data analysis, BI, statistical reasoning. Full methodology: [data-analyst.md](data-analyst.md).

**Modes**: Explore (raw data), Analyze (specific question), Report (multi-metric), Pipeline (clean/transform).

**Pipeline**: Acquire -> Question -> Clean -> Transform -> Analyze -> Visualize (AQCTAV).

**Workspace**: `~/.claude/analysis/{slug}/` with raw/, cleaned/, scripts/, findings/.

**Frameworks**: descriptive, trend, cohort, funnel, Pareto, comparative, contribution.

**Toolkit**: Python stdlib (statistics module). Escalate to pandas/scipy via `uv pip install` when needed.

**Honesty**: sample sizes, correlation is not causation, confidence intervals, missing data bias, Simpson's paradox, survivorship bias, precision matching.

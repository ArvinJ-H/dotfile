---
name: think
description: Analysis, investigation, evaluation, data reasoning. Invoke at even 1% chance the task involves thinking, research, analysis, challenge, audit, recall, or data.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, WebSearch, WebFetch, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, ToolSearch, AskUserQuestion, mcp__sequential-thinking__sequentialthinking
---

Scope boundary: for implementation invoke /work. For creative output invoke /create.

## Router

| Signal | Workflow | Dispatch |
|---|---|---|
| Analytical question, reasoning, "why does X", evaluate trade-offs | [Analyse](#analyse) | Agent(icd-analyse) |
| External info, web sources, library evaluation, "how does X work" | [Research](#research) | Agent(icd-research) |
| Complex multi-component codebase question, 3+ systems | [Deepdive](#deepdive) | Agent(icd-deepdive) |
| Systematic evaluation of a scope, quality assessment | [Audit](#audit) | Agent(icd-audit) |
| "Poke holes", "challenge this", adversarial review | [Challenge](#challenge) | Inline |
| "What do I know about", prior knowledge check | [Recall](#recall) | Inline |
| Data, statistics, CSV, analysis, BI reasoning, metrics | [Data Analyst](#data-analyst) | Inline |
| Unclear | Ask, or default Analyse | |

Workflows chain: Recall as pre-flight for ICD agents (pass results in task prompt). Challenge as inline evaluation. Data Analyst feeding into Research for evidence. Analyse chains to Research or Deepdive when the problem outgrows general reasoning.

## ICD Framework

ICD workflows dispatch to dedicated agents. Each agent runs the full 6-step loop (read state, plan work, execute, self-assess, evaluate, decide) as its primary task. The agent prompt IS the ICD process; steps cannot be skipped because they are the agent's task definition. Mechanical details in `~/.claude/reference/investigation-loop.md`.

### Dispatching

When routing to an ICD workflow:
1. Determine area and slug for the workspace (areas: tiny/, personal/, methodology/, a11y/, ai-literacy/, external/, work/)
2. Run Recall pre-flight if applicable
3. Spawn the corresponding agent with a task prompt containing: the user's question/task, the area and slug, any Recall results, scope boundaries or chain instructions
4. After agent completes, read the workspace README.md
5. Present findings to the user

### Chaining

Analyse may recommend chaining to Research or Deepdive. If the agent's README.md or STATE.md contains a chain recommendation, spawn the recommended agent with the updated scope.

### Workspace

```
~/.claude/investigations/{area}/{slug}/
  STATE.md       -- iteration log, confidence, gaps (living document)
  README.md      -- final deliverable (at exit)
  sub-{slug}.md  -- subagent findings (one per sub-question)
  team-{slug}.md -- adversarial team output (if escalated)
  TRACKER.md     -- audit only: artifact inventory + findings
  eval-{slug}.md -- audit only: per-artifact evaluation
```

**Confidence**: 2D model (likelihood x evidence quality). See investigation-loop.md for levels, collapse table, and stopping criteria.

**Learning extraction**: max 3 entries per session. `confidence: low`, `action: needs-verification`.

---

## Analyse

General-purpose analytical reasoning. The default when /think is invoked. Dispatches to `Agent(icd-analyse)`.

**When**: reasoning needed (not retrieval), not external sources (Research), not 3+ codebase systems (Deepdive), not systematic evaluation (Audit).

**Scope boundary**: chains to Research (needs external sources) or Deepdive (reveals multi-system complexity). The agent writes chain recommendations to STATE.md.

---

## Research

External research via web, docs, all available sources. Dispatches to `Agent(icd-research)`.

**Core principle**: every claim traceable to a source. No unsourced assertions.

**Scope boundary**: codebase questions -> Deepdive instead.

<!-- PRIVATE:think-research-area-routing -->

---

## Deepdive

Deep codebase investigation. Dispatches to `Agent(icd-deepdive)`.

**Scope boundary**: external/web questions -> Research instead. If question spans both, Deepdive handles codebase component.

<!-- PRIVATE:think-deepdive-area-routing -->

**Auto-trigger** (dispatch autonomously when ALL true): 3+ interconnected components, initial exploration raises more questions than answers, existing skills/research don't cover it.

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

### Thinking Floor (lightweight)

Challenge already embeds adversarial thinking, but apply the floor to Challenge's own output: what assumptions did the *challenge itself* not question? What framing did the input impose that the adversarial pass accepted uncritically?

### Output

Findings per lens, each with: severity (critical/important/minor), what, why it matters, what to check. For file output, include a **Synthesis** section: which findings, if any, should change the approach?

---

## Audit

Systematic rubric-driven evaluation. Dispatches to `Agent(icd-audit)`. Full reference: [audit.md](audit.md).

NOT for: single-file code review, codebase exploration (Deepdive), or external research (Research).

**Severity**: critical > major > minor > info.

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
6. Synthesize: **Known** (strong evidence) > **Uncertain** (low confidence) > **Not Found** (searched, empty) > **Suggested Next** (scope boundary to research/deepdive/analyse).
7. **Thinking Floor (lightweight)**: What's absent from accumulated knowledge that matters for this query? What recalled knowledge might be outdated or wrong given current context?

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

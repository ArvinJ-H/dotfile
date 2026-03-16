# Subagent Prompting Patterns

Reusable prompt construction patterns for spawning LLM subagents. Adapted from ReACT patterns in open-source agent frameworks.

## Standard Subagent Prompt Template

When spawning subagents (via Agent tool, TeamCreate, or equivalent), construct prompts using this template. Each field ensures the subagent can operate without access to parent context.

```
Role: {expertise framing, e.g. "Senior code reviewer", "Lead investigator"}
Task: {specific question or assignment}
Background: {all context needed; self-contained, no references to parent conversation}
Tools: {suggested tool sequence for this task type, see Tool-Hint Libraries}
Budget: {min N calls, soft cap M, hard cap M+K}
Tracking: {between-call self-tracking instruction}
Deliverable: {file path + format template}
```

This extends the self-containment rule in `operational-rules.md`: prompts must include role, task, background, and deliverable format. This template adds tool hints, budget, and tracking.

## Pattern Blocks

Copy-paste prompt fragments. Parameterize values in `{braces}`.

### Evidence Depth

Add to any subagent prompt that should gather before synthesizing:

```
EVIDENCE REQUIREMENTS:
- Read/search at least {N} distinct sources before writing output.
- Each claim in your output must trace to a specific source (file, URL, tool result).
- If you are ready to write after fewer than {N} tool calls, you have not
  researched enough. Keep investigating.
```

Recommended minimums: investigation subagents N=3, evaluation subagents N=3, research subagents N=5.

### Tool Diversity

Add when the subagent has 3+ tool types available:

```
TOOL DIVERSITY: You have access to [list tools]. A thorough investigation uses
multiple tool types. If you've made 2+ calls to the same tool without trying
others, pause and consider whether a different tool offers a complementary angle.
```

### Budget Awareness

Add when the subagent has investigation work to do:

```
Prioritize highest-value sources first, so partial completion still covers
what matters most. Phase transitions (broad gathering -> gap-filling ->
writing) happen naturally; focus on what to investigate, not when to stop.
```

A runtime hook (PreToolUse) tracks investigation state and surfaces it when the agent attempts to write output: sources touched, tool types used, and a recommended minimum. The agent decides whether to continue or write. No hard caps or gates. Skills can set `CLAUDE_AGENT_MIN` to adjust the recommended minimum per task type (default 3).

### Authority Framing

Add when the subagent's output must be definitive (evaluations, assessments, rulings):

```
You are the authoritative evaluator for this assessment. You have complete access
to all relevant source material. Make clear, grounded determinations. Do not
hedge with "it appears" or "it seems" -- you have the evidence. State what is true.
Where evidence is genuinely ambiguous, say so explicitly.
```

### Sequential Coherence

When spawning multiple subagents for parts of a larger output, inject prior outputs:

```
[For agent N > 1]
Previously completed sections:
{prior_agent_outputs}
---
Your task: [section description]
Avoid repeating content from previous sections. Focus on what has not been covered.
Build on, rather than duplicate, earlier findings.
```

Alternative for parallel execution: keep agents independent, then add a reconciliation agent that merges, deduplicates, and identifies contradictions.

### Self-Tracking

Since runtime observation injection is not available, instruct the agent to self-track:

```
PROGRESS TRACKING: After each tool call, briefly note:
- What you learned (1 line)
- Tools used so far and total call count
- Whether you have enough to write, or what gap remains
Do not include these notes in your final output.
```

Less reliable than framework-level observation templating, but still improves coherence in longer investigations.

## Tool-Hint Libraries

Suggested tool sequences by task type. Include relevant sequences in the `Tools:` field of subagent prompts.

### Codebase Investigation

```
Grep (find entry points) -> Read (understand context) -> Grep (follow references) -> Read (connected code)
```

### Web Research

```
WebSearch (initial query) -> WebFetch (top 2-3 results) -> WebSearch (fill gaps) -> WebFetch (targeted)
```

### Code Review

```
Read (changed files) -> Grep (find tests) -> Read (test files) -> Grep (find usages of changed APIs)
```

### Artifact Evaluation

```
Read (artifact under review) -> Grep (cross-references) -> Read (referenced files) -> evaluate and write
```

### Data Collection

```
ToolSearch (load MCP tools if needed) -> query primary source -> query secondary source -> verify consistency
```

### Challenge Prompt Block

Add when the ICD loop's evaluate step invokes a challenge pass on iteration findings:

```
CHALLENGE: Review the attached findings for flaws, gaps, and unconsidered paths.
Adversarial lens: unstated assumptions, missing error paths, coupling risks,
scope creep, irreversibility. Rate each: Critical / Important / Minor.
Divergent lens: constraint removal, perspective shifts, adjacent alternatives.
Output: gap list with priority, confidence assessment, recommendation
(loop / escalate / stop).
```

### Loop State Assessment Block

Add to any subagent operating within an ICD loop iteration. Ensures self-assessment (ICD step 4) is captured:

```
SELF-ASSESS before writing your final output:
- New sources this iteration: ___
- Claims added/changed: ___
- Confidence (likelihood / confidence): ___
- Top remaining gap: ___
- Another iteration likely to change conclusions? yes / no / uncertain
Include this assessment at the end of your output file.
```

## Applicability Matrix

Which patterns to apply per generic task type. "Required" means always include; "Recommended" means include when applicable.

| Pattern | Investigation | Evaluation | Research | Code Review | ICD Loop |
|---------|:---:|:---:|:---:|:---:|:---:|
| Evidence Depth | Required (N=3) | Required (N=3) | Required (N=5) | Recommended (N=2) | Recommended (dynamic) |
| Tool Diversity | Required | Recommended | Required | Recommended | Recommended |
| Budget Awareness | Required (min=3) | Required (min=3) | Required (min=5) | Recommended (min=2) | Recommended (dynamic) |
| Authority Framing | - | Required | - | Recommended | - |
| Sequential Coherence | If ordered | - | If ordered | - | - |
| Self-Tracking | Required | Required | Required | Recommended | Recommended |
| Tool Hints | Required | Required | Required | Required | Recommended |
| Challenge Prompt | - | - | - | - | When evaluate step invokes challenge |
| Loop State Assessment | - | - | - | - | Recommended (every iteration) |

## Limitations

These patterns use **upfront priming**: all instructions are placed in the initial prompt. The alternative, **runtime injection**, would insert instructions between tool calls based on observed behavior (e.g., "you've only used Grep, try Read"). Runtime injection is more reliable but requires framework-level changes to the Agent tool.

Known limitations of upfront priming:

- **Compliance decay**: Instructions placed early in a long prompt may lose influence as the agent generates more content. Longer investigations are more susceptible.
- **Limited adaptive correction**: The runtime hook (see Runtime Reinforcement) tracks investigation state and nudges tool diversity, but cannot assess evidence quality or redirect investigation strategy. It surfaces what the agent has done, not whether it's sufficient.
- **Prompt length trade-off**: Adding all pattern blocks increases prompt size. For simple tasks, the overhead may not be worth it. Apply patterns selectively using the applicability matrix.

## Runtime Reinforcement (Active)

A PreToolUse hook provides investigation awareness and tool diversity nudging for subagents. No gates or budget caps.

**Two mechanisms:**

1. **Investigation awareness (on Write):** When the agent attempts to write output, the hook injects a status summary: total calls, tool types used, distinct sources touched, and a recommended minimum. The agent decides whether to proceed or investigate further. This mirrors MiroFish's observation templating, adapted to Claude Code's hook system.

2. **Tool diversity nudge (on investigation tools):** When one tool type dominates (>= 66% of calls after 4+ calls) or only one type has been used after 3+ calls, the hook suggests complementary tools. Silent when diversity is adequate.

**What it tracks:** Per-agent tracker file (`/tmp/claude-budget-{agent_id}`) records call counts by tool type. A sources file (`/tmp/claude-sources-{agent_id}`) records distinct file paths, search targets, and URLs extracted from `tool_input`.

**Design rationale:** Earlier iterations tried budget caps (PostToolUse warnings, PreToolUse denials). Experiments showed: (a) agents ignore advisory messages when they have remaining work, (b) hard denials force output but reduce quality, (c) surfacing investigation state before writing encourages thoroughness without restricting behavior. Condition G (soft awareness) produced 26 evidence rows vs 13 for the no-hook baseline, with the same call count.

**Configuration:** `CLAUDE_AGENT_MIN` env var sets the recommended minimum sources (default 3). Skills can set this per task type. There is no upper limit.

**Experiment citation:** 2026-03-16/17, conditions A-G. Full results in `~/.claude/investigations/subagent-budget-experiment/phase2-results.md`.

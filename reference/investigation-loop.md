# Investigation Loop: Investigate-Challenge-Decide (ICD)

Shared methodology for skills that do multi-step investigation: deepdive, research, audit, and any future investigation skill. Each skill provides its own iteration strategy; this doc defines the loop structure.

## Loop Structure

```
Iteration N:
  1. Read state     -- assess where the investigation stands
  2. Plan work      -- determine what will close the most important gaps
  3. Execute        -- do the planned work
  4. Self-assess    -- update understanding of what changed
  5. Evaluate       -- verify findings through available tools
  6. Decide         -- determine next action
```

## Iteration Details

### Step 1: Read State

Assess where the investigation stands. Read STATE.md. What matters now depends on what happened last iteration and what the investigation needs next.

First iteration: STATE.md may not exist yet. Create it with initial scope and questions.

Resumed investigations: prior STATE.md exists. Read it, assess what's changed since last session, continue from where the investigation left off.

### Step 2: Plan Work

Determine what work will move the investigation forward. The specific mode, team composition, agent count, and tool selection all emerge from the state assessment. They are outputs of this step, not inputs from a lookup table.

What informs the plan: what gaps exist and whether they are independent or coupled, what verification is needed, what the consuming skill's domain requires, what resources best address the current gaps.

### Step 3: Execute

Run the planned investigation. Skill-specific: deepdive decomposes and explores, research surveys sources, audit evaluates artifacts. Subagents write findings to workspace files (not just messages). See `subagent-prompting-patterns.md` for prompt construction.

### Step 4: Self-Assess

Update STATE.md with what changed this iteration. What was learned, what shifted, what's still open. Update 2D confidence (likelihood and evidence quality). The specific content depends on what the execution produced.

### Step 5: Evaluate Findings

Compose a verification layer from available tools, proportional to what the findings need. Multiple tools can and should run in parallel when the situation warrants.

**Available verification tools:**
- **Self-assessment**: the agent's own analysis from step 4
- **Adversarial team**: multi-perspective debate. Team size scales dynamically (2 agents for routine validation, more for contested findings). See "Adversarial Verification" below.
- **Challenge pass**: adversarial + divergent review for assumptions and unconsidered paths
- **Audit pass**: systematic quality assessment, completeness, rubric compliance
- **Verifier agent**: code/artifact correctness checking against source material
- **Any combination**: these are not mutually exclusive options in a lookup table. They compose together based on what the findings actually need.

The adversarial team is a peer verification mechanism that runs alongside other tools, not an escalation reserved for special cases.

### Step 6: Decide

Determine the next action based on what the verification layer found. The decision emerges from the evaluation. Core question: "would another iteration change the conclusions?"

If yes, continue. If the verification surfaced something that needs deeper investigation, plan accordingly. If findings have stabilized and verification found no critical gaps, stop and produce output.

## Stopping Criteria

Qualitative signals, no fixed thresholds:

- **Confidence plateau**: iterations are no longer moving confidence in either dimension. The agent assesses this dynamically, not by counting iterations.
- **Diminishing returns**: iteration mostly confirms existing findings, few new sources or changed claims.
- **Gap closure**: all challenge-identified gaps addressed or explicitly classified as out of scope or undecidable.

**Stop challenge**: on stop decision, challenge that decision: "is stopping premature?" The depth of this challenge is itself dynamic (proportional to how much uncertainty remains). If it surfaces a critical gap, the loop continues.

**Safety valve**: after 5 iterations without convergence, pause and ask the user. Not a cap; the investigation can continue if the user approves.

## Adversarial Verification

A verification mechanism available at step 5 of any iteration. Multi-perspective debate that scales with task complexity. Not an escalation path reserved for special cases; a peer tool in the verification layer.

**Team size is dynamic**: 2 perspectives for routine validation, more for genuinely contested findings. The loop determines team size from the state, not from a fixed threshold.

**Mechanics:**
- Uses TeamCreate with assigned positions
- Each agent uses Toulmin argumentation: claim, evidence, warrant, qualifier, rebuttal
- Mandate: stress-test, don't destroy. Moderate disagreement produces better outcomes than maximal disagreement.
- Rounds continue until positions converge or diminishing progress is detected. No fixed round count or convergence percentage.
- The debate moderator assesses convergence qualitatively.
- Each agent writes findings to workspace files (`team-{position-slug}.md`)

**Characterize disagreement type** when synthesis begins:
- **Factual**: different evidence. Resolution: find authoritative source.
- **Interpretive**: same evidence, different reading. Resolution: seek additional context.
- **Normative**: different trade-off weighting. Resolution: document trade-off, let user decide.

## Thinking Floor

Mandatory minimum depth before any analytical conclusion. Not a checklist to output; an internal discipline that surfaces only when it catches something.

### Checkpoints

**1. Assumption inventory**: What must be true for this conclusion to hold? Enumerate explicitly. Test the weakest: what evidence supports it? What would falsify it?

**2. Alternative generation**: State the strongest competing interpretation, cause, or approach. Argue *for* it (steel-man), not just against it. Why is the current conclusion better? If "better" depends on unstated criteria, surface those criteria.

**3. Pre-mortem**: Assume the conclusion is wrong. What went wrong? Identify the weakest link in the reasoning chain. What evidence would change your mind?

### Application

| Context | Floor form | Minimum |
|---|---|---|
| ICD Step 5 (Evaluate) | Full | All 3 checkpoints, each with at least 1 concrete item |
| Single-pass analysis (Challenge, Recall) | Lightweight | At least 1 assumption named, 1 alternative considered |
| Compressed ICD (work, create, ops, meta) | Domain-adapted | Assumption + alternative, phrased for the domain |
| Trivial/factual queries | Skip | "What's the return type of X?" needs no floor |

### Floor vs. Ceiling

The Thinking Floor sets a minimum, not a target. Complex problems warrant deeper adversarial exploration (full adversarial team, multi-round debate). The floor prevents routine analysis from concluding without basic opposition to its own reasoning.

### Anti-pattern: Mechanical Compliance

The floor fails if it becomes rote. "Assumption: this code works. Alternative: it doesn't. Pre-mortem: a bug." is worse than no floor. Each checkpoint must engage with the *specific* problem. If the assumption inventory doesn't make you reconsider anything, you picked safe assumptions.

## STATE.md Format

Living document. Updated each iteration, not replaced.

```markdown
# Investigation: {title}

**Date started**: YYYY-MM-DD
**Status**: iterating | stopped | paused (awaiting user)
**Current iteration**: N

## Scope

{What this investigation covers. Written at iteration 1, updated if scope changes.}

## Findings

{Accumulated findings. Each finding includes its source iteration, evidence basis,
and confidence. Updated as findings change across iterations.}

## Confidence History

| Iteration | Focus | Likelihood | Confidence | Delta | Sources added |
|-----------|-------|------------|------------|-------|---------------|
| 1 | {focus} | {level} | {level} | - | N |
| 2 | {focus} | {level} | {level} | +/- | N |

## Active Gaps

{Prioritized list of what's still unknown. Updated each iteration.
Items resolved → moved to Findings with resolution note.}

## Iteration Log

### Iteration N
- **Focus**: {what this iteration investigated}
- **Work mode**: {what was planned and why}
- **Verification**: {what tools composed the verification layer and what they found}
- **Decision**: {what was decided and why}
- **Key changes**: {what shifted in findings or confidence}
- **Open**: {what remains after this iteration}

## Stop Challenge Record

{When a stop decision is made, record the challenge and its outcome here.}
```

## Runtime Workspace Structure

Living documents over per-iteration snapshots. Findings accumulate in a few key files rather than proliferating one file per iteration.

### Deepdive / Research

```
~/.claude/investigations/{area}/{slug}/
  STATE.md          -- the investigation: iteration log, confidence trajectory,
                       accumulated findings, active gaps
  README.md         -- final synthesized answer (written at loop exit)
  sub-{slug}.md     -- subagent findings (created as needed, one per sub-question)
  team-{slug}.md    -- adversarial team output (created when verification uses debate)
```

### Audit

```
~/.claude/investigations/{area}/{slug}/
  STATE.md          -- iteration log, confidence, gap tracking
  TRACKER.md        -- artifact inventory + findings (living document,
                       updated each iteration as evaluations complete)
  eval-{slug}.md    -- per-artifact detailed evaluation (one per artifact,
                       named by artifact not by iteration)
  README.md         -- final audit report
```

### Navigation

STATE.md tells the story (what happened, in what order, what changed). README.md gives the answer. TRACKER.md (audit only) is the finding index. Everything else is subagent output for drilling in. Most investigations produce 3-5 files total.

**No per-iteration files**: findings from iteration 2 don't go in `iteration-2.md`; they update STATE.md's findings section with a changelog entry. This keeps the workspace navigable even for 5+ iteration investigations.

## Confidence Model

All ICD-based skills use 2D confidence:
- **Likelihood**: How likely is this claim? (almost certain / likely / even odds / unlikely / almost certainly not)
- **Confidence**: How strong is the evidence? (high / moderate / low / very low)

These are orthogonal. High confidence in a low-likelihood finding ("we're confident this is unlikely") and low confidence in a high-likelihood one ("this probably works but our evidence is weak") are both valid states.

### 2D to 1D Collapse

Downstream consumers using 1D confidence (LEARNINGS.md, Recall workflow rankings) collapse using min(likelihood_tier, confidence_tier):

| Confidence | Likelihood: almost certain/likely | Likelihood: even odds | Likelihood: unlikely/remote |
|------------|----------------------------------|----------------------|---------------------------|
| high | high | medium | low |
| moderate | medium | medium | low |
| low/very low | low | low | low |

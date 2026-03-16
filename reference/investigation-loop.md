# Investigation Loop: Investigate-Challenge-Decide (ICD)

Shared methodology for skills that do multi-step investigation: deepdive, research, audit, and any future investigation skill. Each skill provides its own iteration strategy; this doc defines the loop structure.

## Loop Structure

```
Iteration N:
  1. Read state     -- STATE.md: known facts, gaps, confidence trajectory
  2. Plan work      -- solo, parallel subagents, or adversarial team (dynamic)
  3. Execute        -- investigate per the skill's iteration strategy
  4. Self-assess    -- update confidence (2D), count new evidence
  5. Evaluate       -- dynamic: self-check, /challenge, /audit, or combination
  6. Decide         -- loop, escalate, or stop
```

## Iteration Details

### Step 1: Read State

STATE.md is the investigation's living document. Before each iteration, read it to understand:
- What's known (accumulated findings, confidence levels)
- What's not known (active gaps, unresolved questions)
- Trajectory (is confidence moving? which direction?)

First iteration: STATE.md may not exist yet. Create it with initial scope and questions.

Resumed investigations: prior STATE.md exists. Read it, assess what's changed since last session, continue from where the investigation left off.

### Step 2: Plan Work

Dynamic, not prescribed. The loop chooses the work mode based on current state:

- **Solo investigation**: one agent reads, searches, analyzes. Appropriate when gaps are focused and don't require parallel exploration.
- **Parallel subagents**: spawn agents for independent sub-questions. Appropriate when multiple gaps can be investigated simultaneously. Count and focus driven by what the previous evaluate step found. Max concurrency per skill's configuration (typically 3-4).
- **Adversarial team**: assigned positions, Toulmin argumentation. See "Adversarial Team Escalation" below.

### Step 3: Execute

Run the planned investigation. Skill-specific: deepdive decomposes and explores, research surveys sources, audit evaluates artifacts. Subagents write findings to workspace files (not just messages). See `subagent-prompting-patterns.md` for prompt construction.

### Step 4: Self-Assess

After execution, update STATE.md with:
- New sources consulted this iteration
- Claims added or changed
- Confidence update (both dimensions: likelihood and evidence quality)
- Top remaining gap

### Step 5: Evaluate Findings

Dynamic toolkit, not a fixed step. The loop reads the situation and chooses:

| Tool | When to use | What it does |
|------|-------------|-------------|
| **Self-assessment** | Straightforward iteration, few uncertainties | Agent's own confidence and gap analysis from Step 4 |
| **`/challenge`** | Findings have competing interpretations, unstated assumptions, non-obvious trade-offs | Adversarial + divergent review. Finds flaws, unconsidered paths |
| **`/audit`** | Findings need systematic quality assessment, rubric compliance, completeness checking | Evaluates completeness, consistency, rubric adherence |
| **Both** | High-stakes iteration, complex findings with quality and interpretation concerns | Combined coverage |

No prescribed combination. Depth and type of evaluation are proportional to uncertainty and stakes. A straightforward iteration might need only self-assessment. Findings with quality concerns might need an audit pass. Findings with competing interpretations might need a challenge pass. Complex or high-stakes iterations might invoke both.

### Step 6: Decide

Three options:

- **Loop**: evaluation surfaced gaps, confidence is still moving, another iteration would change conclusions. Continue to next iteration.
- **Escalate**: evaluation surfaced competing hypotheses or irreconcilable interpretations. Trigger adversarial team (see below).
- **Stop**: evaluation found no critical gaps, confidence has plateaued, another iteration is unlikely to change conclusions. Proceed to final output.

## Stopping Criteria

Qualitative signals, no fixed thresholds:

- **Confidence plateau**: iterations are no longer moving confidence in either dimension. The agent assesses this dynamically, not by counting iterations.
- **Diminishing returns**: iteration mostly confirms existing findings, few new sources or changed claims.
- **Gap closure**: all challenge-identified gaps addressed or explicitly classified as out of scope or undecidable.

**Stop challenge**: on stop decision, challenge that decision: "is stopping premature?" The depth of this challenge is itself dynamic (proportional to how much uncertainty remains). If it surfaces a critical gap, the loop continues.

**Safety valve**: after 5 iterations without convergence, pause and ask the user. Not a cap; the investigation can continue if the user approves.

## Adversarial Team Escalation

A loop feature available to any skill. Triggered dynamically when the evaluate step finds:
- Competing hypotheses that self-assessment cannot resolve
- Non-obvious trade-offs where a senior engineer would disagree without more context
- Irreconcilable interpretations of the same evidence

**Mechanics:**
- Uses TeamCreate with assigned positions
- Each agent uses Toulmin argumentation: claim, evidence, warrant, qualifier, rebuttal
- Mandate: stress-test, don't destroy. Moderate disagreement produces better outcomes than maximal disagreement.
- Rounds continue until positions converge or diminishing progress is detected (same signals as the outer loop). No fixed round count or convergence percentage.
- The debate moderator assesses convergence qualitatively.
- Each agent writes findings to workspace files (`team-{position-slug}.md`)

**Characterize disagreement type** when synthesis begins:
- **Factual**: different evidence. Resolution: find authoritative source.
- **Interpretive**: same evidence, different reading. Resolution: seek additional context.
- **Normative**: different trade-off weighting. Resolution: document trade-off, let user decide.

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
- **Work mode**: {solo / N parallel subagents / adversarial team}
- **Evaluation**: {self-check / challenge / audit / combination}
- **Verdict**: {loop / escalate / stop}
- **Key changes**: {claims added, changed, or removed}
- **Gaps surfaced**: {new gaps from evaluation}

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
  team-{slug}.md    -- adversarial team output (created if escalated)
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

## Assembly System

This is a shared public reference doc. If skills need private additions (e.g., project-specific evaluation criteria), the fragment injection system supports this: add a `<!-- PRIVATE:investigation-loop-{slug} -->` marker in this file, create a matching fragment in `private/fragments/`. setup.sh handles the pattern.

## Confidence Model

All ICD-based skills use 2D confidence:
- **Likelihood**: How likely is this claim? (almost certain / likely / even odds / unlikely / almost certainly not)
- **Confidence**: How strong is the evidence? (high / moderate / low / very low)

These are orthogonal. High confidence in a low-likelihood finding ("we're confident this is unlikely") and low confidence in a high-likelihood one ("this probably works but our evidence is weak") are both valid states.

### 2D to 1D Collapse

Downstream consumers using 1D confidence (LEARNINGS.md, /recall rankings) collapse using min(likelihood_tier, confidence_tier):

| Confidence | Likelihood: almost certain/likely | Likelihood: even odds | Likelihood: unlikely/remote |
|------------|----------------------------------|----------------------|---------------------------|
| high | high | medium | low |
| moderate | medium | medium | low |
| low/very low | low | low | low |

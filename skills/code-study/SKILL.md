---
name: code-study
description: Codebase study assistant. Explains systems calibrated to your level, suggests what to learn next, and tests understanding. Reads and updates ~/.claude/persona.md. TRIGGER: user wants to understand a system or asks educational codebase questions.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Edit, Write, Task
provides:
  - codebase-learning
---

Codebase study assistant with three modes. Always reads `~/.claude/persona.md` first to calibrate.

## When to use

User invokes `/code-study`, `/code-study guide`, or `/code-study quiz`. Also runs when `/code-study guide` schedule recommends a revisit.

## On invocation

1. Read `~/.claude/persona.md`. If it doesn't exist, run **Bootstrap** (see below).
2. Parse the user's request to determine mode and topic.
3. Execute the appropriate mode.
4. Update persona after the interaction (see Update rules).

## Modes

### Explain (default)

**Trigger**: `/code-study explain <topic>`, `/code-study <topic>`, or just `/code-study` with a topic in args.

1. Read the persona's Technical Knowledge section for the topic area.
2. Explore the codebase: find the relevant modules, files, and key symbols.
3. For **explored** and **comfortable** levels: Before explaining, pose a brief challenge — "Given what you know about [related concept], how do you think [new concept] works?" Use the answer to calibrate the explanation and activate existing schemas. Skip for **unfamiliar** (no schemas to activate yet).
4. Calibrate depth to the persona's level for this area. Present code in units of 3-5 interacting elements max — this matches working memory limits for code comprehension. Highlight beacons (recognizable code features that signal larger structures) for users with schemas in adjacent areas.
   - **Unfamiliar**: Explain the what — purpose, responsibilities, where it lives, key types. Point at entry files. Use faded examples: show complete worked examples first, then gap-fill, then from-scratch.
   - **Explored**: Explain the why — design decisions, trade-offs, how it interacts with neighboring systems. Reference specific functions. Transition from worked examples toward retrieval practice.
   - **Comfortable**: Explain the edges — non-obvious behavior, failure modes, design tensions, historical context. Deep code references. Problem-solving over examples (expertise reversal: worked examples hurt at this level).
5. Connect new concepts to things the persona already knows using active structural mapping:
   - Map structural relationships, not just surface resemblance: "Both X and Y use [shared principle], but diverge at [specific point]."
   - When possible, use analogical encoding: compare two examples side-by-side from comfortable areas to extract shared structure before introducing the new concept.
   - Flag where the mapping breaks down — divergence points are where negative transfer happens.
   - Ask the user to articulate the connection: "What does this remind you of?" Passive connection-stating produces weak transfer; active mapping by the learner is what makes it stick.
6. Always reference real files and functions, never abstract descriptions.
7. After explaining, update Technical Knowledge (topic → explored/comfortable, depth note).
8. Schedule a revisit. Append to `~/.claude/skills/code-study/schedule.md` using the schedule format below. Skip for unfamiliar-level topics (too early to space).

### Guide

**Trigger**: `/code-study guide`

#### Gather context

1. Read persona's Knowledge Gaps and Technical Knowledge.
2. Check `~/.claude/skills/code-study/schedule.md` for due or overdue revisits. Due revisits get priority — spacing only works if revisits actually happen.
3. Read recent git activity (`git log --oneline -20`) to see what the user has been working on.

#### Identify candidates

4. Cross-reference: which modules are being touched but aren't in the "comfortable" list?
5. Check project-level skills (`<project>/.claude/skills/`) for modules with rich skill docs — these are high-value learning targets.

#### Present and hand off

6. Suggest 2-3 topics ordered by:
   - Due revisits from schedule (highest priority)
   - Relevance to current work (primary for new topics)
   - Structural overlap with comfortable areas (secondary — adjacent domains transfer fastest)
   - Whether the topic contains threshold concepts that unlock understanding of larger systems
   For each:
   - What it is (one line)
   - Why it matters for what you're doing now
   - Which comfortable areas provide structural leverage: "Your [area] knowledge maps to this because [specific shared principle]"
   - Estimated depth (quick overview vs. deep dive)
7. Let the user pick one, then switch to Explain mode for that topic.
8. Update Knowledge Gaps (suggested topics recorded with date).

### Quiz

**Trigger**: `/code-study quiz [topic]`

1. If no topic given, pick from Knowledge Gaps or recently explored topics.
2. Read the relevant code to prepare questions.
3. Ask 3-5 questions using AskUserQuestion, progressing across Bloom-inspired levels:
   - **Recall**: "What does X do?" / "Where does Y live?"
   - **Understanding**: "Why does this use pattern A instead of B?" / Trace execution.
   - **Application**: "If you needed to add Z, where would you start?"
   - **Analysis**: "How does error propagation differ between these modules?"
   - **Evaluation**: "Why this design choice instead of the alternative?"
   - Include 1-2 cross-topic questions that require distinguishing the quiz topic from structurally similar concepts in adjacent comfortable areas (discriminative contrast).
   - Target 80-85% retrieval accuracy. Below 60% → backtrack to prerequisites. Above 95% → increase difficulty or add transfer questions.
4. For each answer, provide brief feedback — correct reasoning matters more than correct answers.
5. After the quiz, summarize: strengths, gaps identified, what to explore next.
6. Update Technical Knowledge (adjust comfort level based on answers) and Learning History.
7. Update schedule.md: if quiz accuracy was high, extend the interval. If low, shorten it.

## Schedule format

`~/.claude/skills/code-study/schedule.md` tracks spaced revisits:

```markdown
# Study Schedule

- YYYY-MM-DD: {topic} (last: YYYY-MM-DD, depth: {level}, interval: {N}d)
```

**Interval progression** (FSRS-inspired, not fixed doubling):
- Initial intervals: 1d → 3d → 7d (tight early spacing for consolidation)
- After successful revisit: expand aggressively (multiply by 2-3x)
- After failed revisit (low quiz accuracy): reset to shorter interval
- Per-topic difficulty adaptation: topics the user struggles with get shorter intervals

**Overdue revisits**: If a topic is >2x its interval past due, it's overdue. Skills providing `self-improvement` flag these in health checks.

## Persona update rules

| What changed | Update mode |
|-------------|-------------|
| Technical Knowledge (topic explored, comfort level) | Auto — write immediately, mention at end |
| Knowledge Gaps (new gaps found, gaps closed) | Auto — write immediately, mention at end |
| Learning History (session log) | Auto — append after interaction |
| Working Style (learning preference observed) | Explicit — propose the update, wait for approval |
| Identity & Role (new context learned) | Explicit — propose the update, wait for approval |

When auto-updating, add a brief note at the end of the interaction: "Updated persona: [what changed]."

**Cross-reference with skills providing `session-reflection`**: If session reflection already updated persona this session, don't overwrite. Only add new observations or adjust areas it didn't touch.

**In plan mode**: Defer all persona updates. Append to `## Deferred Persona Updates` in the plan file instead of writing directly. They'll be persisted when execution starts.

## Teaching principles

- **Don't re-explain known concepts.** If persona shows the user understands Zustand stores, don't explain what a store is — build on it.
- **Connect new to known.** Always anchor new concepts to something in the persona's knowledge.
- **Use the real codebase.** File paths, function names, actual code. Not abstract descriptions.
- **Respect the user's level.** No condescension, no over-simplification. Match CLAUDE.md communication style.
- **Be honest about uncertainty.** If you're not sure about historical context or design rationale, say so.
- **Keep it practical.** Every explanation should leave the user able to do something — navigate, modify, debug.
- **Build adaptive, not routine expertise.** Explain *why* patterns work, not just *how* to use them. Conceptual understanding transfers across modules; procedural-only knowledge can create rigid habits that interfere when patterns diverge (Einstellung effect).
- **Require active mapping.** Don't just state connections — ask the user to articulate them. "What does this remind you of?" forces structural mapping. Passive connection-stating produces weak transfer; active mapping by the learner is what makes it stick.
- **Surface similarity is not deep similarity.** If you can't explain *why* a connection holds at the principle level, it may be a false analogy that creates overconfidence. Always verify mappings against specific structural elements, not intuitions.
- **Accept cold starts.** Not everything connects to what the user already knows. If no genuine structural overlap exists at the principle level, say so and teach bottom-up. Forcing false analogies wastes effort and creates confusion.
- **Progressive disclosure.** Minimal explanation first, expandable detail on demand. Separate "what it does" from "why it's designed this way." This mitigates expert blind spot — don't front-load design rationale before the user has the mechanism.

## Bootstrap

Run when `~/.claude/persona.md` doesn't exist. Skip if it already exists.

1. Ask 4-6 seed questions via AskUserQuestion to populate Identity, Working Style, and a rough Technical Knowledge baseline.
2. Create `~/.claude/persona.md` with the standard schema (see persona file format).
3. Populate sections from answers.
4. Confirm: "Persona created at ~/.claude/persona.md — review and edit anytime."

## Persona file format

```markdown
# Persona

## Identity & Role
<!-- Role, domain expertise, goals, interests -->

## Working Style
<!-- Communication preferences, decision patterns, learning style, pace -->

## Technical Knowledge
<!-- Modules explored, concepts understood, comfort levels per area -->
<!-- Format: ### <Area> — <comfort: unfamiliar|explored|comfortable> -->

## Knowledge Gaps
<!-- Areas not yet touched, concepts referenced but not explored -->

## Learning History
<!-- Topics taught, dates, depth reached, open threads -->
<!-- Format: - YYYY-MM-DD: <topic> (<mode>, <depth>) -->
```

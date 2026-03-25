---
name: reflect
description: Flush unrecorded mistakes and learnings from the current session to ~/.claude/MISTAKES-LOG.md and ~/.claude/LEARNINGS.md. TRIGGER: session has accumulated unrecorded learnings/mistakes, or user asks to reflect.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, AskUserQuestion
---

Review the current session and write any unrecorded observations to the self-improvement files.

## Steps

1. Read `~/.claude/MISTAKES.md` (patterns), `~/.claude/MISTAKES-LOG.md` (log), and `~/.claude/LEARNINGS.md` to see what's already recorded.
2. Review the conversation. Identify:
   - **Mistakes**: anything you got wrong, had to retry, or were corrected on.
   - **Learnings**: preferences, corrections, or working-style observations from the user.
3. For each new mistake, append to `## Log` in MISTAKES-LOG.md using the Gibbs-informed entry structure (see Entry quality below).
   - **Scope**: where the code lives, not where you're working from. Use `global` if universal.
   - **Severity**: `minor` (cosmetic) | `moderate` (rework/retry) | `major` (broke something).
   - **Tags**: optional free-form labels for cross-cutting analysis.
4. For each new learning, append to `## Active` in LEARNINGS.md using the entry format defined in that file.
   - **Scope**: same rules as mistakes.
   - **Sessions**: list observed date(s); on subsequent sessions, append the new date.
   - **Tags**: optional free-form labels for cross-cutting analysis.
5. **Triage auto memory** — read `~/.claude/projects/*/memory/*.md` (skip if no memory dirs exist). For each entry:
   - **Duplicate**: already in LEARNINGS.md or MISTAKES-LOG.md → skip.
   - **Unique, promotable**: observation not in LEARNINGS.md that qualifies as a learning → append to `## Active` in LEARNINGS.md with full metadata. Use `confidence: low`, add `source: auto-memory` tag.
   - **Project fact / navigation aid** (artifact paths, IDs, build commands) → leave in auto memory. Not a learning.
   - **Conflict**: auto memory says X, LEARNINGS.md says Y → flag in summary for user resolution. Do not silently pick a side.
6. Review the session for persona-relevant observations. Read `~/.claude/persona.md`.
   - **Technical Knowledge**: Did the user work in a module? Adjust comfort level
     (unfamiliar → explored → comfortable). Did they demonstrate understanding or struggle?
   - **Knowledge Gaps**: Did new gaps surface? Were existing gaps partially or fully closed?
   - Auto-update Technical Knowledge and Knowledge Gaps — same rules as `codebase-learning`
     (write immediately, mention at end).
   - For Working Style or Identity observations, propose the update and wait for approval.
   - **Additive only**: If the `codebase-learning` skill already updated persona in this session, don't overwrite.
     Only add new observations or adjust areas codebase-learning didn't touch.
   - Skip if no persona-relevant observations found.
7. Check pattern promotion thresholds:
   - If a mistake category now has 3+ entries in Log (across 2+ distinct sessions), move to `## Patterns` and propose a CLAUDE.md amendment. Mark the pattern as `status: provisional`.
   - **Severity-weighted early promotion**: If a `severity: major` mistake occurs 2+ times, promote at N=2 instead of N=3.
   - **Cross-session detection**: Same mistake category in 2+ consecutive sessions → flag as emerging pattern regardless of total count.
8. If a learning reached `confidence: high`, propose the specific amendment — exact section, text, evidence.
9. **Improvement trigger**: If a pattern was promoted this session OR 3+ learnings reached `confidence: high`, present `self-improvement` capability from manifest via AskUserQuestion and create `~/.claude/pending-improve` (empty marker file).
10. **Learnings hygiene** -- review active entries against graduation criteria:
    - **Amended**: Observation became a CLAUDE.md rule or skill update. Knowledge lives in the system now.
    - **Integrated**: Pattern is part of the codebase, a skill, or a reference doc. Keeping it in LEARNINGS is redundant.
    - **Resolved**: One-time bug or situation. The fix is applied. No ongoing relevance.
    - **Superseded**: A newer entry covers the same ground better.
    - **Stale**: Codebase/context changed enough that the observation no longer applies.
    - For each entry meeting a criterion, move to LEARNINGS-ARCHIVE.md with: `Graduated: <reason>`.
    - Entries stay active when: ongoing pattern not yet formalized, recent (< 2 weeks) needing confirmation, or `action: propose-amendment` with amendment not yet made.
    - Report: "Archived N entries. Active LEARNINGS: M entries remaining."
    - Target: keep active LEARNINGS.md under ~150 lines (~30 active entries).
11. Summarize what was recorded (or confirm nothing new).
12. If `~/.claude/pending-reflect` exists, clear it after recording.

## Entry quality

Every mistake entry must pass the **specificity test**: if the description could match more than one distinct failure mode, it's too vague. Entries follow a Gibbs-informed structure (Description → Evaluation → Analysis → Conclusion → Action):

| Field | What to capture | Bad example | Good example |
|-------|----------------|-------------|--------------|
| **Description** | What happened — factual | "Made an error with types" | "Used .value on Option<T> — doesn't exist" |
| **Evaluation** | Severity, impact | "Minor issue" | "moderate — caused retry, wrong code committed" |
| **Analysis** | Root cause, why it happened | (skipped) | "Assumed Option<T> unwraps like Result<T>" |
| **Conclusion** | What to change | "Be more careful" | "Check type definition before unwrapping" |
| **Action** | Proposed constraint | (none) | "Add to Patterns: always check wrapper type API" |

**Root cause depth**: Go deep enough to reach the instruction-level boundary. If the root cause is "the model can't do X" or "the user's request was ambiguous" — that's architecture or environment. Stop there, document the limitation, focus the action on what instructions can mitigate. Typically 2-3 "whys" is sufficient.

## `pending-reflect`

`~/.claude/pending-reflect` is an empty marker file created by session hooks when a session ends with unrecorded observations. On next session start, the protocol notices this file and reminds you to run `/reflect`. This skill clears it after recording (step 11).

## `pending-improve`

`~/.claude/pending-improve` is an empty marker file created by this skill (step 9) when accumulated patterns suggest `self-improvement` should run. Skills providing `self-improvement` clear it after running.

---
name: review
description: Unified entry point for code review. Asks what kind of review is needed, then delegates to the right tool. TRIGGER: user asks to review code, a PR, or a diff.
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion, Edit, Write, Skill, Task
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

Start a code review session.

## Steps

### 1. Detect context

- Run `gh pr view --json number,title,state 2>/dev/null` — PR on this branch?
- Run `git diff --stat` — unstaged local changes?
- Run `git diff --cached --stat` — staged changes?
<!-- PRIVATE:review-project-routing-detect -->

### 2. Ask

Use AskUserQuestion with detected context:

**PR exists:** "Review this PR" (full) or "Review local changes" (unstaged/staged only)
**No PR:** "Review local changes" (unstaged/staged) or "Review against branch" (diff vs base)

### 3. Route

**General routing:**

**PR review:** `/code-review` (automated) or `/pr-review-toolkit:review-pr` (interactive, ask which).

**Local changes:** Review diff directly. Focus: bugs, security, test coverage, patterns. Output: Blocking Issues / Suggestions / Summary.

<!-- PRIVATE:review-project-routing -->

### 4. Multi-Angle Verification

After the review from step 3 completes, run multi-angle verification using independent verifiers: 3 fixed verifiers always run + 0-3 dynamic verifiers based on triage. Do NOT skip this step. It runs on every review, regardless of route.

The multi-angle approach is based on Perspective-Based Reading (PBR) — empirically the strongest technique for multi-angle code review. Different perspectives find different defects with low overlap. One pass per perspective; mixed-concern review increases missed defects.

#### Phase 1 — Triage

Spawn a single **Sonnet** subagent (`subagent_type: "general-purpose"`, `model: "sonnet"`) to analyze the diff:

**Input:** diff content, file paths, change summary from step 3.

**Task:** Examine the diff and return a JSON list of 0-3 dynamic angles from this menu:

| Angle | Trigger signals |
|-------|----------------|
| **Security** | Auth, crypto, input handling, network code, secrets |
| **Performance** | Hot paths, DB queries, loops, caching, data processing |
| **Concurrency** | Async code, threads, locks, shared state, event handlers |
| **API contract** | Public interfaces, type signatures, protocol/schema changes |
| **Domain-specific** | Project CLAUDE.md rules, project-specific patterns |

If no signals match any angle, return an empty list.

#### Phase 2 — Spawn verifiers (all parallel)

Launch all verifiers in a single message (parallel Task calls).

**3 fixed verifiers (always spawn, `subagent_type: "verifier"`):**

| # | Agent | Mode | Receives | Focus |
|---|-------|------|----------|-------|
| 1 | **Independent bug scanner** | `scanner` | Diff + source files only (NOT review findings) | Find issues the review missed — fresh eyes, no anchoring bias |
| 2 | **False positive auditor** | `adversarial` | Review findings + full code context | Challenge each finding — try to disprove it by reading surrounding code |
| 3 | **Completeness checker** | `completeness` | Review findings + diff stat + file tree | All files covered? Related files missed? Test implications? Import/export chain breaks? |

**0-3 dynamic verifiers (per triage output, `subagent_type: "verifier"`):**

Each dynamic verifier gets the diff + source files + a specialized prompt for its angle. Use `mode: scanner` for dynamic verifiers. Construct the prompt dynamically — no separate agent definitions needed.

Total agents: 1 triage + 3 fixed + 0-3 dynamic = 4-7 subagents.

**Timeout handling:** If a verifier fails to return or errors out, note it as a gap in the verification pass. Do not re-spawn — the remaining verifiers are still valid.

#### Phase 3 — Synthesis

After all verifiers return, consolidate:

- Verifier #1 findings overlapping with review → **confirmed** (high confidence)
- Verifier #1 findings that are new → append as `[Verifier: new finding]`
- Verifier #2 challenges that hold up → **downgrade or remove** the flagged finding
- Verifier #3 scope gaps → append as `[Verifier: scope gap]`
- Dynamic verifier findings → append as `[Verifier: {angle}]`

**False positive discipline:** Every finding must include specific location (file:line), mechanism (how the defect manifests), and impact (what breaks). Findings without concrete evidence are noise — suppress or demote them. Findings the developer can't act on in the current change scope are out of scope.

Present consolidated output:

```
### Verification Pass (3 fixed + {N} dynamic)

**Confirmed:** {count} findings independently verified
**New findings:** [list, if any — with source verifier angle]
**Downgraded/removed:** [list with reasoning, if any]
**Scope gaps:** [list, if any]
**Dynamic angles checked:** [list of angles that were spawned]
**Verifier gaps:** [list any verifiers that failed to return, if any]
```

#### Phase 4 — Escalation check

If synthesis finds **unresolvable conflicts** between verifiers (one confirms an issue, another disproves it with equal evidence):

- **Stop for resolution.** Surface the disagreement to the user and do not proceed with further review steps until resolved. This matches the CLAUDE.md Verification Protocol: "If verifier findings conflict with original analysis → surface disagreement and stop for resolution."
- Flag in output: "Verification produced conflicting findings on {topic} — **review paused for resolution**."
- Characterize the conflict: factual (different evidence), interpretive (same evidence, different reading), or normative (different trade-off weighting).
- At scope boundary (`codebase-investigation`), read manifest, present providers via AskUserQuestion for deeper investigation if needed.

<!--
Decision tree (for future skill development reference):

Independent work, report back only → subagents
  - Verification passes (each verifier works alone)
  - Parallel review angles (each reviewer checks independently)
  - Triage / classification tasks

Agents need to communicate / challenge each other → teams
  - Adversarial hypothesis testing
  - Cross-layer coordination (frontend + backend + tests)
  - Competing interpretations needing debate

For /review: always subagents. Escalate to `codebase-investigation` skill (which uses teams
at Tier 3) when conflicts are unresolvable.
-->

### 5. Learn

After review, extract 0-3 generalizable takeaways. Skip entirely if all findings are covered by existing skills or too specific.

**Classify and record:**

| Scenario | Route to | Severity/Confidence |
|----------|----------|-------------------|
| Issue in code Claude wrote this session | MISTAKES.md | Match to impact (minor/moderate/major) |
| Recurring pattern in others' code | LEARNINGS.md | `confidence: low` (first occurrence) |
| Anti-pattern not in `code-review-guidelines` | LEARNINGS.md | Add `action: propose-amendment` |

Use standard MISTAKES.md / LEARNINGS.md entry format. Always include `source:review` in tags.

**After recording:** If any `source:review` category in MISTAKES.md has 3+ entries, note that `self-improvement` capability should be invoked.

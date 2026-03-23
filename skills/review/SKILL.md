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
- **Check for existing PR comments**: if PR exists, run `gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[].user.login' | sort | uniq -c` to see if reviewers/bots have already commented. Flag this in context.
- **Detect migration signals**: check if diff touches lockfiles, package manager configs, or CI files. Signals: new/deleted lockfile (yarn.lock, pnpm-lock.yaml, bun.lock), config files (bunfig.toml, .npmrc, .yarnrc), Jenkinsfile/Makefile pm commands changed.
<!-- PRIVATE:review-project-routing-detect -->

### 2. Ask

Use AskUserQuestion with detected context:

**PR exists:** "Review this PR" (full) or "Review local changes" (unstaged/staged only)
**No PR:** "Review local changes" (unstaged/staged) or "Review against branch" (diff vs base)
**Migration detected:** Add option "Migration review" (structured migration checklist)
**PR comments exist:** Note: "{N} existing review comments from {reviewers}. Include in review?"

### 3. Route

**General routing:**

**PR review:** `/code-review` (automated) or `/pr-review-toolkit:review-pr` (interactive, ask which).

**Local changes:** Review diff directly. Focus: bugs, security, test coverage, patterns. Output: Blocking Issues / Suggestions / Summary.

**Migration review:** See Migration Review Protocol below.

<!-- PRIVATE:review-project-routing -->

### 3b. Migration Review Protocol

Triggered when the diff changes package manager, build tool, or CI pipeline. A structured 11-step process:

#### Phase A: Merge & Resolve
1. **Merge main** into migration branch, resolve all conflicts
2. **Review full diff** against main, every file. Categorize each change: pm-swap (yarn→bun), content change from main, or unrelated change. Flag unrelated changes.

#### Phase B: Validate Against Main
3. **Check PR review comments** from all reviewers (human + bot). Triage: already resolved, not migration-related (skip), or needs action.
4. **Fix divergences from main** that aren't migration-related. If main has a pattern and the branch diverges without reason, sync with main.
5. **Remove stale config** from the old tool (.yarnrc, .npmrc, pnpm-workspace.yaml, old lockfiles).

#### Phase C: CI & Build
6. **Fix CI scripts** (correct invocation patterns for new pm, error chaining).
7. **Fix container/Docker** issues (new pm available where needed).
8. **Test locally** — lint, type check, full build chain. Do NOT skip this. Every edit must be verified before pushing.

#### Phase D: Validate
9. **Push, wait for CI.** Fix what breaks. If CI fails, reproduce locally first.
10. **Final audit:**
    - Grep for ALL references to old pm (yarn, pnpm, npm) across the repo
    - Verify every diff is necessary and correct
    - Check config files against official docs (invalid options are silent failures)
    - Check for version resolution differences (new pm may resolve different versions)
11. **Squash and clean up** the PR.

#### Migration-Specific Checks

**Version resolution**: Different package managers resolve semver ranges differently. When migrating lockfiles, the new pm may resolve newer patch/minor versions that break the build. Compare versions of key dependencies between old and new lockfiles. Pin in overrides if needed.

**Config file validation**: When migration introduces new config files (bunfig.toml, .npmrc), validate every option against official docs. Invalid options are silently ignored and cause confusion later.

**Lockfile determinism**: Ensure the new pm uses frozen lockfile in CI. Without it, the lockfile can change on every install, breaking cache hashing (e.g. NX remote cache).

**Test what you change**: Every edit must be locally tested before pushing. Run the actual build/lint/test commands, not just "it looks right". If a command can't run locally (CI-only), note it explicitly.

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
| **Migration** | Lockfile changes, pm config, version resolution, CI pipeline |

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

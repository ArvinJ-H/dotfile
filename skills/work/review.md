# Review Methodology

Detailed code review workflow for the /work meta-skill. Parent SKILL.md handles: routing, ICD framework, disciplines.

## Steps

### 1. Detect context

- `gh pr view --json number,title,state 2>/dev/null` -- PR on this branch?
- `git diff --stat` -- unstaged local changes?
- `git diff --cached --stat` -- staged changes?
- Check for existing PR comments: `gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[].user.login' | sort | uniq -c`
- Detect migration signals: diff touches lockfiles, pm configs, CI files? Signals: new/deleted lockfile, config files (bunfig.toml, .npmrc), Jenkinsfile/Makefile pm commands changed.

### 2. Ask

Use AskUserQuestion with detected context:

- **PR exists**: "Review this PR" (full) or "Review local changes"
- **No PR**: "Review local changes" or "Review against branch"
- **Migration detected**: add "Migration review" option
- **PR comments exist**: note existing review comments, offer to include

### 3. Route

**PR review**: automated code-review or interactive toolkit (ask which).

**Local changes**: review diff directly. Focus: bugs, security, test coverage, patterns. Output: Blocking Issues / Suggestions / Summary.

**Migration review**: structured 11-step process (see Migration Protocol below).

### 4. Multi-Angle Verification (PBR)

Runs on every review. Based on Perspective-Based Reading: different perspectives find different defects with low overlap. One pass per perspective; mixed-concern review increases missed defects.

#### Phase 1: Triage

Spawn a single Sonnet subagent to analyze the diff. Return 0-3 dynamic angles:

| Angle | Trigger signals |
|-------|----------------|
| Security | Auth, crypto, input handling, network, secrets |
| Performance | Hot paths, DB queries, loops, caching |
| Concurrency | Async, threads, locks, shared state, event handlers |
| API contract | Public interfaces, type signatures, protocol changes |
| Domain-specific | Project CLAUDE.md rules, project patterns |
| Migration | Lockfile changes, pm config, version resolution, CI |

#### Phase 2: Spawn verifiers (all parallel)

**3 fixed verifiers** (always):

| # | Agent | Mode | Receives | Focus |
|---|-------|------|----------|-------|
| 1 | Independent scanner | scanner | Diff + source (NOT review findings) | Fresh eyes, no anchoring bias |
| 2 | False positive auditor | adversarial | Review findings + full context | Challenge each finding with code evidence |
| 3 | Completeness checker | completeness | Findings + diff stat + file tree | Coverage, related files, imports, tests |

**0-3 dynamic verifiers** per triage. Each gets diff + source + specialized prompt.

Total: 4-7 subagents. Timeout: note gaps, don't re-spawn.

#### Phase 3: Synthesis

- Overlapping findings -> **confirmed** (high confidence)
- Scanner-only findings -> append as `[Verifier: new finding]`
- Auditor challenges that hold -> **downgrade or remove**
- Scope gaps -> append as `[Verifier: scope gap]`
- Dynamic findings -> append as `[Verifier: {angle}]`

**False positive discipline**: every finding needs file:line, mechanism, impact. No evidence = suppress.

#### Phase 4: Escalation

If unresolvable conflicts between verifiers (one confirms, another disproves with equal evidence):
- Stop for resolution. Surface disagreement to user.
- Characterize: factual, interpretive, or normative.
- At scope boundary, invoke /think (Deepdive workflow) or present providers via AskUserQuestion.

### 5. Learn

Extract 0-3 generalizable takeaways:

| Scenario | Route to | Notes |
|----------|----------|-------|
| Issue in code Claude wrote this session | MISTAKES.md | Match severity |
| Recurring pattern in others' code | LEARNINGS.md | confidence: low |
| Anti-pattern not in guidelines | LEARNINGS.md | action: propose-amendment |

If any `source:review` category hits 3+ entries, note self-improvement capability should be invoked.

## Migration Review Protocol

Triggered when diff changes package manager, build tool, or CI pipeline.

**Phase A: Merge and Resolve**
1. Merge main into migration branch, resolve conflicts.
2. Review full diff. Categorize each change: pm-swap, content from main, or unrelated. Flag unrelated.

**Phase B: Validate Against Main**
3. Check PR comments from all reviewers. Triage: resolved, not migration-related, or needs action.
4. Fix divergences from main that aren't migration-related.
5. Remove stale config from old tool.

**Phase C: CI and Build**
6. Fix CI scripts (correct invocation for new pm).
7. Fix container/Docker issues.
8. Test locally: lint, type check, full build. Every edit verified before push.

**Phase D: Validate**
9. Push, wait for CI. Fix what breaks (reproduce locally first).
10. Final audit: grep for ALL old pm references, verify every diff, validate configs against official docs, check version resolution.
11. Squash and clean up.

**Migration checks**: version resolution differences (pin in overrides if needed), config validation against official docs (invalid options are silent), lockfile determinism (frozen lockfile in CI).

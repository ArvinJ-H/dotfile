# Review Criteria by Change Type

Supporting reference for the Review workflow. Provides change-type detection patterns and review criteria for non-code PRs.

## Change-Type Detection

Classify each changed file using structural detection. Three tiers in priority order:

### Tier 1: Path patterns

| Pattern | Category |
|---|---|
| `docs/`, `doc/`, `documentation/`, `man/`, `examples/`, `demos/` | docs |
| `test/`, `tests/`, `__tests__/`, `spec/`, `specs/`, `test-data/` | tests |
| `.github/workflows/`, `.gitlab/`, `.circleci/`, `jenkins/` | infra |
| `kubernetes/`, `k8s/`, `helm/`, `terraform/`, `.terraform/` | infra |
| `.claude/`, `.cursor/`, `.windsurf/`, `.continue/`, `.amazonq/`, `.aiassistant/`, `.tabnine/`, `.cody/` | ai-config |
| `.github/instructions/`, `.github/copilot*` | ai-config |
| `node_modules/`, `vendor/`, `dist/`, `build/`, `.yarn/`, `cache/` | generated |

### Tier 2: Known filenames

| Filename pattern | Category |
|---|---|
| `README*`, `CONTRIBUTING*`, `CHANGELOG*`, `LICENSE*`, `COPYING*`, `CODE_OF_CONDUCT*`, `SECURITY*`, `CITATION*` | docs |
| `CLAUDE.md`, `AGENTS.md`, `AGENTS.override.md`, `.cursorrules`, `.windsurfrules`, `.clinerules`, `.continuerules`, `.aider.conf.yml`, `.aiderignore`, `.claudeignore`, `.cursorignore`, `.cursorindexingignore`, `.clineignore` | ai-config |
| `Makefile`, `CMakeLists.txt`, `Rakefile`, `Cargo.toml`, `go.mod`, `go.sum`, `package.json`, `pyproject.toml`, `pom.xml`, `build.gradle*` | config |
| `tsconfig*`, `jest.config*`, `vitest.config*`, `.eslintrc*`, `.prettierrc*`, `.stylelintrc*`, `.rubocop.yml`, `.editorconfig`, `.gitignore`, `.gitattributes`, `.npmrc` | config |
| `Dockerfile*`, `Containerfile`, `docker-compose*`, `Vagrantfile`, `Procfile`, `Earthfile`, `Jenkinsfile`, `.gitlab-ci.yml` | infra |
| `*.lock`, `package-lock.json`, `yarn.lock`, `Gemfile.lock`, `Cargo.lock`, `composer.lock`, `poetry.lock`, `bun.lockb` | lock |

### Tier 3: Extension fallback

Only when tiers 1 and 2 don't match.

| Extension | Category | Notes |
|---|---|---|
| `.md`, `.rst`, `.adoc` | docs | Unless in source directory |
| `.tf`, `.tfvars` | infra | Terraform |
| `.yaml`, `.yml` in root or config dirs | config | Ambiguous in source dirs |
| Everything else | code | Default |

### Classification logic

```
For each changed file:
  1. Check path against Tier 1 patterns -> return category if match
  2. Check basename against Tier 2 filenames -> return category if match
  3. Check extension against Tier 3 -> return category
  4. Default: code
```

For a PR, collect all unique categories. Mixed PRs get the union of review criteria.

---

## Review Criteria

### Code

Defer to project-specific guidelines (project KNOWLEDGE.md files, archetype patterns). The /work Review workflow's PBR methodology handles code review.

### Docs

| Dimension | What to check |
|---|---|
| **Accuracy** | Do instructions match current behavior? Are code snippets runnable? Version numbers current? |
| **Completeness** | Full workflow covered? Prerequisites listed? Edge cases mentioned? "Why" explained, not just "how"? |
| **Clarity** | Target audience can follow without outside help? Jargon defined? Sentences short and direct? |
| **Audience** | Who is this for (user, contributor, operator)? Assumed knowledge matches audience? |
| **Freshness** | Internal links valid? External links live? No references to removed features or deprecated APIs? |
| **Formatting** | Follows project doc style? Consistent headings, lists, code fences? |

**Critical pattern**: docs should ship in the same PR as the code they describe. Flag docs-only PRs that claim to document a feature shipped separately.

**Common mistakes**: docs describing planned behavior (not shipped), untested code samples, "See X" where X was renamed, mixing audiences in one doc.

**Output format**: Accuracy Issues / Gaps / Clarity / Stale References

### Config

| Dimension | What to check |
|---|---|
| **Backwards compat** | Breaks existing builds or dev setups? New env vars documented? All consumers updated? |
| **Security** | Hardcoded secrets? New permissions minimal? CI actions pinned to SHA (not mutable tag)? Docker base images pinned to digest? |
| **Performance** | Increased build time or image size? Caches properly configured? CI jobs parallelized? |
| **Correctness** | Syntactically valid? Options supported by the tool version in use? Disabled rules have comments? Lock file matches manifest? |
| **Scope** | PR description explains *why*? One concern per PR? Dependency update risk level noted? |
| **Reproducibility** | Clone-and-build works? Version constraints specific enough? CI runner images pinned? |

**Common mistakes**: CI action pinned to `@main` not SHA, Docker `:latest` in production, new env var missing from `.env.example`, lock file drift, config that works on author's OS but not CI.

**Output format**: Change / Impact / Risk / Verify

### AI Tool Configs

Files: CLAUDE.md, AGENTS.md, .cursorrules, .cursor/rules/*.mdc, .windsurfrules, .windsurf/rules/*.md, .github/copilot-instructions.md, .github/instructions/*.instructions.md, .clinerules, .continuerules, .continue/rules/*.md, .aider.conf.yml, CONVENTIONS.md, .tabnine/guidelines/*.md, .amazonq/rules/*.md, .aiassistant/rules/*.md, .claudeignore, .cursorignore, .cursorindexingignore, .clineignore, .aiderignore, .cody/ignore, .claude/settings.json

| Dimension | What to check |
|---|---|
| **Leakage** | Internal URLs, IPs, hostnames? Credentials or API keys (even as examples)? Proprietary architecture or internal tool names? Internal team/org references? Real internal file paths in examples? |
| **Instruction quality** | Clear and unambiguous? Contradictions between instructions? Constraints testable (not vague "write good code")? Scoped to this project (not a generic dump)? No harmful instructions ("skip validation", "never write tests")? |
| **Injection risk** | Instructions to override safety behavior? Encoded or obfuscated strings? "Ignore previous instructions"? Auto-approve or skip-review instructions? External URL fetching at runtime (indirect injection)? |
| **Cross-tool consistency** | Multiple AI configs agree on conventions? Contradictions with CONTRIBUTING.md or style guides? All configs updated together? |
| **Project alignment** | Instructions match actual codebase patterns? Referenced libraries are real dependencies? Referenced patterns exist in the code? File paths are real? |
| **Maintenance burden** | References specific versions, file paths, team members (will go stale)? Too long for tool's token limit? Duplicated across config files (will drift)? |

**OWASP context**: prompt injection is rated #1 LLM risk. Attack success rates on coding agents reach ~84%. Review AI configs with security mindset.

**Common mistakes**: internal staging URLs in public repos, "@company/internal-package" leaking names, auto-approval instructions, config copied from another project without adaptation, Cursor-specific instructions in CLAUDE.md.

**Output format**: Leakage / Injection Risk / Consistency / Suggestion

### Infra

| Dimension | What to check |
|---|---|
| **Security** | No hardcoded secrets? IAM/RBAC least privilege (no wildcards)? Firewall rules: no 0.0.0.0/0 on sensitive ports? Encryption at rest and in transit? Container security contexts (runAsNonRoot, readOnlyRootFilesystem)? |
| **Cost** | Estimated cost impact? Instance types appropriate? Autoscaling prevents runaway costs? Expensive resources (NAT, LB, GPU) justified? |
| **Reliability** | Redundancy (multi-AZ, replicas)? Health/readiness/liveness probes? Resource requests and limits set? Rollback strategy exists? |
| **Blast radius** | How many resources touched? Could a mistake take down production? Changes isolated by environment? terraform plan output included? |
| **Reproducibility** | Apply from scratch to a new environment? Provider/module/image versions pinned? Variable defaults sensible? |
| **Governance** | Resources tagged consistently (owner, env, cost center)? Naming conventions followed? No deprecated API versions? |

**Common mistakes**: terraform plan shows unintended destruction, security group allows 0.0.0.0/0 on SSH, no resource limits on K8s pods, S3 without encryption, IAM with Action:"*", module version unpinned.

**Output format**: Change / Security / Cost / Blast Radius / Verify

### Tests

| Dimension | What to check |
|---|---|
| **Coverage** | New behavior has tests? Edge cases covered? Negative cases (what should NOT happen)? |
| **Quality** | Assertions are meaningful (not just "no error")? No false-greens (tests that pass for wrong reasons)? |
| **Isolation** | Tests don't depend on each other's state? No global state leaks? Parallelizable? |
| **Naming** | Test names describe behavior, not implementation? |

Tests-only PRs (adding coverage, fixing flaky tests) get lighter review. Tests alongside code changes get full scrutiny.

### Lock files

Lock file changes are low-review-priority. Check: was it regenerated intentionally (matches manifest change)? Is it committed with the correct package manager version? Flag if lock file changed but manifest didn't (accidental regen).

---

## Mixed PRs

When a PR contains multiple change types:
1. Report the breakdown (e.g., "12 code, 3 docs, 1 AI config")
2. Apply review criteria for ALL detected types (union, not pick-one)
3. Section the review output by change type
4. Cross-reference: do docs changes match code changes in the same PR?

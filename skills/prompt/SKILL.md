---
name: prompt
description: Analyse a draft prompt for gaps and ambiguity, ask targeted questions, then output a refined version. Use when a task is too complex for one-shot or when you want to sharpen a prompt before sending it. TRIGGER: always. Runs on every user prompt to analyze for gaps and refinement opportunities. Follow-up prompts are grouped with the original context.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Task, Write, WebSearch, WebFetch
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

Refine a draft prompt by identifying gaps, asking targeted questions always with AskUserQuestion tool, and producing a ready-to-use version.

## Steps

### 1. Receive, classify, and detect target

Take the user's draft prompt (from arguments or ask for it). Classify by **type** and **target**.

**Type:**

| Type | Characteristics | Key dimensions |
|------|----------------|----------------|
| **Code task** | Implementation, bug fix, refactor | Context, Constraints, Scope, Success criteria |
| **Research** | Investigation, analysis, comparison | Intent, Scope, Depth, Output format |
| **System prompt** | Agent instructions, persona definition | Persona, Boundaries, Tone, Examples |
| **Creative** | Writing, naming, design | Tone, Audience, Constraints, Examples |
| **Workflow** | Multi-step process, automation | Sequence, Error handling, Scope, Success criteria |

**Target** — who will consume this prompt:

| Target | When it fires | Key adaptation |
|--------|--------------|----------------|
| **Self** (default) | Prompt for this Claude session | Skip Persona, focus on Intent/Scope/Constraints |
| **External tool** | "for ChatGPT", "for Cursor", mentions pasting elsewhere | Full self-containedness, include Persona |
| **System prompt** | Designing agent instructions, persona definitions | Persona IS the deliverable; Boundaries, Tone, Examples. Distinct discipline: defensive design, positive framing, structural clarity (XML/headers/delimiters), constraint-driven over instruction-driven. |

Auto-detect from content when possible ("write a prompt for GPT to..." → external). Ask if ambiguous. State both classifications briefly before proceeding.

**Density preference** — for substantial drafts (not thin one-liners, not system prompts), ask:

- **Concise** — tight, 2-5 sentences. For simple tasks or when the user knows exactly what they want.
- **Standard** (default) — balanced structure. Clear without being bureaucratic.
- **Comprehensive** — full brief with all sections. For complex tasks, reusable prompts, or system prompt design.

Skip for thin drafts (always need building up) and system prompts (always comprehensive).

### 2. Code-aware enrichment (if applicable)

If the draft references specific files, functions, or modules — read them. Use this to:
- Verify the references exist (catch stale paths)
- Pull function signatures, types, or structure as candidate context for the refined prompt
- Identify constraints the user may have forgotten (e.g. the function is async, the module has no tests)

Skip this step if the prompt is not code-related or doesn't reference specific code.

### 2b. Knowledge enrichment (if applicable)

If the draft could benefit from accumulated knowledge or external research:
1. If significant gaps remain that would improve the prompt, invoke /think (Research workflow). Do not create research workspaces or run research from /prompt.
2. If the prompt targets codebase investigation, invoke /think (Deepdive workflow).

Skip if the prompt is self-contained and doesn't require external knowledge.

### 3. Gap analysis

Evaluate the draft across grouped dimensions. For each, score **coverage** and **severity**.

**Coverage**: `present` (explicitly stated) | `implied` (inferable but not explicit) | `missing`

**Severity**: `critical` | `important` | `nice-to-have` — context-dependent:
- Missing Intent → always critical
- Missing Persona when target = external → critical
- Missing Examples on a simple task → nice-to-have
- Missing Examples on an ambiguous task → critical
- Missing Output format when the default is fine → nice-to-have
- Missing Output format when format matters → important

**Core dimensions (always evaluated):**

| # | Dimension | What to check | Common failure mode |
|---|-----------|--------------|-------------------|
| 1 | **Intent** | Desired *outcome*, not just the task | "Refactor this" — but to achieve what? |
| 2 | **Contradictions** | Do parts conflict? | "Keep it simple" + "Handle all edge cases" |
| 3 | **Context** | Enough background for the *recipient*? | Assumed knowledge about codebase, domain |
| 4 | **Scope** | What's in and out? | "Improve the API" — all endpoints? |
| 5 | **Constraints** | Boundaries explicit? | No mention of compat, perf, style |
| 6 | **Success criteria** | How to verify correctness? | No acceptance test, no "done looks like" |
| 7 | **Output format** | What structure, length, format? | Default assumed when format matters |

**Conditional dimensions:**
- **Persona** — when target != self. Who should do this, what expertise, what tone?
- **Examples** — when task is ambiguous or complex enough to benefit from input/output pairs.
- **Reasoning strategy** — when the task requires multi-step analysis, comparison, or synthesis. What thinking approach? (decompose first, enumerate options, argue both sides, etc.)

Severity guides what becomes a question (critical/important) vs. a brief note in synthesis (nice-to-have).

### 4. Questionnaire

Use AskUserQuestion targeting the top gaps. Rules:

- **Max 2 rounds of questions.** More than that means the draft needs rewriting, not gap-filling.
- **2-4 questions per round.** Focus on critical and important gaps first.
- **Be specific, not generic.** Bad: "Can you add more context?" Good: "This references `CardList` — should the fix only affect the focused state, or also the selected state?"
- **Offer concrete options** when the gap has enumerable answers.
- **Implied -> confirm, not ask.** If something is inferable, confirm the inference: "I'm reading this as TypeScript-only, no runtime changes — correct?"
- **Skip the round** if the draft is already solid. Not every prompt has gaps.

### 5. Synthesise

Produce the refined prompt in this format:

```
**Refined prompt:**

[The improved prompt text — ready to copy/paste]

**What changed:**
- [Brief bullet list of additions/clarifications/restructuring]
```

Refinement guidelines:
- **Tighten, don't inflate.** Strip noise before adding context. The refinement should be more precise, not just longer.
- **Preserve voice.** Match the user's tone and style.
- **Make implicit explicit.** The main value is surfacing assumed context.
- **Restructure if needed.** Better ordering can improve a prompt without adding words.
- **Front-load and repeat critical instructions.** Research shows beginning and end of prompts get highest attention (lost-in-the-middle effect). Place key constraints at the start and reiterate at the end for long prompts.
- **Flag remaining ambiguity.** If something is still unclear after 2 rounds, note it as a known gap rather than guessing.

**Tightening pass** — apply before finalising:

Safe to apply:
- Strip politeness ("please", "could you", "would you")
- Remove fillers ("basically", "actually", "really", "very", "just", "simply") — NOT near negations ("not really" stays)
- Compress verbose headers ("Your task is to" → direct statement, "You are a" → "Role:" for non-self targets)
- Collapse excessive whitespace (preserve code block formatting)
- Restructure for directness — lead with the ask, context after

Skip (harmful in CLI):
- Abbreviations (database→db) — loses precision
- Aggressive truncation — mid-sentence cuts
- Whitespace collapse inside code blocks

### 6. Iterate or use

Ask: "Use this prompt, iterate further, or adjust specific parts?"

One round of adjustment is fine. More than that — the user should edit the prompt directly.

If the prompt targets codebase investigation, invoke /think (Deepdive workflow) instead.

## Always-On Behavior

/prompt runs automatically on every user prompt:
1. Classify the prompt (type + target) per Step 1
2. Run lightweight gap analysis per Step 3
3. If gaps are critical/important → enter questionnaire (Step 4)
4. If prompt is solid → proceed to execution without interruption
5. **Route to provider**: After analysis, check the Capability Manifest in CLAUDE.md. If the task matches a provider, invoke it via `Skill(provider)` before using native tools. One clear match, invoke directly. Multiple matches, pick the primary. This step is not optional.

Follow-up prompts within the same task are grouped with the original:
- Maintain prompt context across follow-ups
- New information refines the original classification, not a fresh start
- Only re-run questionnaire if the follow-up changes scope significantly

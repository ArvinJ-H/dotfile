# Design Evaluation
**When to load**: Evaluating existing UI, reviewing mockups, assessing usability, running heuristic evaluation  |  **Skip if**: Creating new designs from scratch (use other pillars first, then evaluate)

> **Scope boundary**: This file covers frameworks and methods for evaluating design quality. For accessibility-specific evaluation, also load `accessibility-design`. For implementation-specific code review, delegate to `code-review`.

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Nielsen's 10 heuristics are the first-pass framework** | Developed 1994, validated across thousands of evaluations. 3-5 evaluators find ~75% of usability issues (Nielsen & Landauer, 1993). Diminishing returns beyond 5. | Every evaluation should start here. Structured framework prevents "I don't like it" feedback. |
| 2 | **Severity = frequency x impact x persistence** | Not all issues are equal. Cosmetic (1), Minor (2), Major (3), Catastrophic (4). A rare catastrophic issue outranks a frequent cosmetic one. Persistence: can the user work around it? | Prioritizes fix order. Prevents spending effort on polish while critical flows are broken. |
| 3 | **Evaluate against tasks, not screens** | Users don't browse screens — they complete tasks. A beautiful screen that blocks task completion is a failed design. | Always define 3-5 core tasks before evaluating. Walk through each end-to-end. |
| 4 | **Mental model alignment determines usability** | Norman's Gulf of Execution (user intention → system action) and Gulf of Evaluation (system state → user understanding). Mismatches between user mental model and system model cause errors. | Information architecture, naming, navigation, and feedback all evaluated against: "Does this match how users think about this?" |
| 5 | **Expert evaluation complements, not replaces, user testing** | Heuristic evaluation finds different issues than user testing. Experts catch structural/systematic issues. Users reveal unexpected workflows and misunderstandings. Both needed. | Expert evaluation for design reviews and iteration. User testing for validation before shipping. |
| 6 | **Comparison requires baselines** | "Is this good?" is unanswerable without context. Compare against: previous version, competitor, industry benchmark, or established patterns. | Always establish what you're comparing against. Improvement over baseline, not abstract quality. |

## Decision Tables

### Method Selection

| Situation | Method | Time needed | Evaluators | Output |
|-----------|--------|-------------|------------|--------|
| Quick design review (PR, mockup) | Heuristic evaluation | 1-2 hours | 1-3 experts | Issue list with severity ratings |
| Validating a new flow before build | Cognitive walkthrough | 2-4 hours | 1-2 experts | Step-by-step pass/fail with failure reasons |
| Assessing overall product usability | User testing (think-aloud) | 1-2 weeks | 5 representative users | Task completion rates, error patterns, qualitative insights |
| Comparing two design options | A/B test or preference test | Days-weeks (A/B), hours (preference) | Statistical sample (A/B), 20-30 (preference) | Quantitative conversion/preference data |
| First-impression clarity | Five-second test | Minutes per participant | 20-30 participants | Recall accuracy: what is this page about? |
| Quick quantitative benchmark | System Usability Scale (SUS) | 2 minutes per participant | 12+ participants for reliable scores | Score 0-100. Average ~68. Above 80.3 = A grade. |
| Information architecture validation | Tree test / card sort | Days | 30-50 participants | Task success rate (tree test), category agreement (card sort) |
| Measuring task efficiency over time | PURE evaluation | 30 min-1 hour | 1-3 experts | Task completion probability rating per step |

### Severity Rating Calibration

| Severity | Definition | Fix priority | Examples |
|----------|-----------|-------------|----------|
| 0 — Not a problem | Evaluators disagree or issue is preference. No user impact. | Don't fix | Subjective color preference. Minor alignment difference. |
| 1 — Cosmetic | User notices but isn't slowed. Visual polish. | Fix if time permits | Inconsistent border radius. Slightly off spacing. |
| 2 — Minor | User is slowed but can recover independently. | Fix in normal cycle | Unclear label (users figure it out). Non-obvious but findable feature. |
| 3 — Major | User is significantly impaired. May need external help or abandon task attempt before recovering. | Fix before next release | Critical action buried in menu. Ambiguous destructive action. Form validation that clears input. |
| 4 — Catastrophic | User cannot complete task. Data loss possible. | Fix immediately | Broken flow with no recovery. Undiscoverable required action. State loss on back navigation. |

### Nielsen's 10 Heuristics — Quick Reference

| # | Heuristic | Key questions | Common violations |
|---|-----------|--------------|-------------------|
| 1 | Visibility of system status | Does the user always know what's happening? Is there feedback within 100ms (action), 1s (result), 10s (progress)? | Missing loading states. No confirmation after action. Stale data without indication. |
| 2 | Match between system and real world | Does it use user language, not developer language? Do metaphors match expectations? | Technical jargon in UI. Icon metaphors that don't translate. Unfamiliar terminology. |
| 3 | User control and freedom | Can users undo? Is there a clear exit from every state? | No undo. No cancel. Modal dialogs with no escape. Forced flows. |
| 4 | Consistency and standards | Same action = same result everywhere? Platform conventions followed? | Different patterns for same interaction. Non-standard controls. Inconsistent terminology. |
| 5 | Error prevention | Are dangerous actions guarded? Are constraints clear before commitment? | No confirmation on delete. Ambiguous submit buttons. Easy to click wrong target. |
| 6 | Recognition over recall | Is information visible when needed? Are options shown, not memorized? | Hidden navigation. Format requirements shown only after error. Codes users must remember. |
| 7 | Flexibility and efficiency | Are there shortcuts for experts? Can the interface adapt to frequency of use? | No keyboard shortcuts. No bulk actions. No defaults for common choices. |
| 8 | Aesthetic and minimalist design | Does every element earn its space? Is signal-to-noise ratio high? | Cluttered screens. Decorative elements competing with content. Redundant information. |
| 9 | Help users recognize, diagnose, recover from errors | Are error messages specific, helpful, and actionable? | Generic "Something went wrong." Error codes instead of explanations. No suggested fix. |
| 10 | Help and documentation | Is help findable, task-oriented, and concise? | No contextual help. Documentation organized by feature, not task. FAQ as substitute for good design. |

### State Coverage Checklist

| State | What to evaluate | Often missed? |
|-------|-----------------|---------------|
| Empty state | Is it helpful? Does it guide toward first action? Or is it just "No data." | Very often |
| Loading state | Is there feedback within 1 second? Does it indicate progress or just activity? | Often |
| Error state | Is the error message specific and actionable? Can the user recover without starting over? | Often |
| Partial data | What if only 2 of 5 fields are filled? What if the list has 1 item vs 1000? | Often |
| Overflow | Long names, long descriptions, many items. Does the design handle extremes? | Often |
| Permission denied | Clear explanation of why access is denied and how to get it? | Very often |
| Offline / degraded | What's the experience when network drops? Stale data with warning? | Often on web |
| Success confirmation | Does the user know their action worked? How? For how long? | Sometimes |
| Concurrent editing | What happens when two users edit the same thing? Conflict indication? | Often in collaborative tools |
| Expired session | Graceful re-authentication? Data preservation? | Often |

### Response Time Thresholds (Jakob Nielsen, 1993 — still valid)

| Threshold | User perception | Design requirement |
|-----------|----------------|-------------------|
| 0-100ms | Instantaneous. Direct manipulation feels connected. | Button state changes, toggle switches, hover effects. |
| 100ms-1s | User notices delay but flow isn't broken. | Form submissions, simple navigation, search results. Show action acknowledgment. |
| 1-10s | User's attention wanders. Flow is interrupted. | Show progress indicator. Skeleton screens. Ability to cancel. |
| 10s+ | User may abandon task. | Show progress percentage or estimate. Allow background processing. Provide abort option. |

## Platform Notes

**Web (primary)**:
- Evaluate at multiple viewport widths: 320px (small mobile), 768px (tablet), 1280px (laptop), 1920px (desktop). Responsive breakpoints are usability-critical.
- Test with browser zoom at 100%, 200%, 400%. Content reflow at high zoom is a major failure point.
- Network conditions: evaluate loading states on 3G throttle. Skeleton screens, progressive loading, error recovery.
- Browser inconsistencies: test in Chrome, Firefox, Safari minimum. Safari on iOS has unique viewport and scroll behaviors.
- SPA navigation: evaluate whether browser back button works correctly. History state, scroll position restoration, deep linking.

**Mobile**:
- Thumb zone: primary actions in bottom 1/3 of screen (Hoober, 2017). Navigation increasingly bottom-anchored.
- Evaluate with actual devices, not just responsive browser. Touch interactions, scroll momentum, keyboard behavior differ.
- Interruption recovery: mobile users get interrupted. Can they return and resume? Is state preserved?
- Reachability: one-handed use. Top-right corner is hardest to reach on large phones.
- Soft keyboard: does it obscure form fields? Does the viewport adjust? Is the correct keyboard type shown (email, number, URL)?

**Desktop**:
- Keyboard navigation: tab through entire flow. Is it logical? Are there traps? Can you complete every task without a mouse?
- Information density: desktop users expect (and can handle) more density than mobile. But density != clutter — structure and whitespace still matter.
- Multi-window: evaluate alongside other apps. Does it work at half-screen width? Does it handle focus loss/return?
- Right-click and context menus: do they conflict with custom controls? Are they suppressed where they shouldn't be?

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| Evaluating without defined tasks | "Look at this screen and tell me what you think" produces opinions, not usability data. | Define 3-5 representative tasks. Evaluate each step of task completion. | Very common |
| Conflating preference with usability | "I don't like blue" is not a usability finding. Preference studies and usability studies answer different questions. | Tie every finding to a heuristic or task impact. If it's preference, label it as such. | Very common |
| Fixing cosmetic issues before critical ones | Low-severity fixes are visible and satisfying. High-severity fixes are harder. Leads to polished but broken experiences. | Sort by severity. Fix 3s and 4s first. Batch 1s and 2s for polish passes. | Common |
| Testing with colleagues or stakeholders | Internal users know the system. They don't represent real users. Familiarity masks discoverability and learnability issues. | Use representative users. If internal testing is unavoidable, use new employees or people from unrelated teams. | Common |
| Evaluating the mockup, not the interaction | Static mockups hide timing, animation, state transitions, loading, error handling. Many usability issues live in the transitions. | Evaluate interactive prototypes where possible. For static mockups, explicitly evaluate each state transition in writing. | Common |
| One evaluator, one pass | Single evaluator finds 35% of issues (Nielsen). Confirmation bias narrows focus after first pass. | 3-5 independent evaluators. Merge findings after independent passes. Second pass after reading others' findings. | Moderate |
| Anchoring on first evaluation | First evaluation sets expectations. Subsequent evaluations compared to it rather than to user needs. | Re-ground each evaluation in user tasks and heuristics. Compare to baseline, not to previous evaluation round. | Moderate |
| Ignoring error and edge-case states | Happy path looks great. Empty states, error states, loading states, permission-denied states are where UX breaks down. | Explicitly evaluate: empty, loading, error, partial, overflow, expired, denied. Each is a design deliverable. | Common |

## Named Patterns

### Heuristic Evaluation Protocol
**When to use**: Any design review — mockups, PRs, live product assessment.
**When NOT to use**: Not a substitute for user testing on critical flows before launch.
**Steps**: (1) Brief evaluators on user personas and core tasks. (2) Each evaluator independently reviews against all 10 heuristics. (3) Each issue gets: heuristic violated, description, severity, screenshot/location. (4) Merge findings, deduplicate, calibrate severity as group. (5) Prioritize by severity for fix backlog.

### Cognitive Walkthrough Script
**When to use**: Validating new flows or redesigns, especially onboarding and first-use.
**When NOT to use**: Established flows where analytics show high completion rates.
**At each step ask**: (1) Will the user try to achieve this action? (motivation) (2) Will the user see the control? (visibility) (3) Will the user associate the control with the action? (labeling, affordance) (4) Will the user understand the feedback? (system status). Failure on any question = design issue.

### Five-Second Test
**When to use**: Evaluating first-impression clarity. Landing pages, dashboards, key entry points.
**When NOT to use**: Complex workflows that require interaction to understand.
**Protocol**: Show screen for 5 seconds, hide it, ask: "What was this page about?" "What could you do on this page?" "Who is this for?" Accuracy below 60% = clarity problem.

### System Usability Scale (SUS)
**When to use**: Benchmarking overall usability. Tracking across versions. Comparing alternatives.
**When NOT to use**: Diagnosing specific issues (SUS tells you *how much* of a problem, not *what* the problem is).
**Scoring**: 10 questions, 5-point Likert. Score range 0-100. Mean ~68. Below 51 = F. 68 = C. 80.3+ = A. Adjective equivalent: below 50 = "awful," 85+ = "excellent" (Bangor et al., 2009).

### Task Completion Analysis
**When to use**: User testing sessions. Quantifying usability.
**When NOT to use**: Expert-only evaluations (no real users to measure).
**Metrics**: Completion rate (binary), time on task, error rate, error recovery rate, number of assists. Jeff Sauro's recommendation: 78% benchmark completion rate for average web tasks. Below = problem. Report confidence intervals, not just averages.

### Competitive Benchmark
**When to use**: New product design. Justifying redesign investment. Setting usability targets.
**When NOT to use**: Unique products with no comparable competitors.
**Protocol**: Define 3-5 shared tasks. Run same evaluation method (SUS, task completion, heuristic) on your product and 2-3 competitors. Compare scores. Identify where competitors succeed that you don't — those are priority gaps.

### Evaluation Report Template
**When to use**: Documenting any formal evaluation for team review.
**When NOT to use**: Quick verbal feedback in a design review meeting.
**Structure**: (1) Evaluation scope: what was evaluated, which tasks, which version. (2) Method: which method(s) used, who evaluated, when. (3) Summary: total issues by severity, top 3 critical findings. (4) Findings table: each issue with ID, heuristic violated, severity, description, screenshot, suggested fix. (5) Comparison: against baseline or previous version. (6) Recommendations: prioritized fix list grouped by severity.

### Think-Aloud Protocol
**When to use**: Moderated user testing sessions. Understanding user reasoning.
**When NOT to use**: Large-sample quantitative studies (think-aloud doesn't scale and affects performance).
**Protocol**: (1) Introduce: "Tell me everything you're thinking as you work through these tasks." (2) Prompt when silent: "What are you thinking?" not "Why did you do that?" (3) Don't help, guide, or react to errors. Neutral prompts only. (4) Record: screen + audio minimum. Video of face optional. (5) Analyze: extract patterns across participants, not individual behaviors. 5 participants reveal ~80% of patterns (Virzi, 1992).

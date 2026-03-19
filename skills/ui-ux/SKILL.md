---
name: ui-ux
description: >
  UI/UX design domain knowledge for web-primary applications. Grounded design
  decisions, alternatives with trade-off analysis, and design evaluation.
  Web-primary, with reference-level mobile/desktop coverage. TRIGGER: design
  decisions, layout trade-offs, interaction patterns, UX evaluation.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Task, ToolSearch
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

# UI/UX Design Domain Knowledge

Domain knowledge for UI/UX design decisions in web applications. Grounds recommendations in named principles, generates alternatives with honest trade-off analysis, and supports creation, review, and consultation.

**Scope**: Web-primary UI/UX design. Mobile and desktop conventions at reference level. Accessibility is embedded for design decisions; deep WCAG/ARIA implementation delegates to `a11y-domain-knowledge`.

**Key statistic**: 88% of users are less likely to return after bad UX (Amazon). Nielsen Norman Group finds users form aesthetic judgments in ~50ms.

## 1. Operating Modes

| Mode | Entry signals | Behavior | Output |
|------|--------------|----------|--------|
| **Create** | "design a...", "propose a...", "how should I..." | Route to pillars → recommend + alternatives | Proposal with grounding + alternatives + tensions |
| **Review** | "evaluate...", "review the UX of..." | Load design-evaluation + relevant pillars → evaluate against principles | Findings table (severity, pillar, principle violated, correction) |
| **Consult** | "why is...", "should I use...", "when to..." | 1-2 pillars → grounded answer | Conversational, every claim cites principle |
| **Research integration** | Invoked by another skill | Provide domain context from relevant pillars | Structured domain context block |

Auto-detect from user input. Ask if ambiguous.

## 2. Pillar Routing Table

Route tasks to the right reference files. Load primary pillars first; load secondary only when primary content isn't sufficient.

| Task signal | Primary pillars | Secondary |
|-------------|----------------|-----------|
| New component design | interaction-design, design-systems | visual-design, accessibility-design |
| Layout / page structure | information-architecture, responsive-adaptive | visual-design |
| Form design | interaction-design, content-design | error-edge-states, accessibility-design |
| Color / typography | visual-design | accessibility-design, i18n-rtl |
| Loading / state UI | performance-ux, error-edge-states | interaction-design |
| Animation / transition | motion-animation | interaction-design, user-psychology |
| Navigation / wayfinding | information-architecture | platform-conventions, responsive-adaptive |
| Evaluating existing design | design-evaluation | (determined by findings) |
| i18n concern | i18n-rtl | content-design, responsive-adaptive |
| Design system / tokens | design-systems | visual-design, platform-conventions |
| Error handling UX | error-edge-states, content-design | interaction-design |
| Mobile/cross-platform | platform-conventions, responsive-adaptive | interaction-design |
| Cognitive load concern | user-psychology | information-architecture, visual-design |
| Microcopy / labels | content-design | i18n-rtl, accessibility-design |
| Inclusive / accessible design | accessibility-design | visual-design, interaction-design |

**Loading**: Read `references/{pillar}.md` on demand. Each file starts with "When to load" / "Skip if" triggers.

## 3. Quick-Reference Decision Tables

80/20 from all 14 pillars. Use for quick grounding; load the full reference file for nuance.

### Visual Design
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Visual hierarchy (size, weight, contrast) | Every layout | Users scan, don't read — guide the eye |
| Gestalt proximity/similarity | Grouping related elements | Items that belong together must look together |
| 60-30-10 color rule | Color palette application | Dominant-secondary-accent prevents visual chaos |

### Interaction Design
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Affordance clarity | Interactive elements | Clickable things must look clickable |
| Immediate feedback (<100ms) | Every user action | No feedback = perceived as broken |
| State visibility | Toggles, selections, modes | User must always know current state |

### Information Architecture
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Progressive disclosure | Complex features | Show only what's needed now |
| Recognition over recall | Navigation, options | Don't make users remember — show them |
| Miller's law (7±2 chunks) | Menus, option sets | Chunk and group beyond 7 items |

### Design Systems
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Token-based values | Colors, spacing, typography | Never hardcode — tokens for consistency |
| Composition over inheritance | Component variants | Build up from primitives, not down from specifics |
| API-first component design | New components | Consumer interface before internal implementation |

### Motion & Animation
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Motion communicates function | Transitions, feedback | Never decorative-only — must convey state change |
| Duration 100-500ms | UI transitions | <100ms unperceived, >500ms sluggish |
| Respect `prefers-reduced-motion` | All animation | Always provide reduced-motion alternative |

### User Psychology
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Fitts's Law (target size x distance) | Buttons, click targets | Critical actions → large + near current focus |
| Hick's Law (choice time ~ log n) | Menus, option sets | Fewer choices = faster decisions |
| Cognitive load (intrinsic + extraneous) | Any complex UI | Reduce extraneous load; respect working memory |

### i18n & RTL
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Text expansion (1.3-2x for short strings) | All UI text | Leave room — buttons and labels will grow |
| Logical properties over physical | CSS layout | `margin-inline-start` not `margin-left` |
| Cultural variation in icons/color | Global products | Not all metaphors translate |

### Content Design
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Front-load key information | Labels, descriptions | First 2-3 words carry 80% of the message |
| Active voice, specific verbs | Error messages, actions | "Save document" not "Document saving functionality" |
| Empty states are onboarding | Zero-content views | Guide, don't just say "nothing here" |

### Performance UX
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Perceived > actual performance | Loading states | Skeleton screens feel ~30% faster than spinners |
| Optimistic UI | Non-critical writes | Show success immediately, reconcile async |
| Progressive loading (above fold first) | Initial render | 1s to meaningful content; 3s to interactive |

### Error & Edge States
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Prevent > detect > recover | Error strategy | Constraints beat validation beats error messages |
| Graceful degradation | Partial failures | Show what works; hide what doesn't |
| Never lose user input | Form/editor errors | Auto-save or preserve draft on failure |

### Responsive & Adaptive
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Content-out breakpoints | Responsive layouts | Break where content breaks, not at device widths |
| Touch targets >= 44px | Touch interfaces | Apple HIG standard; WCAG 2.5.8 says >= 24px |
| Fluid typography (clamp) | Cross-device text | Scale between min/max, don't jump at breakpoints |

### Accessibility (Design-Level)
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Color contrast >= 4.5:1 (text), >= 3:1 (UI) | All visual elements | Non-negotiable baseline |
| Never convey meaning by color alone | Status, errors, states | Add icon, text, or pattern |
| Focus management as design concern | Interactive flows | Design the focus path, not just the visual path |

### Design Evaluation
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Nielsen's heuristics as first pass | Any evaluation | 10 heuristics catch ~80% of usability issues |
| Severity = frequency x impact x persistence | Prioritizing findings | Not all issues deserve equal attention |
| Compare against user mental model | Navigation, terminology | Match user expectation, not system structure |

### Platform Conventions
| Principle | When it applies | Decision impact |
|-----------|----------------|-----------------|
| Web: content-first, scroll-friendly | Web applications | Users expect scroll; avoid fixed-size panels |
| iOS HIG: direct manipulation, clarity | iOS reference | Touch gestures, navigation patterns |
| Material: elevation, motion, adaptive | Android reference | Responsive layout grid, motion system |

## 4. Alternatives with Reasoning Pattern

**Always use this structure** when recommending a design approach. Prevents false universals and strawman alternatives.

```
### Recommendation: {name}
{Description}
**Grounding**: {Named principle(s) — cite from quick-reference or pillar reference}
**Applies because**: {THIS situation's conditions that make this the right choice}
**Trade-off accepted**: {Honest downside of this choice}

### Alternative: {name}
{Description — must be genuinely defensible, not a strawman}
**Grounding**: {Named principle(s)}
**Why it's viable**: {Logic + visual reasoning that makes this a real option}
**Why not here**: {Specific to THIS situation, not a generic disadvantage}
**When it would apply**: {Concrete scenario where this IS the right choice}
```

**Quality rules**:
- No strawmen. Every alternative must be genuinely defensible with named principles.
- Max 2 alternatives. If more exist, pick the top 2 by viability.
- "Why not here" must be situation-specific, not generic ("it's harder to implement").
- "When it would apply" prevents false universals — the recommendation isn't always right.

## 5. Cross-Cutting Anti-Patterns

| Anti-pattern | Why it's wrong | Pillar(s) |
|-------------|---------------|-----------|
| Designing without empty/error states | Users WILL encounter these — they're not edge cases | error-edge-states, content-design |
| Cargo-culting Material/HIG on web | Platform conventions exist for different interaction models | platform-conventions |
| Infinite scroll without position recovery | Users lose context and can't return | information-architecture, interaction-design |
| Custom controls without ARIA semantics | Screen readers can't see them | accessibility-design |
| Animation without reduced-motion | Motion sensitivity is real (vestibular disorders) | motion-animation, accessibility-design |
| "Flat" design hiding interactivity | Discoverability lost for aesthetic minimalism | interaction-design, visual-design |
| Form submission without input preservation | Users will abandon the form | error-edge-states, interaction-design |
| Color-only status indication | ~8% of males have color vision deficiency | accessibility-design, visual-design |

## 6. Nielsen's 10 Usability Heuristics

Compact lens set for quick evaluation. In Review mode, use as first-pass filter before loading pillar-specific criteria.

| # | Heuristic | Quick check |
|---|-----------|-------------|
| 1 | Visibility of system status | Does the user always know what's happening? |
| 2 | Match between system and real world | Does it use the user's language, not system jargon? |
| 3 | User control and freedom | Can the user undo, escape, go back? |
| 4 | Consistency and standards | Does it follow platform conventions and its own patterns? |
| 5 | Error prevention | Are dangerous actions guarded? Constraints enforced? |
| 6 | Recognition rather than recall | Are options visible? Must the user remember anything? |
| 7 | Flexibility and efficiency of use | Shortcuts for experts? Clear default path for novices? |
| 8 | Aesthetic and minimalist design | Does every element serve a purpose? |
| 9 | Help users recognize, diagnose, recover from errors | Are error messages clear, specific, constructive? |
| 10 | Help and documentation | Is help available in context? |

## 7. Scope Boundaries & Delegation

| When you hit... | Delegate to | Why |
|----------------|------------|-----|
| Specific WCAG SC mapping, ARIA role/pattern implementation, screen reader behavior | `a11y-domain-knowledge` | Deep ARIA/WCAG implementation is a11y's expertise |
| Need to research unfamiliar methodology, framework, or study | `external-research` | Domain knowledge here is reference-level, not exhaustive |
| Need to understand how existing code implements a design | `codebase-investigation` | This skill is about design principles, not code archaeology |

**a11y integration rule**: This skill embeds design-level accessibility (contrast ratios, focus management as design concern, semantic structure, color-independent communication). When the question shifts to "which ARIA role," "which SC applies," or "screen reader behavior" — delegate.

## 8. Decision Points

| Situation | Start here |
|-----------|-----------|
| "Design a new component/feature" | Mode: Create → Pillar Routing Table → relevant references |
| "Review this design/mockup/UI" | Mode: Review → Nielsen's heuristics (Section 6) → Pillar Routing → design-evaluation reference |
| "Should I use X or Y?" | Mode: Consult → Alternatives with Reasoning pattern → relevant pillars |
| "Why does this feel off?" | Mode: Consult → Nielsen's heuristics scan → targeted pillar |
| "Make this accessible" | Route to `a11y-domain-knowledge` — that's their scope |
| "Localize this design" | Mode: Create/Consult → i18n-rtl + content-design references |
| "This doesn't work on mobile" | Mode: Review → platform-conventions + responsive-adaptive references |
| Another skill needs design context | Mode: Research integration → relevant pillars → structured context block |

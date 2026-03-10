# User Psychology
**When to load**: Cognitive load assessment, decision architecture, user attention, learning curves, onboarding, choice design  |  **Skip if**: Implementation-level questions with no user cognition component

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Fitts's Law** | Time to acquire target = f(distance, target size). Shannon formulation: ID = log2(2D/W). Larger targets closer to cursor/thumb = faster acquisition. | Primary actions: large + near current focus. Destructive actions: small + far from common click paths. Touch: min 44pt (HIG), 48dp (Material). Infinite-edge targets (screen edges, corners) have effectively infinite size — use them. |
| 2 | **Hick's Law** | Decision time = a + b*log2(n+1) where n = equally probable choices. More options = slower decisions, higher error rate, lower satisfaction. | Limit visible options. 5-7 in navigation, 3-5 in action menus. Group related options under categories. Use progressive disclosure to defer advanced choices. Schwartz paradox: excessive choice leads to decision paralysis and regret. |
| 3 | **Weber's Law** | Just-noticeable difference (JND) is proportional to magnitude, not absolute. A 1px border change on a 2px element is perceptible; on a 20px element it's invisible. | Contrast ratios, not absolute deltas. Font size steps should be proportional (1.2-1.5x scale). Spacing scales need consistent ratios. Color lightness differences need sufficient ratio to register across contexts. |
| 4 | **Cognitive load theory** (Sweller) | Working memory holds ~4 chunks (Cowan, 2001 — updated from Miller's 7+/-2). Three types: intrinsic (task complexity), extraneous (poor design overhead), germane (learning/schema building). | Minimize extraneous load: consistent layouts, clear labels, logical grouping. Manage intrinsic load: break complex tasks into steps. Support germane load: use familiar patterns so learning transfers. Every unnecessary element competes for the ~4 available slots. |
| 5 | **Peak-end rule** (Kahneman) | Users judge an experience by its peak moment (best or worst) and final moment, not by average quality. | Invest in key moments: first successful action (peak positive), error recovery (avoid peak negative), completion/confirmation (strong end). A smooth ending rescues a bumpy middle. A terrible ending ruins everything before it. |
| 6 | **Doherty threshold** | Productivity increases dramatically when system response time < 400ms. Above this, users context-switch mentally and lose their task thread. | Keep interactions below 400ms where possible. When impossible, use perceived-performance techniques (skeleton screens, optimistic UI, progressive rendering) to stay below the threshold perceptually. |
| 7 | **Serial position effect** (Ebbinghaus) | Users remember first items (primacy) and last items (recency) best. Middle items are recalled worst. | Put critical navigation items first and last. In lists: key actions at top and bottom. In onboarding: make first and last steps most memorable. Don't bury the most important option in position 3 of 6. |

## Decision Tables

### When to Chunk vs Paginate
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Browsing content (articles, products, feeds) | Infinite scroll with position markers | Strict pagination | Browsing is exploration — friction kills flow. But provide scroll position indicator and "back to top." |
| Discrete result sets (search results, data tables) | Pagination | Infinite scroll | Users need to reference specific items. Page numbers provide stable coordinates. "Item was on page 3" is useful; "item was somewhere I scrolled past" is not. |
| Complex form (>7 fields) | Multi-step wizard with progress indicator | Single long form | Working memory limit (~4 chunks). Each step should be one conceptual chunk. Progress bar sustains motivation (goal-gradient effect). |
| Dense data (dashboard, analytics) | Chunked cards/panels with collapse | Tabs hiding everything | Users need cross-reference between data chunks. Tabs hide context. Collapsible panels let users control visible scope. |

### Progressive vs Upfront Complexity
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| New user, feature-rich product | Progressive (show basics, reveal on demand) | Everything visible at once | Cognitive overload on first encounter causes abandonment. Let users build mental model incrementally. |
| Expert user, efficiency-critical workflow | Upfront (show all controls) | Hiding frequently-used features behind progressive disclosure | Disclosure clicks become friction for experts. Power users know what they want — don't make them dig for it every time. |
| Mixed audience (novice + expert) | Default progressive + customizable density / keyboard shortcuts | Forcing one mode | Novice mode as default. Expert escape hatches: density toggle, keyboard shortcuts, saved preferences. Flexibility heuristic (Nielsen #7). |
| One-time setup (account creation, config) | Wizard with smart defaults | All-at-once form | Users won't configure things they don't understand yet. Smart defaults handle 80% of cases. Let them adjust later when they have context. |

### Guided vs Exploratory Flow
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| First-time critical task (onboarding, first publish) | Guided (step-by-step with clear next action) | Open exploration | Users don't know what they don't know. Guide them to first success. Peak-end: make first success memorable. |
| Creative/open-ended task (design tool, writing) | Exploratory (canvas + toolbar, no forced sequence) | Forced linear flow | Creative tasks resist linearity. Provide tools and get out of the way. Structure constrains expression. |
| Configuration with dependencies (field B depends on field A) | Guided (reveal B after A is set) | Show everything with dynamic enable/disable | Disabled fields with invisible dependency chains cause confusion. Progressive reveal teaches the model: "A determines B." |
| Repeated daily workflow | Neither — optimize for speed | Heavy guidance or complex exploration | Frequent tasks need minimum friction. Keyboard shortcuts, remembered state, batch operations. Remove ceremony. |

### Defaults and Smart Choices
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Most users choose the same option (>70%) | Pre-select the common default | No default (force explicit choice) | Defaults reduce cognitive load. Users who want different can change it. Status quo bias works in your favor when the default is good. |
| Dangerous/irreversible choice | No default | Pre-selecting the destructive option | Default = implicit recommendation. Never recommend destruction. Force deliberate choice for consequential actions. |
| Options with learning curve | "Recommended" badge on best starting option | Unmarked options with technical labels | Anchoring effect: users trust "recommended" when they lack expertise. Reduces decision anxiety for uncertain users. |
| Preference with no clear best answer (theme, layout) | Remember last choice per user | Reset to default every time | Respect user investment. Forcing re-selection signals "we don't care what you chose." |

### Attention Budget
| Scenario | Recommended approach | Avoid | Principle |
|----------|---------------------|-------|-----------|
| Long content page | Visual hierarchy + scannable headings + summary at top | Wall of text with equal weight | F-pattern scanning. Users scan headings, read first sentence, skip the rest. |
| Data-heavy dashboard | Highlight anomalies, dim normal values | Equal visual weight on all data | Preattentive processing. Outliers catch attention; sameness fades to background. |
| Onboarding sequence | One concept per screen, one action per step | Multiple CTAs competing for attention | Selective attention (Broadbent). Users can attend to one channel at a time. |
| Error during form submission | Inline error at the field, scroll to first error | Error summary only at top or bottom | Proximity principle + change blindness. Users miss distant notifications during focused tasks. |
| Notification while user is typing | Queue until natural pause (submit, page change) | Interrupt with modal or toast during input | Flow state protection (Csikszentmihalyi). Interruption cost: ~23 min to regain deep focus (Mark et al., 2008). |

## Platform Notes

### Web (primary)
- **Attention span**: Average page visit 52s (Weinreich et al., 2008). Above fold = 80% of viewing time. Front-load value.
- **F-pattern scanning** (Nielsen, 2006): Users scan in F-shape on text-heavy pages. First two lines get read; rest gets scanned along left edge. Put key info in first two content lines and left margin.
- **Banner blindness**: Users ignore anything that looks like an ad, including legitimate content in banner positions or with ad-like styling (right sidebar, 728x90 proportions).
- **Hover interaction budget**: Users hover with purpose. Uninstructed hover discovery rate is low. Don't rely on hover to communicate critical states.
- **Tab switching cost**: Users maintain 10-20 browser tabs. Your app competes with all of them. Lost context on tab return is common — preserve state and re-orient the user.
- **Scroll depth decay**: Engagement drops ~50% below the fold (Chartbeat). Each scroll position must earn continued attention.

### Mobile (reference)
- **Thumb zone** (Hoober): Bottom-center is easiest reach. Top corners require grip shift. Place primary actions in natural thumb arc.
- **Interruption model**: Mobile users are frequently interrupted (Oulasvirta et al., 2005). Save state aggressively. Allow instant resume.
- **Single-task focus**: Small screen forces single-task attention. Leverage this — remove distractions, one primary action per screen.
- **Micro-sessions**: Average mobile session 72 seconds. Design for quick task completion, not extended engagement.

### Desktop (reference)
- **Multi-tasking assumption**: Users have multiple windows, tabs, and apps. Design for partial attention and frequent context-switching.
- **Keyboard-mouse duality**: Expert desktop users rarely touch the mouse for common operations. Provide keyboard shortcuts for all frequent actions.
- **Large screen ≠ more content**: Extra space should create breathing room, not add density. Readability degrades past ~75 characters per line (Baymard Institute).
- **Split attention**: Desktop users frequently reference content across windows. Support copy/paste, link sharing, and side-by-side viewing.

### Learning Curve Strategy
| User type | Strategy | Avoid | Why |
|-----------|----------|-------|-----|
| Complete novice | Guided onboarding → constrained feature set → gradual unlock | Full feature dump on day 1 | Cognitive overload causes abandonment. Scaffolded learning builds confidence. |
| Familiar with competitors | Migration-aware onboarding. Map old terminology to new. Import existing data/settings. | Forcing re-learning of concepts they already know | Transfer of training (Thorndike). Leverage existing schemas — don't fight them. |
| Expert in domain, new to tool | Minimal onboarding + comprehensive search/docs + keyboard shortcuts | Patronizing tutorials for the domain (they know it, they don't know your UI) | Separate domain expertise from tool proficiency. Respect what they already know. |
| Power user (months/years of use) | Customization, density options, macros, keyboard-only workflows | Removing or relocating features in redesigns without migration path | Expertise reversal effect (Kalyuga, 2007). Features that help novices become friction for experts. |

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Choice overload** (Schwartz, paradox of choice) | Too many options → decision paralysis → lower satisfaction even when users choose well. Iyengar jam study: 24 options → 3% purchase; 6 options → 30%. | Limit visible options. Use progressive disclosure, smart defaults, or categorization to reduce effective choice set below 7. | Very high |
| **Dark patterns / FOMO manipulation** | Fake urgency ("Only 2 left!"), shame-based opt-out ("No, I don't want to save money"), hidden unsubscribe. Erodes trust. EU/CA regulations increasingly prohibit. | Honest framing. Opt-out as easy as opt-in. Real scarcity only. Respect user autonomy — it builds long-term trust and reduces churn. | High |
| **Cognitive tunneling** | User fixates on one element/task and misses critical information elsewhere (Wickens, 2005). Often caused by demanding primary tasks. | Don't rely on peripheral attention during complex tasks. Surface critical info in the user's current focal area. Use progressive alerts, not ambient indicators, for urgent status changes. | High |
| **Interruption during flow state** | Pop-ups, notifications, or modals appearing during focused work. Flow state (Csikszentmihalyi) takes ~15 min to reach and seconds to break. | Queue non-urgent notifications. Show on natural breakpoints (task completion, page transition). Never interrupt form filling or content creation. | High |
| **Information overload** | Presenting all available data without hierarchy or filtering. Users can't find what matters. Decision quality degrades (Eppler & Mengis, 2004). | Hierarchy + progressive disclosure. Default view shows summary. Details on demand. Filtering and search for large sets. | High |
| **False simplicity** | Hiding complexity behind an interface that looks simple but behaves unpredictably. Users form incorrect mental models and make errors. | Match surface complexity to actual complexity. Use layered complexity: simple on surface, complex available on demand. Don't lie about what something does. | Medium |
| **Anchoring abuse** | Showing an inflated "original price" or extreme option to make the target option look good. Users feel manipulated when they notice, and they do notice. | Honest comparisons. If showing tiers, make each genuinely viable. Anchor on user value, not on manufactured contrast. | Medium |

## Named Patterns

### Default Selection
**When to use**: Configuration where one option suits 70%+ of users. Account setup, preferences, feature toggles.
**When NOT to use**: Consequential/irreversible choices. Situations where wrong default causes data loss or security exposure. When no option has clear majority preference.
**Key details**: Selected state must be visually distinct. Allow easy change. Indicate "recommended" separately from "default" if they differ. Test defaults with real usage data, not assumptions.

### Smart Defaults
**When to use**: Fields that can be pre-filled from context (timezone from locale, currency from country, name from account, date from current time).
**When NOT to use**: When inference is unreliable (<80% accuracy). When wrong default causes more harm than blank field. When pre-filling masks important decisions.
**Key details**: Always allow override. Show source of inference ("Based on your location"). Don't pre-fill sensitive data (payment info, medical). Pre-fill with visual distinction from user-entered data.

### Wizard Pattern
**When to use**: Multi-step processes with linear dependency (account creation, publication workflow, complex configuration). New users completing unfamiliar tasks.
**When NOT to use**: Simple tasks (<3 steps). Frequently repeated tasks (friction accumulates). Tasks where users need to cross-reference between steps.
**Key details**: Progress indicator (step N of M). Back button always available. Save progress automatically. Allow skip for optional steps. Show summary before final commit. Goal-gradient effect: users accelerate as they approach completion — show progress.

### Anchoring (Price/Comparison)
**When to use**: Pricing pages, plan comparison, feature tiers where you want to guide toward a specific option.
**When NOT to use**: When all options are genuinely equivalent. When users need objective comparison (feature matrices for informed decision).
**Key details**: Place target option in center (primacy of middle position). Highlight with "Most popular" or "Recommended." Use the expensive option as anchor, not the cheap one. Limit to 3-4 tiers (Hick's Law). Make differences between tiers obvious and meaningful.

### Storytelling Onboarding
**When to use**: Products with novel concepts that don't map to existing mental models. When users need motivation, not just instruction.
**When NOT to use**: Products with familiar paradigms (email client, file manager). Users who just want to get to work (provide skip). Returning users.
**Key details**: Show, don't tell. Use the actual product as the onboarding surface (interactive walkthrough > slideshow). Complete within 60-90 seconds. End on first user-generated success (peak-end rule). Always skippable.

### Recognition-Primed Decision Making (Klein)
**When to use**: Expert-user interfaces where speed matters (trading, operations dashboards, development tools). Surfaces where pattern-matching drives action.
**When NOT to use**: Novice users who lack the patterns to recognize. Unfamiliar domains where recognition fails.
**Key details**: Present information in a way that triggers pattern recognition: consistent spatial layout, color coding for anomalies, sparklines for trends. Don't force analytical comparison when recognition suffices. Support the expert's first instinct with rapid confirmation paths, not deliberation scaffolding.

### Zeigarnik Effect (Incomplete Task Motivation)
**When to use**: Profile completion, onboarding checklists, course progress. Users are more motivated to complete tasks they've started.
**When NOT to use**: When completion doesn't actually benefit the user (dark pattern: "complete your profile" when it only benefits the platform). When the "incomplete" framing causes anxiety.
**Key details**: Show progress clearly (progress bar, checklist). Start at >0% to establish the "already started" feeling. Highlight what's remaining, not what's done. Make each step feel achievable. Don't penalize partial completion.

### Goal-Gradient Effect (Hull)
**When to use**: Progress bars, multi-step flows, loyalty programs. Users accelerate effort as they approach a goal.
**When NOT to use**: Tasks without clear endpoints. When artificial progress inflation would feel manipulative.
**Key details**: Show distance to completion, not distance from start. Users speed up as the finish line approaches. Coffee-card studies (Kivetz et al., 2006): pre-stamped loyalty cards (2/12 done) completed faster than equivalent empty cards (0/10). Apply: start progress bars at a non-zero value when legitimate steps are already complete.

### Social Proof
**When to use**: Conversion decisions, feature adoption, plan selection. "1,200 teams use this feature" or "Most popular" badge on pricing tier.
**When NOT to use**: When the numbers are fabricated or misleading. When social proof contradicts user's specific context. When it creates pressure rather than confidence.
**Key details**: Specific numbers beat vague claims ("Join 1,247 teams" not "Join thousands"). Peer relevance matters — "teams like yours" beats raw count. Show activity signals: recently active users, live typing indicators, "Sarah edited 2 min ago." Social proof is strongest for uncertain users and weakest for experts.

### Chunking (Miller / Cowan)
**When to use**: Any information display exceeding 4-7 items. Phone numbers, credit cards, long lists, complex data.
**When NOT to use**: Already-simple information. When chunking creates artificial groupings that mislead.
**Key details**: Group related items visually (whitespace, borders, headers). Phone numbers: 3-3-4 or 3-4. Credit cards: 4-4-4-4. Long lists: alphabetical sections or category headers. Menu items: group by function, separate groups with dividers. Each chunk should be a meaningful unit, not arbitrary groups of N.

# Interaction Design
**When to load**: Affordances, feedback, component states, micro-interactions, user flows, input methods, state machines  |  **Skip if**: Purely visual/color questions with no interaction component

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Affordance clarity** | Interactive elements must look interactive (Norman's perceived affordances). Users don't read — they scan and infer from visual cues. | Every clickable/tappable element needs visual differentiation: depth, color, cursor change, underline. If it looks flat, users won't try clicking it. |
| 2 | **Immediate feedback** | Every action gets a response within 100ms (Nielsen's response time thresholds: 0.1s = instant, 1s = flow maintained, 10s = attention limit). Silence = broken. | Button press → visual change immediately. Network actions → optimistic UI or loading indicator within 100ms. Never leave the user wondering if their click registered. |
| 3 | **State visibility** | System status must always be communicated (Nielsen heuristic #1). Users need to know: where am I, what's happening, what can I do. | Design all 8 states: default, hover, active/pressed, focus, disabled, loading, error, success. Plus empty state for collections. |
| 4 | **Direct manipulation** | Prefer direct interaction over indirect commands (Shneiderman). Dragging an item to reorder is more intuitive than "Move to position 3." | Use direct manipulation for spatial tasks (reorder, resize, position). Use indirect commands for abstract operations (permissions, settings). |
| 5 | **Forgiveness** | Support undo, confirm destructive actions (Nielsen heuristic #3: user control and freedom). Mistakes are inevitable — the cost of mistakes should be low. | Reversible actions: just do it + offer undo. Irreversible actions: confirm first. Destructive + high-impact: require explicit input (type to confirm). |
| 6 | **Consistency** | Same interaction = same behavior everywhere (Nielsen heuristic #4). Users build mental models from patterns — breaking them forces re-learning. | Once a pattern exists (e.g., click-to-edit, swipe-to-delete), apply it uniformly. Inconsistency creates distrust even when individual patterns are good. |
| 7 | **Progressive disclosure** | Show only what's needed now; reveal complexity on demand (Tidwell). Reduces cognitive load (Sweller) while keeping power accessible. | Default view: core actions only. Secondary actions: overflow menu or expandable section. Advanced: settings panel or keyboard shortcuts. |

## Decision Tables

### Button vs Link
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Triggers an action (submit, delete, save) | Button | Link styled as button | Buttons signal "this does something." Links signal "this goes somewhere." Mixing confuses the mental model. |
| Navigates to another page/view | Link | Button | Links have browser affordances: middle-click, right-click → copy URL, hover → URL preview. Buttons lose these. |
| Navigates but looks like an action ("Get started") | Button (with navigation role) | Unstyled link | CTA prominence matters more than semantic purity here. Use `role="link"` or actual `<a>` with button styling. |
| Inline within text ("Learn more") | Link | Button | Buttons break text flow. Links are inline by nature. |

### Modal vs Inline
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Requires focused decision (confirm delete, choose option) | Modal | Inline expansion | Modal blocks context — appropriate when the decision needs full attention. |
| Shows supplementary info (details, preview) | Inline expansion / panel | Modal | Don't interrupt flow for non-blocking info. Modals are heavy; use proportional weight. |
| Multi-step form within a page | Inline stepper or slide-over panel | Modal | Modals constrain space. Multi-step flows need room. Escape-to-close risks losing progress. |
| System-level alert (session expiring, unsaved changes) | Modal (non-dismissable) | Toast / inline | Must demand attention. Toast is too easily missed for critical warnings. |

### Drag vs Click-to-Move
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Reordering a short list (<20 items) | Drag-and-drop with handle | Click-to-move only | Direct manipulation is faster and more intuitive for spatial reordering. Handle makes grip point clear. |
| Reordering a long list or across containers | Click-to-move (or both) | Drag-only | Long-distance drags are imprecise and exhausting. Provide move-to dialog as alternative. |
| Touch-primary interface | Drag with long-press to initiate | Drag on touch-start | Touch-start drag conflicts with scroll. Long-press disambiguates intent. |
| Accessibility requirement | Click-to-move (keyboard operable) | Drag-only | Drag is not keyboard-accessible without custom ARIA live regions. Always provide non-drag alternative. |

### Hover vs Click for Reveal
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Preview / tooltip | Hover (with 200-300ms delay) | Click | Low-commitment info peek. Click would add a step for throwaway info. Delay prevents flicker on mouse transit. |
| Actions menu on list items | Hover to reveal + click to activate | Hover to activate | Hover reveals; click commits. Hover-to-activate causes accidental triggers on mouse transit. |
| Touch interface | Click/tap only | Hover | Hover doesn't exist on touch. Any hover-dependent interaction is invisible on mobile. |
| Critical action or navigation | Click | Hover | Hover is transient and accidental. Anything consequential needs deliberate activation. |

### Single-Click vs Double-Click
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Web application primary actions | Single-click | Double-click | Web convention is single-click. Double-click is a desktop OS pattern (file open). Users don't expect it on web. |
| Text editing (select word) | Double-click | Single-click | Platform convention for text selection. Users expect this from every text environment. |
| File manager / desktop-style UI | Double-click to open, single to select | Mixing conventions | Matches OS file manager mental model. But must be clearly communicated — add single-click alternative (open button). |

## Component State Reference

Every interactive component should account for these states. Missing states cause "it feels unfinished" feedback.

| State | Visual signal | Purpose | Common mistakes |
|-------|-------------|---------|-----------------|
| **Default** | Resting appearance, neutral | Baseline. Must be clearly interactive (affordance principle). | Looking identical to non-interactive elements. |
| **Hover** | Subtle change (background tint, shadow lift, underline) | Confirms interactivity before commitment. Web/desktop only. | Too dramatic (looks like active). Too subtle (invisible on some monitors). |
| **Active / Pressed** | Depressed, darker, scaled down slightly (0.95-0.98) | Confirms the click/tap registered. Physical metaphor: pushed in. | Missing entirely (dead-feeling clicks). |
| **Focus** | Visible outline (2-3px, high contrast, offset from element) | Keyboard navigation indicator. Accessibility requirement (WCAG 2.4.7). | Using `outline: none` without replacement. Browser default only (often too subtle). |
| **Disabled** | Reduced opacity (0.4-0.6), `cursor: not-allowed` | Communicates "not available now." Must explain WHY via tooltip. | Looking like default but lighter (ambiguous). No explanation of why disabled. |
| **Loading** | Spinner, skeleton, or progress indicator replacing/overlaying content | Action in progress. Prevents duplicate actions. | No loading state (user clicks repeatedly). Blocking the entire UI for one async action. |
| **Error** | Red border/text, error icon, inline message | Something went wrong. Message must say what and how to fix. | Generic "An error occurred." Red color only (color-blind inaccessible). |
| **Success** | Green accent, checkmark, brief confirmation | Action completed. Often transient (fade after 2-3s). | Staying forever (clutters UI). No success state (user wonders if it worked). |
| **Empty** | Illustration + guidance text + primary action | Collection/view has no content yet. First-time experience. | "No items" with no guidance. Missing empty state entirely (blank white space). |
| **Selected** | Highlighted background, checkmark, or filled state | Item is chosen in a multi-select or toggle context. | Indistinguishable from hover. No visual difference in selected vs unselected. |

## Platform Notes

### Web (primary)
- **Click is the primary verb.** Hover enhances but never gates functionality.
- **Right-click context menus** are uncommon in web apps but powerful for power users (Figma, VS Code web). Consider for tool-heavy interfaces.
- **Scroll is free.** Users expect to scroll. Don't paginate content that could flow naturally. Reserve pagination for discrete result sets (search, tables).
- **Focus management** is critical. Tab order must follow visual order. Focus traps in modals. Return focus on modal close.
- **Keyboard shortcuts** differentiate novice from expert UX. Provide discoverability (command palette, tooltip hints).
- **Double-submit prevention**: Disable submit buttons on click or debounce. Web latency makes double-click common.
- **Form autofill**: Browsers autofill forms. Use correct `autocomplete` attributes. Don't fight the browser — work with it.

### Mobile (reference)
- **Touch targets**: minimum 44x44pt (Apple HIG), 48x48dp (Material). Spacing between targets matters as much as size.
- **Gestures**: swipe, long-press, pinch, pull-to-refresh are expected vocabulary. But always provide button alternative — gestures are invisible affordances.
- **No hover state.** Any hover-dependent interaction must have a tap alternative or be removed entirely.
- **Bottom of screen** is thumb-reachable. Primary actions go bottom. Navigation goes bottom (iOS tab bar, Material bottom nav).
- **Scroll momentum**: iOS and Android have native scroll momentum (rubber-banding, overscroll). Don't override with custom scroll behavior unless absolutely necessary.

### Desktop (reference)
- **Multi-window, multi-monitor** awareness. Don't assume viewport is the world.
- **Right-click context menu** is expected for most elements.
- **Keyboard-first** users exist. Full keyboard navigation is baseline, not enhancement.
- **Drag-and-drop** is native and expected for file operations, window management, and spatial arrangement.
- **Tooltip on hover for all icon-only controls.** Desktop has hover; use it for discoverability. Show keyboard shortcut in tooltip.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Invisible affordances** | Flat design taken too far — interactive elements indistinguishable from static content. Users miss functionality entirely. | Add depth, color differentiation, cursor change, or underline. At minimum, hover state must differ from static text. | Very high |
| **Delayed/missing feedback** | User clicks → nothing visible happens for 500ms+. User clicks again → duplicate action or confused state. | Immediate visual response (<100ms). For async: optimistic UI or spinner/skeleton within 100ms of action. | Very high |
| **Ambiguous disabled state** | Disabled element looks like normal element with low contrast. User doesn't know if it's broken, loading, or intentionally locked. | Visually distinct disabled state (reduced opacity + cursor: not-allowed) plus tooltip explaining why and how to enable. | High |
| **Gesture-only interactions** | Swipe-to-delete with no visible delete button. Power users love it; everyone else never discovers it. | Gesture as shortcut, button as primary. Onboarding hint for gesture if it's a key interaction. | High |
| **Destructive action without undo** | One-click delete with no recovery. Or worse: confirm dialog that users auto-dismiss. | Soft delete + undo toast (30s window). For truly irreversible: require typed confirmation. | High |
| **Mystery meat navigation** | Icons without labels, especially for non-universal icons. User must hover/click to discover what something does. | Label icons. If space-constrained: tooltip on hover, but always label on first encounter. | Medium |
| **Inconsistent interaction models** | Some list items are click-to-expand, others click-to-navigate, same visual treatment. | One visual pattern = one interaction behavior. Different behaviors need visually different affordances. | Medium |
| **Modal abuse** | Every action opens a modal. Confirmation modals for non-destructive actions. Modals within modals. | Modals for focused decisions only. Inline editing for quick changes. Drawers for supplementary content. Never nest modals. | Medium |

## Named Patterns

### Hover Preview
**When to use**: User needs to peek at content without committing to navigation (link preview, image thumbnail expansion, data cell detail).
**When NOT to use**: Touch-primary interfaces. Content that requires interaction (forms, editable fields). Critical information that must be accessible without hover.
**Key details**: 200-300ms delay before show. 100ms delay before hide (prevents flicker). Keep preview near trigger. Don't occlude the trigger itself.

### Inline Editing
**When to use**: Quick, single-field edits on content the user is already viewing (rename, status change, short text edit).
**When NOT to use**: Multi-field forms. Edits requiring validation against other fields. Content where accidental edits are dangerous.
**Key details**: Click-to-edit with clear visual transition (border appears, background changes). Enter to save, Escape to cancel. Show save/cancel buttons for discoverability. Preserve original value until explicit save.

### Drag-and-Drop
**When to use**: Spatial reordering, moving items between containers, file upload, timeline/calendar rearrangement.
**When NOT to use**: As the only way to perform an action (keyboard inaccessible). Long-distance moves (>500px). Precision placement on touch devices.
**Key details**: Grab handle affordance (grip dots icon). Visual placeholder at drop target. Snap-to-grid if applicable. Always provide keyboard alternative (arrow keys + modifier). Cancel on Escape.

### Progressive Action (Click > Confirm > Execute)
**When to use**: Destructive or irreversible actions (delete, publish, send). High-impact state changes (role change, plan downgrade).
**When NOT to use**: Routine, easily reversible actions (save, close, toggle). Frequent actions where friction degrades UX.
**Key details**: First click reveals confirmation UI (inline, not modal for medium-severity). Confirmation shows consequence ("This will delete 12 items"). Auto-dismiss after 10s if no action. For highest severity: require typed confirmation.

### Toast Notification
**When to use**: Non-critical success/info messages that don't require action ("Saved," "Copied to clipboard," "3 items moved").
**When NOT to use**: Error messages requiring user action. Critical system alerts. Messages needing acknowledgment.
**Key details**: Auto-dismiss in 5-8s. Include undo action for reversible operations. Stack from bottom-right (web convention). Limit to 3 visible. Pause auto-dismiss on hover.

### Contextual Toolbar
**When to use**: Actions that apply to selected content (text formatting, bulk operations on selected list items, image editing tools).
**When NOT to use**: Global navigation. Actions not tied to selection. Persistent actions that should always be visible.
**Key details**: Appears near selection (floating above or inline). Disappears on deselection. Contains only actions relevant to selection type. Keyboard accessible (arrow keys between tools). Avoid obscuring the content being acted upon.

### Command Palette
**When to use**: Power-user shortcut for keyboard-heavy applications. Quick access to deeply nested actions. Application-wide search across commands, content, and navigation.
**When NOT to use**: Simple apps with <10 actions. Touch-primary interfaces. Replacement for visible navigation (discoverability still matters).
**Key details**: Trigger: Cmd/Ctrl+K (emerging standard). Fuzzy search. Recent items at top. Categorized results. Type-ahead with highlighted match. Escape to close. Extensible (plugins can register commands).

### Skeleton Loading
**When to use**: Content that takes 300ms-3s to load. Layouts where the structure is predictable before data arrives.
**When NOT to use**: Instant content (<300ms). Unknown/variable layouts. Full-page loading where a progress bar is more appropriate.
**Key details**: Match the shape of real content (not generic rectangles). Subtle pulse animation (not spinning). Transition to real content with fade, not jump. Feels ~30% faster than spinner (perceived performance research). Respect `prefers-reduced-motion`: static gray blocks, no pulse.

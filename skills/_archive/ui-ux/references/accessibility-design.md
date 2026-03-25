# Accessibility Design (Design-Level)
**When to load**: Color contrast, focus management as design concern, semantic structure, inclusive design decisions  |  **Skip if**: Need specific ARIA roles, WCAG SC mapping, screen reader behavior — delegate to `a11y-domain-knowledge` capability

> **Scope boundary**: This file covers accessibility as a *design* concern. Deep ARIA implementation, specific WCAG Success Criteria mapping, APG pattern implementation, and screen reader quirks delegate to `a11y-domain-knowledge`. This file owns: contrast, visual focus design, color-independent communication, design-level semantic structure, touch target sizing, cognitive accessibility, motion sensitivity.

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Color contrast ratios are non-negotiable** | WCAG 1.4.3: 4.5:1 normal text, 3:1 large text (18pt/14pt bold). WCAG 1.4.11: 3:1 for UI components and graphical objects. | Every color palette decision. Every text-on-background choice. Brand colors that fail contrast need accessible alternatives. |
| 2 | **Color is never the sole indicator** | ~8% of males, ~0.5% of females have color vision deficiency. Deuteranopia (red-green) is most common. | Status, errors, success, categories, charts, links — all need a second channel: icon, shape, text, underline, pattern. |
| 3 | **Focus management is a design deliverable** | Focus order = reading order (WCAG 2.4.3). Focus indicators must be visible (2.4.7) and meet 2.4.13 minimum area in WCAG 2.2. Keyboard users navigate by focus — invisible focus = invisible navigation. | Design the focus path alongside visual flow. Specify focus indicator styles in design specs. Modal/dialog focus trapping is a design decision, not just implementation. |
| 4 | **Visual hierarchy = semantic hierarchy** | If it looks like a heading, it must be a heading. If it looks like a group, it should be semantically grouped. Misalignment between visual and semantic structure breaks assistive technology navigation. | Card layouts, section groupings, heading levels, list vs non-list — these are design decisions with semantic consequences. |
| 5 | **Cognitive accessibility drives simplicity** | WCAG 2.2 added 3.3.7 (Redundant Entry), 3.3.8 (Accessible Authentication). COGA guidance: consistent navigation, predictable behavior, clear language. Cognitive disabilities are more prevalent than visual disabilities. | Don't require memorization across screens. Provide clear error recovery. Use consistent patterns. Limit choices per screen (Hick's Law + cognitive load). |
| 6 | **Touch targets have minimum sizes** | WCAG 2.5.8 (AA): 24x24 CSS px minimum. WCAG 2.5.5 (AAA): 44x44. Apple HIG: 44x44pt. Material: 48x48dp. Small targets cause errors for motor impairments, elderly users, and mobile contexts. | Button sizing, link spacing, checkbox/radio sizing, icon button padding. Inline links in text are exempt from target size but benefit from generous line-height. |

## Decision Tables

### Focus Indicator Design

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Default browser focus | Custom 2px solid outline, 2px offset, high-contrast color | `outline: none` without replacement | Browser defaults are often low-contrast or thin. Removal without replacement violates 2.4.7. |
| Dark backgrounds | Light focus ring (white or brand-light) with dark outer shadow | Same color as light-mode focus ring | Contrast against background matters. Double-ring (light + dark outline) works universally. |
| Complex components (cards, tiles) | Outline around entire interactive boundary | Inner glow or subtle highlight alone | Outline is unambiguous. Inner effects can be missed or confused with hover state. |
| Focus within composite widgets | Highlight active descendant, dim siblings | No visible distinction between container focus and item focus | Roving tabindex patterns need visual clarity about what's actually focused. |
| Text inputs | Border color change + thicker border + optional ring | Only color change | Border color alone may not meet 3:1 against adjacent colors. Thickness change adds a non-color signal. |

### Color Palette Accessibility Testing

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Building a new palette | Test all foreground/background combinations in a contrast matrix. Use tools: Stark, Colour Contrast Analyser, or Leonardo. | Picking colors visually and checking "a few" combinations | Combinatorial — missed pairs cause regressions. |
| Palette has near-fail ratios (4.5:1 to 5:1) | Darken/lighten by 1-2 steps to build margin | Shipping at exactly 4.5:1 | Anti-aliasing, subpixel rendering, and screen variation can push borderline ratios below threshold. |
| Data visualization colors | Use ColorBrewer palettes (colorblind-safe sets). Add pattern fills, direct labels, or shape variation. | Rainbow gradients, red-green pairs without redundant encoding | Charts are the #1 failure point for color-only communication. |
| Dark mode | Re-test all contrast ratios. Don't just invert — recalibrate. Light text on dark needs different ratios than dark text on light (perceived contrast differs). | Auto-inversion or simple hue rotation | Inverted palettes frequently break contrast, especially for mid-tones. |

### Touch Target Sizing by Context

| Context | Minimum target | Recommended target | Spacing |
|---------|---------------|-------------------|---------|
| Primary actions (buttons, CTAs) | 44x44 CSS px | 48x48 | 8px minimum between targets |
| Secondary actions (toolbar icons) | 24x24 (WCAG AA) | 44x44 | 8px or combine with padding |
| Dense data (tables, lists) | 24x24 per interactive element | Row height >= 44px, clickable row | Ensure no overlapping targets |
| Navigation links (text) | Exempt from target size if inline | Generous line-height (1.5+), padding on block links | 8px vertical between link blocks |
| Form controls | 24x24 minimum | 44x44 for checkbox/radio hit area (larger than visual) | 16px between form groups |

### Motion Sensitivity

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Decorative animation | Respect `prefers-reduced-motion`. Provide toggle. | Auto-playing animation with no off switch | WCAG 2.3.3, vestibular disorders. Parallax, zoom, spinning particularly problematic. |
| Meaningful transition (state change) | Reduce to opacity fade or instant cut under reduced-motion | Removing all feedback | Reduced motion != no feedback. Crossfade or instant state change preserves information. |
| Loading indicators | Subtle pulse or static spinner. Avoid large pulsing overlays. | Full-screen pulsing skeleton screens without reduced-motion alternative | Large-area pulsing can trigger vestibular symptoms. |
| Auto-advancing content (carousels) | Pause on hover/focus. Visible controls. Stop after one cycle. | Infinite auto-advance with no pause mechanism | WCAG 2.2.2: moving content must be pausable. |

### Semantic Structure Decisions

| Visual pattern | Semantic requirement | Common mistake |
|---------------|---------------------|----------------|
| Card with title + body | Heading element for card title. Group with accessible name if cards are listed. | `<div class="title">` with no heading semantics. |
| Tabbed interface | Tab list + tab + tab panel. Active tab indicated semantically, not just visually. | Visual tabs that are actually styled links with no tab semantics. |
| Sidebar navigation | `<nav>` landmark with accessible label. Nested lists for hierarchy. | `<div class="nav">` with flat link list. |
| Breadcrumbs | `<nav aria-label="Breadcrumb">` + ordered list. Current page marked. | Plain text with `/` separators. No list structure. |
| Data table | `<table>` with `<th>` headers and `scope`. Caption or `aria-label` for table purpose. | CSS grid styled as table with no table semantics. Divs that look like rows. |
| Modal dialog | Dialog landmark. Focus trapped. Return focus on close. Accessible name from heading. | Overlay `<div>` with no dialog role. Focus escapes to background content. |
| Accordion | Heading + button pattern. Expanded/collapsed state communicated. | Clickable `<div>` with no expanded state. Missing heading level. |
| Toast/notification | Status role or alert role depending on urgency. Auto-dismiss must be pausable. | Visual-only notification with no live region. Auto-dismiss with no user control. |

### Contrast Reference — Quick Lookup

| Text/element type | Minimum ratio | WCAG criterion | Practical minimum hex on white |
|-------------------|--------------|----------------|-------------------------------|
| Normal text (<18pt, <14pt bold) | 4.5:1 | 1.4.3 AA | `#767676` |
| Large text (>=18pt, >=14pt bold) | 3:1 | 1.4.3 AA | `#949494` |
| UI components (borders, icons) | 3:1 | 1.4.11 AA | `#949494` |
| Focus indicator against background | 3:1 | 2.4.13 AA (WCAG 2.2) | `#949494` |
| Disabled elements | No minimum | Exempt from 1.4.3 | Still aim for 3:1 for usability |
| Placeholder text | 4.5:1 (if conveying info) | 1.4.3 AA | `#767676` — browsers default to ~#757575, barely passing |
| Enhanced (AAA) normal text | 7:1 | 1.4.6 AAA | `#595959` |

## Platform Notes

**Web (primary)**:
- CSS `outline` is the canonical focus indicator. `outline-offset` for spacing. `:focus-visible` to show focus only for keyboard navigation (hides on mouse click).
- `prefers-reduced-motion` and `prefers-contrast` media queries — design for both.
- Logical reading order: DOM order should match visual order. CSS Grid/Flexbox `order` property can desync visual and DOM order — flag this in design reviews.
- `prefers-color-scheme` for dark mode: respect OS preference, offer manual toggle. Both modes must pass contrast independently.
- Forced colors mode (`forced-colors: active`): test custom components. Background images, box shadows, and custom paints disappear. Use `forced-color-adjust: none` sparingly and only when providing equivalent alternatives.

**Mobile**:
- Touch targets: Apple 44pt, Material 48dp. Both exceed WCAG AA (24px) but align with AAA (44px).
- No hover state — any information conveyed by hover must have a tap/long-press alternative.
- Dynamic Type (iOS) / Font scaling (Android): designs must handle 200% text scaling without truncation or overlap.
- Screen readers: VoiceOver (iOS) and TalkBack (Android) navigate by swipe gestures. Design must make sense in linear swipe-through order, not just visual scan.
- Haptic feedback: provides non-visual confirmation for actions. Design which interactions warrant haptic response.

**Desktop**:
- Keyboard navigation is primary accessibility concern. Tab order, focus trapping in modals, skip links.
- High-contrast mode (Windows): test with `forced-colors: active`. Custom focus rings may disappear — ensure `outline` fallback.
- Zoom: layouts must work at 400% zoom (WCAG 1.4.10). Single-column reflow at high zoom.
- Screen magnification users see ~1/16th of the screen at 400%. Contextual information (tooltips, popovers) must appear near their trigger, not at fixed screen positions.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| Light gray on white (`#999` on `#fff` = 2.85:1) | Fails 4.5:1 for normal text. The most common contrast failure on the web (WebAIM Million 2024: 81% of home pages). | Minimum `#767676` on white for 4.5:1. Prefer `#595959` (7:1) for comfortable reading. | Extremely common |
| `outline: none` / `outline: 0` without replacement | Removes keyboard focus indicator entirely. Violates WCAG 2.4.7. Makes site unusable for keyboard users. | Replace with custom `:focus-visible` style. Never remove without adding. | Very common |
| Red/green only for error/success | Indistinguishable with deuteranopia (most common CVD). | Add icons: checkmark for success, X or exclamation for error. Add text labels. | Very common |
| Placeholder as label | Placeholder disappears on input — user forgets what field is for. Fails WCAG 1.3.1, 3.3.2. Low contrast by spec. | Persistent visible label above or beside input. Placeholder is supplementary hint only. | Common |
| Custom controls without focus management | Dropdown menus, date pickers, modals that can't be reached or operated by keyboard. | Design focus behavior alongside visual behavior. Specify in design specs. | Common |
| Disabling zoom (`user-scalable=no`, `maximum-scale=1`) | Prevents low-vision users from enlarging content. Violates WCAG 1.4.4. | Remove viewport restrictions. Design for reflow at 400% zoom. | Common on mobile |
| Conveying information by position alone | "Click the button on the right" — meaningless for screen readers, reflows differently at zoom. | Label controls explicitly. Don't rely on spatial relationships for meaning. | Moderate |
| Infinite scroll with no alternative | Keyboard users can never reach footer content. Focus gets lost on dynamic insertion. | Provide "Load more" button or paginated alternative. Ensure focus management on new content. | Moderate |

## Named Patterns

### High-Contrast Focus Ring
**When to use**: All interactive elements as default focus style.
**When NOT to use**: Never skip — but can customize appearance per component.
**Spec**: 2px solid outline, 2px offset from element edge, contrast >= 3:1 against both the element background and the page background. Double-ring variant (dark inner + light outer) for universal contrast.

### Status Indicator (Multi-Channel)
**When to use**: Any status communication: error, success, warning, info, active, disabled.
**When NOT to use**: Decorative color accents that carry no semantic meaning.
**Spec**: Color + icon + text label. Minimum two channels. Icon alone acceptable only if accompanied by tooltip AND aria-label (design must specify both).

### Redundant Link Pattern
**When to use**: Cards or list items where the entire row is clickable but contains multiple interactive elements.
**When NOT to use**: Simple lists with a single link per item.
**Spec**: One primary link wraps the main content. Secondary actions (edit, delete) are separate focusable elements. Avoid wrapping entire card in `<a>` — causes verbose screen reader announcements.

### Responsive Target Sizing
**When to use**: Interactive elements that must work across desktop and mobile.
**When NOT to use**: Desktop-only dense UIs (though still respect 24px minimum).
**Spec**: Visual element can be smaller than hit area. Use padding to extend touch target to 44x44 minimum. `min-height`/`min-width` on interactive wrapper, not visual element.

### Motion-Safe Progressive Enhancement
**When to use**: Any animation or transition in the UI.
**When NOT to use**: Instant state changes (no animation to reduce).
**Spec**: Default to reduced motion. Enhance with animation only when `prefers-reduced-motion: no-preference`. Reduced version: opacity fade or instant cut. Never remove state-change feedback entirely.

### Visible Label Pattern
**When to use**: Every form input without exception.
**When NOT to use**: Search fields with a search icon + submit button can use `aria-label` — but visible label is still preferred.
**Spec**: Persistent text label above or inline-start of input. Placeholder text is supplementary (format hints, examples). Label must be programmatically associated. Label text must match accessible name.

### Skip Navigation
**When to use**: Any page with repeated navigation blocks before main content.
**When NOT to use**: Single-page apps with no repeated header/nav (rare).
**Spec**: First focusable element on page. Visually hidden until focused (appears on Tab). Links to `#main-content`. Multiple skip links acceptable for complex layouts (skip to nav, skip to search, skip to main). Must be visible when focused — `sr-only` class alone is insufficient.

### Error Summary Pattern
**When to use**: Form validation with multiple possible errors.
**When NOT to use**: Single-field inline validation where the error is immediately adjacent.
**Spec**: Error summary appears at top of form on submission failure. Lists all errors as links to the offending fields. Focus moves to summary on appearance. Each error link text matches or references the field label. Individual fields also show inline error. Announced via `role="alert"` or focus management.

# Responsive & Adaptive Design
**When to load**: Breakpoint decisions, fluid layouts, touch targets, mobile-first strategy, cross-device behavior, viewport adaptation  |  **Skip if**: Single-viewport design only, design system token questions, purely visual styling

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Content-out breakpoints** — break where content breaks, not at device widths | Device widths are a moving target (375, 390, 393, 412, 428... just for phones). Content-based breakpoints survive new devices. (Marcotte, *Responsive Web Design*) | Open the design in a resizable window. Drag the edge. Where does the layout break? That's your breakpoint. Device-named breakpoints (`tablet`, `phone`) are lies — name them by purpose (`compact`, `medium`, `wide`). |
| 2 | **Mobile-first as progressive enhancement** — start constrained, add capability | Mobile-first forces you to prioritize. Desktop-first tempts you to cram features and then scramble to hide them. Progressive enhancement means the base works everywhere; extras layer on. | Write CSS mobile-first: base styles are mobile, `min-width` media queries add desktop features. This isn't dogma — it's about starting with the hardest constraint. |
| 3 | **Fluid everything** — typography (`clamp`), spacing (viewport units), layouts (grid/flex) | Hard breakpoints create jarring jumps. Fluid scaling creates smooth transitions. Reduces the number of breakpoints needed. | `font-size: clamp(1rem, 0.5rem + 1.5vw, 1.5rem)` — scales smoothly from 16px to 24px. `gap: clamp(8px, 2vw, 24px)` — spacing breathes with viewport. Fewer media queries = simpler CSS. |
| 4 | **Touch targets >= 44px** (Apple HIG) — WCAG 2.5.8 minimum 24px with 24px spacing | Fat fingers. Motor impairments. Rushed users on public transit. Small targets cause errors and frustration. 44x44px is Apple's standard; Google recommends 48x48dp. | Interactive elements: minimum 44px tap area (can use padding to achieve this without visual size change). Spacing between targets: at least 8px gap to prevent accidental taps. WCAG 2.5.8 (AAA) specifies 24x24px minimum with no adjacent target within 24px. |

## Decision Tables

### Mobile-First vs Desktop-First

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Consumer-facing product, high mobile traffic (>50%) | Mobile-first. Base layout is single-column. Progressive enhancement via `min-width`. | Desktop-first with `max-width` overrides to strip features | Mobile-first keeps the default simple. Desktop additions are additive. Removing features with `max-width` is fragile — you forget to hide things. |
| Enterprise/productivity tool, primarily desktop | Desktop-first is acceptable. Mobile is a companion view, not the primary experience. | Forcing full mobile parity when the tool fundamentally requires screen real estate | Data-dense tools (spreadsheets, IDEs, admin panels) don't meaningfully translate to 375px. Design a useful mobile subset, not a cramped desktop clone. |
| Internal tool with known device set | Target the actual devices. Skip breakpoints for devices nobody uses. | Over-engineering responsive behavior for hypothetical devices | If 95% of users are on 1920x1080 desktop, don't spend days on phone layouts nobody will see. Validate with analytics. |
| New product, uncertain audience | Mobile-first. You can always add desktop features. Removing mobile-hostile patterns later is expensive. | Desktop-first "because it's easier to prototype" | The prototype's device bias persists into production. Start where constraints are tightest. |

### Responsive vs Adaptive Strategy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Content-driven site (blog, docs, marketing) | Fluid responsive. Single layout that flexes. Few or no breakpoints needed with modern CSS. | Fixed-width layouts at specific breakpoints | Fluid layouts handle every width gracefully. Fixed layouts create dead zones between breakpoints. |
| Complex app layout with fundamentally different mobile/desktop experiences | Adaptive: distinct layouts per breakpoint range. Mobile = bottom nav + stack. Desktop = sidebar + multi-panel. | Trying to fluid-scale a sidebar layout into a single column | Some layouts don't scale — they transform. A three-panel desktop layout has no fluid-scale equivalent at 375px. Switch layouts. |
| Data tables with 10+ columns | Adaptive: rewrite the table for mobile (stack rows, hide columns, or horizontal scroll with frozen first column). | Shrinking all columns to fit (unreadable at 375px) | Tables are the hardest responsive problem. There's no fluid solution for 10 columns on a phone. Change the pattern entirely. |
| Image-heavy content | Responsive images: `srcset` + `sizes` for art direction. `<picture>` element for format switching. CSS `aspect-ratio` for layout stability. | Serving desktop images to mobile (wastes bandwidth, slows LCP) | Mobile networks are slower and metered. A 2MB hero image on a phone is hostile. Serve appropriate sizes. |

### Breakpoint Strategy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Defining system breakpoints | 3-4 breakpoints: compact (~0-599px), medium (~600-1023px), wide (~1024-1439px), ultrawide (~1440px+). | Device-specific: "iPhone 14" (390px), "iPad" (768px) | Devices change yearly. Content-based ranges are stable. Use these as defaults, add content-specific breaks as needed. |
| Component-level responsiveness | Container queries (`@container`). Component responds to its container, not the viewport. | Viewport media queries for component internals | A card in a sidebar is narrow even on a wide viewport. Container queries let components adapt to their actual space. Supported in all modern browsers. |
| Typography scaling | `clamp()` with viewport-relative middle value. Example: `clamp(1rem, 0.8rem + 0.5vw, 1.25rem)` | Fixed `px` sizes swapped at breakpoints (creates jumps) | Fluid type eliminates the jump between breakpoints. `clamp()` sets min and max to prevent extremes (too small on phone, too large on ultrawide). |
| Spacing scaling | Fluid: `clamp(16px, 3vw, 48px)` for layout margins. Token-based: swap token values at breakpoints for component spacing. | One spacing scale for all viewports | 48px margin on a 375px viewport wastes 25% of screen width. 16px margin on 2560px ultrawide looks cramped. |

### Responsive Images

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Hero/banner images | `<picture>` with art-directed crops per breakpoint. Mobile crop focuses on subject; desktop shows wider scene. | Scaling one image to all sizes (mobile gets unnecessary data, or desktop gets phone-crop) | Art direction is content strategy, not just scaling. The important part of the image may be off-screen at a different aspect ratio. |
| Thumbnails / cards | `srcset` with width descriptors + `sizes` attribute. Let the browser pick the optimal resolution. | Loading full-size images and CSS-scaling down | The browser's resource selection algorithm is smarter than manual breakpoint logic. Provide options, let it choose. |
| Icons / illustrations | SVG. One file, infinite scaling, tiny payload. Optimize with SVGO. | PNG icons at 1x, 2x, 3x (3 files, larger payload combined) | SVG scales perfectly to any density. A single SVG replaces three PNGs and is often smaller than the 1x PNG alone. |
| Background images | CSS `image-set()` for resolution switching. `media` queries for art direction. | `background-image: url(huge-bg.jpg)` everywhere | CSS backgrounds don't benefit from `srcset`. Use `image-set()` or media-query-gated `background-image` declarations. |
| Lazy loading | `loading="lazy"` on images below the fold. `loading="eager"` (or omit) for LCP image. `fetchpriority="high"` for hero. | Lazy loading everything including above-fold images | Lazy loading the LCP image delays the largest contentful paint. Only lazy load what's off-screen on initial load. |

### Input Mode Adaptation

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Detecting touch vs pointer | `@media (hover: hover) and (pointer: fine)` for mouse/trackpad. `@media (pointer: coarse)` for touch. | Using viewport width as proxy for input type | A 1024px iPad is touch. A 375px desktop browser window is mouse. Width does not determine input type. |
| Hover-dependent UI (tooltips, preview on hover) | Provide hover behavior for `(hover: hover)`. Provide tap/long-press alternative for touch. | Hover-only information with no touch fallback | Touch devices have no hover. If information is only accessible on hover, touch users never see it. |
| Text input on mobile | Set `inputmode` attribute: `numeric`, `email`, `tel`, `url`, `search`. | Relying on `type` alone | `inputmode` controls the virtual keyboard layout without changing input semantics. `inputmode="numeric"` shows number pad without `type="number"` arrow behavior. |
| Form factor differences | Desktop: multi-column forms, inline validation, rich drag-and-drop. Mobile: single-column, bottom-sheet pickers, native select. | Same form layout on all devices | Forms have the highest device-dependent UX gap. A multi-column form on mobile = horizontal scroll or cramped fields. Adapt the layout, not just the width. |

### Viewport & Orientation Handling

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Full-height layouts (app shells) | `height: 100dvh` for dynamic viewport. Fallback: `height: 100vh; height: 100dvh;` for progressive enhancement. | `height: 100vh` alone on mobile | Mobile browser chrome (URL bar, bottom nav) makes `100vh` taller than the visible area. `dvh` adjusts dynamically. |
| Landscape mobile | Test and support. Ensure no content is clipped. Consider auto-hiding non-essential chrome (headers) to maximize vertical space. | Forcing portrait via CSS `transform: rotate` or dismissing landscape entirely | Users rotate devices constantly. Broken landscape = broken app for a significant usage scenario. |
| Foldable devices (Galaxy Fold, etc.) | Test at fold widths (~280px compact, ~720px unfolded). Use CSS `env(fold-*)` experimental APIs where available. | Assuming minimum 320px width | Foldable compact mode can be as narrow as 280px. Content must not overflow. Rare but growing device category. |
| PWA / fullscreen mode | Account for lack of browser chrome. Provide your own navigation (back button, URL bar equivalent). Status bar area: use `env(safe-area-inset-top)`. | Assuming browser chrome is always present | In standalone PWA mode, there's no browser back button. Users are stranded without app-level navigation. |

## Platform Notes

**Web (primary)**: CSS Grid and Flexbox are the layout engines — float-based layouts are legacy. Container queries (`@container`) enable component-level responsive behavior. `dvh` / `svh` / `lvh` viewport units solve mobile browser chrome issues (100vh lies on iOS Safari). `prefers-reduced-motion` media query: respect it — disable parallax, auto-play, and large animations. CSS `scroll-snap` for swipeable carousels. `overscroll-behavior: contain` prevents scroll chaining (mobile modal scroll leak). `@media (scripting: none)` for no-JS fallbacks.

Performance budget by viewport: mobile has less CPU and memory. Avoid layout thrashing (reading then writing DOM in loops). Use `content-visibility: auto` for off-screen content to skip rendering. `will-change` for elements that animate — but remove after animation completes to free compositor memory.

**Mobile reference**: iOS Safari: input zoom at `<16px` font-size — always use `>=16px` for inputs. Safe area insets (`env(safe-area-inset-*)`) for notch/Dynamic Island/home indicator. `touch-action: manipulation` disables double-tap-to-zoom delay (300ms) — use on interactive elements. Viewport meta: `<meta name="viewport" content="width=device-width, initial-scale=1">` is mandatory. Add `interactive-widget=resizes-content` for virtual keyboard behavior. Hardware back button (Android) must be handled in SPAs. Virtual keyboard pushes content up — use `visualViewport` API to detect and adapt.

Scroll behavior: iOS Safari has momentum scrolling built in. Android Chrome uses fling physics. Don't override native scroll with JS-based scroll — it always feels worse. Use CSS `scroll-behavior: smooth` for programmatic scrolls, native behavior for user scrolls.

**Desktop reference**: Large viewports need max-width constraints — text lines beyond ~75 characters reduce readability (Baymard Institute). `max-width: 70ch` on text containers. Multi-column layouts become viable at >1200px. Hover states provide rich feedback — design them intentionally. Pointer precision allows smaller interactive targets than touch (but don't go below 24px). `@media (hover: hover)` and `@media (pointer: fine)` detect input capability — use these, not viewport width, to determine touch vs mouse. Ultrawide (>2560px): consider centering content with max-width, or using the extra space for persistent panels.

Window resizing is a desktop-specific concern. Layouts must survive continuous resizing (not just fixed breakpoints). Test by slowly dragging the window edge — no content should jump, overlap, or disappear at any intermediate width.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Fixed-width layouts** (`width: 960px` centered) | Ignores every viewport not exactly that width. Horizontal scroll on mobile. Wasted space on desktop. | `max-width` + percentage widths + fluid grid. No fixed widths on layout containers. | Declining but still present |
| **Horizontal scroll on mobile** (non-scrollable direction) | Vertical scroll is expected. Horizontal scroll is disorienting and often accidental — users think they broke the page. | Audit: `overflow-x: hidden` on body is a bandage, not a fix. Find and fix the overflowing element (`* { outline: 1px solid red }` debug trick). | Common |
| **Tiny touch targets** (icon buttons at 24px with no padding) | Mis-taps frustrate users and are an accessibility failure (WCAG 2.5.5, 2.5.8). Motor impairments amplify the problem. | Minimum 44x44px tap area. Use padding to enlarge tap area without enlarging the visual element. `min-height: 44px; min-width: 44px;` on all interactive elements. | Very common |
| **Hiding essential content on mobile** (`display: none` on information users need) | "Mobile users don't need this" is almost always wrong — they need it more, because they have less context (smaller screen, distracted usage). | Progressive disclosure instead of hiding. Collapsed sections, expandable details, linked sub-pages. The content should be accessible, not absent. | Common |
| **Device-specific breakpoints** (`@media (width: 768px)` "for iPad") | The iPad has been 768px, 810px, 820px, 834px, and 1024px across models. Device-targeted breakpoints are whack-a-mole. | Content-based breakpoints. Test by dragging browser width. Break where the design breaks, not where a device spec says. | Common |
| **Viewport-unit-only font sizing** (`font-size: 3vw`) | Uncontrollable extremes — microscopic on small screens, enormous on large. No user override possible. WCAG 1.4.4 requires 200% zoom. | `clamp()` with rem min and max: `font-size: clamp(1rem, 0.75rem + 1vw, 1.5rem)`. User can still zoom, sizes stay in bounds. | Moderate |
| **Using `100vh` for full-screen mobile layouts** | Mobile browsers have dynamic chrome (URL bar, bottom nav). `100vh` overflows the visible area by ~80-100px on iOS Safari. | Use `100dvh` (dynamic viewport height) or `100svh` (small viewport height). Fallback: `-webkit-fill-available`. | Very common |
| **Ignoring landscape orientation** on mobile | Users rotate devices. If the UI is only designed for portrait, landscape either breaks or wastes space. | Test landscape. Ensure no content is cut off. For media-centric apps, landscape is the primary orientation — design for it. | Moderate |
| **Desktop hover patterns on touch without fallback** | Menus that open on hover, tooltips that show on hover, preview panels on hover — all invisible to touch users. | `@media (hover: none)` to detect touch. Provide tap-to-open, long-press, or inline alternatives for every hover interaction. | Common |

## Named Patterns

### Fluid Grid
**When to use**: Any multi-column layout that should adapt continuously. Content grids (cards, image galleries). Main layouts.
**When NOT to use**: When fixed-width columns are required (e.g., exact image aspect ratios in a mosaic).
**Key decisions**: CSS Grid with `fr` units for proportional columns. `repeat(auto-fill, minmax(250px, 1fr))` for responsive card grids without media queries. `gap` for gutters (scales with viewport using `clamp()`). No need for a CSS framework — native Grid handles this. For asymmetric layouts, use named grid areas that rearrange at breakpoints.

### Responsive Sidebar (Collapse to Drawer)
**When to use**: App layouts with persistent navigation or filters on desktop. Content + aside layouts. Admin panels.
**When NOT to use**: Simple content pages (sidebar is overhead). When the sidebar content is rarely needed (use an on-demand panel instead).
**Key decisions**: Breakpoint where sidebar collapses: typically ~768-1024px (content-dependent). Collapsed state: off-screen drawer with hamburger trigger (mobile), or icon-only rail (tablet, 48-64px wide). Animation: `transform: translateX()` for GPU-accelerated slide. Overlay vs push: overlay is simpler and doesn't reflow main content. Focus trap when drawer is open. Persist collapsed/expanded preference in `localStorage`.

### Priority+ Navigation
**When to use**: Horizontal nav with variable item counts. When all items matter but viewport is limited.
**When NOT to use**: When items have clear priority hierarchy (show top 5 and cut the rest). Vertical nav (unlimited vertical space).
**Key decisions**: Measure available width, show as many items as fit, overflow rest into "More" menu. Use `ResizeObserver` for container-based measurement (not `window.resize`). Active item should always be visible even if it would normally overflow. "More" button should indicate count of hidden items. Animate items entering/leaving the visible set.

### Responsive Data Tables
**When to use**: Any table with more than 4-5 columns viewed on mobile.
**When NOT to use**: Simple 2-3 column tables (they scale fine). When the table is only used on desktop.
**Key decisions**: Three strategies, pick by data type:
1. **Stack**: Each row becomes a card. Label-value pairs stacked vertically. Best for heterogeneous data where each row is an entity.
2. **Horizontal scroll**: Freeze first column (identifier), scroll remaining. Best for comparative data where column alignment matters. Add scroll shadow to indicate more content.
3. **Simplify**: Show subset of columns on mobile with "expand" for full row. Best when some columns are secondary.
Avoid: hiding columns without telling the user. Always indicate when data is truncated or scrollable.

### Container Queries Layout
**When to use**: Components that appear in varying-width containers (sidebar card vs main content card). Design system components that must adapt regardless of viewport.
**When NOT to use**: When component always appears at a known width. Older browser support required (pre-2023, though support is now >90%).
**Key decisions**: Define container on parent: `container-type: inline-size`. Query in child: `@container (min-width: 400px) { ... }`. Name containers for specificity: `container-name: card-container`. Replaces many viewport-based media queries with more accurate container-based logic. Test by placing the same component in narrow and wide containers simultaneously.

### Off-Canvas Panel
**When to use**: Secondary content that doesn't warrant permanent screen space. Filters on mobile e-commerce. Detail panels in list-detail patterns. Settings/preferences.
**When NOT to use**: Primary navigation on desktop (use persistent sidebar). Content users need to compare with the main view (overlay obscures it — use split view instead).
**Key decisions**: Direction: left for navigation (reading order), right for detail/context, bottom for actions (mobile sheet pattern). Scrim/overlay behind panel to indicate modality. Focus trap: keyboard focus must stay in panel when open. Escape key and scrim click to close. Preserve scroll position of main content underneath. Width: max 80vw on mobile to keep context visible. Animate with `transform` for 60fps.

### Responsive Form Layout
**When to use**: Forms that appear on both mobile and desktop viewports. Settings pages. Data entry.
**When NOT to use**: Very short forms (1-3 fields) that don't need layout adaptation.
**Key decisions**: Single column on mobile always. Two columns on desktop only for short, related field pairs (first/last name, city/state). Full-width inputs on mobile — never side-by-side that requires horizontal scroll. Action buttons (Submit/Cancel) full-width on mobile, right-aligned on desktop. Floating labels save vertical space but have accessibility trade-offs — test with screen readers. Group related fields with `<fieldset>` and `<legend>` for both visual grouping and accessibility.

### Responsive Modal / Bottom Sheet
**When to use**: Confirmations, quick actions, and focused tasks that overlay main content. Adapts between centered modal (desktop) and bottom sheet (mobile).
**When NOT to use**: Full-page content that should be a route. Complex multi-step flows that need their own URL.
**Key decisions**: Desktop: centered modal with max-width (480-640px), backdrop scrim, max-height with scroll. Mobile: bottom sheet sliding up from bottom edge, drag handle for dismiss, partial-height default with expand-to-full option. Transition: switch pattern at ~768px or when `(pointer: coarse)`. Both need focus trap, Escape to close, and `aria-modal="true"`. Bottom sheet physics: drag threshold at ~30% height to dismiss, spring animation on release.

### Responsive Navigation Bar
**When to use**: Primary app navigation that must adapt from mobile to desktop.
**When NOT to use**: Simple landing pages where a single hamburger suffices at all sizes.
**Key decisions**: Mobile (<600px): bottom tab bar for 3-5 items, hamburger for secondary. Tablet (600-1024px): icon-only rail sidebar (48-64px wide) or compact top nav. Desktop (>1024px): full sidebar with labels or horizontal top nav. Transition animations between states. Active state indicator must be visually prominent at all sizes. Badge/notification dots must remain visible in compact modes.

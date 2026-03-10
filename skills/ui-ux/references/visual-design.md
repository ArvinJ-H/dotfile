# Visual Design
**When to load**: Color choices, typography decisions, layout composition, visual hierarchy, spacing, density  |  **Skip if**: Purely interaction/behavior questions, IA structure, component API design

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Visual hierarchy** — size, weight, color, contrast create scanning paths | Users don't read, they scan. Hierarchy determines what gets noticed first (Nielsen Norman, F-pattern research). | Every layout decision must answer: what does the user see first, second, third? If everything is bold, nothing is. |
| 2 | **Gestalt laws** — proximity, similarity, continuity, closure, figure-ground | The brain groups visual elements automatically. Fighting these laws creates cognitive friction. | Proximity > lines for grouping. Similar elements must look similar. Dissimilar elements must look different. No ambiguity. |
| 3 | **60-30-10 color rule** — dominant / secondary / accent | Borrowed from interior design. Creates visual balance without monotony. 60% neutral, 30% secondary, 10% accent. | Accent color = action color. If accent appears everywhere, it loses signaling power. Reserve for CTAs and state changes. |
| 4 | **Typographic scale** — modular scale ratios (1.25 minor third, 1.333 perfect fourth, 1.5 perfect fifth) | Harmonious size relationships feel intentional. Arbitrary sizes feel chaotic. Robert Bringhurst's *Elements of Typographic Style*. | Pick one ratio. Derive all sizes from it. 1.25 for dense UI (dashboards), 1.333 for general apps, 1.5 for editorial/marketing. |
| 5 | **Whitespace as element** — negative space is active design, not empty | Whitespace increases comprehension by 20% (Wichita State study). It signals grouping, importance, and breathing room. | Resist the urge to fill space. Padding and margins are design decisions, not leftovers. Cramped UI signals low quality. |

## Decision Tables

### Color Palette Selection

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Brand-new product, no existing palette | Start with 1 primary + 1 neutral scale + semantic colors (error/warning/success/info) | Picking 5+ brand colors upfront | You'll use neutral 80% of the time. Expand palette only when a real need emerges. |
| Dark mode support needed | Define colors as semantic tokens, not raw values. Light/dark swap at token level. | Inverting hex values or using `filter: invert()` | Inversion breaks semantic meaning. Red-on-white != red-on-black — contrast ratios change. |
| Data visualization colors | Use perceptually uniform scales (CIELAB/OKLab). 5-7 distinguishable hues max. | Rainbow gradients, relying on hue alone | ~8% of men are color-blind. Use hue + luminance + pattern. Viridis/Cividis are safe defaults. |
| Accessible text contrast | WCAG AA minimum: 4.5:1 normal text, 3:1 large text. Target AAA (7:1) for body copy. | Light gray on white (#999 on #fff = 2.85:1) | Legal liability in many jurisdictions. Also: users over 40 need higher contrast. |
| Semantic color mapping | Red = destructive/error. Green = success (with icon, never color alone). Yellow/amber = warning. Blue = info/primary action. | Green for "go"/primary action (conflicts with success state) | Semantic colors must be unambiguous. If green means both "success" and "primary action," users can't distinguish states. |
| Surface/elevation system | Use lightness to encode depth. Lighter surfaces = higher elevation (light mode). Darker surfaces = higher elevation (dark mode, per Material 3). | Same background color for all layers | Without surface hierarchy, overlapping elements (modals, dropdowns, cards) lack depth cues. Users can't parse z-order. |

### Typography Pairing

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| App UI (data-dense) | Single family, vary weight. Inter, IBM Plex Sans, Source Sans Pro. | Decorative fonts. Serif body in compact UI. | System-like clarity. One family = zero pairing risk. Weight variation provides hierarchy. |
| Marketing/editorial | Serif headings + sans body (classic). Or: geometric sans headings + humanist sans body. | Two serifs. Two fonts from same classification. | Contrast creates hierarchy. Same classification = too similar to justify two fonts. |
| Monospace needs (code, data) | JetBrains Mono, Fira Code, IBM Plex Mono. Pair with the sans from the same superfamily if available. | Courier New. | Ligatures aid code readability. Superfamily pairing guarantees harmony. |
| Font sizing — base | 16px base for web (browser default). 14px minimum for dense enterprise UI. Never below 12px for any readable text. | 13px base "because it fits more" | Sub-14px fails WCAG at many contrast ratios. Users with aging eyes need 16px+. |
| Line height | 1.4-1.6 for body text. 1.1-1.3 for headings. Tighter for large type, looser for small. | Single line-height for all sizes | Large text with 1.6 line-height wastes space and looks disconnected. Small text at 1.2 is unreadable. |
| Letter spacing | -0.01 to -0.02em for headings >24px. 0 for body. +0.02 to +0.05em for small caps/labels <12px. | Ignoring tracking at extremes | Large text needs tightening (tracking is designed for body size). Small text needs loosening for legibility. |
| Font loading strategy | `font-display: swap` for body text (avoid FOIT). `font-display: optional` for icons/decorative (skip if slow). Preload critical fonts via `<link rel="preload">`. | No `font-display` (browser default = FOIT for 3s) | Invisible text for 3 seconds is unacceptable. Swap shows fallback immediately. Preload cuts swap flash duration. |

### Spacing Systems

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Base spacing unit | 4px base grid (permits 4, 8, 12, 16, 20, 24, 32, 40, 48, 64). Use 8px as primary increment. | 5px or 10px base (doesn't halve cleanly) | 4px grid aligns with browser defaults, common icon sizes, and touch target math (44px = 11 x 4). |
| Component internal padding | Use consistent scale: 8px compact, 12px default, 16px comfortable. | Mixing arbitrary values (7px here, 13px there) | Inconsistent padding breaks Gestalt similarity. Components should feel like they belong to the same system. |
| Section spacing | 2-3x the component spacing. If components use 16px gap, sections use 32-48px. | Same spacing for items within a group and between groups | Proximity principle: tighter spacing = stronger grouping. Section breaks need visible breathing room. |
| Responsive spacing | Scale with viewport: `clamp(16px, 4vw, 64px)` for section margins. | Fixed pixel margins at all viewports | 64px margin on 375px screen wastes 34% of width. Fluid spacing adapts without breakpoint jumps. |
| Vertical rhythm | Establish a baseline grid (e.g., 4px or 8px). All vertical spacing snaps to this grid. | Freeform vertical spacing without a system | Consistent vertical rhythm creates a sense of order that users feel but can't name. Inconsistency feels "off." |

### Visual Weight Balancing

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Primary vs secondary actions | Primary: filled, high-contrast. Secondary: outlined or ghost. Tertiary: text-only link. | Two filled buttons side by side | Squint test: if both buttons look equal, the user has to read both to decide. Visual weight should encode priority. |
| Icon + text alignment | Optical alignment — icons often need 1-2px offset from mathematical center. Use `vertical-align: text-bottom` or flex with gap. | Trusting `vertical-align: middle` alone | Icons have visual weight that differs from their bounding box. Optical center != geometric center. |
| Dense vs spacious layouts | Density control: offer compact/default/comfortable modes. Don't pick one. | One-size-fits-all density | Enterprise users scanning 200 rows want compact. Onboarding users need comfortable. Density is a user preference. |
| Balancing asymmetric elements | Visual weight factors: size, darkness, saturation, complexity, isolation. A small saturated element balances a large muted one. | Only considering physical size for balance | A bright red error icon visually outweighs a larger gray text block. Weight is perceptual, not geometric. |

### Border, Shadow & Depth

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Card/container boundaries | Subtle border (1px, low-contrast) OR soft shadow. Not both simultaneously. | Heavy borders (2px+, dark) on every container | Heavy borders create visual noise. Modern UIs prefer shadow for depth and subtle borders for separation. |
| Elevation levels | Define 3-5 shadow levels: none (flat), low (cards), medium (dropdowns), high (modals), highest (toasts). | Ad-hoc shadow values per component | Inconsistent shadows create an incoherent z-axis. Defined levels form a predictable depth system. |
| Dividers vs spacing | Prefer spacing (whitespace) to separate items. Use dividers only when spacing alone is ambiguous (dense lists). | Dividers between every item regardless of density | Dividers add visual clutter. If spacing clearly groups items, the divider is redundant. |
| Focus indicators | 2px solid outline, offset from element. High contrast against all backgrounds. Never suppress `:focus-visible`. | `outline: none` for aesthetics | Removing focus indicators breaks keyboard navigation. WCAG 2.4.7 requires visible focus. Style them, don't remove them. |

### Icon Design & Usage

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Icon style consistency | Pick one style system-wide: outlined OR filled OR two-tone. Don't mix. | Mixing filled and outlined icons in the same context | Mixed styles break Gestalt similarity. Users read inconsistency as meaning difference when there is none. |
| Icon sizing | Align to a 4px grid: 16, 20, 24, 32px. Design on a pixel grid to avoid blurry rendering. | Odd sizes (18px, 22px) that don't align to pixel grid | Sub-pixel rendering blurs icon edges. Grid-aligned icons render crisply at 1x density. |
| Icon + label pairing | Icon left of label (LTR). 4-8px gap. Icon size matched to text x-height or line-height, not the cap height. | Icon above label in horizontal nav (wastes vertical space, slows scanning) | Left-of-label is fastest to scan. Icon-above-label forces vertical eye movement between icon and label. |
| Icon-only buttons | Only for universally recognized icons: close (X), search (magnifier), hamburger menu. Always add `aria-label`. | Icon-only for domain-specific actions (filter, archive, flag) | If >5% of users would need the tooltip to understand the action, add a text label. Icon-only saves space but costs discoverability. |
| Decorative vs functional icons | Decorative: `aria-hidden="true"`. Functional (conveys info not in text): needs `aria-label` or adjacent text. | All icons as decorative (hides information from screen readers) | An error icon next to a field conveys meaning. If it's hidden from assistive tech, screen reader users miss the error signal. |

## Platform Notes

**Web (primary)**: Subpixel rendering varies by OS/browser — test on Windows (ClearType) and macOS (no subpixel since Mojave). System font stack (`system-ui, -apple-system, ...`) eliminates FOUT. Variable fonts reduce payload while providing full weight/width range. CSS `font-optical-sizing: auto` improves readability at small sizes. `color-scheme: light dark` meta tag enables native UI theming (scrollbars, form controls). OKLab/OKLCH color spaces in CSS enable perceptually uniform gradients and palette generation.

Color management: `color()` function with `display-p3` gamut enables wider, more vivid colors on supporting displays — use for brand accents, not for semantic colors that must fall back gracefully. `@media (color-gamut: p3)` to detect support. Always define sRGB fallback first.

**Mobile reference**: Larger touch targets increase minimum text size to ~16px (iOS auto-zooms inputs below 16px). System fonts preferred for native feel. Dynamic Type (iOS) and `sp` units (Android) respect user preferences — don't fight them. High-DPI screens (3x) mean hairline borders need care: `0.5px` borders render on retina but collapse to 0 on 1x screens. Use `border-width: thin` or media query for `min-resolution`.

Dark mode is default for many mobile users. Test visual hierarchy in both modes — what works in light may lose contrast in dark. Shadows are nearly invisible in dark mode; use lighter surface colors or subtle borders instead.

**Desktop reference**: Higher pixel density means finer detail is possible. However, viewing distance is greater than mobile — net effect is similar readability requirements. Hover states allow richer visual feedback layers (tooltips, previews, expanded labels). Cursor changes communicate affordance: `pointer` for clickable, `grab` for draggable, `text` for selectable. Consider `prefers-contrast: more` for users who request high contrast.

Multi-monitor setups mean your design may span different DPI screens. Test with mixed-DPI configurations — font rendering, shadow crispness, and border weights can vary between monitors on the same machine.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Low contrast for aesthetics** ("light gray looks cleaner") | Fails WCAG AA. Excludes ~15% of users with low vision. "Clean" is not a user need. | Use contrast checker. Minimum 4.5:1 for normal text. Design within constraints. | Very common |
| **Too many font weights** (thin, light, regular, medium, semibold, bold, black) | More than 3-4 weights creates indistinguishable hierarchy levels. Increases font payload. | Limit to regular + medium + bold. Occasionally semibold. Each weight must serve a distinct hierarchy role. | Common |
| **Inconsistent spacing** (hand-tuned pixel values per component) | Breaks visual rhythm. Makes the system unmaintainable. New components never "fit." | Define a spacing scale. Use tokens. Apply programmatically, not by eye per instance. | Very common |
| **Decorative color** (color that signals nothing) | Every color should encode meaning or grouping. Random color adds noise to the signal. | Audit: for each color, ask "what does this communicate?" If nothing, remove it. | Common |
| **Centering everything** (centered text blocks, centered layouts) | Centered text is harder to scan than left-aligned (ragged left edge disrupts saccade return). | Left-align body text. Center only headings, hero text, or single-line items. | Moderate |
| **Relying on color alone for state** | ~4.5% of population is color-blind. WCAG 1.4.1 requires non-color indicators. | Add icons, underlines, patterns, labels. Color reinforces, never carries alone. | Common |
| **Orphaned visual styles** (one-off colors, sizes, or shadows not in the system) | Creates inconsistency that accumulates. Each orphan makes the next orphan feel more acceptable. | Every visual value must trace to a token. If a new value is needed, add it to the system — don't use a raw value. | Very common |
| **Zebra striping as default** (alternating row colors in all tables) | Adds visual noise when row spacing is sufficient. Reduces emphasis of actual highlighted rows. | Use zebra stripes only for dense, borderless tables where row tracking is genuinely difficult. Prefer hover highlight + adequate row height. | Moderate |

## Named Patterns

### Card Pattern
**When to use**: Grouping heterogeneous content into scannable units. Collections of items with image + text + action.
**When NOT to use**: Homogeneous lists (use table or list). Single-item detail views. Cards-within-cards (nesting breaks containment semantics).
**Key decisions**: Border vs shadow vs background for containment. Fixed vs fluid height (avoid fixed — truncation loses content). Action placement (bottom-aligned, always). Clickable card = entire card is one target (use `<a>` or `<button>` wrapping the card, not nested click handlers).

### Hero Section
**When to use**: Landing pages, feature introductions. One primary message with strong visual impact.
**When NOT to use**: Repeated on every page (hero fatigue). When the content below the fold is the actual goal — hero pushes it down.
**Key decisions**: Full-bleed vs contained width. Text overlay on image (requires scrim/overlay for contrast — test at all viewport sizes). CTA placement and visual weight. Consider reduced-motion alternatives for animated heroes.

### F-Pattern / Z-Pattern Scanning
**When to use**: F-pattern for text-heavy pages (articles, search results). Z-pattern for minimal pages (landing pages, hero sections).
**When NOT to use**: Data tables (users scan columns). Dashboards (users scan by widget priority, not F/Z).
**Key decisions**: Place primary content and CTAs along the scanning path. Secondary content goes outside the pattern. Gutenberg diagram for print-like layouts (primary optical area → terminal area diagonal).

### Modular Grid
**When to use**: Complex layouts with multiple content types. Editorial layouts. Dashboard widgets.
**When NOT to use**: Simple single-column content (blog posts, documentation). Forms (single-column form outperforms multi-column — Baymard Institute).
**Key decisions**: Column count (12-column is standard for web — divisible by 2, 3, 4, 6). Gutter width (16-24px). Column + gutter must sum to clean fractions of container. CSS Grid `subgrid` enables nested components to align to the parent grid.

### Golden Ratio Layout
**When to use**: Content + sidebar layouts (62/38 split ~ golden ratio). Image cropping. Typographic scale derivation.
**When NOT to use**: As a dogmatic rule. The golden ratio is a guideline, not a law — the 2:1 or 3:2 ratios work equally well in many contexts.
**Key decisions**: Apply to macro layout (main/sidebar), not micro spacing. Use as a sanity check, not a design system. Fibonacci-adjacent numbers (5, 8, 13, 21, 34) can inform spacing scales.

### Optical Alignment Grid
**When to use**: When mathematical alignment looks wrong. Icons next to text. Play buttons in circles. Text in irregular containers. Triangular or asymmetric shapes.
**When NOT to use**: Standard text layout (left-align is correct). Tables (strict grid alignment is expected).
**Key decisions**: Trust the eye over the pixel grid. Shift elements 1-4px to achieve perceived alignment. Document optical adjustments in design tokens or comments so they aren't "corrected" later.

### Content Density Tiers
**When to use**: Enterprise/productivity applications where users range from overview scanners to power users processing hundreds of items.
**When NOT to use**: Consumer apps where one density suits the audience. Marketing pages.
**Key decisions**: Three tiers: compact (row height ~32px, 12px font), default (40px, 14px), comfortable (48px, 16px). Persist user preference. Density affects padding, font-size, icon-size, and line-height simultaneously — not just one dimension. Expose via settings, not per-component toggles.

### Skeleton Screen
**When to use**: Loading states where the layout shape is predictable. Lists, cards, profiles, dashboards. Replaces spinners for content-area loading.
**When NOT to use**: Unpredictable content shapes. Very fast loads (<200ms — skeleton flashes and adds perceived delay). Full-page loading where a progress bar is more informative.
**Key decisions**: Match skeleton shapes to actual content dimensions. Animate with a shimmer/pulse (subtle, `prefers-reduced-motion` aware). Gray blocks for text, circles for avatars, rectangles for images. Never show skeleton + spinner simultaneously.

### Split Complementary Color Scheme
**When to use**: When a single accent color feels flat and the palette needs secondary vibrancy. Data visualization with 2-3 category groups. Feature differentiation.
**When NOT to use**: When the brand already provides sufficient color range. UI-dense applications where multiple vibrant colors compete for attention.
**Key decisions**: Pick one dominant hue. Select two colors adjacent to its complement (not the complement itself — too harsh). Use the dominant for primary actions, the splits for secondary categorization. Test all combinations against WCAG contrast requirements.

### Truncation & Overflow Strategy
**When to use**: Any text that might exceed its container. Usernames, titles, descriptions, tags, URLs.
**When NOT to use**: Critical information (error messages, legal text) — these should never truncate.
**Key decisions**: Single-line: `text-overflow: ellipsis`. Multi-line: `-webkit-line-clamp` (widely supported). Always provide full text on hover/focus (tooltip) or expand affordance. Truncation position matters: end-truncation for titles ("Very long title na..."), middle-truncation for file paths ("src/.../component.tsx"). Right-to-left text: truncation must respect reading direction.

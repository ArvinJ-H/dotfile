# Motion & Animation
**When to load**: Transitions, animations, micro-interactions, state changes, perceived performance, loading patterns  |  **Skip if**: Static design only, no state transitions under discussion

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Functional motion** | Animation must communicate: state change, spatial relationship, attention direction, or causality. Decorative motion adds processing cost with no information gain. Disney's 12 principles apply to UI only where they serve function. | Before adding animation, name what it communicates. If you can't, remove it. "It looks nice" is not a function. Valid: "it shows where the item went." |
| 2 | **Duration sweet spot** | 100-300ms for micro-interactions (button press, toggle, hover). 200-500ms for transitions (page change, panel slide, modal enter). <100ms is imperceptible (wasted compute). >500ms feels sluggish and blocks interaction. Material Design guidelines: small elements 100ms, medium 250ms, large/complex 300-500ms. | Size and distance scale duration. Small in-place change: 100-150ms. Medium panel slide: 200-300ms. Full-screen transition: 300-500ms. Never exceed 700ms for any UI animation. |
| 3 | **Easing functions** | Linear motion feels mechanical and unnatural. Physical objects accelerate and decelerate. Easing communicates direction of travel. | **Entering** (appearing, opening): `ease-out` / decelerate — element arrives and settles. **Exiting** (disappearing, closing): `ease-in` / accelerate — element leaves and picks up speed. **On-screen movement**: `ease-in-out` — natural arc. **User-driven** (dragging, scrolling): linear — direct mapping to input. |
| 4 | **Reduced motion respect** | Vestibular disorders affect ~35% of adults over 40 (Agrawal et al., 2009). Parallax, zoom, and sliding animations can trigger nausea, dizziness, or seizures. `prefers-reduced-motion` is a medical accessibility need, not a preference. | **Always** implement `prefers-reduced-motion: reduce`. Strategy: replace motion with instant cut (opacity 0→1, no translate). Keep functional state changes (color, opacity) but remove spatial movement. Never skip this — it's not optional. |
| 5 | **Spatial consistency** | Elements should move to/from their logical origin. This builds a coherent spatial mental model (Lakoff & Johnson embodied cognition). Users maintain a spatial map of the interface. | Menu animates from its trigger button. Deleted item collapses in-place (not fades). Modal enters from center (focus zoom). Sidebar slides from its edge. New page slides from navigation direction. If origin is unclear, fade — it's the neutral option. |
| 6 | **Choreography** | When multiple elements animate simultaneously, they need coordinated timing to avoid visual chaos. Uncoordinated parallel motion causes cognitive overload. | Stagger entrance of related elements (30-50ms offset). Group items animate as a unit, not individually. Primary action animates first, secondary follows. Exit animations are faster than entrance (users are done looking — get out of the way). |
| 7 | **Performance budget** | Animation runs on the main thread (JS) or compositor thread (CSS transforms/opacity). Main-thread animation causes jank. 60fps = 16.6ms per frame. | Only animate `transform` and `opacity` (compositor-friendly). Avoid animating `width`, `height`, `top`, `left`, `margin`, `padding` (trigger layout recalc). Use `will-change` sparingly (reserves GPU memory). Prefer CSS transitions over JS animation for simple state changes. |

## Decision Tables

### When to Animate
| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| State change (open/close, show/hide, enable/disable) | Animate with 150-300ms transition | Instant toggle (jarring) or long animation (blocking) | Transition communicates what changed and where. Instant state swaps can disorient — users lose spatial continuity. |
| Content loading (skeleton → real content) | Fade-in (150-200ms) or crossfade | Slide-in or complex entrance | Loading replacement should be subtle. Content arrival is expected — don't celebrate it. Skeleton → content is a substitution, not an entrance. |
| User-initiated action feedback (click, submit) | Micro-interaction (100-150ms): scale bounce, color flash, ripple | No feedback (dead click) or heavy animation | Confirm the action was received. Must be fast — user is waiting for the next thing, not watching an animation. |
| List reordering / item add-remove | Animate position change (200-300ms). Collapse/expand gap. | Instant re-render (items jump) | Spatial continuity. Users need to track where things went. FLIP technique (First, Last, Invert, Play) handles this efficiently. |
| Page/view navigation | Shared element transition or directional slide (300-400ms) | Fade only (loses spatial model) or no transition (context jump) | Communicates navigation direction and hierarchy. Forward = slide left, back = slide right. Maintains user's mental map. |
| Decoration / delight | Skip unless it serves brand identity with clear user value | Animation for animation's sake | Every animation is a performance cost and an accessibility risk. "Delight" that delays interaction isn't delightful. |

### Duration by Context
| Context | Duration | Easing | Notes |
|---------|----------|--------|-------|
| Hover state change | 100-150ms | ease-out | Fast enough to feel responsive, slow enough to perceive |
| Button press / toggle | 100-200ms | ease-out (press), ease-in (release) | Tactile feel. Scale to 0.95 on press, back to 1.0 on release. |
| Tooltip appear | 150-200ms (with 200-300ms delay before trigger) | ease-out | Delay prevents flicker on mouse transit. Appear is gradual. |
| Dropdown / menu open | 150-250ms | ease-out | Slides from trigger origin. Faster close (100-150ms, ease-in). |
| Modal enter | 200-300ms | ease-out with slight overshoot | Scale from 0.95→1.0 + fade. Overshoot adds weight/presence. |
| Modal exit | 150-200ms | ease-in | Faster than enter. User initiated close — don't delay. |
| Page transition | 300-500ms | ease-in-out | Shared element transitions bind old and new views. |
| Skeleton → content | 150-200ms | ease-out (fade only) | Crossfade. No spatial movement — content is replacing, not entering. |
| Loading spinner start | 300ms delay before showing | — | Don't show spinner for operations that complete in <300ms. Avoids flash-of-spinner for fast operations. |

### Easing by Motion Type
| Motion type | Easing | CSS value | Rationale |
|------------|--------|-----------|-----------|
| Element entering viewport | Decelerate (ease-out) | `cubic-bezier(0, 0, 0.2, 1)` | Arriving = slowing down. Object "lands" in position. |
| Element exiting viewport | Accelerate (ease-in) | `cubic-bezier(0.4, 0, 1, 1)` | Leaving = speeding up. Object "departs." |
| On-screen repositioning | Standard (ease-in-out) | `cubic-bezier(0.4, 0, 0.2, 1)` | Natural movement arc — accelerate, coast, decelerate. |
| User-driven (drag, scroll) | Linear | `linear` | 1:1 mapping to input. Any easing creates disconnect between hand and element. |
| Spring / bounce | Custom spring | `cubic-bezier(0.175, 0.885, 0.32, 1.275)` | Overshoot for playful/physical feel. Use sparingly — only for primary interaction moments. |

### Reduced-Motion Strategy
| Animation type | Full motion | Reduced motion | Why this alternative |
|---------------|-------------|---------------|---------------------|
| Slide/translate transitions | Slide + fade | Instant cut or fade-only (150ms) | Remove spatial movement (vestibular trigger). Fade preserves state-change signal. |
| Loading skeleton pulse | Gentle opacity pulse animation | Static gray placeholder (no animation) | Pulse is subtle but still motion. Static skeleton still communicates loading. |
| Parallax scrolling | Layered scroll-speed differences | All layers scroll at same speed | Parallax is the #1 vestibular trigger. Full removal, no compromise. |
| Hover/focus state | Smooth color/shadow transition | Instant state swap | Micro-transitions are generally safe, but instant is safer. Keep the state change, remove the transition. |
| Page transitions | Directional slide | Instant swap (no transition) | Cross-screen motion is disorienting. Instant is clear and safe. |
| Auto-playing video/animation | Plays automatically | Paused with play button. Still frame visible. | User controls when motion starts. Never auto-play under reduced motion. |

## Platform Notes

### Web (primary)
- **CSS transitions** for simple state changes (hover, focus, open/close). **CSS animations** (`@keyframes`) for multi-step or looping. **Web Animations API** for complex choreography needing JS control.
- **`will-change`**: Apply to elements about to animate. Remove after animation completes. Permanent `will-change` wastes GPU memory. Apply via class toggle, not inline style.
- **`requestAnimationFrame`** for JS-driven animation. Never use `setInterval`/`setTimeout` for frame-based animation — they don't sync with display refresh.
- **Intersection Observer** for scroll-triggered animations. Avoid scroll event listeners (performance drain).
- **`prefers-reduced-motion`** media query: `@media (prefers-reduced-motion: reduce) { ... }`. Check in JS: `window.matchMedia('(prefers-reduced-motion: reduce)').matches`.
- **Layout thrashing**: Reading layout properties (`offsetHeight`, `getBoundingClientRect`) then writing style properties in the same frame forces synchronous layout. Batch reads before writes, or use `requestAnimationFrame`.
- **View Transitions API**: `document.startViewTransition()` enables native shared-element transitions between DOM states. Chromium-supported (2023+). Progressive enhancement — works without for other browsers.
- **Scroll-driven animations** (`animation-timeline: scroll()`): CSS-native scroll-linked animations. Replaces JS scroll listeners for parallax, progress bars, reveal effects. Emerging standard — use with fallback.

### Mobile (reference)
- **60fps is non-negotiable** on mobile — dropped frames are more noticeable on small screens held close to eyes. Budget is tighter due to weaker GPUs.
- **Gesture-driven animation** (swipe, pull-to-refresh) must be 1:1 with finger position during drag. Easing only applies on release.
- **iOS**: UIKit spring animations are standard. `CASpringAnimation` with damping ratio 0.7-0.85 for interactive elements.
- **Android**: Material motion system. Shared axis, container transform, fade through, fade patterns. Duration scales with device performance class.

### Desktop (reference)
- **More GPU headroom** — can afford slightly more complex animation (blur, shadow animation) that would jank on mobile.
- **Larger travel distances** — increase duration proportionally. A 1000px slide needs more time than a 200px slide to feel smooth.
- **Mouse hover enables preview animations** that don't exist on touch. Use these to communicate interactivity and preview state changes.

## Motion Audit Checklist

Quick evaluation criteria for reviewing animation in a design or implementation.

| Question | If no | Action |
|----------|-------|--------|
| Does this animation communicate something (state change, spatial relationship, attention)? | Motion is decorative | Remove or replace with instant transition |
| Is the duration in the 100-500ms range for its context? | Too fast or too slow | Adjust per Duration by Context table |
| Does it use ease-out for enter, ease-in for exit? | Wrong easing | Correct per Easing by Motion Type table |
| Does it honor `prefers-reduced-motion`? | Missing accessibility | Add reduced-motion alternative (mandatory) |
| Does the motion origin make spatial sense? | Breaks spatial model | Trace back to logical source; use fade if no source |
| Does it animate only `transform` and `opacity`? | Layout properties animated | Convert to transform-based animation |
| Is the element interactive during/after animation? | Animation blocks interaction | Shorten duration or allow interaction during animation |

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Animation for animation's sake** | Every motion costs: performance, accessibility risk, user time. Decorative animation that communicates nothing is pure cost. | Ask "what does this animation tell the user?" If the answer is "nothing" or "it looks cool," remove it. | Very high |
| **Long durations blocking interaction** | Animations >500ms that disable input while running. User must wait for animation to finish before proceeding. UIs that prioritize spectacle over workflow. | Cap at 300ms for interactive elements. Allow interaction during non-essential animations. Animation serves the user, not the other way around. | High |
| **Spatial inconsistency** | Menu slides in from the right but its trigger is on the left. Modal enters from bottom but exits to the right. Elements move in directions that contradict the UI's spatial model. | Every animation origin must trace back to a logical source. If there's no spatial source, use fade (neutral entry). Map out the spatial model before choreographing motion. | High |
| **Parallax causing motion sickness** | Parallax scrolling separates foreground and background scroll speeds, creating relative motion that triggers vestibular symptoms in susceptible users. Most common motion accessibility complaint. | Remove parallax entirely under `prefers-reduced-motion`. For full-motion users: keep parallax subtle (1.0-1.2x speed differential, not 2-3x). Avoid parallax on vertical scroll. | High |
| **Loading spinner shown immediately** | Spinner appears for operations that complete in 50-200ms. User sees a flash of spinner → content, which feels janky and slower than showing nothing. | Delay spinner display by 300ms. If operation completes before delay, show content directly. If not, show spinner. Skeleton screens are preferred over spinners for layout-predictable content. | Medium |
| **Animating layout properties** | Animating `width`, `height`, `top`, `left`, `padding`, `margin` triggers layout recalculation on every frame. Causes jank, especially on mobile. | Use `transform: translate()` for position, `transform: scale()` for size changes, `opacity` for visibility. These run on the compositor thread — no layout recalc. | Medium |
| **No exit animation** | Element enters with a polished 300ms animation but disappears instantly when closed. The asymmetry feels jarring and incomplete. | Exit animation at 60-80% of entrance duration. Exit uses `ease-in` (accelerating out). Exit can be simpler than entrance (fade-out is fine even if entrance was slide+fade). | Medium |

## Named Patterns

### Skeleton Loading
**When to use**: Content loading 300ms-3s. Predictable layout structure. Lists, cards, profiles, dashboards.
**When NOT to use**: Operations <300ms (show nothing, then content). Completely unpredictable layouts. Full-page initial load (use progress bar instead).
**Key details**: Shape matches real content (text lines, avatars, image placeholders). Subtle pulse animation (opacity 0.6-1.0, 1.5s cycle). Transition to real content with 150ms crossfade. ~30% faster perceived loading vs spinner (research by Bill Chung). Reduced motion: static gray blocks, no pulse.

### Staggered Reveal
**When to use**: List of items entering view (search results, dashboard cards, navigation items). Creates visual rhythm and directs attention sequentially.
**When NOT to use**: Single items. Lists with >10 items (stagger time accumulates — cap at 5-7 items, then batch the rest). Content the user is waiting for urgently.
**Key details**: Each item offset by 30-50ms. Total stagger duration should not exceed 300ms. Items: fade + translate-y (10-20px). First item appears at base timing; last item at base + (n * offset). All items should be visible within 500ms of trigger.

### Shared Element Transition
**When to use**: Navigation between views that share a common element (thumbnail → detail, card → full page, avatar → profile). Maintains object permanence.
**When NOT to use**: Navigation between unrelated views. When shared element identity is ambiguous. When it would delay navigation perceptibly.
**Key details**: Element morphs position, size, and shape from source to destination. Duration 300-400ms, ease-in-out. Other content fades during transition. FLIP technique: snapshot First position, set Last position, Invert with transform, Play the animation. View Transitions API (`document.startViewTransition`) enables this natively in modern browsers.

### Morphing Button
**When to use**: Button that transforms into its result (submit button → success checkmark, button → loading spinner → complete). Keeps attention on the action.
**When NOT to use**: When the result appears elsewhere on the page (user needs to look away from button). Navigation buttons (they leave the page). Multi-step sequences where button state changes aren't the focus.
**Key details**: Width morphs smoothly (don't jump). Text crossfades. Loading state: button shrinks to circle + spinner inside. Success: circle + checkmark + color change (green). Duration: 200ms for each state transition. Return to original state after 2-3s or on next interaction.

### Slide-Over Panel
**When to use**: Detail view, settings, secondary content that relates to the main view. User needs to see main content alongside panel.
**When NOT to use**: Content that requires full attention (use full page). Small amounts of info (use popover/tooltip). Actions that affect the main view (confusing split-attention).
**Key details**: Slides from right edge (LTR) at 250-300ms, ease-out. Width: 30-50% of viewport (not fixed px — adapt to screen). Push main content or overlay with scrim (40% black). Close: slide right at 200ms, ease-in. Focus trap inside panel. Escape to close. Scrim click to close.

### Collapse/Expand
**When to use**: Accordion sections, expandable rows, show/hide detail, FAQ. Content that's sometimes relevant and sometimes not.
**When NOT to use**: Content that should always be visible. Primary content hidden behind expand (important content shouldn't require action to reveal).
**Key details**: Height animation is expensive (layout property). Technique: animate `max-height` from 0 to estimated max, or use `grid-template-rows: 0fr → 1fr` (modern CSS). Duration: 200-250ms, ease-out. Include chevron rotation (180deg) as expand indicator. Reduced motion: instant expand, no height animation.

### Fade + Translate (Standard Enter/Exit)
**When to use**: Default enter/exit pattern for most UI elements. Tooltips, dropdowns, toasts, popovers, notification cards.
**When NOT to use**: Elements with clear spatial origin (use directional slide instead). Elements replacing other elements in place (use crossfade).
**Key details**: Enter: fade 0→1 + translateY 8-16px→0, 150-200ms, ease-out. Exit: fade 1→0 + translateY 0→8-16px, 100-150ms, ease-in. Translate direction: down for elements appearing above trigger, up for below. Small translate distance (8-16px) — don't overshoot. Reduced motion: fade only, no translate.

### Progress Indicator (Determinate vs Indeterminate)
**When to use**: Operations exceeding 1s where the user must wait. File uploads, bulk operations, system processes.
**When NOT to use**: Operations <1s (show nothing or instant feedback). Operations where progress can't be measured at all (use skeleton instead).
**Key details**: **Determinate** (known duration): progress bar filling left-to-right. Update smoothly, not in jumps. Show percentage or step count. **Indeterminate** (unknown duration): looping animation (spinner, progress bar shimmer). Switch from indeterminate to determinate when progress becomes measurable. Nielsen: progress bars that slow at the end feel longer. Consider ease-out on progress fill — fast start, settling end — feels faster.

### FLIP Animation Technique
**When to use**: Layout animations where elements move between positions (list reorder, grid resize, card expand/collapse). The key technique for smooth layout transitions.
**When NOT to use**: Simple show/hide (overkill — use CSS transition). When the start and end states aren't both rendered in the DOM.
**Key details**: **F**irst: capture element's starting position (`getBoundingClientRect`). **L**ast: apply the DOM change, capture new position. **I**nvert: apply `transform` to move element back to starting position. **P**lay: remove the transform with CSS transition — element animates to its natural (new) position. This converts expensive layout animations into cheap transform animations. Duration: 200-300ms. Libraries: Framer Motion (`layout` prop), GSAP Flip plugin, or manual implementation.

# Performance UX
**When to load**: Loading states, perceived performance, skeleton screens, optimistic updates, lazy loading  |  **Skip if**: Backend performance optimization (this covers perceived performance, not server-side)

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Perceived performance > actual** | Skeleton screens feel ~30% faster than spinners (Google Web Fundamentals). Progress bars with non-linear easing feel faster than linear ones (Harrison et al., CHI 2010). User satisfaction correlates with perceived speed, not measured speed. | Default to skeletons for content-heavy views. Reserve spinners for unpredictable-duration operations. Use progress bars when you can estimate completion. |
| 2 | **Response time thresholds** (Nielsen/Miller) | 0.1s = instant (no feedback needed). 1s = flow maintained (show subtle progress). 10s = attention lost (provide estimate, cancel option). These are cognitive boundaries, not arbitrary numbers. | <100ms: no loading UI. 100ms-1s: subtle indicator (pulse, inline spinner). 1-10s: skeleton/progress. >10s: progress + time estimate + cancel. |
| 3 | **Optimistic UI** | Show success immediately for non-critical writes; reconcile failures async. Reduces perceived latency to near-zero for common operations. Users feel in control. | Apply to: likes, toggles, reorder, status changes. Avoid for: payments, deletes, sends to external systems. Always implement rollback. |
| 4 | **Progressive loading** | First Contentful Paint (FCP) within 1s, Largest Contentful Paint (LCP) within 2.5s (Core Web Vitals). Above-fold content first. Users judge speed by time to first useful content, not time to complete page. | Prioritize critical rendering path. Defer below-fold images/components. Stream HTML where possible. Inline critical CSS. |
| 5 | **Lazy load deliberately** | Defer off-screen content (Intersection Observer for media, dynamic import for code). But eager-load anything on the critical path. Bad lazy loading causes layout shift (CLS penalty) and blank content during fast scrolls. | Lazy: images below fold, heavy components in tabs, routes not yet visited. Eager: hero image, initial data, first screen of content. |

## Decision Tables

### Loading Indicator by Content Type

| Content type | Predictable layout? | Recommended | Why |
|-------------|---------------------|-------------|-----|
| Card grid / list | Yes | Skeleton screen | Layout is known — skeleton matches final shape, reduces CLS. |
| Text article | Partially | Skeleton for structure, placeholder lines for text | Text length varies but structure (heading + paragraphs) is stable. |
| Dashboard widgets | Yes | Per-widget skeleton, independent loading | Each widget loads independently — don't block all for slowest. |
| Image gallery | Yes (if sized) | Blur-up / LQIP placeholder per image | Sized containers prevent layout shift. Blur-up gives visual preview. |
| Search results | No | Spinner or pulsing indicator | Result count/shape unknown — skeleton would mislead. |
| Modal / dialog content | Depends | Spinner if quick (<1s), skeleton if slow | Modals are focused context — skeleton for >1s, spinner for brief loads. |
| Full page transition | No | Top progress bar (NProgress-style) | Full-page skeleton is complex to maintain. Progress bar is universal. |

### Optimistic vs Confirmed Updates

| Factor | Optimistic | Confirmed (wait for server) |
|--------|-----------|---------------------------|
| Failure consequence | Low — easily recoverable (toggle, like, reorder) | High — money, external notification, permanent delete |
| Failure frequency | Rare (<1% expected) | Non-trivial (rate limits, validation, permissions) |
| Latency sensitivity | High — user expects instant response | Lower — user expects processing time |
| Rollback complexity | Simple — revert local state | Complex — cascading side effects |
| Data consistency requirement | Eventually consistent is fine | Strong consistency required |
| **Example** | Like/unlike, drag-reorder, toggle setting | Payment, send email, publish, delete account |

### Lazy vs Eager Loading

| Content | Viewport probability | Recommendation |
|---------|---------------------|----------------|
| Hero image / above-fold | 100% | Eager — preload in `<head>`, `fetchpriority="high"` |
| Second viewport of content | ~70% (scroll-likely) | Eager or low-priority prefetch |
| Tab content (non-active tab) | ~30% (click required) | Lazy — load on tab click, show skeleton briefly |
| Modal content | ~10% (action required) | Lazy — load on open trigger |
| Below-fold images | Variable | Lazy — Intersection Observer, `loading="lazy"` |
| Route not yet visited | <20% | Lazy — dynamic import. Prefetch on hover/intent signals. |

### Full-Page vs Incremental Loading

| Scenario | Strategy | Rationale |
|----------|----------|-----------|
| Initial page load | Stream HTML + incremental hydration | Show content ASAP; hydrate interactive parts progressively. |
| Navigation (SPA) | Route-level code split + skeleton | Keep shell, swap content area. Skeleton for new content. |
| Data refresh (same page) | SWR — show stale, revalidate background | No loading state needed if stale data is acceptable. |
| Paginated list (next page) | Append with loading indicator at bottom | Don't replace existing content; extend it. |
| Filter/sort change | Inline loading state on the list area only | Don't reload nav, sidebar, header. Scope the loading indicator. |

### Transition & Animation Performance

| Transition type | Duration | Easing | Priority | Why |
|----------------|----------|--------|----------|-----|
| Micro-interaction (toggle, checkbox) | 100-150ms | ease-out | GPU-composited (transform/opacity only) | Must feel instant — any delay feels laggy for direct-manipulation controls. |
| Content swap (tab change, accordion) | 200-300ms | ease-in-out | Avoid layout triggers during animation | Fast enough to not block, slow enough to track visually. |
| Modal / overlay entrance | 200-250ms | ease-out (decelerate in) | Backdrop: opacity. Panel: transform translateY | Entrance should feel deliberate, not jarring. |
| Modal / overlay exit | 150-200ms | ease-in (accelerate out) | Same properties as entrance | Exit faster than entrance — user wants it gone. |
| Page/route transition | 250-400ms | ease-in-out | Crossfade or slide depending on hierarchy | Longer transitions okay for navigation — it's a context switch. |
| Loading shimmer pulse | 1.5-2s per cycle | ease-in-out (sine wave feel) | CSS only — no JS animation | Slow, calm rhythm. Fast pulsing feels anxious. |

## Platform Notes

### Web (primary)
- **Core Web Vitals targets**: LCP < 2.5s, FID/INP < 200ms, CLS < 0.1. These directly affect SEO ranking (Google, 2021+).
- **Skeleton implementation**: Match exact layout dimensions to prevent CLS. Animate with CSS (`@keyframes shimmer`) not JS. Use `aria-busy="true"` on loading containers.
- **Image optimization**: WebP/AVIF with `<picture>` fallback. `srcset` for responsive sizes. Explicit `width`/`height` attributes to reserve space.
- **Prefetch signals**: `<link rel="prefetch">` for likely next navigations. `<link rel="preconnect">` for third-party domains. `<link rel="preload">` for critical resources.
- **Loading delay threshold**: Show loading indicators only after 200-300ms delay. Avoids flash-of-loading for fast responses. Implement with `setTimeout` + cleanup on resolve.
- **Reduce motion**: Respect `prefers-reduced-motion`. Replace animations with instant state changes. Skeleton shimmer can remain (it's informational, not decorative).

### Mobile
- Slower networks are common — 3G baselines still relevant for global audiences. Test on throttled connections.
- Touch-initiated loads: show feedback within 100ms (tap highlight, button press state) even if content takes longer.
- Reduce payload: fewer images, smaller bundles. Data saver mode detection via `Save-Data` header.
- Skeleton screens should be simpler — fewer placeholder elements to reduce render cost on low-end devices.
- Pull-to-refresh: provide immediate haptic/visual feedback on pull gesture. Show spinner at top. Content below stays visible and interactive during refresh.
- App resume (backgrounded -> foregrounded): if stale >30s, refresh data silently. If stale >5min, show brief "Updating..." indicator.

### Desktop
- Higher bandwidth expected but not guaranteed. Don't assume fast connections.
- Hover-to-prefetch is viable — preload route/data on hover before click.
- Parallel loading: wider screens show more content simultaneously — load visible widgets in parallel, not sequentially.
- Background tabs: pause non-critical fetches when tab is hidden (`document.visibilityState`).
- Multi-window: if user opens same app in multiple windows, coordinate cache invalidation via `BroadcastChannel`. Stale data across windows erodes trust.
- Large monitor layouts show more content — but also more loading indicators simultaneously. Coordinate to avoid "Christmas tree" of independent spinners; stagger or use a single top-level indicator when loading multiple sections at once.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| Spinner for everything | Spinners convey zero information — no shape preview, no progress, no estimate. | Use skeleton for known layouts, progress bar for estimable tasks, spinner only as last resort. | Very common |
| Layout shift from lazy content | Elements pop in and push content around — CLS penalty, disorienting, causes mis-clicks. | Reserve exact dimensions with aspect-ratio containers or explicit width/height. | Very common |
| Blocking entire UI for single slow request | One slow API call freezes the whole page. Users can't interact with anything. | Load components independently. Isolate failures. Show available content while slow parts load. | Common |
| Flash-of-loading (no delay threshold) | Loading indicator appears for 50ms then vanishes — visual noise, feels broken. | Show loading UI only after 200-300ms. If resolved sooner, skip the indicator entirely. | Common |
| Skeleton that doesn't match final layout | Skeleton shows 3 rows, content has 10. Or skeleton has different widths than real content. | Derive skeleton from the actual component's layout. Automate where possible. Update when layout changes. | Moderate |
| Optimistic UI without rollback | Show success, server fails, user's data is wrong. No correction, no notification. | Always implement rollback: revert UI state + show error toast on failure. Test the failure path. | Moderate |
| Infinite scroll without virtualization | DOM grows unbounded — 10,000 nodes kill scroll performance and memory. | Virtual list (react-window, @tanstack/virtual): render only visible items + buffer. Recycle DOM nodes. | Common |
| Loading text that lies | "Almost done..." shown at 10%. Progress bar that stops at 90% for 30 seconds. | Use indeterminate indicators when you can't estimate. If using progress, base it on real metrics. | Moderate |

## Named Patterns

### Skeleton Screen
**When**: Content with predictable layout (cards, lists, profiles, articles). Load time >300ms.
**When NOT**: Unknown/variable layout (search results with unknown count). Very fast loads (<200ms).
**How**: Gray/neutral pulsing shapes matching exact content dimensions. Animate with CSS shimmer (left-to-right gradient). Replace atomically per content block — don't fade individual skeleton pieces. `aria-busy="true"` on container, `aria-hidden="true"` on skeleton elements.

### Stale-While-Revalidate (SWR)
**When**: Data that changes but staleness is acceptable for seconds/minutes (dashboards, feeds, profiles).
**When NOT**: Real-time critical data (stock prices, live scores), or data that must be fresh on display (auth state).
**How**: Show cached/stale data immediately. Fetch fresh data in background. Replace stale data when fresh arrives. If fresh data differs significantly, show subtle "Updated" indicator rather than jarring content swap.

### Optimistic Update with Rollback
**When**: Low-risk user actions with high latency sensitivity — likes, toggles, reorders, inline edits.
**When NOT**: Payments, sends, publishes, destructive actions, anything with external side effects.
**How**: 1) Apply state change locally. 2) Send request to server. 3a) Success: confirm (no-op visually). 3b) Failure: revert local state + show error toast. Keep rollback logic colocated with the optimistic update — don't scatter it.

### Progressive Image (Blur-Up / LQIP)
**When**: Image-heavy pages — galleries, product images, hero banners. Any image above fold.
**When NOT**: Icons, thumbnails under 10KB, decorative images that can use CSS background.
**How**: Serve tiny placeholder (20-40px wide, ~200 bytes inline base64 or blurhash). Scale up with CSS blur. On full image load, crossfade to sharp version. Container must have fixed aspect ratio to prevent CLS.

### Infinite Scroll with Virtual List
**When**: Large homogeneous lists (feeds, logs, search results) where users scan rather than navigate to specific items.
**When NOT**: Content where users need to reach specific positions (use pagination). Lists under 100 items (no virtualization needed). Content requiring footer access.
**How**: Intersection Observer triggers next-page fetch. Virtual list renders only visible items + overscan buffer (~5 items). Show loading indicator at list bottom during fetch. Provide "Back to top" affordance. Preserve scroll position on back-navigation.

### Prefetch on Hover/Intent
**When**: Navigation-heavy UIs where next destination is predictable from user behavior (menus, link lists, tabs).
**When NOT**: Mobile (no hover). Low-bandwidth contexts. Expensive endpoints (don't prefetch speculatively if it costs server resources).
**How**: On `mouseenter` (with ~100ms debounce to filter drive-by hovers), initiate prefetch of route code and/or data. Cache the result. If user clicks, load is instant or near-instant. If they don't click, cache expires naturally.

### Content Placeholder (Pulsing Lines)
**When**: Text-heavy content where exact layout is known but line count varies (articles, comments, descriptions).
**When NOT**: Structured data like tables or forms where field-level skeletons are more appropriate.
**How**: 2-4 horizontal bars of varying width (100%, 100%, 75%) to mimic text block shape. Same shimmer animation as skeleton. First line full-width, last line shorter — mimics natural paragraph endings. Match font-size line-height for accurate vertical spacing.

### Streaming / Chunked Rendering
**When**: Large datasets, AI-generated content, real-time feeds where data arrives incrementally.
**When NOT**: Small payloads that complete in <200ms. Content that must be displayed atomically (e.g., a single image).
**How**: Render each chunk as it arrives — don't buffer the entire response. For text: append to DOM. For lists: insert items at bottom. Show a "receiving" indicator (pulsing cursor, typing dots) at the insertion point. Allow user to scroll/interact with already-rendered content while more arrives.

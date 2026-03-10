# Information Architecture
**When to load**: Navigation design, content organization, page structure, mental models, wayfinding, taxonomy, search patterns  |  **Skip if**: Visual styling questions, component API design, responsive layout

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Progressive disclosure** — reveal complexity gradually | Cognitive load theory (Sweller, 1988): working memory handles ~4 chunks. Front-loading everything overwhelms. | Default view shows the 80% case. Advanced options behind expandable sections, secondary tabs, or progressive flows. Never hide — disclose on demand. |
| 2 | **Recognition over recall** (Miller, 1956; Nielsen heuristic #6) — show options, don't require memory | Recall requires mental retrieval. Recognition requires only comparison. Recognition is faster, less error-prone, and less effortful. | Visible labels > icon-only. Dropdown > free text when options are finite. Recent items > "type the ID." Breadcrumbs > remembering path. |
| 3 | **Mental model alignment** — match user expectations, not system structure | Users carry models from prior experience (other apps, real-world analogies). System model mismatch = confusion. (Norman, *Design of Everyday Things*) | Card sort to discover user groupings. Task analysis before sitemap. "Where would you look for X?" testing. Never expose database schema as navigation. |
| 4 | **Chunking** (Miller's Law, 7+-2; Cowan's revision: 4+-1) — group related items | Ungrouped lists beyond ~5 items force serial scanning. Grouped lists enable category-level skipping. | Navigation: max 5-7 top-level items. Settings: group into categories. Long forms: chunk into sections with clear headings. |
| 5 | **Findability** — every piece of content discoverable from at least 2 paths | Single-path content is fragile — if the user's mental model doesn't match that path, the content is invisible. (Morville & Rosenfeld, *Information Architecture*) | Cross-link related content. Provide both search and browse. Tag content for multiple access paths. Sitemap as safety net. |

## Decision Tables

### Hierarchy Depth

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Small app (<30 pages/views) | Flat: 1-2 levels of navigation | 3+ levels deep | Small content sets don't need depth. Flat = fewer clicks, less disorientation. |
| Medium app (30-200 views) | 2-3 levels max. Global nav -> section nav -> local nav. | Single mega-nav trying to show everything | Medium apps need structure but not bureaucracy. Two-level nav covers most patterns. |
| Large app (200+ views) | 3 levels max with strong search. Hub-and-spoke at top level -> section-specific sub-nav. | >3 levels deep without search | Beyond 3 levels, users lose context. Search becomes primary navigation for power users. |
| Growing content (CMS, docs) | Faceted navigation + search. Categories are entry points, not containers. | Fixed hierarchy that breaks when content grows | Hierarchies are brittle. Facets scale because items can belong to multiple categories. |

### Navigation Pattern Selection

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| 5-7 top-level sections, all equally important | Horizontal top nav (web). Bottom tab bar (mobile). | Hamburger menu hiding all top-level nav | Visible nav outperforms hidden nav by 15-20% in task completion (Nielsen Norman Group, 2016). |
| 8+ top-level sections | Group into 5-7 categories. Or: mega menu with visual grouping. | Long horizontal nav that wraps or scrolls | Wrapping nav breaks spatial memory. Mega menus work if well-organized with clear grouping. |
| Deep content within a section | Left sidebar nav (collapsible). Contextual to current section. | Showing all sections' deep nav globally | Section-specific nav reduces noise. User is in a context — show that context's options. |
| Task-based app (e.g., email, project tool) | Action-oriented nav: verbs ("Create," "Review," "Search") alongside object nav. | Only object-based nav ("Projects," "Users") when tasks cross objects | Users think in tasks, not objects. "Review pull requests" spans repos — don't bury it under a single repo. |
| Utility/settings/account | Secondary nav pattern: top-right dropdown, footer links, or separate settings area. | Mixing utility nav with primary content nav | Utility actions are infrequent. They shouldn't compete with primary tasks for attention. |

### Breadcrumbs vs Back Buttons

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Hierarchical content (docs, e-commerce categories) | Breadcrumbs showing full path | "Back" button alone (ambiguous: back to parent or back in history?) | Breadcrumbs show location AND enable jumping to any ancestor level. |
| Linear flow (checkout, onboarding) | Step indicator + explicit "Back" to previous step | Breadcrumbs (implies users can jump to any step) | Linear flows are sequential. Breadcrumbs suggest random access that may not be supported. |
| Search results -> detail page | "Back to results" link (preserving search state) | Generic browser back (may lose filters, scroll position) | Search context is precious. Losing it forces the user to re-enter their query. |
| Flat app (no meaningful hierarchy) | Neither. Current section indicator in nav suffices. | Breadcrumbs showing "Home > Current Page" (adds nothing) | One-level breadcrumbs are visual noise. They don't aid navigation. |

### Search vs Browse Strategy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| User knows what they want (known-item search) | Search-first with autocomplete. Filters as refinement. | Forcing browse through categories first | Known-item search is 2-3x faster via search than browse (Hearst, *Search User Interfaces*). |
| User is exploring (unknown-item browse) | Category browse with faceted filtering. Search as secondary. | Search-only interface with no browse affordance | Exploratory users don't know the right query. Browsing reveals the vocabulary of the domain. |
| Mixed user base | Both: prominent search bar + visible category nav. | Hiding one behind the other | Power users search. New users browse. Support both without favoring either. |
| Content > 1000 items | Search mandatory. Browse becomes impractical as primary strategy. | Only browse with pagination | Nobody clicks to page 47. Search + sort + filter is the only scalable pattern for large datasets. |

### URL & Routing Design

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Content pages with stable identity | Human-readable slugs: `/products/widgets/blue-widget` | Opaque IDs: `/page?id=4f2a` | Readable URLs communicate hierarchy, are shareable, bookmarkable, and aid SEO. |
| Filtered/sorted views | Query params for filters: `/products?color=blue&sort=price` | Encoding filter state in the path: `/products/color-blue/sort-price` | Query params are composable, removable, and understood by browsers. Path segments imply hierarchy that doesn't exist. |
| SPA navigation | Update `history.pushState` on every meaningful view change. Restore state on back/forward. | Hash-only routing (`#/page`) or no URL updates on navigation | Back button is a navigation tool. If the URL doesn't update, back breaks the user's spatial model. |
| Deep-linkable state (tabs, panels, modals) | URL param or hash for significant state: `/settings#notifications`. | Ephemeral state in URL (tooltip open, hover state) | Deep-link what users would share or bookmark. Transient states don't belong in the URL. |

### Empty States & Zero-Data

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| First-time user, no data yet | Helpful empty state: explain what goes here + CTA to create first item. Show example/illustration. | Blank page or "No data" text | First impressions matter. Empty state is an onboarding moment. Guide the user toward their first success. |
| Search with no results | "No results for X" + suggestions: check spelling, try broader terms, browse categories. | Blank results area | Dead ends frustrate. Always offer a next step. Suggest similar queries if possible. |
| Error loading content | Error state with retry action. Preserve any previously loaded content. | Replacing the entire page with an error | Partial data > no data. If 1 of 5 widgets fails, show 4 and error the 1. Don't nuke the whole dashboard. |
| Filtered to zero results | Show active filters prominently + "Clear all filters" CTA. Indicate total count without filters. | Same empty state as first-time (confusing: did I do something wrong or is there no data?) | Users need to understand why there's nothing. "0 results with these filters (47 total)" resolves ambiguity immediately. |

### Content Labeling & Taxonomy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Naming navigation items | Use nouns for objects ("Projects"), verbs for actions ("Create"). Be specific: "Activity Log" not "History." | Generic labels ("Dashboard," "Home") that don't describe content | Users predict content from labels. Vague labels force clicking to discover. Specific labels enable confident navigation. |
| Category naming | Use user language discovered through card sorts or search analytics. | Internal jargon, abbreviations, or system terminology | "SOW" means nothing to new users. "Statement of Work" is clear. Search logs reveal what users actually call things. |
| Duplicate content across categories | Cross-reference with links. Don't duplicate the content itself. | Maintaining identical content in two locations | Duplication drifts. One copy gets updated, the other doesn't. Cross-link to the canonical location. |
| Content versioning (docs, policies) | Clear version indicator + link to latest. Archive old versions, don't delete. | Unmarked versions floating in search results | Users must know if they're reading the current version. Old versions in search results cause costly mistakes. |

## Platform Notes

**Web (primary)**: URL structure should mirror IA. `/products/widgets/blue-widget` communicates hierarchy in the URL itself — aids shareability, bookmarking, and SEO. Browser back button is a navigation element — don't break it with client-side routing that doesn't update history. Anchor links for in-page navigation in long content. `<nav>` landmark with `aria-label` distinguishes multiple nav regions for screen readers. Skip links (`Skip to main content`) must be the first focusable element.

Browser history management: every meaningful state change should push to history. Filter changes, tab switches, modal opens (if they represent a "place"). Test: if the user hits back, do they go where they expect? If not, the history management is wrong.

**Mobile reference**: Limited screen real estate forces IA compression. Bottom tab bar (iOS pattern) for 3-5 top-level destinations. Hamburger for secondary nav (acceptable when primary nav is in tabs). Drill-down navigation with full-screen transitions — user's mental model is a stack. Swipe-back gesture (iOS) as implicit "back." Deep linking via Universal Links (iOS) / App Links (Android) must mirror web URL structure for consistency.

Gesture navigation (swipe back, pull to refresh) is now the primary interaction model on iOS and Android. IA must account for gesture-based mental models: the user thinks of navigation as a physical stack they can "peel back."

**Desktop reference**: Space allows persistent sidebar nav — reduces navigation cost to zero clicks for section switching. Keyboard shortcuts for power users navigating between sections (Gmail's `g then i` pattern). Multi-panel layouts (email: list + preview) reduce navigation trips. Right-click context menus as navigation shortcuts for expert users. Command palette (Cmd+K) as universal search/navigate — increasingly expected in productivity apps.

Multi-window/tab workflows: users open items in new tabs to compare. IA must support this — every meaningful view needs a stable, shareable URL. Deep state (scroll position, expanded panels) can use `sessionStorage` for within-tab persistence.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Deep nesting (>3 levels)** | Users lose context after 3 levels. "Where am I?" becomes the primary question instead of the primary task. | Flatten hierarchy. Use facets instead of nested categories. 3 levels max with search as escape hatch. | Very common |
| **Inconsistent navigation across pages** | Spatial memory (users remember "it's in the top-left") breaks when nav moves, reorders, or changes between pages. | Global nav is sacrosanct. Same items, same order, same position on every page. Section nav can vary by section. | Common |
| **System-centric taxonomy** ("Manage Resources" / "Administration Module") | Users don't think in system terms. They think in tasks and domain objects. Card sort studies consistently show this mismatch. | Use user language. "People" not "User Management." "Settings" not "System Configuration." Run a card sort. | Very common |
| **Mystery meat navigation** (icons without labels, creative link text) | Users can't predict where they'll end up. Hover-to-reveal labels add a click-cost equivalent. | Label everything. Icons supplement labels, never replace them. Exception: universally understood icons (home, search, close). | Common |
| **Junk drawer pages** ("Miscellaneous," "Other," "More") | Catch-all categories signal IA failure. Users don't look in "Other." | Redistribute items to proper categories. If they don't fit, the taxonomy is wrong — redesign it. | Moderate |
| **Orphan pages** (no navigation path, only reachable via direct URL) | Content without a path is invisible content. If it's not worth navigating to, delete it. | Audit: every page must appear in at least one nav path. Link from related content. Include in sitemap. | Common |
| **Modal as navigation** (modal opens modal opens modal) | Modals are interruptions, not destinations. Stacking them destroys spatial context — user can't orient. | If it needs a URL, it's a page. If it needs back navigation, it's a page. Modals are for focused, single-step tasks only. | Moderate |
| **Pagination without load estimates** ("Page 1 of ?") | Users can't gauge scope. "Am I 5% through or 95% through?" Uncertainty increases abandonment. | Show total count. "1-20 of 347 results." Or: "Load more" with remaining count. Virtual scroll for very large lists. | Common |

## Named Patterns

### Hub-and-Spoke
**When to use**: Mobile apps with distinct modes (camera, gallery, settings). Dashboards where each widget links to a deep section. Home screens as launch pads.
**When NOT to use**: Workflows that span multiple spokes — users shouldn't have to return to the hub to switch context. High-frequency cross-section navigation.
**Key decisions**: Hub must be lightweight (not itself content-heavy). Spoke-to-spoke navigation needed? If yes, augment with global nav or shortcuts. Hub should surface personalized content (recent items, relevant actions) to reduce time-to-task.

### Breadcrumb Trail
**When to use**: Hierarchical content deeper than 2 levels. E-commerce (category > subcategory > product). Documentation sites. File system navigation.
**When NOT to use**: Flat structures (breadcrumbs would always show the same thing). Wizard/stepper flows. Dynamic filtering results (path is not hierarchical).
**Key decisions**: Each crumb is a link. Current page is shown but not linked. Truncation strategy for deep paths (show first + last, collapse middle with "..."). Schema.org `BreadcrumbList` markup for SEO.

### Faceted Search
**When to use**: Large catalogs with multiple orthogonal attributes (size, color, price, brand). Content libraries. Job boards. Any dataset where users filter by multiple dimensions.
**When NOT to use**: Small datasets (<50 items). Content with fewer than 3 meaningful facets. When the vocabulary is not established (users don't know the facet values).
**Key decisions**: Show active filters prominently with "clear" affordance. Counts per facet value (shows result density). AND within facet, OR across facets (most intuitive default). Auto-update results vs "Apply" button (auto-update for <200ms response time). Mobile: facets move to a filter sheet/panel, not inline.

### Wizard / Stepper
**When to use**: Multi-step tasks with dependencies between steps. Onboarding. Complex form submission. Checkout flows. Configuration processes.
**When NOT to use**: When users need to see all fields simultaneously (use a single long form). When steps have no dependencies and order is arbitrary. When the task takes <30 seconds total.
**Key decisions**: Show step count and current position. Allow back-navigation freely. Allow step-skipping only if no dependencies. Save progress between steps (auto-save, not just on "Next"). Validate per-step, not at the end. Final step shows summary for review before submission.

### Dashboard Layout
**When to use**: Overview/summary views aggregating multiple data sources. Monitoring/analytics. Admin panels. Home screens for complex apps.
**When NOT to use**: As the only way to access data (dashboards summarize, detail views explain). When the dashboard has >12 widgets (information overload).
**Key decisions**: Priority placement: top-left = most important (Gutenberg diagram). Widget sizing: important = large, secondary = small. Customizable layout (user reorder) for power users. Empty states for each widget independently. Refresh strategy (real-time vs polling vs manual). Loading: skeleton screens per widget, not a single spinner for the whole page.

### Priority+ Navigation
**When to use**: Horizontal navigation that must adapt to varying widths. When all items are important but space is limited.
**When NOT to use**: When items have clear priority differences (just show the top 5). Vertical nav (space is unlimited vertically).
**Key decisions**: Items overflow into a "More" dropdown as width shrinks. Order matters — leftmost items stay visible longest. "More" menu must show how many items are hidden. Consider showing the active item even if it would normally overflow. Implement via `ResizeObserver` measuring available space, not viewport breakpoints.

### Command Palette
**When to use**: Productivity apps with many features/routes. Power users who prefer keyboard navigation. As a universal search + action interface.
**When NOT to use**: Simple apps with <10 routes. Consumer-facing apps where discoverability through visible UI is more important.
**Key decisions**: Cmd+K (Mac) / Ctrl+K (Windows) as trigger. Fuzzy search across pages, actions, and recently visited. Categorize results (Navigation, Actions, Recent). Show keyboard shortcut hints inline. Close on selection or Escape. Must not conflict with browser shortcuts.

### Contextual Sidebar (Inspector Pattern)
**When to use**: Detail views where users need to see both a list/overview and item details simultaneously. Email clients, file managers, admin panels.
**When NOT to use**: When the detail view requires full-screen focus (complex forms, editors). When the sidebar competes with primary navigation sidebar.
**Key decisions**: Sidebar width: 30-40% of container, or fixed ~350-500px. Resizable handle for user preference. Close affordance to return to full-width list. On narrow viewports, switch to stacked (list then detail page) rather than cramping both into a small space. Persist open/closed state per user.

### Tabbed Interface
**When to use**: Parallel content sections within a single page. Settings categories. Profile sections. Dashboard views. When users need to switch between related views without navigating away.
**When NOT to use**: Sequential steps (use wizard/stepper). When all tabs must be visible simultaneously (use accordion or single page with anchors). More than 7 tabs (use dropdown or sidebar nav instead).
**Key decisions**: Tab bar position: top (web standard), bottom (mobile). Scrollable tabs for overflow (with arrow indicators). Active tab must be visually distinct. Content below tabs should not shift layout when switching. Lazy-load tab content to avoid upfront cost, but consider preloading adjacent tabs. URL hash per tab for deep linking (`/settings#notifications`).

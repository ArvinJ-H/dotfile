# Platform Conventions
**When to load**: Cross-platform design decisions, web vs mobile patterns, platform-specific expectations, native vs web trade-offs  |  **Skip if**: Single-platform web-only decisions with no cross-platform consideration

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Convention over innovation** | Users bring expectations from the platform they use 8+ hours daily. Violating platform conventions forces re-learning and creates friction. Jakob's Law: users spend most of their time on other sites/apps. | Default to platform conventions. Innovate only when the convention is measurably inferior for your specific use case. The burden of proof is on the deviation, not the convention. |
| 2 | **Web is content-first** | Web users expect: scrolling, text selection, link sharing, back button, URL-driven state, right-click, hover states, keyboard shortcuts. The browser is the platform — respect its affordances. | Don't break browser behavior: back button must work, URLs must be shareable, text must be selectable, scroll must be natural. SPAs that break these lose the platform's advantages. |
| 3 | **iOS HIG: clarity, deference, depth** | iOS users expect: direct manipulation, edge swipe navigation, tab bar, pull-to-refresh, system-integrated feel (Dynamic Type, Dark Mode, SF Symbols). Deference = content is primary, chrome is minimal. | Navigation stacks (push/pop). Tab bar for top-level destinations (max 5). System controls for standard inputs (date picker, share sheet). Swipe gestures for common actions. Integrate with iOS conventions or users feel "this is a web app in a wrapper." |
| 4 | **Material Design: elevation, motion, adaptive** | Android/Material users expect: surface metaphor (elevation communicates hierarchy), motion system (container transform, shared axis), FAB for primary action, bottom navigation, snackbars for feedback. | Elevation for layering (0dp base, 1dp card, 4dp nav, 8dp modal, 16dp dialog). Motion choreography between surfaces. Responsive layout grid (columns adapt to breakpoint). Material 3: dynamic color from user wallpaper. |
| 5 | **Platform divergence is OK** | The same feature legitimately uses different patterns on different platforms. A settings page uses a sidebar on web, a navigation stack on iOS, and a preference fragment on Android. Forcing one platform's pattern onto another creates friction on both. | Map the user task, not the UI implementation, across platforms. Same capability, different embodiment. Don't mock iOS tab bar in a web app. Don't force web-style sidebar into a mobile app. |
| 6 | **Progressive enhancement across platforms** | Start with the broadest baseline (web: HTML that works without JS) and add platform-specific enhancements. Graceful degradation when platform features are unavailable. | Web: core functionality works in any browser. Mobile: use platform APIs when available (haptics, biometrics, camera), fall back gracefully. Desktop: add keyboard shortcuts, multi-window support, drag-and-drop — don't require them. |
| 7 | **Platform detection informs, not determines** | Detect platform capabilities, not platform identity. Feature detection over user-agent sniffing. Touch capability doesn't mean phone. Large screen doesn't mean no touch (Surface, iPad Pro). | Use `@media (hover: hover)` not "is this desktop?" Use `@media (pointer: coarse)` not "is this mobile?" Test for capabilities: touch events, hover support, screen size, input method. Adapt to what the device can do, not what you assume it is. |

## Decision Tables

### Navigation Pattern by Platform
| Platform | Primary pattern | Secondary | Avoid | Why |
|----------|----------------|-----------|-------|-----|
| **Web (desktop)** | Sidebar navigation (persistent, collapsible) | Top navigation bar + breadcrumbs | Hamburger menu on wide screens (hides navigation unnecessarily) | Desktop has horizontal space. Persistent nav gives constant wayfinding. Breadcrumbs for deep hierarchies. Top bar for flat site structures. |
| **Web (mobile viewport)** | Bottom tab bar (3-5 items) or hamburger (>5) | Bottom sheet for secondary nav | Full sidebar (covers content on small screens) | Thumb reachability. Bottom is natural reach zone. Hamburger is acceptable on mobile because screen real estate is genuinely constrained. |
| **iOS** | Tab bar (bottom, 3-5 items) + navigation stack (push/pop within each tab) | Sidebar (iPad, split view) | Hamburger menu (Apple discourages), bottom nav with >5 items | iOS convention is tab bar. Each tab is a self-contained navigation stack. Users expect back = pop stack, not back = browser history. |
| **Material/Android** | Bottom navigation (3-5 destinations) | Navigation drawer (6+ destinations), Navigation rail (tablet/large screen) | iOS-style tab bar styling, fixed top tabs for primary nav | Material 3 bottom nav is the primary pattern. Navigation rail for tablets (left side, icon + label). Drawer for deep hierarchy. |
| **Desktop app** | Menu bar + sidebar | Command palette (Cmd+K) | Web-style hamburger, mobile-style tab bar | Desktop users expect menu bar (File, Edit, View). Sidebar for workspace navigation. Command palette for power users. |

### Dialog / Sheet by Platform
| Platform | Light confirmation | Heavy form/content | Action selection |
|----------|-------------------|-------------------|-----------------|
| **Web** | Inline confirmation or modal dialog | Modal or slide-over panel | Dropdown menu or popover |
| **iOS** | Alert (system UIAlertController) | Full-screen modal (presented modally) or sheet (.sheet modifier) | Action sheet (slides from bottom) |
| **Material** | Alert dialog (centered, 280dp wide) | Full-screen dialog or bottom sheet | Bottom sheet (modal or standard) |
| **Desktop** | System dialog or inline confirmation | Window or panel | Context menu (right-click) |

### Gesture Support by Platform
| Gesture | Web | iOS | Material/Android | Desktop |
|---------|-----|-----|-----------------|---------|
| **Tap/click** | Primary interaction | Primary interaction | Primary interaction | Primary interaction |
| **Swipe horizontal** | Rare (carousel). Don't override browser back. | Navigation (back swipe from left edge). List actions (swipe to delete/archive). | Dismiss (snackbar, bottom sheet). Tabs. | Not expected |
| **Swipe vertical** | Scroll (native). Pull-to-refresh (custom). | Scroll. Pull-to-refresh (native). Dismiss sheet (swipe down). | Scroll. Pull-to-refresh. Dismiss bottom sheet. | Scroll only |
| **Long press** | Not expected on web. | Context menu (iOS 13+). Reorder in lists. Peek (deprecated, replaced by context menu). | Select mode. Move/drag. Haptic feedback. | Not expected (use right-click) |
| **Pinch** | Zoom (browser native — don't override!) | Zoom (photos, maps). | Zoom. | Zoom (trackpad gesture) |
| **Right-click** | Context menu (native or custom) | N/A (no right-click on touch) | N/A | Context menu (expected for most elements) |
| **Keyboard shortcut** | Expected for frequent actions. Cmd/Ctrl+key. | Limited (external keyboard). System shortcuts take priority. | Limited. Back button is hardware/gesture. | Expected for everything. Full keyboard navigation. |

### Form Input Patterns by Platform
| Input type | Web | iOS | Material/Android |
|-----------|-----|-----|-----------------|
| **Date** | Native `<input type="date">` or custom picker. Native varies wildly by browser — consider custom for consistency. | UIDatePicker (wheels or inline calendar). System-provided. Always use it — users expect the wheels. | Material date picker (calendar or input). Material 3 has both modal and docked variants. |
| **Select/dropdown** | Native `<select>` for simple cases. Custom dropdown for complex (search, multi-select, grouped options). | UIPickerView (wheels) for short lists. Full-screen table for long lists. Never web-style dropdown. | Exposed dropdown menu (Material). Bottom sheet for long option lists. |
| **Toggle** | Checkbox (on/off), toggle switch (immediate effect). Checkbox for forms, switch for settings. | UISwitch. Always immediate effect (no "save" button needed). System-styled — don't customize heavily. | Material switch. Immediate effect. Material 3 includes icon in thumb for on/off state. |
| **Text input** | `<input>` / `<textarea>`. Floating label optional. Clear button on search. | UITextField with clear button. Floating label not standard iOS (use placeholder or fixed label above). | Material text field. Outlined or filled variant. Floating label is standard Material pattern. Character counter for max-length. |
| **Search** | Search input in nav bar or dedicated page. Instant search (filter as you type) or submit-based. | Search bar with cancel button. Recent searches. Search suggestions. Scope bar for filtering. | Search bar (Material). Expanding search icon → full-width input. Voice search integration. |

## Platform Notes

### Web (primary — deep coverage)
- **URL is state**: Every meaningful state should be URL-representable and shareable. Filters, pagination, tab selection, modal open state — put it in the URL. Users copy URLs to share, bookmark, and navigate.
- **Back button contract**: Browser back must go back. SPA routing that breaks back button violates the platform's most fundamental navigation pattern. `history.pushState` for state changes; `history.replaceState` for state refinements.
- **Text selection**: Web content is selectable by default. Don't add `user-select: none` unless there's a genuine reason (drag handles, game canvas). Selectable text is a platform feature.
- **Tab order**: Focus order must match visual order. `tabindex="0"` for custom interactive elements. Never use `tabindex > 0` (breaks natural order). Visible focus indicators — browsers provide defaults; enhance, don't remove.
- **Responsive is baseline**: Web viewport ranges from 320px (small phone) to 3840px (4K monitor). Design for the range, not for "desktop" and "mobile" as two fixed targets. Use fluid layouts and content-driven breakpoints.
- **Print**: Web content may be printed. Consider `@media print` for content-heavy pages. Hide nav, expand collapsed sections, linearize layout.
- **Performance constraints vary wildly**: Same URL loads on 2015 Android phone and 2024 MacBook Pro. Performance budgets must target the low end. Core Web Vitals as baseline (LCP <2.5s, FID <100ms, CLS <0.1).
- **Progressive Web App (PWA)**: Web apps can behave like native apps (install, offline, push notifications). But PWA conventions differ from both web and native — users may not know they're in a PWA. Provide clear navigation that doesn't depend on browser chrome.

### iOS (reference)
- **Human Interface Guidelines (HIG)**: Apple publishes detailed guidelines. Deviation from HIG causes App Store review friction and user confusion.
- **Safe area**: Content must respect notch, Dynamic Island, home indicator. Use `safeAreaInsets`. Don't place interactive elements behind system UI.
- **Dynamic Type**: Respect the user's text size preference. Use system fonts and auto-layout that adapts. Don't hardcode font sizes.
- **Haptics**: UIFeedbackGenerator for tactile feedback on actions. Light (selection), medium (impact), heavy (notification). Use sparingly — haptic inflation desensitizes.
- **SwiftUI vs UIKit**: SwiftUI is the modern standard. UIKit for complex custom UI. Both follow HIG. SwiftUI enables automatic Dark Mode, Dynamic Type, and accessibility support.

### Material / Android (reference)
- **Material 3 (Material You)**: Dynamic color from user's wallpaper (Monet engine). Color roles replace fixed palette. Elevation system with tonal surfaces (not just shadow).
- **Edge-to-edge**: Content draws behind system bars. Use `WindowInsets` for safe areas. System bars are translucent.
- **Navigation component**: Single Activity + Fragment navigation is legacy. Jetpack Compose Navigation is current standard. Deep linking support built in.
- **Adaptive layout**: Use Window Size Classes (compact, medium, expanded) — not specific device dimensions. Compact = phone, medium = foldable/tablet portrait, expanded = tablet landscape/desktop.
- **Foldables**: Android-specific concern. Apps should adapt to fold state (flat, half-opened). Material provides guidance for table-top mode and book mode.

### Desktop (reference)
- **Menu bar**: Expected on macOS. Windows uses ribbons (Office) or hamburger+sidebar (modern apps). Linux varies by DE.
- **Multi-window**: Desktop users expect to open multiple windows/instances. Design for windows of varying sizes, not just maximized.
- **System tray/notification area**: Background apps live here. Use for persistent services, not as primary UI.
- **Keyboard-first**: Power users navigate entirely by keyboard. Provide shortcuts for all common actions. Show shortcuts in menus and tooltips.
- **Drag-and-drop**: Cross-application drag is expected (drag file from Finder to app, drag text between windows). Support system drag protocols.
- **Electron/Tauri considerations**: Web-to-desktop wrappers should respect desktop conventions. Add menu bar, keyboard shortcuts, system tray, file associations. Don't ship a browser tab as a desktop app.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **Hamburger menu on desktop web** | Hides navigation that has room to be visible. Desktop screens are 1200px+ wide. Hamburger adds a click to every navigation action. | Persistent sidebar or visible top navigation on desktop. Hamburger only when viewport is genuinely constrained (<768px). | Very high |
| **iOS back swipe in web browsers** | Edge swipe in mobile Safari is browser back, not in-app navigation. Binding swipe gesture in web apps conflicts with browser behavior, causing unpredictable navigation. | Use on-screen back buttons for in-app navigation. Don't bind edge swipe gestures in web apps. Let the browser own the edges. | High |
| **Material FAB in iOS apps** | FAB is a Material/Android pattern. iOS users don't expect a floating circle in the bottom-right. It feels foreign and doesn't match iOS visual language. | Use iOS-native patterns: toolbar button, navigation bar button, or contextual action sheet. If FAB-like behavior is needed, use a bottom-attached bar. | High |
| **Ignoring platform-native controls** | Custom date picker that doesn't match platform's native one. Custom select dropdown on iOS that doesn't use the wheel picker. Users have muscle memory for native controls. | Use native/system controls for standard inputs (date, time, select, toggle). Customize styling minimally. Replace only when the native control genuinely can't support the interaction (multi-select, complex search). | High |
| **Web patterns on native mobile** | Breadcrumbs on mobile (no room, not the nav model). Hover-dependent UI on touch (no hover). Fixed sidebar on 375px screen. Pagination for content that should scroll. | Translate the capability, not the component. Breadcrumbs → back button + title. Hover → long press or visible button. Sidebar → bottom tab bar or hamburger. Pagination → infinite scroll or load-more. | High |
| **Forcing identical UI across platforms** | Same pixel-perfect layout on web, iOS, and Android. Ignores each platform's navigation model, input conventions, and user expectations. | Shared design system tokens (color, typography, spacing). Platform-native components and navigation. Same feature set, different embodiment. Users don't compare cross-platform — they compare to other apps on their platform. | Medium |
| **Breaking browser affordances in SPAs** | Non-functional back button, non-shareable URLs, disabled text selection, broken Cmd+click (open in new tab), scroll position not restored. | URL-driven state for all meaningful views. Standard `<a>` tags for navigation (not `<div onClick>`). Preserve scroll position on back. Support Cmd/Ctrl+click. Never disable text selection on content. | Medium |
| **Desktop-density UI on mobile** | Small tap targets, dense data tables, hover-dependent actions, tiny close buttons. Designed on desktop, "shipped" to mobile without adaptation. | Touch-first sizing (44pt minimum targets). Simplified information density. Actions surfaced via visible buttons, not hover. Consider whether the feature should exist on mobile at all — sometimes the right answer is to cut scope. | Medium |

## Named Patterns

### Web: Sidebar Navigation
**When to use**: Applications with 5+ top-level sections. Content-management tools, dashboards, admin panels, document editors.
**When NOT to use**: Simple marketing sites (<5 pages — use top nav). Mobile viewports (collapse to hamburger or bottom nav). Content-reading experiences (sidebar competes with content).
**Key details**: 240-280px wide (expanded), 56-72px (collapsed/icon-only). Persistent on desktop, collapsible on tablet, hidden on mobile. Active state clearly highlighted. Group related items with section headers. Scrollable independently of main content.

### Web: Command Palette
**When to use**: Tool-heavy web applications (editors, dashboards, dev tools). Power-user shortcut for deeply nested actions.
**When NOT to use**: Consumer-facing apps with simple navigation. Mobile (keyboard isn't primary input). Apps with <15 total actions.
**Key details**: Trigger: Cmd/Ctrl+K (de facto standard — Figma, VS Code, GitHub, Linear, Notion all use this). Fuzzy search across commands, navigation, and content. Recent items prioritized. Category grouping (Actions, Navigation, Settings). Keyboard-navigable results (arrow keys + Enter). Esc to close.

### iOS: Tab Bar
**When to use**: 3-5 top-level destinations in an iOS app. Each destination is a self-contained navigation stack.
**When NOT to use**: >5 destinations (use "More" tab reluctantly, or reconsider information architecture). Desktop/web (use sidebar). Single-purpose apps with one main view.
**Key details**: Fixed at bottom. 5 items maximum. Each tab has an icon + label (icon-only is less accessible). Badge for notification count. Active tab is tinted; inactive is gray. Each tab preserves its navigation stack state. Tab bar is visible during in-stack navigation (hides only for immersive content like video).

### iOS: Action Sheet
**When to use**: Presenting a set of actions related to the current context (share, delete, copy, move). Alternative to a dropdown/popover on iOS.
**When NOT to use**: Navigation (use navigation stack). Form input (use picker). Confirmation-only dialogs (use alert).
**Key details**: Slides up from bottom on iPhone, appears as popover on iPad. Always includes a Cancel action. Destructive actions styled in red. Group related actions. Max ~8 actions before it becomes overwhelming. System-provided via `UIAlertController` with `.actionSheet` style.

### Material: Bottom Sheet
**When to use**: Secondary content or actions that relate to the main view. Quick selections, filters, details panel. Standard (non-modal, can interact with content behind) or modal (blocks interaction).
**When NOT to use**: Primary navigation (use bottom navigation). Full content views (use full-screen). Simple yes/no decisions (use dialog).
**Key details**: Drag handle at top for grip affordance. Swipe down to dismiss. Snap points: collapsed (peek), half-expanded, fully expanded. Scrim behind modal sheets. Corner radius: 28dp (Material 3). Content scrollable within sheet. Respects edge-to-edge and safe areas.

### Material: Navigation Rail
**When to use**: Tablet and large-screen Android apps. 3-7 destinations. Alternative to bottom navigation when screen width allows.
**When NOT to use**: Phone-sized screens (use bottom navigation). >7 destinations (use navigation drawer). Web (use sidebar).
**Key details**: Vertical strip on the leading edge (left in LTR). 80dp wide. Icon + label for each destination. Optional FAB at top. Active indicator pill around selected icon (Material 3). Always visible — not collapsible like a web sidebar.

### Cross-Platform: Adaptive Component
**When to use**: When building a component that must work across platforms. Navigation, dialogs, inputs, selection controls.
**When NOT to use**: Platform-exclusive features (iOS-only, web-only). When platform-native component is clearly superior.
**Key details**: Define the component by its capability, not its form. "User selects one option from a list" → web: dropdown; iOS: picker wheel; Material: exposed dropdown menu. Share: design tokens (color, typography, spacing), component API/props, and behavior specification. Let platform implementation differ. Test on each platform with native users — cross-platform testing by developers misses convention violations that real users feel instantly.

### Web: Breadcrumbs
**When to use**: Deep hierarchical content (documentation, e-commerce categories, file systems). 3+ levels of nesting.
**When NOT to use**: Flat navigation (< 3 levels). Mobile viewports (truncate aggressively or replace with back button). Linear flows (wizards — use step indicator instead).
**Key details**: Show full path from root. Separator: "/" or ">". Current page is last item, not linked. Truncate middle items on overflow ("Home / ... / Category / Item"). Schema.org `BreadcrumbList` for SEO. Keyboard-navigable links.

### Web: Toast Notifications
**When to use**: Non-blocking feedback for completed actions. "Saved," "Copied," "Email sent." Low-severity status updates.
**When NOT to use**: Errors requiring user action (use inline error). Critical alerts (use modal). Multi-action feedback (use dedicated status area).
**Key details**: Position: bottom-right (web convention) or top-center (alternative). Auto-dismiss: 5-8s. Stack limit: 3 visible. Include undo action for reversible operations. Pause auto-dismiss on hover/focus. `role="status"` + `aria-live="polite"` for screen readers. Reduced motion: appear instantly, no slide animation.

### iOS: Pull-to-Refresh
**When to use**: Lists and feeds that display server-fetched content. Users expect this on any scrollable content that can be stale.
**When NOT to use**: Static content that doesn't change. Offline-only views. Non-scrollable views.
**Key details**: Native `UIRefreshControl` — always use the system component, never custom. Haptic feedback on trigger threshold. Loading indicator in the pull area. Content stays visible during refresh (don't blank it). Complete with brief success indicator or silent content update.

### Material: Snackbar
**When to use**: Brief feedback after an action. Equivalent of web toast but Material-specific. Can include single action (Undo, Retry).
**When NOT to use**: Persistent information. Errors requiring attention. Multiple simultaneous messages.
**Key details**: Positioned at bottom of screen, above FAB and bottom navigation. Single line preferred, two lines max. Duration: 4-10s. One action maximum (text button, not icon). Swipe to dismiss. Only one snackbar at a time — queue if multiple. `Scaffold` in Jetpack Compose manages snackbar state and positioning.

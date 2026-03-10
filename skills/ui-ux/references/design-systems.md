# Design Systems
**When to load**: Token definition, component API design, theming, variant strategy, composition patterns, system governance  |  **Skip if**: Individual design decisions not about the system itself, one-off page layouts

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Design tokens** — semantic layer between design intent and implementation values | Raw values (`#1a73e8`, `16px`) are meaningless without context. Tokens encode intent (`color.action.primary`, `spacing.md`). Change one token, update everywhere. | Three-tier minimum: global (raw values) -> semantic/alias (purpose-mapped) -> component (scoped). Never reference global tokens in components — always go through semantic. |
| 2 | **Composition over inheritance** — build up from primitives | Inheritance creates fragile hierarchies. A "PrimaryButton" that extends "Button" that extends "Clickable" breaks when any ancestor changes. (GoF, *Design Patterns*) | Small, composable primitives: `Box`, `Stack`, `Text`, `Icon`. Complex components compose these, not extend a base class. Slots/children over deep inheritance chains. |
| 3 | **API-first component design** — consumer ergonomics before internals | Components are used 100x more than they're built. A confusing API taxes every consumer. | Props should be obvious without docs. Sensible defaults for everything. Required props = essential only. Boolean props for binary states, enum props for multi-state. |
| 4 | **Single source of truth** — one token/component definition, many consumers | Duplication between Figma and code, or between web and mobile, guarantees drift. Drift erodes trust in the system. | Tokens defined once (JSON/YAML), transformed to all platforms (Style Dictionary, Tokens Studio). Component spec defines behavior; implementations derive from it. |
| 5 | **Gradual adoption** — systems must support incremental migration | Big-bang adoption fails. Teams need to migrate component-by-component. If the system can't coexist with legacy, it won't be adopted. | Namespace tokens and components to avoid collisions. Provide migration guides per component. Support both old and new patterns during transition. Deprecation warnings before removal. |

## Decision Tables

### Token Naming Strategy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Global/raw token layer | Descriptive of the value: `color.blue.500`, `spacing.16`, `font.size.400` | Semantic names at this layer (`color.primary` as global) | Global tokens are the palette — they describe what, not why. Mixing in purpose creates naming conflicts. |
| Semantic/alias token layer | Purpose-based: `color.action.primary`, `color.text.muted`, `spacing.component.gap` | Value-based names (`color.blue`, `spacing.medium`) | Semantic tokens decouple intent from value. Changing brand color means updating one alias, not hundreds of references. |
| Component token layer | Scoped to component: `button.color.bg.primary`, `input.border.color.default` | Global references in components (`color.blue.500` in button styles) | Component tokens enable per-component theming without side effects. Changing button blue doesn't change link blue. |
| Scale naming | T-shirt sizes (`xs, sm, md, lg, xl`) or numeric scale (`100-900`) | Arbitrary numbers (`1, 2, 3`) without clear progression | T-shirt sizes are intuitive but hard to extend (what's between `sm` and `md`?). Numeric scales extend cleanly. Pick one, commit. |
| Dark mode tokens | Same semantic names, different values: `color.surface.primary` resolves to `#fff` (light) / `#1a1a1a` (dark) | Separate token sets (`color.light.surface` / `color.dark.surface`) | Consumers reference one token. The system resolves the theme. Separate sets force consumers to handle theme switching. |
| Interactive state tokens | Explicit state tokens: `button.bg.default`, `button.bg.hover`, `button.bg.active`, `button.bg.disabled` | Deriving states via opacity or filter in components | Explicit state tokens give full control per theme. Auto-derived states (e.g., darken 10%) look wrong in dark mode and across brand colors. |

### Component Granularity

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Primitive layout (`Box`, `Stack`, `Flex`, `Grid`) | Include in system. These are the most-used components. Encode spacing scale, responsive props. | Skipping them ("just use CSS") | Without layout primitives, every team reinvents spacing. Primitives enforce the spacing scale automatically. |
| Simple composition (`Card`, `Alert`, `Badge`) | Include when 3+ teams need them. Otherwise, let teams compose from primitives. | Building every possible composition upfront | YAGNI. Premature components become maintenance burdens. Wait for demonstrated need. |
| Complex components (`DataTable`, `DatePicker`, `RichTextEditor`) | High investment — build only when the unstyled/headless option is insufficient. Consider wrapping a headless library (Radix, Headless UI, TanStack). | Building from scratch when headless libraries exist | Complex components take 10-50x the effort of simple ones. Headless libraries handle accessibility and interaction; you add styling. |
| Page-level templates | Not system components. Provide layout patterns (sidebar + main, dashboard grid) as documented recipes, not rigid components. | Template components with built-in data fetching or routing | Page templates couple the system to app architecture. Recipes guide, components constrain. |
| Utility components (`VisuallyHidden`, `Portal`, `FocusTrap`, `Slot`) | Include these early. They're invisible to users but critical infrastructure for accessible, well-composed components. | Reimplementing these utilities inside each complex component | `VisuallyHidden` alone appears in 10+ components. Centralizing prevents subtle inconsistencies in screen reader behavior. |

### Variant Strategy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| 2 visual states (primary/secondary, default/error) | Explicit enum: `variant="primary" | "secondary"` | Two separate components (`PrimaryButton`, `SecondaryButton`) | Separate components duplicate API surface. One component with variants keeps the interface unified. |
| 3-5 visual states | String union enum: `variant="filled" | "outlined" | "ghost" | "link"` | Nested booleans (`filled && !outlined && !ghost`) | Boolean combinatorics explode. `filled` + `ghost` = contradiction. Enums enforce mutual exclusivity. |
| Size variations | `size="sm" | "md" | "lg"` prop that scales padding, font-size, icon-size proportionally via tokens | Separate size props for each dimension (`paddingSize`, `fontSize`) | Sizes should be cohesive. A "small" button means small everything. Separate knobs create Frankenstein combinations. |
| Compound variants (size + color + state) | CSS-in-JS variant functions (Stitches-style `compoundVariants`) or utility-class composition (Tailwind `cva`) | Giant switch/case blocks mapping every combination | Compound variants declare the matrix explicitly. Imperative code for n x m combinations is unmaintainable. |
| Beyond 5 visual variants | Reconsider: likely multiple components, not one. Split by use case. | One component with 8 variants + 15 props | "God component" territory. If you need a decision tree to pick the right variant, the abstraction is wrong. |

### Theming Approach

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Web-only, modern browsers | CSS custom properties (vars). Theme by swapping property values on a root/provider element. | Runtime JS theme object passed through context | CSS vars cascade natively, no re-render. Zero JS cost. DevTools show computed values. |
| Web + React Native / multi-platform | Token-based theme object resolved at build time per platform. Style Dictionary or similar. | CSS vars (not supported in React Native) | Cross-platform requires platform-agnostic token definitions with platform-specific output. |
| White-labeling (customer-branded themes) | Semantic token layer with customer overrides. Restrict overridable surface (don't expose all 500 tokens — expose ~30 brand tokens). | Full token override (customers will break accessibility) | Constrained theming protects contrast ratios and spacing. Expose what's safe, lock what's structural. |
| Dark mode | Media query default (`prefers-color-scheme`) + manual toggle. Store preference in `localStorage`. Apply class/attribute before first paint (inline script in `<head>`). | Only media query (no override) or only manual (ignores system) | Respect system preference, allow override. The toggle should be discoverable (settings or header). Flash of wrong theme = inline script sets theme synchronously. |
| High contrast mode | Respect `prefers-contrast: more` media query. Increase border widths, boost text contrast, remove decorative transparency. | Ignoring forced-colors/high-contrast entirely | Windows High Contrast Mode and forced-colors override your styles. Test with `forced-colors: active` media query. Provide `forced-color-adjust: none` only where you explicitly handle it. |

### Component Documentation

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Props documentation | Auto-generate from TypeScript types. Supplement with usage examples, not just type signatures. | Manual prop tables that drift from code | TypeScript is the source of truth. Manual docs will be wrong within 2 releases. |
| Interactive examples | Live playground (Storybook, Ladle) showing all variants + states. Include edge cases: long text, empty, error, loading. | Only showing the happy path | Consumers need to see how the component handles real content. Edge cases are where designs break. |
| Do/Don't guidance | Visual examples of correct vs incorrect usage. Explain *why* each anti-pattern is wrong. | Rules without reasoning ("Don't use red buttons") | Without reasoning, contributors can't apply judgment to novel situations. They either follow blindly or ignore. |
| Accessibility notes | Per-component: required ARIA attributes, keyboard behavior, screen reader announcements. Link to WAI-ARIA APG pattern. | "This component is accessible" without specifics | Vague claims are unverifiable. Specific notes enable testing and catch regressions. |

### Versioning & Release Strategy

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Breaking component API change | Major version bump. Deprecation warning in N-1. Migration guide + codemod. Minimum 1 release cycle overlap. | Silent breaking changes in minor/patch | Consumers can't upgrade if they can't trust semver. Trust = adoption. |
| New component addition | Minor version bump. No existing code breaks. Document with examples. | Waiting for "complete" before releasing | Ship early, iterate. Real usage reveals API problems faster than internal review. |
| Token value change (e.g., color tweak) | Patch if subtle. Minor if noticeable. Communicate via changelog with visual diff. | Changing tokens without any release notes | A "small" color change can break contrast ratios in consumer applications. Always document. |
| Multi-package monorepo | Independent versioning per package (Lerna/Changesets). Peer dependency ranges. | Lockstep versioning (all packages bump together) | Lockstep forces unnecessary upgrades. Independent versions let consumers update what they need. |

## Platform Notes

**Web (primary)**: CSS custom properties are the theming primitive. `:root` for global, `[data-theme="dark"]` for mode switching. Container queries (`@container`) enable component-level responsive behavior independent of viewport. `@layer` for cascade control in multi-library environments. CSS `color-mix()` and relative colors reduce token count — derive hover/active states from a single base color. `:has()` selector enables parent styling based on child state without JS.

Tree-shaking: components must be individually importable. `import { Button } from '@system/react'` should not pull in `DataTable`. Barrel files (`index.ts`) can break tree-shaking — use explicit re-exports or `sideEffects: false` in `package.json`.

**Mobile reference**: Design tokens export to iOS (Swift/UIKit constants) and Android (XML resources, Compose theme). Platform conventions differ — iOS uses system blur/transparency, Android uses Material elevation/shadow. Don't force web patterns into native; adapt the semantic intent. React Native: use a theme provider with typed tokens. StyleSheet.create for performance; avoid inline styles.

Native component wrapping: wrap platform components (iOS `UIDatePicker`, Android `MaterialDatePicker`) rather than building custom. Users expect platform-native behavior. Only build custom when the platform control is genuinely insufficient.

**Desktop reference**: Electron/Tauri apps can use web tokens directly. Native desktop (AppKit, WPF) needs platform-specific token output. Higher information density expected — compact variants as default, not optional. Desktop users expect right-click menus, keyboard shortcuts, and multi-window support — the design system should provide patterns for these.

Performance: desktop apps run on varied hardware. Test on low-spec machines. Heavy JS-in-CSS solutions that work on M3 MacBooks may stutter on 5-year-old Windows laptops. CSS-first styling is more resilient across hardware tiers.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| **God components** (one component that does everything via 20+ props) | Impossible to document, test, or understand. Every change risks side effects. | Split by use case. `Dialog` vs `AlertDialog` vs `Sheet` vs `Popover` — related but distinct. Max ~10 props per component. | Common |
| **Prop explosion** (>10 props, boolean soup) | `<Button primary large outline disabled loading iconLeft iconRight fullWidth>` — consumers can't remember the API. | Reduce to essentials: `variant`, `size`, `disabled`, `loading`, `children`. Compound components for complex layouts. | Very common |
| **Tokens without semantic layer** (components reference `blue-500` directly) | Theme changes require find-and-replace across every component. Dark mode becomes a massive refactor. | Add alias layer: `blue-500` -> `color.action.primary` -> components use alias. One indirection solves the problem permanently. | Common |
| **Breaking API changes without migration path** | Teams can't upgrade if every release breaks their code. Trust erodes. Adoption stalls. | Semantic versioning. Deprecation warnings for 1+ versions before removal. Codemods for automated migration. Changelog with upgrade guide. | Moderate |
| **Premature abstraction** (building components nobody asked for) | Unused components rot. They don't get tested with real use cases. When someone finally needs them, they don't fit. | Build when 3+ consumers need it (rule of three). Before that, let teams copy-paste and discover the right API organically. | Common |
| **Figma-code drift** (Figma components diverge from implementation) | Designers spec using Figma components. If they don't match code, every handoff is wrong. | Automate sync: Figma -> tokens -> code. Or: code as source of truth, Figma generated from tokens. Regular audits. | Very common |
| **Styling leakage** (component styles bleed into or are overridden by consumer styles) | Tight coupling between system and consumer styles. Upgrades break consumer layouts. | Scope styles via CSS modules, shadow DOM, or CSS-in-JS isolation. Never use global selectors in components. | Common |
| **Missing loading/error/empty states** in component API | Consumers reinvent these states per usage. Inconsistent skeleton shapes, error messages, empty prompts. | Every data-dependent component should accept `loading`, `error`, and `empty` states — or render them internally when wired to data. | Common |

## Named Patterns

### Atomic Design (Quarks -> Atoms -> Molecules -> Organisms -> Templates -> Pages)
**When to use**: Establishing initial system taxonomy. Communicating component hierarchy to designers and developers. Large systems with clear compositional layers.
**When NOT to use**: As rigid implementation structure (don't create `atoms/` `molecules/` `organisms/` folders — the boundaries blur). Small systems where the overhead isn't justified.
**Key decisions**: Use as mental model, not file structure. Atoms: tokens + single-element components (`Button`, `Input`, `Badge`). Molecules: small compositions (`SearchField` = Input + Button). Organisms: complex sections (`Header`, `DataTable`). Templates/Pages are app-level, not system-level.

### Compound Components
**When to use**: Components with multiple child slots that need to share implicit state. `<Tabs>`, `<Accordion>`, `<Menu>`, `<Select>`. Parent provides context, children consume.
**When NOT to use**: Simple components where a single render prop or children prop suffices. When the parent-child contract is too implicit (prefer explicit props for simple cases).
**Key decisions**: Use React Context (or framework equivalent) for shared state. Export sub-components as named exports: `Tabs.Root`, `Tabs.List`, `Tabs.Trigger`, `Tabs.Content` (Radix pattern). Enforce valid composition via TypeScript types where possible.

### Render Props / Slots
**When to use**: When the consumer needs control over what renders, but the component owns the behavior/state. Custom item rendering in lists. Custom trigger rendering in popups.
**When NOT to use**: When composition via children is sufficient. Render props are harder to read — use only when children can't solve the problem.
**Key decisions**: Slot pattern (Vue, Web Components, Svelte) vs render props (React). Named slots for multi-region customization. Provide reasonable defaults for all slots — slots are escape hatches, not required configuration. Type the render prop signature for consumer safety.

### Token Tiers (Global -> Alias -> Component)
**When to use**: Any design system with theming requirements. Multi-brand or dark-mode support. Systems serving 3+ consuming applications.
**When NOT to use**: Single-product, single-theme, small team. Two tiers (global -> component) may suffice. Add alias when you need theme switching.
**Key decisions**: Global tier: exhaustive palette (every color, every spacing value). Alias tier: curated subset with purpose (action, surface, text, border). Component tier: scoped references (`button.bg` -> alias). Tokens flow down, never up or sideways. Strict dependency direction prevents circular references.

### Headless Component Pattern
**When to use**: When you need full styling control but don't want to reimplement complex behavior (focus management, keyboard navigation, ARIA, state machines). Radix UI, Headless UI, React Aria, Ark UI.
**When NOT to use**: When an existing styled library (MUI, Ant, Chakra) already matches your design language closely enough. Headless requires more styling work upfront.
**Key decisions**: Wrapper component in your system that composes the headless primitive + your tokens. Consumers see your API, not the headless library's API. This also makes swapping the underlying library possible without breaking consumers. Pin the headless library version and test upgrades in isolation.

### Polymorphic Component (`as` prop)
**When to use**: When a styled component needs to render as different HTML elements or other components. `<Button as="a" href="/link">` renders a styled anchor. `<Text as="h2">` renders a heading with text styles.
**When NOT to use**: When the semantic difference changes behavior significantly (a button and a link have different interaction models). When TypeScript complexity of `as` outweighs the benefit.
**Key decisions**: Type the `as` prop to inherit the target element's props (`ComponentPropsWithoutRef<E>`). Restrict `as` to a set of valid elements if polymorphism is limited. Consider `asChild` pattern (Radix) as alternative — merges props onto a single child element, avoiding the `as` type complexity.

### State Machine Components
**When to use**: Components with complex state transitions: multi-step forms, media players, drag-and-drop, async data fetching with retry. Where the number of states exceeds what boolean flags can express cleanly.
**When NOT to use**: Simple toggle/binary state components. When the overhead of a state machine library isn't justified by the complexity.
**Key decisions**: Use XState, Zag, or a custom `useReducer` with explicit state types. Define all valid states and transitions upfront — impossible transitions become type errors. Expose state to consumers for conditional rendering (`state.matches('loading')`). State machines make components testable by enumerating all reachable states.

### Design System Governance
**When to use**: Any system with multiple contributors (designers + developers across teams). When the system is past its initial creation phase and needs to scale sustainably.
**When NOT to use**: Solo projects or very small teams where governance overhead exceeds benefit.
**Key decisions**: Contribution model: open (anyone contributes) vs federated (team reps) vs centralized (core team only). RFC process for new components or breaking changes. Visual regression testing (Chromatic, Percy) on every PR. Accessibility audit gate — components must pass automated + manual a11y checks before merge. Regular office hours or design system syncs to surface consumer pain points.

### Controlled vs Uncontrolled Components
**When to use**: Any component that manages internal state (inputs, toggles, accordions, tabs). The system must decide whether the consumer or the component owns the state.
**When NOT to use**: Purely presentational components (Badge, Avatar, Divider) that have no state.
**Key decisions**: Support both modes: uncontrolled (default, component manages state via `defaultValue`) and controlled (consumer passes `value` + `onChange`). Uncontrolled is easier for simple cases. Controlled is required for form libraries, undo/redo, and syncing across components. Implementation: if `value` prop is defined, use it; otherwise use internal state. Never mix — a component should be consistently controlled or uncontrolled during its lifecycle. Warn in dev mode if a component switches from uncontrolled to controlled (React pattern).

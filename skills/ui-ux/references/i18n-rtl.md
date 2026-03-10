# i18n & RTL
**When to load**: Internationalization decisions, right-to-left layout, text expansion, localization, cultural considerations  |  **Skip if**: Single-language English-only product with no plans for localization

> **Scope boundary**: This file covers design-level i18n and RTL concerns. For implementation details (ICU library APIs, locale detection, server-side rendering), delegate to `external-research` or `codebase-investigation`. For accessibility in multilingual contexts, also load `accessibility-design`.

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Design for text expansion from the start** | English is compact. Translations expand: German +30-35%, Finnish +30-40%, French +15-20%. Very short strings (1-3 words) can expand 200-300%. IBM's guideline: design for 1.5x expansion minimum. | Button widths, column layouts, navigation, labels — all must accommodate expansion without truncation or layout break. Fixed-width containers are i18n hostile. |
| 2 | **Use CSS logical properties exclusively** | Logical properties (`inline-start`, `inline-end`, `block-start`, `block-end`) automatically mirror for RTL. Physical properties (`left`, `right`, `top`, `bottom`) require manual RTL overrides. | Every spacing, alignment, positioning, and border decision. `margin-inline-start` not `margin-left`. `border-inline-end` not `border-right`. `text-align: start` not `text-align: left`. |
| 3 | **RTL is layout mirroring, not text reversal** | Entire layout mirrors: nav right-to-left, progress bars right-to-left, reading flow right-to-left. But some elements do NOT flip: phone numbers, timestamps, mathematical expressions, media playback controls, checkmarks, LTR-embedded content. | Every layout component needs a mirroring decision. Some icons need directional variants. Asymmetric designs need RTL-specific review. |
| 4 | **Cultural variation is not optional** | Colors: red = danger (West) / prosperity (China) / mourning (South Africa). Icons: mailbox shape varies by country, owl = wisdom (West) / bad luck (parts of Asia). Gestures: thumbs up is offensive in some Middle Eastern and West African cultures. | Icon choices, color semantics, metaphors, imagery — all need cultural review for target markets. Universal symbols are rarer than assumed. |
| 5 | **String concatenation is a localization bug** | `"You have " + n + " items"` breaks in languages with different word order (Japanese: items come before count), gender agreement (French: masculine/feminine), or number forms (Arabic: dual form). | Use ICU MessageFormat or equivalent. All user-facing strings externalized. Translators need full sentences with context, not fragments. |
| 6 | **Locale affects more than language** | Same language, different locale: en-US (mm/dd/yyyy, $1,234.56) vs en-GB (dd/mm/yyyy, 1,234.56). Number separators, date formats, currency symbols, address formats, name order — all locale-dependent. | Never hardcode formats. Use `Intl` APIs or equivalent locale-aware formatters. Test with locale that differs from language (e.g., Arabic with Western numerals). |

## Decision Tables

### CSS Property Migration

| Physical property | Logical equivalent | Notes |
|------------------|--------------------|-------|
| `margin-left` / `margin-right` | `margin-inline-start` / `margin-inline-end` | Core migration. Covers most spacing. |
| `padding-left` / `padding-right` | `padding-inline-start` / `padding-inline-end` | Same pattern as margin. |
| `border-left` / `border-right` | `border-inline-start` / `border-inline-end` | Includes border-radius: `border-start-start-radius` etc. |
| `left` / `right` (positioning) | `inset-inline-start` / `inset-inline-end` | For absolutely positioned elements. |
| `text-align: left` / `right` | `text-align: start` / `end` | Critical for text blocks. |
| `float: left` / `right` | `float: inline-start` / `inline-end` | Limited browser support — may need fallback. Check caniuse. |
| `margin-top` / `margin-bottom` | `margin-block-start` / `margin-block-end` | Not RTL-critical but consistent with logical model. Matters for vertical writing modes (CJK). |

### Elements That Do and Don't Mirror in RTL

| Element | Mirror? | Rationale |
|---------|---------|-----------|
| Navigation flow | Yes | Reading direction reversal. Nav items flow right-to-left. |
| Sidebar position | Yes | Left sidebar becomes right sidebar. |
| Progress bars, sliders | Yes | Progress reads start-to-end in reading direction. |
| Breadcrumbs, pagination | Yes | Sequence follows reading direction. |
| Checkmarks, success icons | No | Universal symbol, not directional. |
| Media controls (play, rewind) | No | ISO standard, direction-independent by convention. |
| Phone numbers, digits | No | Always LTR. Use `dir="ltr"` on phone number elements. |
| Timestamps and dates | No | Numeric content. Locale affects format, not direction. |
| Charts and graphs | Depends | X-axis may reverse for time series. Y-axis stays. Evaluate per chart type. |
| Directional icons (arrows, chevrons) | Yes | Back arrow points right in RTL. Forward arrow points left. |
| Logos and branding | No | Brand identity is fixed. Never mirror logos. |
| Images and photos | No | Content images are not directional. Exception: illustrations showing reading/writing may need RTL variants. |

### Text Expansion by Language

| Language | Avg expansion (from English) | Peak expansion (short strings) | Design implication |
|----------|------------------------------|-------------------------------|-------------------|
| German | +30-35% | +200% for 1-3 word labels | Widest Latin-script language. Primary test case. |
| Finnish | +30-40% | +200%+ (compound words) | Long compound words. Test single-word overflow. |
| French | +15-20% | +100% for short labels | Moderate. Common target — good first test. |
| Spanish | +20-25% | +100% | Similar to French. Latin America = large market. |
| Japanese | -10-30% (shorter) | CJK characters are wider per-character but strings shorter | Character width matters more than string length. Font metrics differ. |
| Arabic | -20-30% (shorter) | But right-aligned, and connected script needs more horizontal space per character | Shorter strings but RTL layout. Test with real Arabic, not pseudo. |
| Chinese (Simplified) | -30-50% (shorter) | Very compact | Shortest translations. Don't optimize layout for Chinese compactness — it will break in German. |

### String Handling

| Situation | Recommended | Avoid | Why |
|-----------|-------------|-------|-----|
| Pluralization | ICU MessageFormat: `{count, plural, one {# item} other {# items}}` | `count + " item" + (count !== 1 ? "s" : "")` | Many languages have 2-6 plural forms (Arabic has 6). English plural rules don't generalize. |
| Gendered output | ICU `select`: `{gender, select, female {She} male {He} other {They}}` | Hardcoded pronouns | Many languages gender nouns, adjectives, verbs differently. |
| Date/time | `Intl.DateTimeFormat` with locale | `date.getMonth() + "/" + date.getDate()` | Month/day order, separator, and calendar system vary. |
| Numbers | `Intl.NumberFormat` with locale | Template literals with hardcoded separators | Decimal: `.` (US) vs `,` (EU). Thousands: `,` (US) vs `.` (EU) vs ` ` (FR). |
| Currency | `Intl.NumberFormat` with `style: 'currency'` and locale | `"$" + amount` | Symbol position, spacing, decimal rules vary. EUR: 1.234,56 EUR (DE) vs EUR 1,234.56 (IE). |
| Sort order | `Intl.Collator` | `Array.sort()` with default comparison | Alphabetical order varies. Swedish: a-z then a-with-ring, a-with-dots. German: umlauts sort differently in phone books vs dictionaries. |

### Icon Culturalization Decisions

| Icon category | Approach | Examples |
|--------------|----------|---------|
| Universal symbols | Keep as-is, no variants needed | Plus, minus, close (X), search (magnifier), settings (gear) |
| Directional icons | Mirror for RTL via `transform: scaleX(-1)` or separate asset | Arrows, chevrons, reply, forward, undo/redo, external link |
| Culture-specific objects | Replace or abstract for target markets | Mailbox (US-style vs European slot), dollar sign, church/religious buildings |
| Hand gestures | Avoid or use with cultural review | Thumbs up (offensive in Middle East/W. Africa), OK sign (offensive in Brazil), pointing finger |
| Text-containing icons | Localize text within icon or use text-free variant | Icons with "NEW" badge, "A/Z" sort icons, keyboard shortcut hints |
| Animal/nature metaphors | Verify cultural meaning per market | Owl (wisdom vs bad luck), dragon (power vs evil), bat (fear vs fortune) |

### Address and Name Format Variation

| Element | Variation | Design implication |
|---------|-----------|-------------------|
| Name order | Given-Family (Western) vs Family-Given (CJK, Hungarian) | Don't assume "First name / Last name." Use "Given name / Family name" or single "Full name" field. |
| Address lines | US: street, city, state, zip. UK: adds county. Japan: prefecture before city, building after. | Don't hardcode address field order. Use locale-aware address forms (Google's libaddressinput). |
| Phone numbers | Country code, area code length, grouping all vary. | Single field with country code selector. Format display only, not input. |
| Postal codes | 5 digits (US), alphanumeric (UK/Canada), 7 digits (Japan) | Don't validate format against US rules. Use locale-specific validation or accept freeform. |

## Platform Notes

**Web (primary)**:
- `dir="rtl"` on `<html>` element. CSS logical properties handle layout mirroring automatically. `dir="auto"` for user-generated content.
- `lang` attribute on `<html>` and on any element with a different language. Required for screen readers, hyphenation, and spell checking.
- `Intl` API coverage is excellent in modern browsers. Polyfill for IE11 if still needed (unlikely post-2024).
- CSS `writing-mode` for vertical text (CJK). `writing-mode: vertical-rl` for traditional Chinese/Japanese. Rare requirement but logical properties handle it.
- Font stacks: include CJK fonts (Noto Sans CJK, system CJK fonts), Arabic fonts (Noto Sans Arabic), etc. `system-ui` covers many cases but not all.
- `hyphens: auto` with correct `lang` attribute for automatic hyphenation in supported languages. Helps with text expansion in constrained containers.
- Web fonts: CJK fonts are 5-20MB. Use `unicode-range` subsetting or system fonts for CJK. Latin subset for initial load, full charset on demand.

**Mobile**:
- iOS: `NSLocalizedString` and `.stringsdict` for pluralization. Auto Layout handles RTL with leading/trailing constraints (not left/right).
- Android: RTL support via `android:supportsRtl="true"`. Use `start`/`end` instead of `left`/`right` in layouts.
- Dynamic Type and font scaling interact with text expansion — test both simultaneously. A German translation at 200% text size is worst case.
- App Store requires separate screenshots per locale. Marketing text localization is often overlooked — it's the first impression.

**Desktop**:
- Electron/web-based: same rules as web.
- Native: platform RTL APIs (Win32 mirroring, macOS `userInterfaceLayoutDirection`).
- Input methods (IME) for CJK: ensure text fields handle composition events. IME popups must not be occluded by autocomplete or dropdowns.
- Keyboard shortcuts: Ctrl+B for bold works in English but the mnemonic is meaningless in other languages. Show actual key, not the mnemonic letter.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| Hardcoded strings in source code | Cannot be extracted for translation. Invisible to translation tooling. Creates maintenance nightmare. | Externalize all user-facing strings to resource files/catalogs from day one. Key format: `component.context.description`. | Very common |
| Fixed-width containers for text | German translation of "Save" is "Speichern" (+67%). Fixed 80px button truncates or overflows. | `min-width` + `padding` instead of fixed `width`. Allow buttons and labels to grow. Test with pseudolocalization. | Very common |
| Icon-only buttons without text labels | Icons don't translate across cultures. Meanings are culturally dependent. Floppy disk = save (for how long?). Hamburger menu is not universally recognized. | Icon + visible text label for primary actions. If space-constrained, add `aria-label` and tooltip — but visible text is always better for i18n. | Common |
| `text-align: left` and `float: left` in CSS | Physical direction. Doesn't flip for RTL. Requires separate RTL stylesheet or overrides. | `text-align: start`, `float: inline-start`. Migrate entire codebase to logical properties. One-time cost, permanent benefit. | Very common |
| Assuming text direction from language | User content may contain mixed-direction text (Hebrew sentence with English brand name). | Use `dir="auto"` on user-generated content containers. Unicode BiDi algorithm handles most cases, but explicit `dir` helps. | Moderate |
| Translating UI with machine translation only | MT misses context, register, terminology consistency, and cultural nuance. UI strings are short and context-dependent — MT's worst case. | Professional translators with context (screenshots, comments). MT as starting draft, human review required. | Moderate |
| Formatting dates/numbers client-side without locale | Server sends "01/02/2026." Is that Jan 2 or Feb 1? Ambiguous without locale context. | Always format at display time using user's locale. Transfer dates as ISO 8601. Numbers as raw values. | Common |
| Concatenated strings for sentences | `"Welcome, " + name + "! You have " + count + " new messages."` — word order, gender agreement, and plural forms all vary by language. | Single MessageFormat string: `"Welcome, {name}! You have {count, plural, one {# new message} other {# new messages}}."` | Very common |

## Named Patterns

### Pseudo-Localization
**When to use**: During development, before real translations are available. Catches i18n bugs early.
**When NOT to use**: Not a substitute for testing with real translations in target languages.
**How**: Replace ASCII characters with accented equivalents (a→a, e→e). Pad strings to simulate expansion (~30-40%). Wrap in brackets [like this] to catch concatenation and hardcoded strings. Tools: pseudo-locale libraries, `Intl` with pseudo-locale.

### CSS Logical Properties Migration
**When to use**: Any project that may ever support RTL, or as general best practice.
**When NOT to use**: Never — logical properties are strictly better. Even LTR-only projects benefit from consistency and future-proofing.
**Approach**: Lint rule to flag physical properties. Automated codemod for bulk migration. Incremental: start with new code, migrate existing on touch. Browser support is excellent (95%+ global, caniuse 2024).

### Mirror-Aware Icon System
**When to use**: Icon systems in products supporting RTL languages.
**When NOT to use**: Icons that are inherently non-directional (checkmark, plus, close X).
**Categories**: (1) Icons that must mirror: arrows, chevrons, reply, forward, undo/redo, text alignment, list indent. (2) Icons that must NOT mirror: media controls, clocks, search magnifier, checkmarks, hearts. (3) Icons that need entirely different variants: directional illustrations, hand gestures.

### External String Catalog
**When to use**: Any multi-language product. Set up before writing the first user-facing string.
**When NOT to use**: Internal tools with zero chance of localization (rare — be honest about this).
**Structure**: One catalog per language. Key = semantic identifier (`checkout.button.submit`), not English text. Include context comments for translators. Support pluralization (ICU), gender, and interpolation natively. Tooling: i18next, FormatJS (react-intl), Fluent, platform-native (.strings, .xml).

### Locale-Aware Number and Date Formatting
**When to use**: Any display of numbers, dates, times, or currency to users.
**When NOT to use**: Internal logging, API payloads, or data storage (use ISO 8601 / raw numbers).
**Implementation**: Browser `Intl` API is the standard. `Intl.DateTimeFormat`, `Intl.NumberFormat`, `Intl.RelativeTimeFormat`. Server-side: ICU4J (Java), ICU4C (C++), or equivalent. Never build format strings manually. Always derive from locale.

### Bidirectional Text Handling
**When to use**: Any UI accepting or displaying user-generated content in a multilingual product.
**When NOT to use**: Controlled content where language is known and single-direction.
**Rules**: (1) `dir="auto"` on UGC containers — lets Unicode BiDi algorithm determine direction from first strong character. (2) Isolate embedded opposite-direction text with `<bdi>` element or `unicode-bidi: isolate`. (3) Phone numbers, URLs, file paths: always `dir="ltr"` regardless of surrounding direction. (4) Form inputs: `dir="auto"` to match user's input direction.

### Translation Context System
**When to use**: Any string externalization workflow. From the first externalized string.
**When NOT to use**: Internal-only debug strings that will never be translated.
**Structure**: Every string key gets: (1) Developer comment explaining where the string appears and what it means (not just the English text). (2) Screenshot or screenshot ID showing the string in context. (3) Character limit if the string appears in a constrained container. (4) Placeholder descriptions: `{count}` = "number of items in cart." Translators without context produce incorrect translations — context is not optional, it's infrastructure.

### RTL Testing Protocol
**When to use**: Before shipping any RTL language support. During RTL development sprints.
**When NOT to use**: LTR-only products (but consider: will you ever add RTL?).
**Steps**: (1) Set `dir="rtl"` on root element and verify full layout mirror. (2) Check every directional icon (arrows, chevrons, navigation). (3) Verify phone numbers, timestamps, and code snippets remain LTR. (4) Test with real Arabic or Hebrew text, not just mirrored English. Connected Arabic script has different width characteristics. (5) Test bidirectional content: Arabic paragraph containing English brand names, URLs, code. (6) Verify form inputs accept and display RTL text correctly. (7) Test with a native RTL reader if possible — mirroring correctness is not the same as reading comfort.

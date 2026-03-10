# Content Design
**When to load**: Labels, error messages, empty states, microcopy, onboarding text, CTAs  |  **Skip if**: Visual layout or interaction questions without text content decisions

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Front-loading** — most important word first | Users scan F-pattern (Nielsen Norman). First 2-3 words carry ~80% of message comprehension. Truncation on mobile kills trailing context. | Label/CTA word order. "Save changes" not "Changes will be saved". "Delete account" not "Account deletion". |
| 2 | **Active voice, specific verbs** | Active voice is 20-30% shorter, faster to parse, unambiguous about the actor. Specific verbs set correct expectations. | "Save document" not "Document saving functionality". "Delete 3 items?" not "Items will be removed". Every button should be a verb phrase. |
| 3 | **Empty states are onboarding** | Zero-content views are the user's first impression of a feature. They set expectations, teach the data model, and prompt first action. | Empty state = illustration (optional) + explanation + single primary CTA. Never just "No items found." |
| 4 | **Error messages: what happened + what to do** | Users need orientation (what broke) and agency (what to try). Missing either causes helplessness or repeated failure. | Format: "{What went wrong}. {What to do next}." e.g. "Couldn't save — connection lost. Changes saved locally. Try again when online." |
| 5 | **Consistent terminology** | One concept = one term across the entire product. Synonyms create cognitive overhead and break searchability. | Maintain a product glossary. "Remove" vs "Delete" vs "Trash" — pick one and enforce it. Audit quarterly. |

## Decision Tables

### Label vs Placeholder vs Help Text

| Input type | Label | Placeholder | Help text | Why |
|-----------|-------|-------------|-----------|-----|
| Any required field | Always visible | Optional example format only | If constraints aren't obvious | Labels disappear in placeholders — accessibility fail (WCAG 1.3.1). |
| Complex format (phone, date) | Yes | Show format: "555-123-4567" | Explain if non-obvious | Placeholder as format hint reduces errors ~25% (Baymard Institute). |
| Obvious field (email, name) | Yes | Optional, brief | Skip | Redundant help text adds noise. |
| Search box | Optional (icon sufficient) | "Search {what}" | Skip | Search is a learned pattern — icon is the label. |
| Field with constraints | Yes | Skip or format only | State constraints: "8+ characters, one number" | Help text persists; placeholder vanishes on focus. Constraints must be visible during input. |

### Error Message Format

| Scope | Format | Placement | Dismiss |
|-------|--------|-----------|---------|
| Single field | Inline text below field | Adjacent to the field, red/destructive color | Clears on valid input |
| Multiple fields (form submit) | Summary banner at form top + inline per field | Top of form, scroll to first error | Clears when all fixed |
| System/network | Toast or banner | Top of viewport, non-blocking | Manual dismiss or auto after 8-10s |
| Destructive/irreversible | Modal confirmation | Center screen, blocks interaction | Requires explicit choice |
| Background process | Status area or notification | Persistent status indicator | Manual acknowledge |

### CTA Text Patterns

| Context | Pattern | Example | Avoid |
|---------|---------|---------|-------|
| Primary action | Verb + object | "Save changes", "Create project" | "Submit", "OK", "Yes" |
| Destructive action | Specific verb + object | "Delete account", "Remove member" | "Confirm", "Proceed" |
| Navigation | Destination-oriented | "Go to settings", "View report" | "Click here", "Next" |
| Confirmation dialog | Mirror the action | "Delete" / "Keep" (not "OK" / "Cancel") | Generic "Yes" / "No" |
| Upgrade/upsell | Benefit-first | "Get 10 GB storage" | "Upgrade now", "Buy" |

### Confirmation Dialog Wording

| Risk level | Title | Body | Actions |
|-----------|-------|------|---------|
| Low (reversible) | "Remove from list?" | "You can add it back anytime." | "Remove" / "Cancel" |
| Medium | "Delete 3 files?" | "They'll be moved to Trash for 30 days." | "Delete" / "Keep" |
| High (irreversible) | "Permanently delete account?" | "All data will be erased. This can't be undone." | "Delete my account" / "Keep account" |
| Critical (cascading) | "Delete workspace '{name}'?" | "This will delete all projects, files, and member access. Type '{name}' to confirm." | Text input + disabled "Delete" / "Cancel" |

### Notification & Status Text

| Event type | Tone | Pattern | Duration | Example |
|-----------|------|---------|----------|---------|
| Success (action completed) | Confirming, brief | Past tense verb + object | Auto-dismiss 3-5s | "Changes saved" / "Message sent" |
| Info (passive update) | Neutral, factual | Statement of what changed | Auto-dismiss 5s or persistent | "2 new comments" / "Updated 5 min ago" |
| Warning (potential issue) | Advisory, not alarming | State risk + preventive action | Persistent until dismissed or resolved | "Storage almost full. Free up space or upgrade." |
| Error (action failed) | Honest, solution-focused | What failed + recovery action | Persistent — manual dismiss | "Couldn't send message. Check connection and retry." |
| Progress (ongoing action) | Present continuous | "-ing" verb + optional estimate | Until complete | "Uploading... 3 of 7 files" / "Saving..." |

### Onboarding & First-Run Text

| Stage | Goal | Text approach | Example |
|-------|------|--------------|---------|
| Welcome | Orient, build confidence | Short, warm, action-oriented. One sentence about what they can do, one CTA. | "Welcome to Acme. Create your first project to get started." |
| Feature discovery | Teach a capability | Point to the feature + one-line benefit. Dismissible. | "Tip: Drag columns to reorder your board." |
| Empty feature area | Guide first use | Explain what will appear here + how to populate it | "Your notifications will appear here. You'll be notified when someone mentions you." |
| Milestone / completion | Reward, momentum | Acknowledge achievement + suggest next step | "First project created. Invite your team to collaborate." |
| Returning user (after absence) | Re-orient, show changes | Brief changelog or "what's new" — dismissible, scannable | "New: Dark mode is here. Try it in Settings." |

## Platform Notes

### Web (primary)
- **Sentence case** for all UI text (buttons, labels, headings, menus). Title Case only for proper nouns and product names.
- **No periods** on single-sentence labels, button text, headings. Periods on multi-sentence body text.
- **Oxford comma** in lists. Contractions allowed for conversational tone ("can't", "won't") — avoid in legal/formal contexts.
- **Link text**: descriptive, never "click here". Screen readers read links out of context (WCAG 2.4.4).
- **Numbers**: Use digits for counts ("3 items"), spell out for prose ("one of the best"). Consistent formatting for dates, times, currencies — use locale-aware formatting.
- **Truncation rules**: Never truncate CTAs, error messages, or status text. Truncate only secondary content (descriptions, previews) with "..." and a "more" affordance.

### Mobile
- Shorter labels — screen real estate is scarce. "Save" may replace "Save changes" if context is clear.
- Touch target labels: minimum 44x44px tap area even if text is shorter.
- Error messages must be visible without scrolling — anchor to the relevant field.
- Bottom-sheet confirmations preferred over modals — easier thumb reach, feels less intrusive.
- Abbreviate carefully: "Mon" for "Monday" is fine. "Del" for "Delete" is not — ambiguous and feels broken.

### Desktop
- Tooltips work (hover is available). Use for supplementary info, not critical instructions.
- Keyboard shortcuts can be shown in tooltips: "Save (Ctrl+S)".
- More horizontal space — labels can sit beside inputs (not just above).
- Right-click context menus: verb-first labels ("Copy link", "Open in new tab"), grouped logically, destructive actions at bottom with separator.

### Cross-Platform Consistency
- Same concept, same term everywhere. "Delete" on web = "Delete" on mobile = "Delete" on desktop. Don't alias per platform.
- Adapt length, not meaning. Mobile may shorten "Save changes" to "Save" — but "Archive" should never become "Hide" on a different platform.
- Platform-specific terms: use "Tap" on mobile, "Click" on desktop, or avoid both with imperative verbs ("Select", "Choose").
- Date/time: always locale-aware. "Jan 15" (US) vs "15 Jan" (UK). Use relative time for recent events ("2 hours ago"), absolute for older ("Jan 15, 2025").

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| Jargon in user-facing text | "401 Unauthorized", "null reference" — users don't speak developer. | Translate to outcome: "You've been signed out. Sign in again to continue." | Very common |
| Blame-the-user errors | "Invalid input", "Wrong format" — accusatory and unhelpful. | State what's needed: "Enter an email address like name@example.com." | Very common |
| Empty states with no guidance | "No results" dead-ends the user. | Add explanation + action: "No projects yet. Create your first project to get started." | Common |
| Inconsistent terms for same action | "Remove" in one place, "Delete" in another, "Trash" in a third. | Audit terminology. One term per concept. Document in glossary. | Common |
| Walls of text in tooltips | Tooltips are 1-2 sentences max. Hover-dependent = can't be read on mobile. | Move long content to help text, collapsible section, or linked docs page. | Moderate |
| Placeholder-as-label | Placeholder vanishes on focus — users forget what the field was for. Fails WCAG 1.3.1. | Always use a visible label. Placeholder is supplementary only. | Very common |
| Truncating critical text | Ellipsis on error messages, CTAs, or status indicators hides essential info. | Rewrite shorter. If still too long, wrap — don't truncate. | Moderate |
| "Are you sure?" without specifics | "Are you sure you want to continue?" — sure about what? | Name the action and consequence: "Delete 'Q4 Report'? This can't be undone." | Common |

## Named Patterns

### Conversational UI Text
**When**: Onboarding, welcome screens, first-run experiences, chatbot interfaces.
**When NOT**: Dense data UIs, professional tools where efficiency matters more than warmth.
**How**: First person for the system ("I'll help you..."), second person for the user ("Your projects"). Contractions. Short sentences. One idea per screen.

### Progressive Help (Hint -> Tooltip -> Help Page)
**When**: Complex features with varied user expertise. Power users don't need hand-holding; new users need guidance.
**When NOT**: Simple, self-evident UI. If you need three tiers of help, the UI itself may need redesign.
**How**: Layer 1: inline hint text (always visible). Layer 2: tooltip or expandable section (on demand). Layer 3: linked documentation (for deep detail). Each layer is self-contained — user shouldn't need all three.

### Contextual Instructions
**When**: Multi-step flows, form sections with non-obvious requirements, features with prerequisites.
**When NOT**: Obvious interactions. Over-instructing trained users causes "banner blindness."
**How**: Place instructions immediately before the relevant section. Use muted/secondary text style. Remove after first successful completion (progressive disclosure). Keep under 2 sentences.

### Destructive Action Confirmation ("Type name to delete")
**When**: Irreversible actions with high consequences — account deletion, workspace destruction, bulk permanent delete.
**When NOT**: Reversible actions (soft delete, remove from list). Low-stakes deletions. Adds friction that isn't warranted.
**How**: Explain consequence clearly. Require typing exact entity name. Keep confirm button disabled until input matches. Button text mirrors the action ("Delete workspace"), never "OK."

### Friendly Error Pages (404, 500)
**When**: Full-page errors (broken routes, server failure, maintenance).
**When NOT**: Inline errors or partial failures — those use inline/toast patterns instead.
**How**: Acknowledge the problem without blame. Light illustration (optional). Provide navigation: link home, link to status page, search box. For 500s: "Something broke on our end. We've been notified." For 404s: "This page doesn't exist. It may have been moved or deleted."

### Humanized Numbers & Counts
**When**: Displaying counts, quantities, durations, or sizes in user-facing text.
**When NOT**: Data tables, exports, or contexts requiring exact precision.
**How**: Relative time: "2 hours ago" not "2024-01-15T14:30:00Z". Round large numbers: "12.4K followers" not "12,438 followers". Pluralize correctly: "1 item" / "2 items" (never "1 item(s)"). Use "No" instead of "0" in user-facing text: "No messages" not "0 messages". Duration: "About 5 minutes" not "Approximately 300 seconds."

### Permission & Restriction Messaging
**When**: User encounters something they can't access or an action they can't perform due to role/plan/state.
**When NOT**: Errors caused by bugs or system failure — those are error patterns, not permission patterns.
**How**: State what they can't do + why + what would unlock it. "You don't have permission to edit this page. Ask a workspace admin for access." For plan limits: "Free plans include 3 projects. Upgrade to create more." Never reveal existence of resources the user shouldn't know about — use 404 behavior for private resources, not 403.

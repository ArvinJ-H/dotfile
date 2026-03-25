# Error & Edge States
**When to load**: Error handling, degraded states, offline behavior, empty states, boundary conditions  |  **Skip if**: Purely happy-path design

## Core Principles

| # | Principle | Why it matters | Decision impact |
|---|-----------|---------------|-----------------|
| 1 | **Prevent > Detect > Recover** | Prevention eliminates the error entirely (constraints, disabled states, input masks). Detection catches it early (inline validation). Recovery handles what slips through (undo, retry). Each layer is cheaper than the next. Investment should follow this order. | Disable submit until valid. Validate on blur. Provide undo/retry on failure. Don't rely on recovery alone — prevention is 10x cheaper for the user. |
| 2 | **Graceful degradation** | When parts fail, show what works and disable/hide what doesn't. A single failed API call should never crash the entire view. Resilience is a UX feature, not just an engineering concern. | Isolate failure boundaries per component/widget. Show available data. Replace failed sections with retry affordance, not blank space or full-page error. |
| 3 | **Never lose user input** | Data loss is the worst UX failure. Users invest time and cognitive effort in their input. Losing it destroys trust irreversibly. | Auto-save drafts (change-based or interval). Preserve form state across navigation and errors. On session expiry, persist to localStorage. On conflict, show both versions. |
| 4 | **Error proximity** | Show errors near the source. Inline field errors > form-level banner > page-level toast. Distance between error indicator and error source = time spent hunting. Nielsen Norman: inline validation reduces errors by ~22%. | Inline for field-level. Banner at form top for multi-field + scroll-to-first. Toast only for system-level or async errors unrelated to visible content. |
| 5 | **Recovery actions always** | Every error message must include at least one action: retry, go back, contact support, try alternative. An error with no action is a dead end — users have no recourse except closing the app. | Format: "{What happened}. {Recovery action}." Minimum one action. Prefer contextual actions (retry this specific operation) over generic (go to homepage). |

## Decision Tables

### Error Display Format

| Error scope | Format | Placement | Dismiss behavior |
|------------|--------|-----------|------------------|
| Single field validation | Inline text below field | Adjacent, red/destructive styling | Clears automatically when input becomes valid |
| Multi-field form error | Banner at form top + inline per field | Top of form, auto-scroll to first error | Banner clears when all inline errors resolve |
| Async operation failure | Toast notification | Top-right or bottom-center, non-blocking | Manual dismiss or auto-dismiss after 8-10s (never <5s for errors) |
| Network/system error | Persistent banner or status bar | Top of viewport, above content | Manual dismiss or clears when connectivity restores |
| Partial page failure | Inline error within the failed section | Replaces the failed component's content area | Retry button within the section |
| Full page error (404/500) | Dedicated error page | Full viewport | Navigation links provided (home, back, status) |

### Auto-Save Strategy

| Factor | Change-based | Interval-based | Hybrid |
|--------|-------------|----------------|--------|
| When | Every meaningful change (debounced 1-2s after last keystroke) | Fixed interval (30-60s) | Change-triggered with interval floor |
| Pros | Minimal data loss window. Saves only when needed. | Predictable. Simple to implement. | Best of both — responsive and bounded. |
| Cons | High save frequency on rapid editing. | Saves even without changes (wasteful) or misses changes between intervals. | More complex logic. |
| Best for | Documents, rich text editors, design tools | Forms with discrete fields | Long-form content with heavy editing |
| **Status indicator** | "Saved" / "Saving..." / "Unsaved changes" | "Last saved: 2 min ago" | "Saved" with last-save timestamp on hover |

### Offline Strategy

| App type | Strategy | User communication | Sync behavior |
|----------|----------|-------------------|---------------|
| Read-heavy (docs, articles) | Cache for offline reading | "Available offline" badge. "You're offline — showing cached version." | Background sync on reconnect, show "Updated" indicator |
| Write-heavy (forms, editors) | Queue writes locally | "Offline — changes saved on your device. Will sync when online." | Replay queue on reconnect. Conflict? Show both versions. |
| Real-time (chat, collab) | Warn and degrade | "You're offline. Messages will send when you reconnect." | Queue outgoing. On reconnect, merge incoming + flush queue. |
| Transactional (payments, bookings) | Disable and explain | "You're offline. Checkout requires a connection." | No offline action — too risky. Preserve cart/form state for when online. |

### Retry Behavior

| Failure type | Retry strategy | Max attempts | User communication |
|-------------|---------------|-------------|-------------------|
| Network timeout | Auto-retry with exponential backoff (1s, 2s, 4s) | 3 | Show after first failure: "Retrying..." Then: "Couldn't connect. Retry / Work offline" |
| Server error (500) | Auto-retry once after 2s | 1-2 | "Something went wrong on our end. Retry / Contact support" |
| Client error (400/422) | No auto-retry — user must fix input | 0 | Inline validation explaining what to fix |
| Auth error (401/403) | Redirect to re-auth, preserve context | 1 (re-auth) | "Your session expired. Sign in to continue." Preserve draft/form state. |
| Rate limit (429) | Auto-retry after `Retry-After` header value | 1 | "Too many requests. Trying again in {N}s..." or hide entirely if brief |

### Empty State Strategy

| Empty state type | Cause | Content approach | CTA |
|-----------------|-------|-----------------|-----|
| First-use empty | User hasn't created anything yet | Explain what belongs here + benefit of populating it | Primary action: "Create first {item}" |
| Search/filter empty | Query returned no results | Acknowledge: "No results for '{query}'" + suggest alternatives | "Clear filters" / "Try a broader search" |
| Cleared-by-user empty | User deleted/archived everything | Confirm the state: "All caught up" or "No {items} in Trash" | Secondary action only if relevant |
| Error-caused empty | Failed to load content | Distinguish from "genuinely empty" — show error state, not empty state | "Retry" — never show "no items" when you don't know |
| Permission empty | User can't see content that exists | "You don't have access to {items} in this {scope}" | "Request access" / "Contact admin" |

## Platform Notes

### Web (primary)
- **Form persistence**: Use `sessionStorage` for in-progress forms. Restore on back-navigation or accidental close. `beforeunload` event for unsaved changes warning.
- **Offline detection**: `navigator.onLine` + `online`/`offline` events. But `onLine` only detects network interface — not actual connectivity. Supplement with periodic heartbeat fetch for critical apps.
- **Service Worker**: Cache app shell and critical assets. Serve cached responses when offline. Background sync API for queued writes.
- **Error boundaries** (React): Wrap independent UI sections. Each boundary catches its own errors without crashing siblings. Provide fallback UI with retry.
- **Validation**: HTML5 constraint validation for basics (`required`, `type="email"`, `pattern`). Custom validation via JS for complex rules. `aria-invalid="true"` + `aria-describedby` linking error message for screen readers.

### Mobile
- Connectivity is intermittent — design for offline-first or offline-aware, not online-only.
- Network transitions (wifi -> cellular) cause brief disconnects. Don't show error for sub-2s blips.
- Touch targets on error recovery buttons: minimum 44x44px (WCAG 2.5.5 AAA). Error states shouldn't shrink interactive elements.
- Form state must survive app backgrounding/foregrounding — persist to local storage, not just memory.

### Desktop
- `beforeunload` dialog for unsaved changes. Browser-controlled text — keep it generic.
- Multi-tab conflicts: if same resource is open in two tabs, detect via `BroadcastChannel` or `storage` events. Warn on save conflict.
- More screen space for error detail — can show inline help, expandable stack traces (for dev tools), or side-panel error logs.
- Keyboard accessibility for error recovery: error toasts must be reachable via keyboard (focus management). Modals trap focus. Inline errors should be reachable via Tab order.
- Multi-window state: if auth expires in one window, all windows should detect and handle it — don't let one window succeed while another silently fails.

### Cross-Platform Edge State Principles
- Error states must be testable on all platforms. Include error simulation in dev tools (network throttling, error injection).
- Same error = same message across platforms. Adapt format (toast vs banner vs full-screen) but keep the copy identical.
- Offline behavior must be documented per feature — don't leave it to implicit fallback behavior. Each feature should declare: works offline / read-only offline / unavailable offline.

## Anti-Patterns

| Mistake | Why it's wrong | Fix | Frequency |
|---------|---------------|-----|-----------|
| Generic "Something went wrong" with no action | Dead end. User has no recourse. No diagnostic value. Destroys trust. | State what failed + provide at least one action: retry, go back, contact support. | Very common |
| Silent failures | No feedback at all — user thinks action succeeded. Data may be lost or corrupted silently. | Every action needs a success or failure signal. Even background saves need a status indicator. | Common |
| Auto-dismiss errors < 5s | Users need time to read, understand, and act. Error toast that vanishes in 3s is useless. | Errors: manual dismiss or 8-10s minimum. Successes: 3-5s auto-dismiss is fine. | Common |
| Validation only on submit | User fills 10 fields, submits, gets 6 errors at once. Disorienting, frustrating, high abandonment. | Validate on blur (each field as user leaves it). Clear error on change. Show error count on submit if any remain. | Very common |
| Optimistic UI without rollback for critical operations | "Payment successful!" then silently fails. User thinks they paid but didn't. | Use optimistic only for low-risk ops. For critical actions, wait for server confirmation before showing success. | Moderate |
| Disabling button with no explanation | Submit is grayed out. User doesn't know why. No tooltip, no hint. | Show tooltip on hover over disabled button: "Complete all required fields to continue." Or use validation messages. | Common |
| Cascading error modals | Error triggers modal, modal action fails, second modal appears. Error stack grows. | One error surface at a time. Queue errors if multiple. Replace current error with new one if more severe. | Moderate |
| Losing form data on auth expiry | Session expires mid-form. Redirect to login. Return to empty form. All input lost. | Persist form state to localStorage before redirect. Restore after re-auth. Detect near-expiry and refresh token proactively. | Common |

## Named Patterns

### Inline Field Validation
**When**: Any form with more than 2-3 fields. Any field with non-obvious constraints.
**When NOT**: Single-field forms (search). Fields where validation requires server round-trip and latency would degrade typing experience.
**How**: Validate on blur (not on every keystroke — too aggressive). Clear error on the next change event. Show error text below the field with `aria-invalid` and `aria-describedby`. Red/destructive border on the field. On submit: scroll to first error, focus it.

### Retry with Exponential Backoff
**When**: Network or server failures that are likely transient (timeouts, 500s, 503s).
**When NOT**: Client errors (400, 422) where retry won't help. Auth errors (401) that need re-authentication, not retry.
**How**: First retry after 1s, second after 2s, third after 4s. Cap at 3 attempts. Add jitter (random 0-500ms) to avoid thundering herd. After max retries: show manual retry button + alternative action. During auto-retry: show "Retrying..." with attempt count.

### Offline Queue (Sync When Reconnected)
**When**: Write operations in apps used in intermittent connectivity (field work, mobile, travel).
**When NOT**: Operations requiring real-time confirmation (payments, bookings, sending to external systems where timing matters).
**How**: Intercept failed writes. Store in IndexedDB/localStorage queue with timestamp and payload. Show persistent "Offline — changes saved locally" indicator. On reconnect: replay queue in order. Handle conflicts (server state changed): prompt user or auto-merge with last-write-wins. Clear queue and confirm: "All changes synced."

### Auto-Save Indicator
**When**: Any app with auto-save (editors, forms, settings).
**When NOT**: Explicit-save-only flows (where user controls when to save — e.g. git commits, publish workflows).
**How**: Three states: "Saved" (checkmark, muted), "Saving..." (spinner/pulse, brief), "Offline — changes saved locally" (warning color, persistent). Position: near the save-related area (toolbar, header). Transition: saving -> saved should feel quick and confident. Add last-saved timestamp on hover for reassurance.

### Conflict Resolution UI
**When**: Multi-user editing of the same resource without real-time collaboration (CMS, settings, shared documents).
**When NOT**: Real-time collaboration tools (use CRDT/OT instead). Single-user resources.
**How**: Detect conflict on save (version mismatch / ETag). Show both versions side-by-side: "Your version" vs "Current version" with diff highlighting. Actions: "Keep mine", "Use theirs", "Merge manually". Never silently overwrite. Preserve both versions until user resolves. Auto-save should pause during conflict to avoid compounding it.

### Undo Toast ("Deleted — Undo")
**When**: Reversible destructive actions — delete from list, archive, remove member, mark as read. Soft deletes.
**When NOT**: Irreversible actions (permanent delete, send email, payment). Actions requiring confirmation dialog instead.
**How**: Execute action immediately (optimistic). Show toast: "{Action performed}. Undo" with 8-10s timeout. Undo reverses the action (re-insert, un-archive). Toast dismisses on timeout, manual dismiss, or next action. If user navigates away, undo window closes. Actual permanent deletion happens after undo window expires (delayed hard delete).

### Boundary/Limit Warning
**When**: Approaching system limits — storage quota, API rate limits, plan limits, character counts.
**When NOT**: Limits that are far from being reached. Limits the user can't act on.
**How**: Warn at ~80% threshold: "You've used 8 of 10 projects." Warn again at ~95%: "1 project remaining." At limit: disable creation with explanation and upgrade/cleanup action. Use progress bar or counter for continuous limits (storage). Use discrete count for item limits. Color: neutral at <80%, warning at 80-95%, destructive at >95%.

### Timeout with Partial Results
**When**: Operations that may partially succeed before timing out — bulk imports, multi-step workflows, batch operations.
**When NOT**: Atomic operations (all-or-nothing). Operations where partial results are meaningless.
**How**: Show what completed: "Imported 47 of 200 records. 3 failed. 150 remaining." Provide actions: "Continue" (resume from where it stopped), "Retry failed" (just the 3), "Download error log" (for investigation). Never silently discard partial progress.

### Stale Data Warning
**When**: Displaying cached or potentially outdated data — offline mode, SWR patterns, long-open tabs.
**When NOT**: Data that's always fresh (just fetched). Data where staleness doesn't matter (static content).
**How**: Subtle but visible indicator: "Last updated 2 hours ago" or "Showing cached data." Banner (not toast — persistent, not dismissible until resolved). Provide manual refresh: "Refresh" button. If data may have changed in important ways: "This may be outdated. Refresh to see latest." Auto-refresh on tab focus for tabs open >5 minutes.

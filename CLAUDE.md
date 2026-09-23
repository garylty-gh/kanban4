# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-file IT project management Kanban board (`index.html`) for an internal "UOB IT PMO" demo/training tool. Everything — markup, one `<style>` block, one `<script>` block — lives in `index.html`. There is no build, no package manager, no tests, and no linter.

## Running

Open `index.html` directly in a browser (double-click; must keep working over `file://`). To test FormSubmit email delivery, serve it over HTTP instead, since FormSubmit may reject `file://` (null-origin) requests:

```bash
python -m http.server 8000
```

## Hard constraints (from the original brief — do not violate)

- Vanilla HTML/CSS/JS only: no frameworks, libraries, CDN scripts, web fonts, image files, or build step. Icons are Unicode glyphs or inline SVG; fonts are the system stack.
- **No persistence of any kind**: no localStorage/sessionStorage/IndexedDB/cookies. A refresh resetting to seed data is intended, and the header note says so.
- The only network call is the FormSubmit AJAX endpoint. The email address appears only in the `FORMSUBMIT_ENDPOINT` constant at the top of the script.
- No `alert()`/`confirm()` (deletion uses an inline "Delete? Yes / No" inside the card), and no `!important` in CSS.
- Do not add real UOB logos or trademarks, or imitate an official UOB system — the wordmark is plain text with a corporate blue palette.
- Accessibility requirements: `<label for>` on every input, `aria-label` on icon-only buttons, visible `:focus-visible` rings, `aria-live="polite"` toast region, and priority conveyed by text as well as colour.

## Architecture (inside the `<script>` block)

- **Single source of truth**: `state = { tasks, filters, openMoveId, pendingDeleteId, isSubmitting }`. Transient card UI (open Move menu, pending delete confirmation) is kept in `state` rather than toggled in the DOM, so that `renderBoard()` is the only code that writes card contents. Keep it that way: mutate `state`, then call `renderBoard()`.
- **Render path**: `renderBoard()` → filters via `getFilteredTasks()` → `renderCard(task)` returns an HTML string per card → writes to each column's `#list-<slug>` → updates count badges → `renderSummary()` (summary counts always use all tasks, not the filtered set).
- **Escaping**: every value interpolated into card HTML must go through `escapeHtml()`. Toasts use `textContent`.
- **Status ↔ DOM mapping**: `STATUSES` holds the display names; `slugify(status)` produces the element IDs (`list-in-progress`, `count-in-progress`, `sum-in-progress`), and columns carry `data-status="<display name>"`. Adding or renaming a status requires updating the static column markup, the summary strip, and the `--status-*`/`.column[data-status]` CSS together.
- **Events are delegated** on `#board`: a click handler routes on `data-action` (`move-toggle`, `move-to`, `delete`, `delete-yes`, `delete-no`), plus native HTML5 drag-and-drop handlers (`dragstart` / `dragover` / `drop`, which call `moveTask`). After a re-render, focus is restored with `focusAfterRender(selector)` because the card DOM is replaced.
- **Add-task flow is optimistic**: `handleSubmit` → `validateForm` (inline errors via `setFieldError`, sets `aria-invalid`) → `setSubmitting(true)` → `addTask` (pushes, renders, resets the form; the modal stays open showing "Sending…") → `await notifyNewTask` inside try/catch. On failure the card is kept and a warning toast is shown. A FormSubmit failure must never break the board.
- **IDs**: `generateTaskId()` produces `UOB-ITPM-####` from the in-memory `nextIdNumber` counter; the seed tasks take 0001–0008.
- **Dates**: `todayISO()` and `addDaysISO()` use the *local* date (not UTC), and ISO strings are compared lexically. Seed due dates are relative to today, so overdue examples always exist. Overdue means `dueDate < today && status !== "Done"`.

## CSS conventions

Palette, priority colours, status accents and the spacing scale (`--space-1..6`) are custom properties on `:root`. Priority colour flows through a per-card `--card-prio` variable set by the `.prio-<level>` classes. Board layout is 4 columns at ≥1100px, a 2×2 grid at 768–1099px, and a single stacked column below 768px.

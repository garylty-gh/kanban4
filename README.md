# IT PMO Kanban Board (Demo)

A lightweight Kanban board for tracking IT project tasks, built as an internal demo and training tool for an IT project management office. It runs entirely in the browser from a single HTML file, with no dependencies, no build step, and no backend.

> **Disclaimer:** This is an independent demo. It is not affiliated with, endorsed by, or an official system of UOB, and it uses no UOB logos or trademarks.

**Live demo:** https://garylty-gh.github.io/kanban4/

## Features

- **Four status columns:** Backlog, In Progress, Blocked, and Done, each with a live task count.
- **Moving tasks:** drag and drop cards between columns, or use the keyboard-friendly **Move ▸** menu on each card.
- **Add tasks:** a modal form with inline validation. New tasks get IDs in the form `UOB-ITPM-####`.
- **Email notification:** each new task sends a notification through [FormSubmit](https://formsubmit.co/). If sending fails, the task is kept and a warning is shown.
- **Filters:** by project or workstream, by assignee (text match), and by priority.
- **Summary strip:** totals per status across all tasks.
- **Overdue detection:** tasks past their due date that are not Done are flagged. The seed data uses dates relative to today, so overdue examples always appear.
- **Priorities:** Critical, High, Medium, and Low, shown by colour and by text.
- **Inline delete confirmation:** "Delete? Yes / No" appears on the card, with no pop-up dialogs.
- **Accessibility:** labelled inputs, visible focus rings, `aria-live` announcements, and full keyboard operation.
- **Responsive layout:** 4 columns on desktop, a 2×2 grid on tablets, and a single stacked column on phones.

## Running locally

Open `index.html` directly in a browser. That's all you need.

To test FormSubmit email delivery, serve the file over HTTP, because FormSubmit may reject requests from `file://`:

```bash
python -m http.server 8000
```

Then open http://localhost:8000/.

### Configuring email notifications

Set your address in the `FORMSUBMIT_ENDPOINT` constant at the top of the `<script>` block in `index.html`:

```js
const FORMSUBMIT_ENDPOINT = "https://formsubmit.co/ajax/you@example.com";
```

FormSubmit sends a one-time activation email to that address the first time it is used. Any address you put here is public once the site is published.

## No persistence

Nothing is saved: the board does not use localStorage, cookies, or a server. Refreshing the page resets the board to the seed data. This is intentional for a demo and training tool.

## Tech notes

- A single `index.html` file with vanilla HTML, CSS, and JavaScript.
- No frameworks, libraries, CDN scripts, web fonts, or images. Icons are Unicode or inline SVG.
- The only network request is the FormSubmit notification.

## Deployment

The site is published to GitHub Pages by the workflow in [`.github/workflows/pages.yml`](.github/workflows/pages.yml) on every push to `main`. Only `index.html` is deployed.

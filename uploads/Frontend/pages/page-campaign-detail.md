# Page: Campaign Detail & Analytics

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P16 |
| **Version** | 0.2 — In Progress |
| **Status** | In Progress |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Campaign Detail & Analytics page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P1 |
| **Estimated Pages** | 4–8 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |
| 0.2 | 2026-05-24 | Frontend Engineer / UX Designer | Full specification completed |

---

## Table of Contents

- [Route & Access Control](#route--access-control)
- [Page Purpose](#page-purpose)
- [Data Fetching (API Endpoints Consumed)](#data-fetching-api-endpoints-consumed)
- [Component Breakdown](#component-breakdown)
- [UI States (Loading, Empty, Error, Success)](#ui-states-loading-empty-error-success)
- [Layout Wireframe / Mockup Reference](#layout-wireframe--mockup-reference)
- [Validation Rules](#validation-rules)
- [Navigation Flows (Entry & Exit Points)](#navigation-flows-entry--exit-points)
- [Responsive Behavior](#responsive-behavior)
- [Accessibility Notes](#accessibility-notes)

---

## Route & Access Control

| Field | Value |
|---|---|
| **URL Route** | `/campaigns/[id]` |
| **Next.js File** | `app/(dashboard)/campaigns/[id]/page.tsx` |
| **Authentication** | Required — redirect to `/login` if unauthenticated |
| **Authorized Roles** | Admin only |
| **Dynamic Segment** | `[id]` — UUID of the campaign record |

Non-Admin sessions are redirected server-side to `/dashboard`. If the campaign `id` does not exist or does not belong to the authenticated clinic, the server returns `404` and the page renders a "Campaign not found" error state. UUIDs that are syntactically invalid are rejected with a `400` before any database lookup occurs.

---

## Page Purpose

The Campaign Detail & Analytics page provides a complete, per-campaign view of delivery performance and per-recipient message status. It serves as the primary tool for the Admin to assess whether a campaign succeeded, identify patients whose messages failed to deliver, and take follow-up action.

**Core jobs this page performs:**

1. **Delivery Summary** — Four top-level stat cards (Total Sent, Delivered, Failed, Delivery Rate %) give an at-a-glance health check of the campaign. Color coding (green for delivered, red for failed) makes anomalies immediately visible.

2. **Campaign Metadata** — The audience filter, message template used, and send timestamp are displayed in a structured details section, providing context for interpreting the delivery numbers.

3. **Per-Recipient Message Log** — A paginated table listing every patient in the campaign audience with their individual message status (queued, sent, delivered, failed, read), timestamps for sent and delivered events, and a masked phone number for verification.

4. **Live Progress Monitoring** — For campaigns with `status: "running"`, the page automatically refreshes delivery stats every 30 seconds via Supabase Realtime or polling, allowing the Admin to watch a campaign progress in real time without manually refreshing.

5. **Log Export** — The full per-recipient log can be exported as a CSV file for external analysis, archiving, or follow-up contact lists.

6. **Re-engagement Action** — For completed campaigns with failed deliveries, a "Retry Failed" action (visible only when `failed_count > 0`) allows creating a new draft campaign pre-filtered to patients whose messages failed.

---

## Data Fetching (API Endpoints Consumed)

### Page Load

| Data | Method | Endpoint | Notes |
|---|---|---|---|
| Campaign details + stats | GET | `/api/campaigns/:id` | Returns campaign metadata + aggregate delivery stats |
| Message log (first page) | GET | `/api/campaigns/:id/messages` | Params: `page=1`, `limit=25`, `status?` |

Both requests fire in parallel on page mount via `Promise.all`. The page renders a skeleton while both are in flight.

**Campaign detail response shape:**
```json
{
  "id": "uuid",
  "name": "June Recall Campaign",
  "status": "completed",
  "audience_filter": "inactive_30",
  "audience_description": "Inactive patients (30+ days)",
  "template_id": "uuid",
  "template_name": "Appointment Re-engagement",
  "template_language": "ar",
  "sent_at": "2026-06-03T10:00:00Z",
  "scheduled_at": null,
  "created_at": "2026-06-02T09:00:00Z",
  "sent_count": 150,
  "delivered_count": 138,
  "failed_count": 12,
  "queued_count": 0,
  "read_count": 45,
  "delivery_rate": 92.0
}
```

**Message log response shape (per row):**
```json
{
  "id": "uuid",
  "patient_id": "uuid",
  "patient_name": "Fatima Ahmed",
  "phone_masked": "0101***678",
  "status": "delivered",
  "sent_at": "2026-06-03T10:01:22Z",
  "delivered_at": "2026-06-03T10:01:45Z",
  "error_code": null,
  "error_message": null
}
```

### Message Log Pagination & Filtering

| Action | Method | Endpoint | Params |
|---|---|---|---|
| Load next page | GET | `/api/campaigns/:id/messages` | `page`, `limit=25`, `status?` |
| Filter by status | GET | `/api/campaigns/:id/messages` | `status=delivered` or `status=failed` or `status=pending` |

Filtering is performed server-side. The active status filter tab updates the `status` query param and resets pagination to page 1.

### Real-Time Updates (Running Campaigns)

When `campaign.status === "running"`:
1. The component subscribes to `campaigns` table changes via Supabase Realtime (`UPDATE` events filtered to `id = :campaignId`)
2. On receiving an update, the delivery stats are refreshed without a full page reload (only the 4 stat cards and the log table re-fetch)
3. Fallback: if Supabase Realtime is unavailable, a 30-second `setInterval` fires `GET /api/campaigns/:id` to refresh stats only (not the full message log, to avoid unnecessary load)

The real-time subscription is cleaned up in `useEffect` cleanup on component unmount to prevent memory leaks.

### CSV Export

| Action | Method | Endpoint | Response |
|---|---|---|---|
| Export full log | GET | `/api/campaigns/:id/messages/export` | `Content-Disposition: attachment; filename="campaign-{name}-{YYYY-MM-DD}.csv"` |

The export always includes all messages regardless of the current status tab filter. Filter-specific exports are not supported in v1.0.

---

## Component Breakdown

### Page Header Area

| Component | Source | Role |
|---|---|---|
| `BackLink` | Internal | "← Campaigns" link returning to `/campaigns`; uses `ChevronLeft` Lucide icon |
| `CampaignTitleBlock` | Internal | Campaign name as `<h1>` + status badge + send date |
| `CampaignStatusBadge` | Internal | Same component used in the list page — Lucide icon + label + color per status |
| `RefreshButton` | Internal | Shown only when `status === "running"`; `RotateCw` icon; triggers manual re-fetch of stats + log |

### Delivery Stats Row

| Component | Source | Role |
|---|---|---|
| `DeliveryStatCard` × 4 | Internal | `DataCard` variant with large number, label, and accent color; laid out in a 4-column grid (2-column on mobile) |

**The 4 stat cards:**

| Stat | Value | Accent Color | Icon |
|---|---|---|---|
| Total Sent | `sent_count` | `cyan-600` | `Send` |
| Delivered | `delivered_count` | `green-600` | `CheckCircle2` |
| Failed | `failed_count` | `red-600` | `XCircle` |
| Delivery Rate | `delivery_rate` % | green if ≥ 90%, amber if 70–89%, red if < 70% | `TrendingUp` |

When `status === "running"`, all 4 cards display a subtle pulsing cyan outline to indicate live data.

### Campaign Details Section

| Component | Source | Role |
|---|---|---|
| `CampaignDetailsCard` | Internal | Card with a two-column grid of label/value pairs |
| Detail rows | Internal | `<dt>` (label) + `<dd>` (value) inside a `<dl>` for semantic correctness |

**Detail rows displayed:**

| Label | Value |
|---|---|
| Audience | `audience_description` (e.g., "Inactive patients — 30+ days") |
| Template | `template_name` + language badge (Arabic / English) |
| Total Recipients | `sent_count` |
| Sent At | Formatted datetime: "Jun 3, 2026 at 10:00 AM Cairo Time" |
| Created By | Admin name (from `created_by` user record) |

### Message Log Section

| Component | Source | Role |
|---|---|---|
| `MessageLogHeader` | Internal | Section title + status filter tabs + export button |
| `StatusFilterTabs` | Internal | "All | Delivered | Failed | Pending" tab strip; active tab updates `status` query param |
| `ExportCSVButton` | Internal | `Download` icon + "Export CSV"; triggers GET export endpoint |
| `MessageLogTable` | Internal (TanStack Table) | Paginated 25-row table of per-recipient log entries |
| `MessageStatusBadge` | Internal | Per-row status badge; see status design table below |
| `TablePagination` | Internal | Page controls; "Showing X–Y of Z messages" |

**Message Status Badge Design:**

| Status | Badge Style | Icon | Label |
|---|---|---|---|
| `queued` | `bg-slate-100 text-slate-700` | `Clock` | Queued |
| `sent` | `bg-blue-100 text-blue-700` | `Send` | Sent |
| `delivered` | `bg-green-100 text-green-800` | `CheckCircle2` | Delivered |
| `failed` | `bg-red-100 text-red-800` | `XCircle` | Failed |
| `read` | `bg-teal-100 text-teal-800` | `Eye` | Read |

### Failed Message Expansion

Rows with `status === "failed"` are expandable. Clicking the row or a `ChevronDown` toggle reveals:
- Error code: e.g., `30003` (Landline / Unreachable)
- Error message: e.g., "Message delivery to the destination handset failed."
- A "View Patient" link to the patient's profile at `/patients/:patient_id`

### Retry Failed Action

When `failed_count > 0` and `status === "completed"`, a button appears in the page header area:
- Label: "Retry Failed Messages" / `RefreshCw` icon
- Action: Navigates to `/campaigns/new?retry_from={id}` — the wizard opens with the audience pre-filtered to the specific patients whose messages failed in this campaign (a custom segment created server-side from the failed log)

---

## UI States (Loading, Empty, Error, Success)

### Page Load — Skeleton State

While both API calls are in flight:
- The 4 stat cards show skeleton rectangles (shimmer, matching card dimensions)
- The campaign details section shows 5 skeleton label/value rows
- The message log table shows 5 skeleton rows

### Running Campaign — Live State

Visual indicators for an active running campaign:
- Page title area shows the spinning `Loader2` icon next to the "Running" status badge
- Stat cards pulse with a cyan outline (`animate-pulse ring-2 ring-cyan-300`)
- A banner below the stat cards reads: "This campaign is currently sending. Stats update every 30 seconds." with a `RefreshCw` icon and a countdown timer ("Next update in: 18s")

### Completed Campaign — Normal State

Static view with all stats populated. No live indicators. "Retry Failed Messages" button appears if `failed_count > 0`.

### Scheduled Campaign State

- Stat cards show dashes (`—`) since no messages have been sent yet
- Campaign details shows "Scheduled for: Monday, Jun 3, 2026 at 10:00 AM"
- An info banner: "This campaign is scheduled to send in 2 days." with a `Cancel Schedule` button (converts status back to `draft` after confirmation)

### Empty Log State (All Messages Filter)

Should not occur if `sent_count > 0`, but if the log table returns empty unexpectedly:
- `SearchX` icon + "No messages found. This campaign may still be queued."

### Empty Log State (Filtered)

When the status filter tab returns zero results:
- "No messages with status 'Failed' for this campaign."

### Error States

| Scenario | Display |
|---|---|
| Campaign not found (404) | Full-page: `AlertCircle` + "Campaign not found." + "← Back to Campaigns" link |
| Stats fetch error | Stat cards show `—` with a `toast.error("Failed to load campaign stats.")` |
| Message log fetch error | Table area shows inline error: "Failed to load message log." + "Retry" button |
| CSV export error | `toast.error("Export failed. Please try again.")` |

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────┐
│  ← Campaigns                                                 │
│  "June Recall Campaign"           ● Completed  Jun 3, 2026  │
│                                 [Retry Failed Messages ↻]   │
├──────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ Sent     │  │Delivered │  │  Failed  │  │  Del. Rate │  │
│  │  150     │  │   138    │  │    12    │  │    92%     │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
│  (cyan)        (green)         (red)         (green ≥90%)   │
├──────────────────────────────────────────────────────────────┤
│  Campaign Details                                            │
│  Audience:    Inactive patients (30+ days)                   │
│  Template:    Appointment Re-engagement  [Arabic]            │
│  Recipients:  150                                            │
│  Sent at:     Jun 3, 2026 at 10:00 AM Cairo Time            │
│  Created by:  Admin                                          │
├──────────────────────────────────────────────────────────────┤
│  Message Log               [All] [Delivered] [Failed] [Pending]  │
│                                              [↓ Export CSV]  │
│ Patient Name  │ Phone      │ Status    │ Sent     │ Delivered │
│───────────────┼────────────┼───────────┼──────────┼──────────│
│ Fatima Ahmed  │ 0101***678 │ ✓ Deliv.  │ 10:01:22 │ 10:01:45 │
│ Omar Hassan   │ 0502***391 │ ✗ Failed  │ 10:01:22 │    —     │
│   ↳ Error 30003: Landline / Unreachable  [View Patient]      │
│ Sara Mahmoud  │ 0155***244 │ 👁 Read    │ 10:01:24 │ 10:01:50 │
│ ...           │            │           │          │           │
│───────────────────────────────────────────────────────────────│
│  [← Prev]  Page 1 of 6 (150 total)  [Next →]                │
└──────────────────────────────────────────────────────────────┘
```

### Message Log Table Column Specification

| Column | Width | Sortable | Notes |
|---|---|---|---|
| Patient Name | 200px (flex) | Yes | Link to `/patients/:id` on click |
| Phone | 140px | No | Masked: shows first 4 + `***` + last 3 digits |
| Status | 120px | Yes | `MessageStatusBadge` component |
| Sent At | 120px | Yes | Time only (HH:MM:SS); full datetime in tooltip |
| Delivered At | 120px | Yes | Time or `—` if not delivered; full datetime in tooltip |

---

## Validation Rules

This page is primarily a read-only analytics view. The only user-input actions involve navigation and single-click operations:

### Export CSV

- Button is active whenever the campaign has at least 1 message in the log (`sent_count > 0`)
- Button is disabled during a pending export request (prevents double-download)
- Export filename sanitized server-side: campaign name has non-alphanumeric characters replaced with hyphens

### Retry Failed Messages

- Only shown when `status === "completed"` AND `failed_count > 0`
- If `failed_count === 0`, the button is entirely absent (not just disabled)

### Cancel Scheduled Campaign

- Shown only when `status === "scheduled"`
- Triggers a confirmation dialog: "Cancel this scheduled campaign? It will be moved back to Draft."
- On confirm: PATCH `/api/campaigns/:id` with `{ status: "draft", scheduled_at: null }`

---

## Navigation Flows (Entry & Exit Points)

### Entry Points

| Source | How |
|---|---|
| Campaigns List (`/campaigns`) | Click on campaign name link or "View" icon in the action column |
| Campaign Create Wizard | Auto-redirect after successful launch (`POST /api/campaigns` → 201 → redirect to `/campaigns/:new_id`) |
| Toast notification | "View Campaign" link in success toast from the launch flow |

### Exit Points

| Destination | Trigger |
|---|---|
| Campaigns List (`/campaigns`) | Click "← Campaigns" back link in page header |
| Patient Profile (`/patients/:id`) | Click patient name link in message log table; or "View Patient" in failed message expansion |
| Campaign Create Wizard — Retry (`/campaigns/new?retry_from={id}`) | Click "Retry Failed Messages" button |
| Campaign Create Wizard — Edit (`/campaigns/new?edit={id}`) | Appears only for `scheduled` or `draft` campaigns; "Edit Campaign" link in the header |

---

## Responsive Behavior

### Desktop (1024px+)

- Full layout as wireframe: 4 stat cards in one row, details section, full log table with all 5 columns
- Expandable failed message rows show inline below the row
- Log table fills available width; column widths distribute proportionally

### Tablet (768px–1023px)

- Stat cards: 2 rows of 2 (2-column grid)
- Campaign details: single column (labels above values)
- Message log table: all columns visible; horizontal scroll if needed

### Mobile (320px–767px)

- Stat cards: 2-column grid (2 rows of 2)
- Campaign details: single column, stacked
- Message log table scrolls horizontally (`overflow-x: auto`)
- On mobile, "Sent At" and "Delivered At" columns are hidden by default; revealed via horizontal scroll
- Export CSV button is full-width below the status filter tabs
- Failed message expansion is shown as a separate row (full-width, 2 columns for code + patient link stacked)
- "Retry Failed Messages" button moves below the stat cards (not in the header) on mobile

### RTL (Arabic)

- "← Campaigns" back link becomes "الحملات →" with the arrow pointing right
- Stat cards retain LTR for numeric values (delivery rates, counts) using `unicode-bidi: isolate`
- Table column order mirrors: Patient Name appears on the right edge in Arabic layout
- Phone numbers remain LTR within their cells
- Status badge icons remain LTR; only label text switches to Arabic equivalents

---

## Accessibility Notes

### Page Structure

```html
<main>
  <header>
    <!-- Back link, campaign title, status badge -->
  </header>
  <section aria-label="Delivery statistics">
    <!-- 4 stat cards -->
  </section>
  <section aria-label="Campaign details">
    <dl><!-- detail rows --></dl>
  </section>
  <section aria-label="Message log">
    <!-- filter tabs, table, pagination -->
  </section>
</main>
```

Each `<section>` has an `aria-label` to provide landmark navigation for screen reader users.

### Stat Cards

Each `DeliveryStatCard` is a `<article>` with `aria-label="Total Sent: 150"` (combining the label and value) so screen readers announce the full stat without reading the label and number separately:

```html
<article aria-label="Total Sent: 150 messages">
  <Send aria-hidden="true" />
  <span class="sr-only">Total Sent</span>
  <span class="stat-value" aria-hidden="true">150</span>
</article>
```

The `sr-only` span and `aria-hidden` on the visual number prevents double-reading.

### Campaign Details (Definition List)

```html
<dl>
  <div>
    <dt>Audience</dt>
    <dd>Inactive patients (30+ days)</dd>
  </div>
  ...
</dl>
```

`<dl>` / `<dt>` / `<dd>` semantics allow screen readers to announce key/value pairs naturally.

### Message Log Table

```html
<table>
  <caption class="sr-only">Per-recipient message delivery log for June Recall Campaign</caption>
  <thead>
    <tr>
      <th scope="col" aria-sort="none">Patient Name</th>
      <th scope="col">Phone</th>
      <th scope="col" aria-sort="ascending">Status</th>
      ...
    </tr>
  </thead>
```

- `<caption>` is visually hidden but descriptive
- `<th scope="col">` on all header cells
- `aria-sort` updated dynamically on sorted columns

### Message Status Badges

```html
<span aria-label="Message status: Delivered" class="badge-green">
  <CheckCircle2 aria-hidden="true" />
  <span>Delivered</span>
</span>
```

The `aria-label` on the badge container reads the full status; the icon is `aria-hidden="true"` to avoid double-announcement.

### Phone Number Masking

Masked phone numbers (`0101***678`) are announced as written by screen readers, which is correct — the masking is intentional for privacy. A visually hidden description is not added, as announcing the partial number is the expected behavior.

### Live Region for Running Campaigns

```html
<div role="status" aria-live="polite" aria-atomic="true" class="sr-only">
  Campaign stats updated: 138 delivered, 12 failed, 92% delivery rate.
</div>
```

This live region updates when stats refresh during a running campaign. `aria-atomic="true"` ensures the full summary is announced rather than individual character changes. Updates are batched and announced at most once per polling cycle (every 30 seconds) to prevent announcement overload.

### Focus Management

- When the status filter tab changes (e.g., click "Failed"), focus is programmatically moved to the table's first focusable element (the first row's patient name link), with a brief `setTimeout(0)` delay to allow the table to re-render
- When the failed message expansion opens (expandable row), focus moves to the expanded row content
- When the CSV export completes, a `role="status"` live region announces "Export downloaded." and focus returns to the Export button

### Keyboard Navigation

- Tab: cycles through back link, stat cards (focusable for keyboard users), detail section, status filter tabs, export button, table headers, table rows (each row's patient name is a link), pagination controls
- Sortable column headers activate on Enter or Space
- Expandable failed rows: Enter or Space on the row toggles expansion; Escape collapses it
- Pagination: Previous / Next buttons are standard buttons; page number selector (if present) is a `<select>` element

---

*DOC-06-P16 · v0.2 · 2026-05-24 · Physical Therapy Clinic Management System*

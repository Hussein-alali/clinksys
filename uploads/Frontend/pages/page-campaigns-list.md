# Page: Campaigns List

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P14 |
| **Version** | 0.2 — In Progress |
| **Status** | In Progress |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Campaigns List page. |
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
| **URL Route** | `/campaigns` |
| **Next.js File** | `app/(dashboard)/campaigns/page.tsx` |
| **Authentication** | Required — redirect to `/login` if unauthenticated |
| **Authorized Roles** | Admin only |

Non-Admin authenticated users who navigate to `/campaigns` are redirected server-side to `/dashboard`. The sidebar navigation link to Campaigns is conditionally rendered and only appears for Admin-role sessions. The Campaigns module maps to Module 14 (WhatsApp Campaign System) from the PRD, which is a Phase 2 feature accessible only through the Admin portal.

---

## Page Purpose

The Campaigns List page is the central hub for viewing, managing, and launching all WhatsApp outreach campaigns. It gives the Admin an at-a-glance overview of every campaign — past, present, and scheduled — with the ability to filter by campaign status, monitor live delivery progress, duplicate past campaigns for re-use, and launch draft campaigns.

**Core jobs this page performs:**

1. **Inventory** — List all campaigns created in the system with their name, audience targeting description, message delivery metrics, and current status. This allows the Admin to quickly understand what has been sent and to whom.

2. **Status Filtering** — Filter the campaign list by lifecycle status (All / Draft / Scheduled / Running / Completed / Failed) to focus on the relevant subset. A running campaign polling every 30 seconds keeps delivery stats current during active sends.

3. **Launch Control** — Draft campaigns display a "Send" action that opens a confirmation dialog before dispatching. This prevents accidental campaign launches, which could send unwanted messages to patients.

4. **Campaign Creation Entry Point** — The prominent "+ New Campaign" button in the page header starts the 5-step campaign creation wizard at `/campaigns/new`.

5. **Campaign Inspection** — Each row links to the detailed analytics view at `/campaigns/:id` where per-recipient message logs and delivery breakdowns are available.

---

## Data Fetching (API Endpoints Consumed)

### Initial Load

| Data | Method | Endpoint | Key Params | Notes |
|---|---|---|---|---|
| Campaign list | GET | `/api/campaigns` | `status?` (filter param), `page`, `limit` | Returns paginated array of campaign objects |

Each campaign object in the response contains:
```json
{
  "id": "uuid",
  "name": "June Recall",
  "audience_filter": "inactive_30",
  "audience_description": "Inactive patients (30+ days)",
  "sent_count": 150,
  "delivered_count": 138,
  "failed_count": 12,
  "delivery_rate": 92,
  "status": "completed",
  "created_at": "2026-06-03T10:00:00Z",
  "scheduled_at": null,
  "sent_at": "2026-06-03T10:00:00Z"
}
```

### Status Filter

When a status tab is active, the same endpoint is called with a `status` query param:
- `GET /api/campaigns?status=draft`
- `GET /api/campaigns?status=running`

Tab filtering is handled server-side (not client-side) to support accurate pagination when there are many campaigns.

### Real-Time Updates for Running Campaigns

When one or more campaigns with `status: "running"` are present in the list, the component subscribes to Supabase Realtime on the `campaigns` table for INSERT and UPDATE events. This replaces a polling fallback. If Supabase Realtime is unavailable, a polling interval of 30 seconds is used via `setInterval` as a degraded fallback, firing `GET /api/campaigns?status=running` to refresh only the running rows.

### Send Campaign (Draft → Running)

| Action | Method | Endpoint | Payload |
|---|---|---|---|
| Send now | POST | `/api/campaigns/:id/send` | Empty body |

### Duplicate Campaign

| Action | Method | Endpoint | Notes |
|---|---|---|---|
| Duplicate | POST | `/api/campaigns/:id/duplicate` | Server creates a draft copy with name "Copy of [original name]"; returns `{ id: "new-uuid" }` |

After duplication, the client navigates to `/campaigns/new?duplicate_from={new-uuid}` with the wizard pre-populated from the duplicate.

---

## Component Breakdown

### Page Shell

| Component | Source | Role |
|---|---|---|
| `PageHeader` | Internal | Displays "Campaigns" / "الحملات"; contains "+ New Campaign" button aligned to the right (left in RTL) |
| `Button` (+ New Campaign) | Shadcn/UI (variant=primary) | Navigates to `/campaigns/new`; uses `Plus` Lucide icon |

### Status Filter Tabs

| Component | Source | Role |
|---|---|---|
| `StatusTabGroup` | Internal (Shadcn/UI `Tabs`) | Horizontal tab strip; each tab label includes a count badge showing the number of campaigns in that state |
| Tab items | Internal | All / Draft / Scheduled / Running / Completed / Failed |

Tab count badges are populated from a summary object returned alongside the campaign list:
```json
{ "counts": { "all": 12, "draft": 3, "scheduled": 1, "running": 0, "completed": 7, "failed": 1 } }
```

### Campaign Table

| Component | Source | Role |
|---|---|---|
| `CampaignsTable` | Internal (TanStack Table) | Paginated, sortable table of campaign rows |
| `CampaignStatusBadge` | Internal | Renders status-specific color + Lucide icon + text label |
| `CampaignActionsCell` | Internal | Per-row action buttons; collapses to dropdown on mobile |
| `DeliveryRateBar` | Internal | Compact horizontal bar showing delivered % in green and failed % in red, with numeric label |
| `TablePagination` | Internal | Page controls; "Showing X–Y of Z campaigns" |

### Status Badge Design

| Status | Badge Style | Lucide Icon | Text Color |
|---|---|---|---|
| Draft | `bg-slate-100` | `FileText` | `text-slate-700` |
| Scheduled | `bg-yellow-100` | `Clock` | `text-yellow-800` |
| Running | `bg-blue-100` | `Loader2` (animated spin) | `text-blue-700` |
| Completed | `bg-green-100` | `CheckCircle` | `text-green-800` |
| Failed | `bg-red-100` | `XCircle` | `text-red-800` |

### Row Action Buttons

| Action | Icon | Condition | Behavior |
|---|---|---|---|
| View | `Eye` | All statuses | Navigates to `/campaigns/:id` |
| Duplicate | `Copy` | All statuses | Fires POST `/api/campaigns/:id/duplicate`; then navigates to wizard with pre-fill |
| Send | `Play` | Draft only | Opens `SendConfirmDialog` |
| Edit | `Pencil` | Draft only | Navigates to `/campaigns/new?edit={id}` with wizard pre-populated |

### Send Confirmation Dialog

A Shadcn/UI `AlertDialog` with:
- Title: "Send campaign to {N} recipients?"
- Body: "This will immediately send your campaign to {N} patients. This action cannot be undone."
- Actions: "Cancel" (outline) | "Send Campaign" (primary, teal)
- While the POST is in flight: "Send Campaign" button shows `Loader2` and is disabled
- On success: dialog closes, toast fires "Campaign launched successfully.", row status badge updates to "Running"
- On error: dialog stays open, error message shown inline: "Failed to send campaign. Please try again."

---

## UI States (Loading, Empty, Error, Success)

### Page Load — Skeleton State

While `GET /api/campaigns` is in flight:
- The page renders 5 skeleton table rows
- Each skeleton row shows animated shimmer blocks in the shape of the name, audience, sent count, delivery rate bar, and status badge columns
- The "+ New Campaign" button and status tabs are immediately rendered (not skeletonized) so the Admin can start a new campaign without waiting for the list to load

### Populated State

Normal state showing the table with campaign rows. The active status tab's count badge reflects the total for that filter. Pagination shows when there are more than 25 rows.

### Running Campaigns Live Updates

Rows with `status: "running"` show:
- `Loader2` spinning icon in the status badge
- Sent count, delivered count, and delivery rate updating in real time via Supabase Realtime or 30-second polling
- A subtle cyan left border on the row (`border-l-2 border-cyan-600`) to visually distinguish live rows

### Empty State — All Campaigns

When there are no campaigns at all (no campaigns have ever been created):

```
[Megaphone icon — Lucide, 64×64, slate-300]

No campaigns yet.
Create your first campaign to re-engage patients.

[+ New Campaign]  ← CTA button
```

### Empty State — Filtered Status

When the active status tab filter returns no results (e.g., "Draft" tab but no draft campaigns exist):

```
[Filter icon — Lucide, 48×48, slate-300]

No campaigns with status "Draft".
Switch to a different filter or create a new campaign.
```

### Error State

If `GET /api/campaigns` fails:

```
[AlertCircle icon — Lucide, 64×64, red-400]

Failed to load campaigns.
Check your connection and try again.

[Retry]
```

`toast.error("Failed to load campaigns.")` also fires.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────┐
│  PageHeader: "Campaigns" / "الحملات"    [+ New Campaign]     │
├──────────────────────────────────────────────────────────────┤
│  [All (12)] [Draft (3)] [Scheduled (1)] [Running (0)]        │
│  [Completed (7)] [Failed (1)]                                │
├──────────────────────────────────────────────────────────────┤
│ Name          │ Audience        │ Sent │ Del% │ Status   │ Actions │
│───────────────┼─────────────────┼──────┼──────┼──────────┼─────────│
│ June Recall   │ Inactive (30d+) │  150 │  92% │ ✓ Done   │ 👁  ⧉   │
│ Package Exp   │ Expiring Pkg    │   42 │  88% │ ✓ Done   │ 👁  ⧉   │
│ Birthday Jun  │ Birthday/Month  │    — │    — │ ◫ Draft  │ ▶  ✎ ⧉  │
│ New Patient W │ All Active      │    — │    — │ 🕐 Sched │ 👁  ⧉   │
│───────────────┴─────────────────┴──────┴──────┴──────────┴─────────│
│  Showing 1–4 of 4 campaigns                                  │
└──────────────────────────────────────────────────────────────┘
```

### Table Column Specification

| Column | Width | Sortable | Notes |
|---|---|---|---|
| Name | 240px (flex-grow) | Yes | Campaign name as a link to `/campaigns/:id` |
| Audience | 180px | No | Human-readable description of the audience filter |
| Sent | 80px | Yes | Number of messages submitted to Twilio |
| Delivered % | 100px | Yes | `(delivered / sent) * 100`; shown as `DeliveryRateBar` |
| Failed % | 80px | Yes | `(failed / sent) * 100`; shown as a red text label |
| Status | 120px | Yes | `CampaignStatusBadge` |
| Actions | 100px | No | Icon buttons; collapsed to dropdown on mobile |

---

## Validation Rules

The Campaigns List page itself has no form inputs. Validation rules apply to the Send Confirmation interaction:

- The "Send Campaign" action in the dialog is only available when the campaign's `status` is exactly `"draft"` — this is validated server-side before the POST is processed
- If the campaign's estimated recipient count is 0 (audience filter returns no patients), the "Send" action button is disabled with a tooltip: "No recipients match this campaign's audience filter. Edit the campaign to adjust the audience."
- Duplicate action: no validation — any campaign regardless of status can be duplicated

---

## Navigation Flows (Entry & Exit Points)

### Entry Points

| Source | How |
|---|---|
| Sidebar navigation | "Campaigns" link (Admin role only); uses `Megaphone` Lucide icon |
| Campaign Detail page | Breadcrumb "← Campaigns" returns here |
| Post-send success toast | "View Campaign" link in toast navigates to the new campaign's detail page |

### Exit Points

| Destination | Trigger |
|---|---|
| Campaign Detail (`/campaigns/:id`) | Click on campaign name link or "View" (Eye) action icon |
| Campaign Create Wizard (`/campaigns/new`) | Click "+ New Campaign" button |
| Campaign Edit Wizard (`/campaigns/new?edit={id}`) | Click "Edit" (Pencil) action icon on a Draft row |
| Campaign Create Wizard pre-filled (`/campaigns/new?duplicate_from={id}`) | Click "Duplicate" (Copy) action icon |

---

## Responsive Behavior

### Desktop (1024px+)

- Full table layout as specified, all columns visible
- Row action buttons displayed inline as icon-only buttons with tooltips on hover

### Tablet (768px–1023px)

- "Failed %" column hidden to reduce column count
- Action buttons remain inline

### Mobile (320px–767px)

- Table scrolls horizontally within a full-width wrapper (`overflow-x: auto`)
- Only Name, Status, and Actions columns are visible without horizontal scrolling; other columns are accessible by scrolling right
- Row action buttons collapse into a single `MoreVertical` (`⋮`) icon button per row; tapping opens a dropdown menu (`DropdownMenu` from Shadcn/UI) with labeled items: "View", "Duplicate", "Send" (Draft only), "Edit" (Draft only)
- Status tab strip scrolls horizontally (`overflow-x: auto`; no line wrap)
- "+ New Campaign" button is full-width below the page header on small screens

---

## Accessibility Notes

### Table Structure

```html
<table>
  <caption class="sr-only">Campaigns list</caption>
  <thead>
    <tr>
      <th scope="col" aria-sort="ascending">Name</th>
      <th scope="col">Audience</th>
      <th scope="col" aria-sort="none">Sent</th>
      ...
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="/campaigns/abc">June Recall</a></td>
      ...
    </tr>
  </tbody>
</table>
```

- `<caption>` is visually hidden (`sr-only`) but present for screen readers
- `<th scope="col">` on every header cell
- `aria-sort` updates dynamically when a column is sorted

### Status Badges

Each `CampaignStatusBadge` has `aria-label="Status: Completed"` (or whichever status) so screen readers read the full status rather than just the badge icon:

```html
<span aria-label="Status: Completed" class="badge-green">
  <CheckCircle aria-hidden="true" /> Completed
</span>
```

### Action Buttons

- View button: `aria-label="View June Recall campaign"`
- Duplicate button: `aria-label="Duplicate June Recall campaign"`
- Send button: `aria-label="Send June Recall campaign"`
- Edit button: `aria-label="Edit June Recall campaign"`

Each button includes the campaign name to disambiguate for screen reader users who navigate by button list.

### Live Region for Running Campaigns

When a Running campaign's delivery stats update via real-time subscription:
- A visually hidden `aria-live="polite"` region announces: "June Recall campaign: 138 delivered, 12 failed." — but only when the Sent count changes, not on every polling cycle, to avoid announcement spam.

### Running Campaign Row Animation

The `Loader2` spinning icon in the Running status badge uses `aria-hidden="true"` — its motion is purely decorative. The `aria-label="Status: Running"` on the badge wrapper communicates the status to screen readers without relying on the animation.

### Keyboard Navigation

- Tab through table: column headers are focusable (sortable ones) → row links → row action buttons
- Enter on a row's campaign name link: navigates to Campaign Detail
- Enter on "Send" button: opens the confirmation dialog; focus traps inside the dialog
- Escape: dismisses the Send confirmation dialog, returns focus to the Send button

### RTL Notes

- In Arabic layout, the "+ New Campaign" button moves to the left side of the page header
- Table column order mirrors (Name column appears on the right edge)
- The `MoreVertical` dropdown on mobile opens from the left side of the button in RTL
- Status tab strip scrolls in the opposite direction in RTL (right-to-left)

---

*DOC-06-P14 · v0.2 · 2026-05-24 · Physical Therapy Clinic Management System*

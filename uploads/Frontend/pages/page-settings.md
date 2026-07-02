# Page: Settings

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P19 |
| **Version** | 0.2 — In Progress |
| **Status** | In Progress |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Settings page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P2 |
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
| **URL Route** | `/settings` |
| **Next.js File** | `app/(dashboard)/settings/page.tsx` |
| **Authentication** | Required — redirect to `/login` if unauthenticated |
| **Authorized Roles** | Admin only |

Any authenticated non-Admin user who navigates to `/settings` is redirected to `/dashboard` with a `toast.error("You do not have permission to access Settings.")` notification. The route guard is enforced server-side via the Next.js middleware (`middleware.ts`) to prevent any flash of the settings UI before the redirect fires.

The Settings link in the sidebar navigation is rendered conditionally and is only visible to Admin-role sessions. It does not appear for Doctor, Therapist, or Receptionist accounts.

---

## Page Purpose

The Settings page is the central administrative configuration surface for the PTCMS. It allows the Admin to configure four independent domains of clinic behavior — Clinic Information, Business Hours, Google Sheets Integration, and Notification Preferences — each of which saves independently to prevent accidental loss of partial changes across unrelated sections.

**Core jobs this page performs:**

1. **Clinic Identity** — Set the clinic's name, address, phone number, and logo. This information propagates to invoice headers, WhatsApp notification messages, and any patient-facing output.

2. **Business Hours** — Define which days the clinic operates and the open/close time window per day. Business hours are consumed by the appointment booking system to constrain bookable slots.

3. **Google Sheets Sync** — Monitor integration health and manually trigger synchronization for each of the three connected sheets: Patient List, Daily Appointments, and Payments. Provides last-sync timestamps to help Admin identify stale data.

4. **Notification Preferences** — Toggle each category of automated WhatsApp notification on or off. Changes take effect for all future outbound messages; in-flight messages already queued by n8n are not recalled.

5. **Danger Zone** — Export a full database backup as a ZIP archive. This action requires explicit confirmation and is logged in the audit trail.

The page does not contain user account management (password changes, role assignments) — those are handled on the `/staff` and `/profile` pages.

---

## Data Fetching (API Endpoints Consumed)

### Read (on page load)

| Data | Method | Endpoint | Notes |
|---|---|---|---|
| Clinic settings | GET | `/api/admin/settings` | Returns all settings fields: name, address, phone, logo_url, business_hours JSONB, notification_preferences JSONB |
| Google Sheets sync status | GET | `/api/admin/sync/status` | Returns last_synced_at timestamps for each of the 3 sheets and connection status |

Both requests fire in parallel on page load via `Promise.all`. The page renders a full-page skeleton while both requests are in flight.

### Write (on user action)

| Action | Method | Endpoint | Payload |
|---|---|---|---|
| Save clinic information | PATCH | `/api/admin/settings/clinic` | `{ name, address, phone }` |
| Upload clinic logo | POST | `/api/admin/settings/logo` | `multipart/form-data` with `logo` file field |
| Save business hours | PATCH | `/api/admin/settings/hours` | `{ days: [{ day, is_open, open_time, close_time }] }` |
| Save notification preferences | PATCH | `/api/admin/settings/notifications` | `{ preferences: { ... } }` JSONB |
| Trigger Google Sheets sync | POST | `/api/admin/sync/:sheet` | `:sheet` = `patients` \| `appointments` \| `payments` |
| Export all data | POST | `/api/admin/export` | Empty body; server streams ZIP response |

### Logo Upload

Logo upload uses a two-step pattern:
1. POST to `/api/admin/settings/logo` with `multipart/form-data`
2. Server stores the file in Supabase Storage under `clinic-assets/logo`
3. Server returns `{ logo_url: "https://..." }` — the URL is then displayed in the preview and saved to the settings record

---

## Component Breakdown

### Page Shell

| Component | Source | Role |
|---|---|---|
| `PageHeader` | Internal | Displays page title "Settings" / "الإعدادات" |
| `SettingsSectionCard` | Internal | Reusable card wrapper with title bar, divider, and inner padding; used for all 5 sections |

### Section 1 — Clinic Information

| Component | Source | Role |
|---|---|---|
| `Input` (Clinic Name) | Shadcn/UI | Text input, max 100 chars |
| `Input` (Address) | Shadcn/UI | Text input, max 200 chars |
| `Input` (Phone) | Shadcn/UI | Text input, phone format validated |
| `FileUpload` | Internal | File picker restricted to `image/jpeg,image/png,image/webp`; max 2 MB; shows selected file name |
| `LogoPreview` | Internal | Circular 80×80px `<img>` showing current logo or placeholder silhouette; updates immediately on file selection via `URL.createObjectURL` |
| `Button` (Save) | Shadcn/UI (variant=cta) | Triggers PATCH + optional logo upload; shows `Loader2` during request |

### Section 2 — Business Hours

| Component | Source | Role |
|---|---|---|
| `BusinessHoursRow` (×7) | Internal | One row per day of week (Sunday–Saturday); contains day label, open/closed toggle, and conditional time range |
| `Switch` | Shadcn/UI | Per-day open/closed toggle; when switched off, the time range inputs are hidden and the entire row is rendered in `text-slate-400` (greyed out) |
| `TimeInput` (Open) | Internal (native `<input type="time">`) | Start time for the operating day |
| `TimeInput` (Close) | Internal (native `<input type="time">`) | End time for the operating day |
| `Button` (Save) | Shadcn/UI (variant=cta) | Triggers PATCH for all 7 days simultaneously |

Closed-day rows display: `[Sunday] [toggle OFF] Closed` with the time inputs removed from the DOM (not `display:none`) to maintain correct tab order and avoid spurious validation on hidden fields.

### Section 3 — Google Sheets Integration

| Component | Source | Role |
|---|---|---|
| `IntegrationStatusBadge` | Internal | Pill badge: green "Connected" with `CheckCircle` icon / red "Disconnected" with `XCircle` icon |
| `SyncRow` (×3) | Internal | Sheet name + last sync timestamp + "Sync Now" button; one row per sheet (Patients, Daily Appointments, Payments) |
| `Button` (Sync Now) | Internal | Fires POST `/api/admin/sync/:sheet`; shows `Loader2` during pending request; button disabled during sync to prevent double-submission |
| `SyncTimestamp` | Internal | Displays "Last sync X min ago" using `date-fns/formatDistanceToNow`; auto-refreshes every 60 seconds |

On "Sync Now" success: `toast.success("Patient List synced successfully.")` fires; the timestamp for that row updates to "just now."
On "Sync Now" error: `toast.error("Sync failed. Check your Google Sheets connection.")` fires; the button re-enables.

The "Disconnected" status badge links to a knowledge base article explaining how to reconnect the n8n workflow (URL: `/help/google-sheets-setup`).

### Section 4 — Notification Preferences

| Component | Source | Role |
|---|---|---|
| `NotificationToggleRow` (×6) | Internal | Label + description + `Switch` per notification type |
| `Switch` | Shadcn/UI | Toggle switch; `checked` state is derived from the loaded `notification_preferences` JSONB |
| `Button` (Save) | Shadcn/UI (variant=cta) | Saves all 6 preference values in a single PATCH call |

The 6 notification types:

| Key | Label | Description |
|---|---|---|
| `reminder_24h` | Appointment reminder — 24 hours | Sent at T-24h before confirmed appointment |
| `reminder_2h` | Appointment reminder — 2 hours | Sent at T-2h before confirmed appointment |
| `payment_receipt` | Payment receipt | Sent immediately on payment recording |
| `package_expiry` | Package expiry warning | Sent 3 days before package expiry date |
| `birthday_greeting` | Birthday greeting | Sent on patient's birthday at 9:00 AM |
| `welcome_message` | Welcome message | Sent when a new patient profile is created |

### Section 5 — Danger Zone

| Component | Source | Role |
|---|---|---|
| `DangerZoneCard` | Internal | Styled with `border-red-200 bg-red-50` to visually isolate destructive actions |
| `Button` (Export All Data) | Internal (variant=destructive-outline) | Opens a confirmation dialog before triggering export |
| `Button` (Contact Support) | Internal (variant=outline) | Opens `mailto:support@ptcms.com` in the default mail client; rendered with `Mail` Lucide icon |
| `ConfirmDialog` | Internal (Shadcn/UI `AlertDialog`) | Two-step confirmation before export fires |

**Confirm Dialog content:**
- Title: "Export all clinic data?"
- Body: "This will generate a full database export including all patient records, appointments, payments, and documents. The file will be downloaded as a ZIP archive. This action is logged."
- Actions: "Cancel" (secondary) | "Export Data" (destructive red)

---

## UI States (Loading, Empty, Error, Success)

### Page Load — Skeleton State

While both `GET /api/admin/settings` and `GET /api/admin/sync/status` are in flight, the page renders skeleton placeholders:

- Clinic Information section: 3 input skeleton rows + circular logo placeholder
- Business Hours section: 7 row skeletons (day label + switch + time range blocks)
- Google Sheets section: 3 sync row skeletons
- Notification Preferences section: 6 toggle row skeletons

Skeleton uses Tailwind `animate-pulse bg-slate-200 rounded`.

### Save Success State

On successful PATCH for any section:
- `toast.success("Settings saved successfully.")` / `"تم حفظ الإعدادات بنجاح."` fires top-right
- The Save button returns to its default state (spinner stops)
- No page reload — form values remain populated with the saved data

### Save Error State

On PATCH failure:
- `toast.error("Failed to save settings. Please try again.")` fires
- The Save button re-enables
- If the error is a validation error (e.g., phone format), the relevant field displays an inline error message in red below the input

### Logo Upload — File Too Large

If the selected file exceeds 2 MB:
- `FileUpload` component shows inline error: "File too large. Maximum size is 2 MB." / "حجم الملف كبير جداً. الحد الأقصى 2 ميغابايت."
- The file is rejected before any network request is made
- The preview is not updated

### Logo Upload — Invalid Type

If the selected file is not JPEG, PNG, or WebP:
- Inline error: "Invalid file type. Only JPEG, PNG, and WebP are accepted."
- The file is rejected client-side before upload

### Google Sheets — Disconnected State

When `GET /api/admin/sync/status` returns `{ connected: false }`:
- The status badge renders as red "Disconnected" with `XCircle` icon
- All three "Sync Now" buttons are disabled and display a tooltip on hover: "Google Sheets is disconnected. Reconnect to enable sync."
- A top-of-section banner (amber, `AlertTriangle` icon) reads: "Google Sheets integration is disconnected. Your data may be out of date."

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────┐
│  PageHeader: "Settings" / "الإعدادات"                   │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌── Clinic Information ──────────────────────────────┐  │
│  │  Clinic Name:   [_____________________________]    │  │
│  │  Address:       [_____________________________]    │  │
│  │  Phone:         [_____________________________]    │  │
│  │  Logo:          [Upload Logo]   (○ circular preview)│  │
│  │                                         [Save ▶]   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌── Business Hours ──────────────────────────────────┐  │
│  │  Monday    [● Open]   08:00  →  20:00              │  │
│  │  Tuesday   [● Open]   08:00  →  20:00              │  │
│  │  Wednesday [● Open]   08:00  →  20:00              │  │
│  │  Thursday  [● Open]   08:00  →  20:00              │  │
│  │  Friday    [● Open]   08:00  →  20:00              │  │
│  │  Saturday  [● Open]   08:00  →  14:00              │  │
│  │  Sunday    [○ Closed]  ─────────────── (greyed)    │  │
│  │                                         [Save ▶]   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌── Google Sheets Integration ───────────────────────┐  │
│  │  Status:  ● Connected                              │  │
│  │  ─────────────────────────────────────────────     │  │
│  │  Patient List         Last sync: 2 min ago         │  │
│  │                                      [Sync Now]    │  │
│  │  Daily Appointments   Last sync: 8 min ago         │  │
│  │                                      [Sync Now]    │  │
│  │  Payments             Last sync: 45 min ago        │  │
│  │                                      [Sync Now]    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌── Notification Preferences ────────────────────────┐  │
│  │  Appointment reminder — 24 hours            [● ON] │  │
│  │  Appointment reminder — 2 hours             [● ON] │  │
│  │  Payment receipt                            [● ON] │  │
│  │  Package expiry warning                     [● ON] │  │
│  │  Birthday greeting                          [● ON] │  │
│  │  Welcome message                            [● ON] │  │
│  │                                         [Save ▶]   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌── Danger Zone ─────────────────────────────────────┐  │
│  │  (red border, pink background)                     │  │
│  │  [Export All Data]    [✉ Contact Support]          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Validation Rules

### Clinic Information

| Field | Rules |
|---|---|
| Clinic Name | Required; min 2 chars; max 100 chars; no special characters except `-`, `.`, `'` |
| Address | Required; min 5 chars; max 200 chars |
| Phone | Required; Egyptian format: starts with `01` and is 11 digits, or international format `+20XXXXXXXXX` |
| Logo | Optional; if provided: type must be `image/jpeg`, `image/png`, or `image/webp`; max size 2 MB; min dimensions 100×100px |

### Business Hours

| Field | Rules |
|---|---|
| Day toggle | No validation — any combination of open/closed days is valid |
| Open time | Required when day is marked Open; must be a valid time (`HH:MM`); 15-minute increments preferred but not enforced |
| Close time | Required when day is marked Open; must be after Open time by at least 30 minutes; inline error: "Closing time must be at least 30 minutes after opening time" |
| Cross-day | All 7 days are saved atomically; if any time range fails validation, the Save button is blocked and the error is shown inline on the failing row |

### Notification Preferences

- No validation beyond boolean value — each toggle is simply on or off
- The PATCH request sends all 6 preference values together, not individually

### Logo Upload Client-Side Rejection

File is rejected before any API call if:
- File size > 2,097,152 bytes (2 MB)
- MIME type is not one of `image/jpeg`, `image/png`, `image/webp`
- File is not a recognized image (verified by reading magic bytes client-side)

---

## Navigation Flows (Entry & Exit Points)

### Entry Points

| Source | How |
|---|---|
| Sidebar navigation | "Settings" link visible to Admin role only; uses `Settings` Lucide icon |
| Admin dashboard | "Configure" shortcut card on Dashboard for Admin role |

### Exit Points

| Destination | Trigger |
|---|---|
| Dashboard (`/dashboard`) | Browser back button or breadcrumb |
| Staff management (`/staff`) | No direct link from Settings; user navigates via sidebar |
| Help page (`/help/google-sheets-setup`) | "Learn more" link in Disconnected state banner |
| Email client | "Contact Support" button in Danger Zone (`mailto:` link) |

### Unsaved Changes Warning

If the user navigates away from the page while any section has unsaved changes (form state differs from the loaded values), a browser-native `beforeunload` confirmation fires: "You have unsaved changes. Are you sure you want to leave?" This is implemented via the `useBeforeUnload` hook from React Router / Next.js navigation events.

---

## Responsive Behavior

### Desktop (1024px+)

- All sections rendered in a single scrollable column, max-width 800px, centered
- Clinic Information: label on the left, input on the right in a two-column form grid
- Business Hours: day name (fixed 120px), switch (48px), "Open" label (48px), time inputs (2×120px), gap between times shows "→" arrow
- Save buttons right-aligned within each section card

### Tablet (768px–1023px)

- Single-column layout (same as desktop but without the two-column form grid for Clinic Information — labels stack above inputs)
- Business Hours rows remain single-row but time inputs shrink to native mobile width
- Save buttons full-width

### Mobile (320px–767px)

- All form fields are full-width
- Business Hours time pickers use native `<input type="time">` which presents the OS time picker on mobile (avoids custom picker complexity)
- Each section card has reduced padding (16px instead of 24px)
- Save buttons are full-width, placed at the bottom of each section
- The Danger Zone section is collapsed by default (accordion) with an "Expand" chevron to reduce accidental interaction on mobile
- Google Sheets sync rows stack vertically: sheet name on one line, last sync timestamp below it, "Sync Now" button below that (full-width)

### RTL (Arabic)

- All section labels right-align
- Inputs remain LTR for phone numbers and URLs; other text inputs switch to RTL
- Business Hours "→" separator becomes "←" in RTL
- Save buttons appear on the left side of the section card (which is visually the "end" side in RTL)
- Logo preview remains circular and centered regardless of direction
- Switch components work the same functionally; their track direction does not change in RTL (per Shadcn/Radix behavior)

---

## Accessibility Notes

### Form Structure

Each section is wrapped in a `<section>` element with an `aria-labelledby` pointing to the section heading:

```html
<section aria-labelledby="section-clinic-info">
  <h2 id="section-clinic-info">Clinic Information</h2>
  <!-- form fields -->
</section>
```

This allows screen reader users to navigate between sections using heading shortcuts.

### Input Labels

All form inputs have explicit `<label>` elements associated via `htmlFor` / `id` pairing. Placeholder text is used as a hint only and is never the sole label.

### Switch (Toggle) Components

Each `Switch` component has:
- `aria-label="Enable appointment reminder — 24 hours"` (combines the action + the preference name)
- `aria-checked="true"` / `aria-checked="false"` (managed by Radix UI `Switch`)

### Save Buttons

- During saving: `aria-busy="true"` is set on the button; button text changes to "Saving…" for screen readers (`sr-only` span)
- On success: focus remains on the button; a `role="status"` live region announces "Settings saved."

### Logo Upload

- The file input has `aria-label="Upload clinic logo"` and `accept=".jpg,.jpeg,.png,.webp"`
- After selection, a visually hidden status announcement reads "Logo selected: filename.png. Preview updated."
- After upload success: "Logo uploaded successfully."

### Color Independence

- The Google Sheets status badge uses both color (green/red) and text ("Connected" / "Disconnected") plus an icon — color alone does not convey the state
- The Danger Zone section uses a red border and background as a secondary visual cue; its heading "Danger Zone" makes the purpose clear without relying on color

### Focus Management

- When the Confirm Export dialog opens, focus moves to the dialog and is trapped inside it
- When the dialog is dismissed (Cancel or Export), focus returns to the "Export All Data" button
- All interactive elements have a visible `focus-visible` ring using `outline: 2px solid #0891B2`

---

*DOC-06-P19 · v0.2 · 2026-05-24 · Physical Therapy Clinic Management System*

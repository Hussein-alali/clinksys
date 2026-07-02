# Page: Campaign Create (Wizard)

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P15 |
| **Version** | 0.2 — In Progress |
| **Status** | In Progress |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Campaign Create (Wizard) page. |
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
| **URL Route** | `/campaigns/new` |
| **Next.js File** | `app/(dashboard)/campaigns/new/page.tsx` |
| **Authentication** | Required — redirect to `/login` if unauthenticated |
| **Authorized Roles** | Admin only |
| **Query Params** | `?duplicate_from={id}` (pre-fills wizard from existing campaign); `?edit={id}` (loads draft for editing) |

Non-Admin sessions are redirected server-side to `/dashboard`. The wizard state is managed client-side only (Zustand store); no partial-save drafts are written to the database until the user completes Step 5 and clicks "Launch Campaign" or explicitly saves as a draft from any step.

---

## Page Purpose

The Campaign Create Wizard is a 5-step guided flow that allows the Admin to build and launch a targeted WhatsApp marketing campaign. The wizard breaks the campaign creation process into discrete, cognitively manageable steps to minimize errors and ensure that every required piece of information is collected before a campaign is dispatched to patients.

**The five steps and their responsibilities:**

1. **Audience Filter** — Define who receives the campaign by selecting one of 14 predefined patient-segment filters. An estimated recipient count is shown immediately after filter selection to set expectations before committing.

2. **Message Template** — Choose the WhatsApp message template to send. Templates are pre-approved Arabic messages with optional variable substitution (e.g., patient name, appointment date).

3. **Preview** — Review the final composed message in a simulated WhatsApp phone frame, with variables replaced by real sample data. Catch template variable resolution issues before sending.

4. **Schedule** — Choose to send immediately or schedule for a future date and time. Timezone is fixed to Cairo Time (Africa/Cairo, UTC+2/UTC+3 DST).

5. **Confirm** — Final summary of all selections (audience, template, schedule, estimated recipient count) before launching. The launch action cannot be undone.

The wizard also supports two pre-fill modes:
- **Duplicate mode** (`?duplicate_from={id}`): All steps are pre-populated from an existing campaign; the Admin can modify any step before launching
- **Edit mode** (`?edit={id}`): Loads a saved draft campaign; on launch, the draft is updated and sent rather than creating a new record

---

## Data Fetching (API Endpoints Consumed)

### Step 1 — Audience Filter

| Action | Method | Endpoint | Params | Notes |
|---|---|---|---|---|
| Estimate recipient count | GET | `/api/campaigns/estimate` | `?filter={filter_key}` | Returns `{ count: 47 }` |

Fired immediately when a filter card is selected; debounced by 300ms to prevent rapid-fire requests during keyboard navigation.

### Step 2 — Message Template

| Action | Method | Endpoint | Notes |
|---|---|---|---|
| Load available templates | GET | `/api/message-templates?active=true` | Returns array of template objects with `id`, `name`, `body`, `variables[]` |

Templates are fetched once on component mount and cached for the duration of the wizard session.

### Step 3 — Preview

No API call. The preview is generated client-side by interpolating sample data into the selected template's body string. Sample data used:

| Variable | Sample Value |
|---|---|
| `{{patient_name}}` | سارة محمود |
| `{{appointment_date}}` | الاثنين، 3 يونيو 2026 |
| `{{appointment_time}}` | 10:00 صباحاً |
| `{{clinic_name}}` | عيادة العلاج الطبيعي |
| `{{therapist_name}}` | د. أحمد علي |

### Step 4 — Schedule

No API call. The datetime picker is purely client-side; the scheduled time is stored in wizard state and submitted in the final Step 5 payload.

### Step 5 — Confirm & Launch

| Action | Method | Endpoint | Payload | Notes |
|---|---|---|---|---|
| Launch campaign (new) | POST | `/api/campaigns` | Full campaign object | Creates campaign record + triggers n8n send flow |
| Launch campaign (edit/duplicate) | PUT | `/api/campaigns/:id` | Full campaign object | Updates draft record + triggers send |

**Payload structure:**
```json
{
  "name": "June Recall Campaign",
  "audience_filter": "inactive_30",
  "template_id": "uuid",
  "schedule_type": "now",
  "scheduled_at": null,
  "status": "running"
}
```

For scheduled campaigns, `schedule_type` is `"scheduled"` and `scheduled_at` contains the ISO 8601 datetime string.

### Pre-fill Load (Duplicate / Edit)

| Action | Method | Endpoint | Notes |
|---|---|---|---|
| Load campaign for pre-fill | GET | `/api/campaigns/:id` | Returns full campaign object including audience_filter, template_id, scheduled_at |

Fired on page mount when `?duplicate_from` or `?edit` query param is present.

---

## Component Breakdown

### Wizard Shell

| Component | Source | Role |
|---|---|---|
| `WizardProgressBar` | Internal | Horizontal step indicator at top of page; 5 steps; active step is filled cyan, completed steps are green with checkmark, future steps are grey |
| `WizardStepLabel` | Internal | Step label below each dot: "Audience", "Template", "Preview", "Schedule", "Confirm" |
| `WizardStepContent` | Internal | Renders the active step component |
| `WizardFooter` | Internal | "Back" button (left) + "Next" / "Launch Campaign" button (right); "Save as Draft" link (center) |

### Step 1 — Audience Filter

| Component | Source | Role |
|---|---|---|
| `AudienceFilterGrid` | Internal | 2-column grid (1-column on mobile) of selectable audience filter cards |
| `AudienceFilterCard` | Internal | Card with Lucide icon + title + description; selected state: `border-cyan-600 bg-cyan-50` with `CheckCircle` icon in top-right corner |
| `RecipientEstimateBadge` | Internal | Shown below the grid after a filter is selected; renders "Estimated recipients: 47 patients" with `Users` icon |
| `EstimateLoadingSpinner` | Internal | `Loader2` icon shown while estimate API call is in flight |

**The 14 audience filter cards:**

| Filter Key | Icon | Title | Description |
|---|---|---|---|
| `all_active` | `Users` | All Active Patients | Send to all currently active patients |
| `inactive_30` | `UserX` | Inactive (30+ days) | Patients with no appointment in 30+ days |
| `inactive_60` | `UserX` | Inactive (60+ days) | Patients with no appointment in 60+ days |
| `inactive_90` | `UserX` | Inactive (90+ days) | Patients with no appointment in 90+ days |
| `expiring_packages` | `Package` | Expiring Packages | Packages expiring within 7 days |
| `expired_packages` | `Package` | Expired Packages | Patients with an expired package |
| `overdue_payments` | `AlertCircle` | Overdue Payments | Patients with outstanding balance |
| `birthday_month` | `Gift` | Birthday This Month | Patients celebrating birthday this month |
| `new_patients_30` | `UserPlus` | New Patients (30 days) | Patients registered in the last 30 days |
| `completed_treatment` | `ClipboardCheck` | Completed Treatment | Patients who completed their treatment plan |
| `no_show_last` | `CalendarX` | Recent No-Shows | Patients who missed their last appointment |
| `pending_followup` | `Bell` | Pending Follow-Up | Patients flagged for follow-up by a doctor |
| `specific_therapist` | `Stethoscope` | By Therapist | Patients of a specific therapist (sub-select shown on pick) |
| `custom_segment` | `Filter` | Custom Segment | Manual filter by multiple criteria |

When `specific_therapist` is selected, an additional `TherapistSelect` dropdown appears below the grid.

### Step 2 — Message Template

| Component | Source | Role |
|---|---|---|
| `TemplateGrid` | Internal | 2-column grid of template cards |
| `TemplateCard` | Internal | Template name (bold, `text-teal-900`) + Arabic body text truncated to 3 lines (`line-clamp-3`); selected state: `border-cyan-600 bg-cyan-50` + `CheckCircle` overlay |
| `TemplateFullPreviewTooltip` | Internal | On hover/focus, shows a popover with the full untruncated template body |
| `CreateNewTemplateLink` | Internal | Link: "Create new template →" navigating to `/templates/new` in a new tab; only shown to Admin |

Template card selected state uses `ring-2 ring-cyan-600` in addition to the border change to ensure visibility without relying on color alone.

### Step 3 — Preview

| Component | Source | Role |
|---|---|---|
| `WhatsAppPhoneFrame` | Internal | SVG/CSS phone frame mockup (320px wide, centered) |
| `WhatsAppMessageBubble` | Internal | Right-aligned chat bubble with `bg-[#DCF8C6]` (WhatsApp green), Arabic message body, sender name, and timestamp |
| `UnresolvedVariableWarning` | Internal | Amber alert shown below the frame if any `{{variable}}` in the template was not replaced by sample data |

**Phone frame mockup:**
```
┌──────────────────────────┐
│  WhatsApp Preview        │
│  ────────────────────    │
│  عيادة العلاج الطبيعي    │
│                          │
│  ┌──────────────────┐    │
│  │ مرحباً سارة،     │    │
│  │ نذكرك بموعدك     │    │
│  │ الاثنين 10:00    │    │
│  │          ✓ 10:30│    │
│  └──────────────────┘    │
└──────────────────────────┘
```

The `✓` (single check) represents "Sent" status in the preview — not "Read" — to set accurate expectations.

### Step 4 — Schedule

| Component | Source | Role |
|---|---|---|
| `ScheduleOptionCards` | Internal | Two large radio-card options (60px height): "Send Now" and "Schedule for Later" |
| `RadioCard` | Internal | Styled radio input with visible selection border; `aria-checked` managed |
| `DateTimePicker` | Internal | Shown only when "Schedule for Later" is selected; date picker + 12-hour time selector |
| `TimezoneDisplay` | Internal | Static label: "Cairo Time (UTC+2)" — not selectable; timezone is fixed |

**"Send Now" card:**
- Icon: `Zap` (Lucide)
- Title: "Send Now"
- Description: "Campaign will start immediately after you confirm."

**"Schedule for Later" card:**
- Icon: `CalendarClock` (Lucide)
- Title: "Schedule"
- Description: "Choose a date and time to send this campaign."

When "Schedule for Later" is selected, the `DateTimePicker` animates into view (`height` transition, 200ms ease-out).

### Step 5 — Confirm

| Component | Source | Role |
|---|---|---|
| `CampaignSummaryCard` | Internal | Full-width card listing all campaign parameters |
| `SummaryRow` | Internal | Icon + label + value for each parameter |
| `LaunchButton` | Internal | Full-width, `bg-cyan-600` button; shows `Loader2` during POST; disabled during loading |
| `BackToEditLink` | Internal | Text link: "← Back to edit" that returns to Step 1 |

**Summary rows displayed:**

| Icon | Label | Example Value |
|---|---|---|
| `Users` | Audience | Inactive patients (30+ days) · 47 recipients |
| `MessageSquare` | Template | Appointment Re-engagement · Arabic |
| `Clock` | Schedule | Send Now — or — Monday, Jun 3, 2026 at 10:00 AM |
| `Send` | Estimated Messages | 47 messages via Twilio |

---

## UI States (Loading, Empty, Error, Success)

### Wizard Load — Skeleton (Pre-fill mode)

When `?duplicate_from` or `?edit` is present and the campaign is being fetched:
- The entire Step 1 grid shows skeleton cards (grey shimmer)
- The "Next" button is disabled until the pre-fill data arrives
- A `Loader2` spinner appears in the center of the step content area

### Step 1 — Estimate Loading

When a filter card is selected and the estimate API is in flight:
- The `RecipientEstimateBadge` shows a skeleton/spinner: `Loader2` + "Calculating recipients…"
- The "Next" button remains disabled until the estimate resolves
- If estimate fails: `toast.error("Could not estimate recipients.")` fires; "Next" remains disabled; a "Retry" link appears next to the badge

### Step 1 — Zero Recipients

If the estimate returns `{ count: 0 }`:
- The badge displays: "No patients match this filter."
- The "Next" button remains disabled
- An amber inline alert below the badge reads: "This audience filter matches 0 patients. Select a different filter to continue."

### Step 2 — Template Load Error

If `GET /api/message-templates` fails:
- The template grid area shows an error state: `AlertCircle` icon + "Failed to load templates. Please try again." + "Retry" button

### Step 3 — Unresolved Variables Warning

If the template body contains a `{{variable}}` that does not exist in the sample data map:
- An amber `AlertTriangle` warning appears below the phone frame: "Warning: The variable {{xyz}} could not be resolved. Contact your admin to update the template."
- The "Next" button is NOT blocked by this warning — it is informational only, not a hard blocker

### Step 4 — Invalid Schedule Time

If the scheduled datetime is less than 5 minutes in the future:
- Inline error below the time picker: "Please schedule at least 5 minutes from now."
- "Next" button is disabled

### Step 5 — Launch Error

If `POST /api/campaigns` fails:
- The `LaunchButton` re-enables
- An error alert renders inside the summary card: `AlertCircle` (red) + "Failed to launch campaign. Please check your connection and try again."
- `toast.error("Campaign launch failed.")` fires

### Step 5 — Launch Success

On `201 Created` response:
- A full-page success state briefly renders (500ms): centered `CheckCircle` icon (green, 64px) + "Campaign Launched!" + redirect countdown
- Automatically navigates to `/campaigns/{new_id}` after 1.5 seconds
- A `toast.success("Campaign launched successfully.")` fires on the destination page

---

## Layout Wireframe / Mockup Reference

```
┌────────────────────────────────────────────────────────────┐
│  ● ─────── ○ ─────── ○ ─────── ○ ─────── ○              │
│ Audience  Template  Preview  Schedule  Confirm             │
│ (Step 1 active)                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Select your audience                                      │
│  ┌───────────────────┐  ┌───────────────────┐            │
│  │ [Users icon]      │  │ [UserX icon]      │            │
│  │ All Active        │  │ Inactive (30d+)   │            │
│  │ Patients          │  │                   │            │
│  │ Send to all       │  │ No appt 30+ days  │            │
│  │ active patients   │  │                   │            │
│  └───────────────────┘  └───────────────────┘            │
│  ┌───────────────────┐  ┌───────────────────┐            │
│  │ [Package icon]    │  │ [AlertCircle]     │            │
│  │ Expiring          │  │ Overdue           │            │
│  │ Packages          │  │ Payments          │            │
│  └───────────────────┘  └───────────────────┘            │
│  ... (14 cards total, 2 columns)                          │
│                                                            │
│  ● Estimated recipients: 47 patients                       │
│                                                            │
├────────────────────────────────────────────────────────────┤
│  [← Back]  [Save as Draft]          [Next: Template →]    │
└────────────────────────────────────────────────────────────┘
```

**Progress bar dot states:**
- Completed step: `bg-green-500` circle + `Check` icon (white, 12px)
- Active step: `bg-cyan-600` circle + step number (white)
- Future step: `bg-slate-200` circle + step number (`text-slate-400`)
- Line connecting steps: `bg-green-500` for completed segments, `bg-slate-200` for upcoming

---

## Validation Rules

### Step 1 — Audience Filter

| Rule | Error Message |
|---|---|
| A filter must be selected | "Please select an audience filter to continue." |
| Estimated recipient count must be > 0 | "This audience filter matches 0 patients. Select a different filter." |
| If `specific_therapist` selected: therapist must be chosen | "Please select a therapist to continue." |

### Step 2 — Message Template

| Rule | Error Message |
|---|---|
| A template must be selected | "Please select a message template to continue." |

### Step 4 — Schedule

| Rule | Error Message |
|---|---|
| One of "Send Now" or "Schedule" must be selected | "Please select when to send the campaign." |
| If "Schedule": date and time must be provided | "Please select a date and time." |
| If "Schedule": datetime must be at least 5 minutes in the future | "Please schedule at least 5 minutes from now." |
| If "Schedule": datetime cannot be more than 90 days in the future | "Campaigns cannot be scheduled more than 90 days in advance." |

### General Wizard Rules

- The "Next" button is blocked on each step until the step's required selection is valid
- The "Back" button is always active (except on Step 1 where it navigates to `/campaigns`)
- "Save as Draft" is available on steps 1–4; it saves the current partial wizard state as a `draft` campaign and navigates to `/campaigns`. Minimum required: a campaign name (auto-generated as "Draft Campaign — {today's date}" if not yet named)
- On browser back/refresh: a `beforeunload` dialog warns "Your campaign will be lost. Are you sure you want to leave?"

---

## Navigation Flows (Entry & Exit Points)

### Entry Points

| Source | How |
|---|---|
| Campaigns List | Click "+ New Campaign" button |
| Campaigns List — Duplicate | Click Duplicate icon on a row → `/campaigns/new?duplicate_from={id}` |
| Campaigns List — Edit Draft | Click Edit icon on a Draft row → `/campaigns/new?edit={id}` |
| Template Management | "Create Campaign using this template" link → `/campaigns/new?template_id={id}` (Step 2 pre-selected) |

### Exit Points

| Destination | Trigger |
|---|---|
| Campaign Detail (`/campaigns/:id`) | Successful launch (auto-redirect after 1.5s) |
| Campaigns List (`/campaigns`) | "Save as Draft" action; or "Back" on Step 1; or confirming the `beforeunload` dialog |
| Template Create (`/templates/new` — new tab) | "Create new template" link in Step 2 |

---

## Responsive Behavior

### Desktop (1024px+)

- Wizard shell max-width 720px, centered in the content area
- Audience filter grid: 2-column card grid with 16px gap
- Template grid: 2-column card grid
- Progress bar: full horizontal span with all 5 step labels visible
- Phone preview (Step 3): centered at 320px width, surrounded by instructional copy

### Tablet (768px–1023px)

- Wizard shell fills available width with 24px horizontal padding
- Audience filter grid: 2-column on tablet
- Progress bar: all 5 labels visible (truncated to first word if needed)

### Mobile (320px–767px)

- Wizard shell fills full viewport width with 16px horizontal padding
- Audience filter grid: single column (1 card per row)
- Template grid: single column
- Progress bar: step dots visible but labels are hidden; active step label shown below the bar in a separate line: "Step 2 of 5 — Template"
- Phone preview (Step 3): phone frame scales to fit viewport width (max 280px)
- "Back" and "Next" buttons are each 50% width, side-by-side in the wizard footer
- "Save as Draft" link centered below the Back/Next buttons

---

## Accessibility Notes

### Wizard Progress

The progress bar uses `role="navigation"` and `aria-label="Campaign creation progress"`:

```html
<nav role="navigation" aria-label="Campaign creation progress">
  <ol>
    <li aria-current="step">Audience</li>
    <li>Template</li>
    ...
  </ol>
</nav>
```

`aria-current="step"` marks the active step for screen readers.

### Audience Filter Cards

Each card is a `<button>` element (not a `<div>`):
```html
<button
  role="radio"
  aria-checked="false"
  aria-label="Inactive patients — 30 or more days. Patients with no appointment in 30 or more days."
  class="filter-card">
```

The card grid uses `role="radiogroup"` with `aria-label="Select audience filter"`. Arrow key navigation moves between cards within the group.

### Template Cards

Same pattern as Audience Filter cards — `role="radiogroup"` + `role="radio"` + `aria-checked`.

### WhatsApp Phone Frame (Step 3)

The phone frame is decorative. The actual composed message is also rendered as accessible text in a visually hidden `<div role="region" aria-label="Message preview">` below the frame. This ensures screen reader users can hear the message content without navigating through the decorative frame structure.

### Date/Time Picker (Step 4)

- Date input: `aria-label="Campaign send date"` + `aria-describedby="date-hint"` where `date-hint` contains "Select a date at least 5 minutes from now, in Cairo Time."
- Time input: `aria-label="Campaign send time"`
- Validation error is announced via `role="alert"` on the inline error element

### Launch Button (Step 5)

- Default state: `aria-label="Launch campaign — send to 47 recipients"`
- Loading state: `aria-label="Launching campaign"`, `aria-busy="true"`, button disabled
- The recipient count in the `aria-label` is updated when the audience estimate changes

### Focus Management Between Steps

When "Next" is clicked and the wizard advances to the next step:
- Focus moves to the step heading (`<h2>`) of the new step using `element.focus()` after the step transition completes
- This announces the new step name to screen reader users and places keyboard focus at the top of the new content

### Color Independence

- Selected filter/template cards use both a cyan border (`ring-2 ring-cyan-600`) and a `CheckCircle` icon with visible text label — selection state is never conveyed by color alone
- The progress bar uses both color (green for completed) and a `Check` icon inside completed step dots

### RTL Notes

- In Arabic layout, the wizard footer "Back" button is on the right, "Next" is on the left (reversed from LTR)
- The phone frame message bubble (`WhatsAppMessageBubble`) remains right-aligned regardless of document direction, since WhatsApp Arabic messages are inherently RTL
- The progress bar step sequence reads right-to-left in Arabic layout
- Audience filter card text switches to Arabic translations of the card labels and descriptions

---

*DOC-06-P15 · v0.2 · 2026-05-24 · Physical Therapy Clinic Management System*

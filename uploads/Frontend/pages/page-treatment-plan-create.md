# Page: Treatment Plan Create

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P08 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Treatment Plan Create page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P1 |
| **Estimated Pages** | 4–8 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |

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

| Property | Value |
|---|---|
| **URL Route** | `/treatment-plans/new` |
| **Auth Required** | Yes |
| **Allowed Roles** | Doctor, Admin |
| **Unauthorized Redirect** | Other roles → `/patients`; unauthenticated → `/` |
| **RTL Support** | Yes |

---

## Page Purpose

The Treatment Plan Create page enables doctors and admins to prescribe a structured treatment plan for a patient. It captures the clinical diagnosis, therapeutic goals, assigned therapist, session count, and the specific treatment methods to be applied. The right-side preview panel gives immediate feedback on the treatment composition, and a warning is shown if the patient already has an active plan to prevent accidental duplicates.

Upon successful submission, the plan is created with `status = active`, a Supabase record is inserted, and an n8n webhook is triggered to notify the assigned therapist and update the Google Sheets integration.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Patient search | `patients` WHERE `full_name.ilike.%q% OR file_number.ilike.%q%` LIMIT 10 | Combobox type, 300ms debounce |
| Active plan check | `treatment_plans` WHERE `patient_id = [id] AND status = active` COUNT | Patient selected from combobox |
| Active therapists | `profiles` WHERE `role = therapist AND status = active` | Page load |
| Treatment methods catalog | `treatment_methods` ORDER BY `category, name` | Page load |
| Submit — create plan | INSERT into `treatment_plans` + INSERT into `plan_treatment_methods` (junction) | Form submit |
| n8n webhook | POST `[n8n_webhook_url]/treatment-plan-created` with plan data | After successful INSERT |

---

## Component Breakdown

### Page Header
- `<PageHeader>`: `<h1>` "New Treatment Plan" + breadcrumb "Treatment Plans → New Plan"
- No action buttons in header

### Main Layout
Desktop: `grid grid-cols-3 gap-8` — left 2 cols = form, right 1 col = preview panel. Mobile: single column (preview panel moves below form, collapsed by default in an accordion).

### Form Section 1 — Patient Selection
- `<label>` "Patient *"
- `<Combobox>` (Shadcn `<Popover>` + `<Command>`): type to search by name or file number. Renders matching results as `[File#] Full Name` rows. On select, popover closes and selected patient shown as a chip with `X` to clear.
- **Active Plan Warning** (conditional): after patient is selected, if they have an active plan, render:
  `<Alert variant="warning" className="border-yellow-400 bg-yellow-50">` `<AlertTriangle>` "This patient already has an active treatment plan. Creating a new plan will not automatically close the existing one. [View existing plan →]"`

### Form Section 2 — Clinical Details
- **Diagnosis*** `<Textarea>` — 4 rows, min 20 chars, max 1000 chars. Character counter.
- **Goals*** `<Textarea>` — 3 rows, min 10 chars, max 500 chars. Placeholder: "Describe the expected outcomes of treatment."
- **Notes** `<Textarea>` — 3 rows, optional. Placeholder: "Any additional clinical notes or instructions for the therapist."

### Form Section 3 — Assignment & Schedule
- **Therapist*** `<Select>` — options from active therapists query. Width full.
- **Start Date*** `<DatePicker>` — defaults to today. Cannot be more than 30 days in the past.
- **Expected End Date** `<DatePicker>` — optional. Must be after Start Date if provided. Hint text: "Optional — estimated completion date."

### Form Section 4 — Sessions Prescribed
- **Sessions Prescribed*** `<Input type="number">` — min 1, max 100, step 1. Displays below: "Estimated duration at 1 session/week: X weeks."

### Form Section 5 — Treatment Methods
- Section heading: "Treatment Methods *" + "At least 1 method required" hint in `text-xs text-slate-500`.
- 13 method cards rendered in a responsive `grid grid-cols-2 gap-3` (desktop: 3 cols).
- Each method card: `<button role="checkbox" aria-checked>` with:
  - `<Badge variant="outline">` category color chip (e.g., "Manual Therapy" = teal, "Electrotherapy" = blue, "Exercise" = green)
  - Method name (Figtree 500 14px)
  - Default duration chip: "30 min" / "45 min" etc.
  - Selected state: `border-2 border-cyan-600 bg-cyan-50 shadow-sm`
  - Unselected: `border border-slate-200 bg-white hover:border-slate-300`
- Selected methods also appear as removable `<Badge>` chips in a "Selected Methods" strip above the grid, with `X` button per chip.
- Selected methods count badge in section heading: "Treatment Methods (3 selected)"

### Right Preview Panel (Desktop)
`<Card className="sticky top-6">` — "Plan Summary" heading.
- Patient name (if selected)
- Therapist name (if selected)
- Sessions: X prescribed
- Estimated total: "X sessions × avg duration = ~Y hours"
- Selected methods list: each as a `<li>` with method name + duration
- "Estimated completion" (if end date set)

---

## UI States (Loading, Empty, Error, Success)

### Patient Combobox — Loading
`<Loader2 animate-spin>` inside the dropdown while search query is in flight.

### Patient Combobox — No Results
"No patients found matching '[query]'." inside the dropdown.

### Active Plan Warning
Yellow `<Alert>` appears below the combobox immediately after patient with active plan is selected.

### Methods — None Selected (Submit Attempt)
Section heading turns red: "Treatment Methods * — At least 1 method required." Section highlighted with `border-red-300`.

### Submit — Loading
Full-form disable + submit button: `<Loader2>` + "Creating Plan…". Brief (500ms) then either success or error.

### Submit — Success
Toast: "Treatment plan created successfully." + navigate to `/treatment-plans/[newPlanId]`.

### Submit — Error
Toast (red): "Failed to create treatment plan. Please try again." Form re-enabled.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  Treatment Plans > New Plan                             │
│            │  ─────────────────────────────────────────             │
│            │  ┌──────────────────────────────┐ ┌───────────────┐   │
│            │  │ 1. Patient                   │ │ Plan Summary  │   │
│            │  │  [Search patient...     ▼]   │ │               │   │
│            │  │  [⚠ Active plan warning]     │ │ Patient: —    │   │
│            │  │                              │ │ Therapist: —  │   │
│            │  │ 2. Clinical Details          │ │ Sessions: —   │   │
│            │  │  Diagnosis* [textarea]       │ │               │   │
│            │  │  Goals*     [textarea]       │ │ Methods:      │   │
│            │  │  Notes      [textarea]       │ │  · —          │   │
│            │  │                              │ │               │   │
│            │  │ 3. Assignment                │ │ Est. total:   │   │
│            │  │  Therapist* [Select ▼]       │ │ — hours       │   │
│            │  │  Start Date [picker]         │ └───────────────┘   │
│            │  │  End Date   [picker]         │                      │
│            │  │                              │                      │
│            │  │ 4. Sessions Prescribed       │                      │
│            │  │  [  12  ] sessions           │                      │
│            │  │                              │                      │
│            │  │ 5. Treatment Methods (0)     │                      │
│            │  │  [TENS][Manual][Exercise]... │                      │
│            │  │                              │                      │
│            │  │          [Cancel] [Create Plan] │                   │
│            │  └──────────────────────────────┘                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

| Field | Rule | Error |
|---|---|---|
| Patient | Required, must exist | "Please select a patient." |
| Diagnosis | Required, 20–1000 chars | "Diagnosis must be at least 20 characters." |
| Goals | Required, 10–500 chars | "Please describe the treatment goals." |
| Therapist | Required, active therapist | "Please assign a therapist." |
| Start Date | Required, not more than 30 days past | "Please select a valid start date." |
| Expected End Date | Must be after Start Date if provided | "End date must be after start date." |
| Sessions Prescribed | Required, integer 1–100 | "Sessions must be between 1 and 100." |
| Treatment Methods | At least 1 required | "Select at least one treatment method." |

Client-side Zod schema + React Hook Form. Server-side re-validation on submit.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- "Create Plan" button from Treatment Plans list or Patient Profile (Treatment Plans tab)
- Direct URL `/treatment-plans/new`
- Optional: `?patientId=[id]` pre-fills the patient combobox

### Exit Points
- Submit success → `/treatment-plans/[newPlanId]`
- "Cancel" → `/treatment-plans` (or back if `?patientId` was set, back to `/patients/[id]`)
- Dirty form navigation guard: confirmation dialog on unsaved exit

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Single column. Preview panel moves below all form sections, inside a collapsed `<Accordion>` "Plan Preview". Treatment method cards: 2-column grid. Submit/Cancel full-width stacked. |
| Tablet (`640px–1024px`) | Single column form + preview panel on right (1/3 width). Method cards: 2-column grid. |
| Desktop (`> 1024px`) | 2/3 + 1/3 split. Method cards: 3-column grid. |

---

## Accessibility Notes

- Patient combobox: `role="combobox"`, `aria-expanded`, `aria-autocomplete="list"`, `aria-activedescendant`. Options list `role="listbox"`.
- Active plan warning: `role="alert"` to announce immediately on patient selection.
- Treatment method cards as `<button role="checkbox" aria-checked="true|false">` with keyboard toggle (Space).
- "Selected Methods" strip: each chip `<Badge>` has `aria-label="Remove [method name]"` on its X button.
- All textareas: `aria-describedby` pointing to character counter.
- Required fields: `aria-required="true"`, asterisk has `aria-hidden="true"` with separate `<span className="sr-only">required</span>`.
- Submit button: `aria-busy="true"` + `aria-disabled="true"` when loading.

### RTL Considerations
- Two-column form layout mirrors: preview panel appears on the left in RTL.
- Combobox dropdown text right-aligned.
- Treatment method cards: category badge and method name right-aligned.
- Textarea inputs use `dir="rtl"` when `lang=ar` for Arabic text entry.
- Selected chips strip: chips flow right-to-left.
- Date pickers use Arabic calendar locale (`ar-EG`).

---

*DOC-06-P08 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*

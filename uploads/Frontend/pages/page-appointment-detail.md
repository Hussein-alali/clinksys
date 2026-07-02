# Page: Appointment Detail

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P07 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Appointment Detail side sheet. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P0 |
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
| **Surface** | Shadcn `<Sheet>` sliding panel — not a standalone page |
| **Trigger** | Click on an appointment card in the calendar, or from the dashboard activity feed |
| **URL State** | Optional: `?appointment=[id]` query param appended when sheet opens, enabling shareable deep-links and browser back to close |
| **Auth Required** | Yes (inherits session from parent page) |
| **Allowed Roles** | Admin (all actions), Receptionist (all actions), Doctor (view + edit clinical fields), Therapist (view + log session), Patient (view own appointment only) |
| **RTL Support** | Yes — sheet slides from left in RTL, content mirrors |

---

## Page Purpose

The Appointment Detail sheet is a contextual overlay that presents the full detail of a single appointment without navigating away from the calendar. It is the primary surface for appointment status management — confirming, completing, cancelling, or marking no-shows — and the entry point to session logging. The sheet design keeps the calendar context visible behind the overlay, reducing disorientation for staff managing a busy schedule.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Appointment detail | `appointments` WHERE `id = [id]` JOIN `patients` (name, phone, id) JOIN `profiles` (doctor name, therapist name) | Sheet open |
| Session log (if completed) | `session_logs` WHERE `appointment_id = [id]` | Sheet open (if status = completed) |
| Status update | PATCH `appointments` SET `status = [new]` WHERE `id = [id]` | Action button click (after confirmation) |
| Cancellation | PATCH `appointments` SET `status = 'cancelled', cancellation_reason = [reason]` | Cancel confirmation submit |
| Edit appointment | PATCH `appointments` SET date/time/doctor/therapist | Edit form submit |

---

## Component Breakdown

### Sheet Container
Shadcn `<Sheet>`:
- `side="right"` (LTR) / `side="left"` (RTL)
- `className="w-[480px] max-w-full"` (full-width on mobile)
- Overlay: `bg-black/40` backdrop
- Opens with `translate-x` slide animation (200ms ease-out)
- Closes on: X button click, Escape key, backdrop click (with unsaved-edit guard)

### Sheet Header
- Left side: `<StatusBadge>` for current appointment status (Pending / Confirmed / Completed / Cancelled / No-show)
- Right side: `<Button variant="ghost" size="icon">` `X` close button, `aria-label="Close appointment details"`

### Body Sections

**1. Patient Section**
- Icon: `User` (Lucide, 16px `text-cyan-600`)
- Patient full name as `<Link href="/patients/[id]" className="text-cyan-600 underline font-medium">` — opens patient profile in same tab
- Phone number `dir="ltr"` with `Phone` icon prefix

**2. Date & Time Section**
- Icon: `Calendar` (Lucide)
- Date: formatted `"Weekday, DD Month YYYY"` (e.g., "Sunday, 24 May 2026")
- Time range: `"09:00 – 10:00"` (start time + duration calculated)
- Duration chip: `"60 min"` `<Badge variant="secondary">`

**3. Clinical Section**
- Icon: `Stethoscope`
- Doctor: name row with `UserCheck` icon
- Therapist: name row with `User` icon
- Treatment Plan (if linked): plan name as link → `/treatment-plans/[planId]`

**4. Notes Section** (rendered only if `notes` is non-empty)
- Icon: `FileText`
- Freetext content in `<p className="text-sm text-slate-600 whitespace-pre-wrap">`

**5. Cancellation Reason** (rendered only if `status = cancelled`)
- Icon: `AlertCircle` `text-red-500`
- Label: "Cancellation Reason" in `text-xs text-slate-500 uppercase`
- Value: cancellation reason text in `text-sm text-red-700 bg-red-50 rounded p-2`

### Action Button Bar
Pinned to the sheet footer (`border-t border-slate-200 pt-4`). Buttons are conditional on status and role:

| Status | Role | Available Actions |
|---|---|---|
| `pending` | Admin / Receptionist | `[Confirm]` (cyan, primary) `[Cancel]` (outline red) |
| `confirmed` | Admin / Receptionist | `[Complete]` (green) `[No-show]` (orange outline) `[Cancel]` (outline red) |
| `completed` | Admin / Receptionist / Therapist | `[View Session Log]` (if log exists) or `[Log Session]` (if no log yet) |
| `cancelled` | Admin / Receptionist | `[Reschedule]` (outline, creates new appointment) |
| `no_show` | Admin / Receptionist | `[Reschedule]` |
| Any | Admin / Receptionist | `[Edit]` icon button (pencil, top-right of sheet body) — opens edit form inline |

### Confirmation Dialogs
Each action that changes status opens a Shadcn `<AlertDialog>`:

**Confirm:** "Are you sure you want to confirm this appointment for [Patient Name] on [Date]?" → [Cancel] [Confirm Appointment]

**Complete:** "Mark this appointment as completed?" → [Cancel] [Mark Complete]

**No-show:** "Mark [Patient Name] as a no-show for this appointment?" → [Cancel] [Mark No-Show]

**Cancel:** Requires mandatory textarea:
- Dialog title: "Cancel Appointment"
- Body: `<Textarea placeholder="Enter cancellation reason (required)..." rows={3}>` — required, min 10 chars
- Buttons: [Back] [Cancel Appointment] (disabled until reason entered)

### Edit Form (Inline)
Clicking "Edit" transforms the sheet body into an edit form:
- Date: `<DatePicker>`
- Time: `<TimePicker>` (HH:MM, 30-min steps)
- Duration: `<Select>` (30 / 45 / 60 / 90 min)
- Doctor: `<Select>` (active doctors)
- Therapist: `<Select>` (active therapists)
- Notes: `<Textarea>`
- Footer: [Cancel Edit] [Save Changes]

---

## UI States (Loading, Empty, Error, Success)

### Sheet Opening — Loading
Sheet slides in immediately. Body shows a skeleton: 3–4 horizontal skeleton bars mimicking the section layout. Header (status badge + X button) renders immediately.

### Action — Loading
Action button shows `<Loader2 animate-spin>` + disabled state while the PATCH request is in flight. Other buttons also disabled to prevent concurrent actions.

### Action — Success
- Sheet status badge updates immediately (optimistic update).
- Toast (Sonner): "[Action] successfully. Appointment status updated." (e.g., "Appointment confirmed.")
- Calendar card in the background updates color to reflect new status (Supabase Realtime or re-fetch).

### Action — Error
Toast (red): "Failed to update appointment. Please try again." Action buttons re-enabled.

### Edit Form — Validation Error
Inline field errors below each invalid field. "Save Changes" button disabled until all fields are valid.

### Edit Form — Success
Toast: "Appointment updated." Sheet exits edit mode, returns to detail view with new values.

---

## Layout Wireframe / Mockup Reference

```
┌───────────────────────────────────────┐
│  [● Confirmed]              [X Close] │
│ ─────────────────────────────────────  │
│  👤 Patient                           │
│     Ahmed Mohamed Ali                 │
│     0501234567                        │
│                                       │
│  📅 Date & Time                       │
│     Sunday, 24 May 2026               │
│     09:00 – 10:00  [60 min]           │
│                                       │
│  🩺 Clinical                          │
│     Doctor: Dr. Khaled Mansour        │
│     Therapist: Sara Kamal             │
│     Plan: Lower Back Recovery Plan    │
│                                       │
│  📝 Notes                             │
│     Patient requested morning slot.   │
│                                       │
│ ─────────────────────────────────────  │
│  [Complete]  [No-show]  [Cancel]      │
└───────────────────────────────────────┘
```

---

## Validation Rules

### Cancellation Reason
- Required (blocking submit), min 10 characters, max 500 characters.
- Shown below textarea: "X / 500 characters" counter.

### Edit Appointment
| Field | Rule |
|---|---|
| Date | Required, cannot be in the past |
| Time | Required, within 08:00–20:00 |
| Duration | Required, one of: 30, 45, 60, 90 min |
| Doctor | Required, must be active |
| Therapist | Required, must be active |
| Conflict | Server validates no therapist conflict at new time slot |

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Click appointment card in monthly calendar
- Click appointment card in day view timeline
- Click appointment row in dashboard activity feed
- Direct URL with `?appointment=[id]` query param

### Exit Points
- X button / Escape key / backdrop click → closes sheet, returns focus to triggering card
- "View Patient" name link → `/patients/[id]` (full navigation)
- "View Session Log" / "Log Session" → `/appointments/[id]/session-log` (full navigation)
- "View Plan" link → `/treatment-plans/[planId]` (full navigation)

---

## Responsive Behavior

| Breakpoint | Behavior |
|---|---|
| Mobile (`< 640px`) | Sheet becomes full-width bottom drawer (`side="bottom"`, `height: 90vh`, with drag handle). Action buttons stack vertically. Edit form fields stack single-column. |
| Tablet (`640px–1024px`) | Sheet at 480px from right, calendar partially visible. Same as desktop. |
| Desktop (`> 1024px`) | Sheet at 480px from right edge. Calendar grid shrinks accordingly (no obscuring). |

---

## Accessibility Notes

- Sheet uses `role="dialog"`, `aria-modal="true"`, `aria-labelledby` pointing to the status badge heading.
- Focus is trapped within the sheet while open (Radix UI `<Sheet>` handles this by default).
- Escape key always closes the sheet (Radix default).
- On sheet open, focus moves to the close button or the first action button.
- On sheet close, focus returns to the appointment card that triggered it.
- Confirmation dialogs: `role="alertdialog"`, focus moves to the primary action button.
- Cancellation textarea: `aria-required="true"`, `aria-describedby` pointing to character count.
- Action buttons: descriptive `aria-label` (e.g., "Confirm appointment for Ahmed Ali on 24 May 2026").

### RTL Considerations
- Sheet slides in from the left (`side="left"`) in RTL layout.
- All section icons remain on the right side in RTL (using `rtl:flex-row-reverse`).
- Patient name link text aligns right.
- Cancellation reason textarea `dir="rtl"` when `lang=ar`.
- Action buttons in footer maintain logical order (primary action leftmost in LTR, rightmost in RTL).

---

*DOC-06-P07 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*

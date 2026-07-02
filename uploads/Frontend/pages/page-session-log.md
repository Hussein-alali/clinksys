# Page: Session Log Form

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P10 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Session Log Form page. |
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
| **URL Route** | `/appointments/[id]/session-log` |
| **Auth Required** | Yes |
| **Allowed Roles** | Therapist (assigned to this appointment only — RLS enforced), Admin |
| **RLS Enforcement** | Therapist can only INSERT/SELECT `session_logs` where the related appointment's `therapist_id = auth.uid()`. |
| **View Mode** | If a session log already exists for this appointment (`session_logs WHERE appointment_id = [id]`), the page renders in read-only view mode instead of the form. A "View only" badge appears in the header. |
| **RTL Support** | Yes |

---

## Page Purpose

The Session Log Form is a mobile-first clinical documentation tool used by therapists immediately after completing a treatment session — typically while still in the treatment room. It captures:

1. Pain levels before and after the session (VAS 0–10 scale).
2. Clinical progress assessment (Improved / Same / Declined / Completed).
3. Treatment methods applied during the session.
4. Free-text clinical notes.
5. Therapist digital signature for accountability and audit trail.

The form is deliberately large-tap-target and minimal-distraction, designed for one-hand phone operation. The submit button is disabled until all required fields (pain level before, progress, signature) are filled to prevent incomplete clinical records.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Appointment detail | `appointments` WHERE `id = [id]` JOIN `patients` (name) JOIN `treatment_plans` (id, methods, session number) | Page load |
| Prescribed methods | `plan_treatment_methods` JOIN `treatment_methods` WHERE `plan_id = [planId]` | Page load |
| Existing session log | `session_logs` WHERE `appointment_id = [id]` | Page load (determines edit vs. view mode) |
| Submit — create log | INSERT into `session_logs` with all field values + signature as base64 or storage URL | Form submit |
| Session count update | Auto-updated via DB trigger: `treatment_plans.sessions_completed++` on `session_logs` INSERT | Server-side trigger |

---

## Component Breakdown

### Page Header
- `<Button variant="ghost" size="icon">` `ChevronLeft` back button — returns to appointment or patient profile
- Patient name: Figtree 700 18px `text-slate-900`
- Session date: `text-sm text-slate-500` (e.g., "Sunday, 24 May 2026")
- Session number badge: `<Badge className="bg-cyan-100 text-cyan-700">` "Session #5" (derived from `sessions_completed + 1` on the linked plan)

### Section 1 — Pain Level Before (Required)

`<PainSlider>` custom component:
- Label: "Pain Level Before Session *" — Figtree 600 16px
- Large VAS slider: `w-full h-8 rounded-full` track. Gradient background: `from-green-400 via-yellow-400 to-red-500`.
- Thumb: 44×44px circle with current number inside, shadow.
- Current value: large numeric display `text-6xl font-bold` centered above slider, color matches gradient position (green for 0–3, yellow for 4–6, red for 7–10).
- Emoji hints below the slider endpoints: `0 😊` (left) … `5 😐` (center) … `10 😣` (right) — spaced proportionally.
- Range: 0–10, step 1.
- Initial state: thumb at position 5 (neutral). No value is "committed" until the user first interacts — field is required.

### Section 2 — Pain Level After (Optional)

Identical `<PainSlider>` component with label "Pain Level After Session (optional)". Not required. Initial state: disabled/muted until user taps "Add Post-Session Pain Level" toggle. When toggled on, slider appears with same interaction pattern.

### Section 3 — Progress Assessment (Required)

4 large tap-friendly radio cards in a 2×2 grid (mobile) or 4-column row (desktop):

| Option | Icon | Color |
|---|---|---|
| Improved | `TrendingDown` (pain trend down = good) | `border-green-500 bg-green-50 text-green-700` when selected |
| Same | `Minus` | `border-yellow-500 bg-yellow-50 text-yellow-700` when selected |
| Declined | `TrendingUp` | `border-orange-500 bg-orange-50 text-orange-700` when selected |
| Completed | `Star` | `border-cyan-500 bg-cyan-50 text-cyan-700` when selected |

Each card: min-height 64px (touch target), `rounded-xl border-2`, full-width label, icon centered above label. Unselected: `border-slate-200 bg-white`. Selection state uses `aria-checked`.

### Section 4 — Treatment Methods Applied

Section label: "Methods Applied This Session"
The prescribed methods from the treatment plan are rendered as `<button>` toggle chips:
- `rounded-full px-4 py-2 text-sm border-2` — min 44px height
- Unselected: `border-slate-200 bg-white text-slate-700`
- Selected: `border-cyan-600 bg-cyan-50 text-cyan-700`
- Tap to toggle. Multiple selections allowed.
- If the plan has no linked methods, section is hidden.

### Section 5 — Clinical Notes

`<Textarea>` — 4 rows minimum, auto-expands on mobile. `placeholder` "Add clinical observations, patient feedback, or instructions for next session…" Optional field.

### Section 6 — Digital Signature (Required)

`<SignatureCanvas>` component (using `react-signature-canvas`):
- Container: `border-2 border-dashed border-slate-300 rounded-xl bg-white` — width 100%, height 160px on mobile, 200px on desktop.
- `touch-action: none` to prevent scroll interference on mobile.
- Prompt text above canvas: "Draw your signature to confirm this session log." — `text-sm text-slate-500 text-center`.
- Below canvas: `<Button variant="outline" size="sm">` `RotateCcw` icon "Clear Signature" — resets the canvas.
- Signed indicator: after any strokes are drawn, a `<span className="text-green-600 text-sm flex items-center gap-1">` `<CheckCircle>` "Signature captured" appears below the canvas.
- On submit, signature is exported as PNG base64 via `signatureRef.current.toDataURL()` and stored in Supabase Storage.

### Submit Button
`<Button type="submit" className="w-full h-14 text-lg bg-cyan-600">` "Save Session Log" / "حفظ سجل الجلسة"

Disabled conditions (all must be met to enable):
1. `pain_level_before` has been set (slider interacted with)
2. A progress assessment has been selected
3. Signature canvas is non-empty

Visual disabled state: `opacity-50 cursor-not-allowed`.

Below the button: helper text listing what's still required, e.g., "Signature required to save." in `text-sm text-amber-600 text-center` when submit is attempted while disabled.

---

## UI States (Loading, Empty, Error, Success)

### Page Load
Form sections render immediately. Prescribed methods chips load when plan data arrives (skeleton chips during fetch). All required fields shown as unfilled (slider at 5, no progress card selected, signature empty).

### View Mode (Session Already Logged)
If a log exists for this appointment, the page renders all data as read-only:
- Sliders become read-only display bars (no thumb interaction).
- Progress card shows the recorded choice highlighted but unclickable.
- Methods chips shown but unclickable.
- Notes shown as a `<p>`.
- Signature shown as an `<img src={signatureDataUrl}>`.
- "View only" `<Badge>` in header.
- No submit button.

### Submit — Loading
Button shows `<Loader2 animate-spin>` + "Saving…". All inputs disabled.

### Submit — Success
Toast: "Session logged successfully." Page navigates back to the appointment or `/patients/[patientId]` after 1s delay.

### Submit — Error
Toast (red): "Failed to save session log. Please try again." Form re-enabled.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────┐
│ [←]  Ahmed Ali    24 May 2026  [#5]  │
│ ──────────────────────────────────── │
│                                      │
│  Pain Level Before Session *         │
│         8                            │
│  ━━━━━━━━●━━━━━━━━━━━━━━━━━━━━━━━━  │
│  😊                  😐         😣   │
│                                      │
│  + Add Post-Session Pain Level       │
│                                      │
│  Progress Assessment *               │
│  ┌──────────┐ ┌──────────┐           │
│  │ Improved │ │  Same    │           │
│  │   📈↓   │ │   ─      │           │
│  └──────────┘ └──────────┘           │
│  ┌──────────┐ ┌──────────┐           │
│  │ Declined │ │Completed │           │
│  │   📈↑   │ │   ★      │           │
│  └──────────┘ └──────────┘           │
│                                      │
│  Methods Applied                     │
│  [TENS ✓] [Manual] [Exercise ✓]     │
│                                      │
│  Clinical Notes                      │
│  [textarea 4 rows]                   │
│                                      │
│  Signature *                         │
│  ┌──────────────────────────────┐    │
│  │  [Draw your signature here]  │    │
│  └──────────────────────────────┘    │
│  [Clear]          ✓ Signature        │
│                                      │
│  ┌──────────────────────────────┐    │
│  │      Save Session Log        │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

---

## Validation Rules

| Field | Rule |
|---|---|
| Pain Level Before | Required. Must be a number 0–10. "Required" state: slider must have been explicitly moved from its initial neutral position (tracked by interaction flag). |
| Pain Level After | Optional. If toggled on, must be 0–10. |
| Progress Assessment | Required. One of: `improved`, `same`, `declined`, `completed`. |
| Treatment Methods | Optional (can submit with none selected if no methods prescribed). |
| Clinical Notes | Optional. Max 2000 characters. |
| Signature | Required. Canvas must have at least 1 stroke (non-empty `toDataURL`). |

Zod schema validates all fields client-side before submit. Server-side re-validates and enforces RLS.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Appointment Detail sheet → "Log Session" button
- Appointment Detail sheet → "View Session Log" button (leads to view mode)
- Direct URL `/appointments/[id]/session-log`

### Exit Points
- Back button (`ChevronLeft`) → appointment page or patient profile (browser history)
- Submit success → `/patients/[patientId]` or `/appointments/[id]`
- Dirty form guard: if user attempts to leave with unsaved data, confirmation dialog "Discard unsaved session log?"

---

## Responsive Behavior

This page is designed mobile-first. All touch targets are 44×44px minimum. The layout is a single full-width column at all breakpoints.

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Primary design surface. Sliders are large (44px thumb). Progress cards: 2×2 grid. Signature canvas: 160px tall. Entire page scrollable. |
| Tablet (`640px–1024px`) | Same single-column layout, max-width 640px centered. Slightly larger slider. Progress cards: 4-column row. |
| Desktop (`> 1024px`) | max-width 640px centered on white card with shadow. Progress cards: 4-column row. Signature canvas: 200px tall. |

---

## Accessibility Notes

- `<PainSlider>`: `<input type="range" min="0" max="10" step="1" aria-label="Pain level before session" aria-valuetext="8 out of 10">`. Numeric display has `aria-live="polite"` to announce value changes.
- Emoji hints: `aria-hidden="true"` (decorative). Pain scale explained in visually hidden text: `<span className="sr-only">Scale: 0 = no pain, 10 = worst imaginable pain</span>`.
- Progress radio cards: `<fieldset>` + `<legend>` "Progress Assessment". Each card = `<label>` wrapping a hidden `<input type="radio">`.
- Methods chips: `role="group"` + `aria-label="Treatment methods applied"`. Each chip `role="checkbox" aria-checked`.
- Signature canvas: `aria-label="Signature canvas. Draw your signature using touch or mouse."`. Below: `aria-live="polite"` region announces "Signature captured" when strokes begin.
- Submit button: `aria-disabled` + tooltip listing missing requirements when hovered/focused in disabled state.
- View mode: all interactive elements have `aria-disabled="true"` and `tabIndex="-1"` to exclude from focus order.

### RTL Considerations
- Pain slider: thumb interaction and gradient remain left-to-right (0 = low pain = start). In RTL, the slider is wrapped with `dir="ltr"` to keep the pain scale semantically correct (0 = left = green).
- Emoji position labels swap sides only in layout, not semantically.
- Progress cards: 2×2 grid layout unchanged (grid is direction-agnostic).
- Clinical notes textarea: `dir="rtl"` for Arabic input.
- Signature canvas: direction-agnostic (freehand drawing).
- All labels, prompts, and section headings in Noto Sans Arabic when `lang=ar`.

---

*DOC-06-P10 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*

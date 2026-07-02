# Page: Patient Create/Edit

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P05 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Patient Create page. |
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
| **URL Route** | `/patients/new` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin, Receptionist |
| **Unauthorized Redirect** | Other roles → `/patients` (or role home); unauthenticated → `/` |
| **RTL Support** | Yes |

---

## Page Purpose

The Patient Create page provides a structured, two-column form for registering a new patient in the system. It is designed for quick, accurate data entry by front-desk staff, with real-time validation to prevent duplicates and enforce data quality before submission. Upon successful save, a file number is auto-generated and the user is redirected to the new patient's profile.

Key design goals:
- Complete a new registration in under 3 minutes for a typical patient.
- Prevent duplicate phone number registrations before form submission.
- Auto-calculate patient age from date of birth.
- Allow document uploads (photo, ID) as part of registration without a separate step.

---

## Data Fetching (API Endpoints Consumed)

| Data | Method | Trigger |
|---|---|---|
| Phone uniqueness check | `patients` SELECT `id` WHERE `phone = inputValue` (count) | 500ms debounce after phone field change |
| Submit — create patient | POST to Supabase `patients` table INSERT | Form submit |
| Upload profile photo | `supabase.storage.from('patient-photos').upload(path, file)` | File selected/dropped, triggered on submit |
| Upload ID card | `supabase.storage.from('patient-docs').upload(path, file)` | File selected/dropped, triggered on submit |
| Generate file number | Server-side function: `SELECT nextval('patient_file_seq')` wrapped in a Supabase Edge Function or DB trigger | Automatically on INSERT |
| "How heard" options | Static array (no API call) | Page load |

---

## Component Breakdown

### Page Header
- `<PageHeader>`: `<h1>` "New Patient" / "تسجيل مريض جديد" + breadcrumb "Patients → New Patient"
- No action buttons in header (form has its own submit)

### Two-Column Form Layout
Desktop: `grid grid-cols-2 gap-8`. Mobile: `grid-cols-1`. Each column is a `<Card>` with a section heading.

#### Left Column — Personal Information

| Field | Component | Notes |
|---|---|---|
| Full Name* | `<Input>` | Required. `autoFocus`. Arabic name supported. |
| Phone* | `<Input>` with inline status indicator | `type="tel"`, `dir="ltr"`, `inputMode="numeric"`. After 500ms debounce: shows `<CheckCircle className="text-green-500">` "Available" or `<XCircle className="text-red-500">` "Phone already registered" with link to existing patient. |
| Date of Birth | `<DatePicker>` (Shadcn Popover + Calendar) | On select: auto-fills read-only "Age" field below (`text-sm text-slate-500 "Age: 34 years"`). Restricts to past dates only. |
| Age | `<Input readOnly>` | Auto-calculated from DOB. Shows "—" until DOB selected. |
| Gender* | `<RadioGroup>` | Two `<RadioGroupItem>` cards: Male (`Mars` icon) / Female (`Venus` icon). Cards: 80px wide, `border-2`, selected state `border-cyan-600 bg-cyan-50`. |
| Address | `<Textarea>` | 2 rows, optional. |
| Job / Occupation | `<Input>` | Optional. |
| How Heard About Us | `<Select>` | Options: Social Media / Referral / Walk-in / Google / Other. Optional. |

#### Right Column — Medical Information

| Field | Component | Notes |
|---|---|---|
| Chief Complaint* | `<Textarea>` | Required. 4 rows. Min 10 chars, max 500 chars. Character counter shown below: "X / 500". |
| Previous Surgeries | `<Textarea>` | 3 rows. Optional. |
| Chronic Diseases | `<Textarea>` | 3 rows. Optional. |

Section note below the column: `<Alert variant="default">` with `Info` icon: "A full diagnosis will be added by the treating doctor after the first session."

#### Bottom Section — File Uploads
Full-width section below both columns, inside a `<Card>`.

**Profile Photo Upload**
- `<FileUploadZone>` (custom): dashed border `border-2 border-dashed border-slate-300 rounded-full w-32 h-32 mx-auto`. Shows upload icon + "Photo" label.
- On file select: renders circular preview `<img>` inside the zone, with a `<Button variant="ghost" size="icon">` (`X` icon) to remove.
- Accepts: PNG, JPG, WEBP. Max 5MB. Enforced client-side before upload.
- Error: "File too large (max 5MB)" shown below the zone in `text-red-500 text-sm`.

**ID Card Upload**
- `<FileUploadZone>`: rectangular, `w-full h-24`, not circular.
- Shows `Upload` icon + "Upload ID Card" label.
- On file select: shows file name + file size + `<Button variant="ghost" size="icon">` (`X` icon) to remove.
- Accepts: PNG, JPG, PDF. Max 5MB.

**File Number (Read-Only)**
- Shown at the bottom: `<Input readOnly value="Will be auto-generated upon save" className="bg-slate-50 text-slate-400 italic" />` with label "File Number".

### Form Actions
- `<Button type="submit">` "Create Patient" / "إنشاء ملف المريض" — full-width on mobile, right-aligned on desktop. `bg-cyan-600`. Disabled while: any upload is in progress, phone uniqueness check is pending, or form has validation errors.
- `<Button variant="outline">` "Cancel" — navigates back to `/patients`.
- Loading state on submit: button shows `<Loader2 animate-spin>` + "Creating…" text. Inputs disabled.

---

## UI States (Loading, Empty, Error, Success)

### Idle State
Form with empty fields. Phone uniqueness indicator not shown until user types in the phone field.

### Phone Check — Checking
Small `<Loader2 animate-spin>` (14px) next to the phone field while the debounced check is in flight.

### Phone Check — Available
`<CheckCircle>` green icon + text "Available" shown inline next to the phone field.

### Phone Check — Already Exists
`<XCircle>` red icon + text "Phone already registered." + hyperlink "View existing patient →" (opens patient profile in a new tab). Form submit is blocked.

### File Upload — Uploading
Progress bar below each upload zone showing upload percentage. Submit button disabled.

### Submit Loading
All inputs disabled, submit button shows spinner + "Creating…". Lasts until server responds.

### Success
Toast (Sonner, green): "Patient created successfully. File number: PT-0143." Auto-dismiss 5s. Page navigates to `/patients/[newId]` immediately after toast appears.

### Error — Submission Failure
Toast (red): "Failed to create patient. Please try again." Inputs re-enabled. If the error is field-specific (e.g., phone race condition), the relevant field shows an inline error.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  Patients > New Patient                                  │
│            │  ──────────────────────────────────────────────────     │
│            │  ┌───────────────────────┐ ┌───────────────────────┐   │
│            │  │  Personal Information  │ │  Medical Information   │   │
│            │  │                       │ │                        │   │
│            │  │  Full Name*           │ │  Chief Complaint*      │   │
│            │  │  [________________]   │ │  [________________]    │   │
│            │  │                       │ │  [________________]    │   │
│            │  │  Phone*   [✓ Avail.]  │ │                        │   │
│            │  │  [________________]   │ │  Previous Surgeries    │   │
│            │  │                       │ │  [________________]    │   │
│            │  │  Date of Birth  Age   │ │                        │   │
│            │  │  [__________]   [34]  │ │  Chronic Diseases      │   │
│            │  │                       │ │  [________________]    │   │
│            │  │  Gender  ○Male ○Female│ │                        │   │
│            │  │                       │ │  [ℹ] Diagnosis added   │   │
│            │  │  Address              │ │  by doctor later.      │   │
│            │  │  [________________]   │ │                        │   │
│            │  │                       │ │                        │   │
│            │  │  Job / How Heard      │ │                        │   │
│            │  │  [______] [________]  │ │                        │   │
│            │  └───────────────────────┘ └───────────────────────┘   │
│            │                                                           │
│            │  ┌───────────────────────────────────────────────────┐  │
│            │  │  File Uploads                                      │  │
│            │  │  [ (○) Photo ] (drag or click)    [ID Card Upload] │  │
│            │  │  File Number: Will be auto-generated upon save     │  │
│            │  └───────────────────────────────────────────────────┘  │
│            │                              [Cancel]  [Create Patient]  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

| Field | Rule | Error Message (EN) |
|---|---|---|
| Full Name | Required, 2–100 chars | "Full name is required." / "Name must be between 2 and 100 characters." |
| Phone | Required, Egyptian mobile format `^(010|011|012|015)\d{8}$` | "Phone number is required." / "Enter a valid Egyptian mobile number." |
| Phone | Unique (server check) | "This phone number is already registered." |
| Date of Birth | Valid date, past only | "Please enter a valid date of birth." |
| Gender | Required, must select one | "Please select a gender." |
| Chief Complaint | Required, 10–500 chars | "Chief complaint is required (10–500 characters)." |
| Profile Photo | Optional. If provided: PNG/JPG/WEBP, ≤ 5MB | "Photo must be PNG, JPG, or WEBP and under 5MB." |
| ID Card | Optional. If provided: PNG/JPG/PDF, ≤ 5MB | "ID card must be PNG, JPG, or PDF and under 5MB." |

Validation uses Zod schema, shared between client (React Hook Form) and server. Client-side validation triggers on blur for most fields, on submit for all fields.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- "Add Patient" button on `/patients` list
- Direct URL `/patients/new`

### Exit Points
- Submit success → `/patients/[newId]` (new patient profile)
- "Cancel" button → `/patients` (browser back if no form changes, confirmation dialog if form is dirty)
- Dirty form navigation guard: if the user tries to leave via browser back or a sidebar link with unsaved data, a `<AlertDialog>` confirms "Discard unsaved changes?"

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Two-column form becomes single column. Sections stack: Personal Info card → Medical Info card → File Uploads card. Submit/Cancel buttons are full-width, stacked (Submit on top). |
| Tablet (`640px–1024px`) | Two columns, slightly narrower cards. File upload zone stacks vertically. |
| Desktop (`> 1024px`) | Full two-column layout as designed. |

Upload zones use touch-friendly large tap areas on mobile. The circular photo zone is always 128×128px (centered). File input is triggered by both tap and drag-drop.

---

## Accessibility Notes

- All form fields have explicit `<label>` elements, linked by `htmlFor`/`id`. Required fields have `aria-required="true"` and a visible asterisk.
- Phone uniqueness status is announced via `aria-live="polite"` region adjacent to the field.
- Date of Birth picker: keyboard-accessible via arrow keys within the calendar. Escape closes the popover.
- Gender radio group: `<fieldset>` + `<legend>` wrapping, keyboard navigation with arrow keys.
- File upload zones: `<input type="file">` is visually hidden but accessible. Label acts as the click target. `aria-describedby` links to the size/type requirements text.
- Error messages: each field error rendered in a `<p role="alert">` below the field, linked via `aria-describedby`.
- Submit button: `aria-busy="true"` + `aria-disabled="true"` during loading.
- Focus management: on validation failure on submit, focus moves to the first field with an error.

### RTL Considerations
- Left column becomes right column in RTL grid layout (`rtl:order-2` / `rtl:order-1`).
- Gender radio cards: icon + text direction reverses.
- Phone field always `dir="ltr"` regardless of locale.
- File upload zone text in Arabic: "اسحب الصورة هنا أو انقر للرفع".
- Character counter for Chief Complaint: Arabic numerals in Arabic locale.
- All labels and placeholders use Noto Sans Arabic when `lang=ar`.

---

*DOC-06-P05 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*

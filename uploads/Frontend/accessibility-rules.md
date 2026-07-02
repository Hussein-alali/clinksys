# Accessibility Rules

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-004 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | WCAG 2.1 AA compliance requirements and testing procedures. |
| **Owner** | Frontend Engineer / QA Engineer |
| **Dependencies** | design-system.md |
| **Priority** | P2 |
| **Estimated Pages** | 10–16 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / QA Engineer | Initial stub |
| 1.0 | 2026-05-24 | Frontend Engineer / QA Engineer | Full content added |

---

## Table of Contents

- [WCAG 2.1 AA Checklist](#wcag-21-aa-checklist)
- [Keyboard Navigation Requirements](#keyboard-navigation-requirements)
- [Screen Reader Support (ARIA)](#screen-reader-support-aria)
- [Color Contrast Ratios](#color-contrast-ratios)
- [Focus Management in Modals](#focus-management-in-modals)
- [Form Accessibility](#form-accessibility)
- [Testing Tools & Procedures](#testing-tools--procedures)
- [Audit Schedule](#audit-schedule)

---

## WCAG 2.1 AA Checklist

PTCMS targets **WCAG 2.1 Level AAA** for all patient-critical information and **Level AA** as the universal minimum across the full application. The clinic serves patients and clinical staff in a medical context — accessibility is a safety concern, not a compliance box.

### Perceivable

| Criterion | Level | Implementation | Status |
|---|---|---|---|
| 1.1.1 — Non-text Content | A | All images have descriptive `alt` text; decorative images use `alt=""` | Required |
| 1.3.1 — Info and Relationships | A | Semantic HTML (`<table>`, `<th scope>`, `<fieldset>`, `<legend>`) used throughout | Required |
| 1.3.2 — Meaningful Sequence | A | DOM order matches visual reading order; RTL layout uses CSS flex-direction reversal, not DOM reordering | Required |
| 1.3.3 — Sensory Characteristics | A | Instructions never rely on color alone (e.g., "click the green button") | Required |
| 1.3.4 — Orientation | AA | No component locked to portrait or landscape | Required |
| 1.3.5 — Input Purpose | AA | All form inputs have correct `autocomplete` attributes (`name`, `email`, `tel`, `bday`, `sex`) | Required |
| 1.4.1 — Use of Color | A | Status badges include icon + text label, never color only (e.g., `<CheckCircle>` + "Confirmed") | Required |
| 1.4.3 — Contrast (Minimum) | AA | All text/background pairs ≥ 4.5:1 (see Color Contrast table below) | Required |
| 1.4.4 — Resize Text | AA | UI fully functional up to 200% browser zoom | Required |
| 1.4.5 — Images of Text | AA | No rasterized text in images; all text is real DOM text | Required |
| 1.4.10 — Reflow | AA | Page reflows without horizontal scrolling at 320px viewport width | Required |
| 1.4.11 — Non-text Contrast | AA | UI components and focus rings ≥ 3:1 contrast against adjacent colors | Required |
| 1.4.12 — Text Spacing | AA | No content lost when letter-spacing, line-height, word-spacing increased to WCAG limits | Required |
| 1.4.13 — Content on Hover/Focus | AA | Tooltips/popovers dismissible with Esc, persistent until dismissed, not clipped | Required |

### Operable

| Criterion | Level | Implementation | Status |
|---|---|---|---|
| 2.1.1 — Keyboard | A | All functionality reachable via keyboard Tab / Shift+Tab / Enter / Space / Arrow keys | Required |
| 2.1.2 — No Keyboard Trap | A | Focus never trapped outside of intentional modal focus traps (Radix Dialog handles this) | Required |
| 2.1.3 — Keyboard (No Exception) | AAA | All interactions keyboard-accessible, including PainSlider and SignatureCanvas | Target |
| 2.4.1 — Bypass Blocks | A | Skip-to-main-content link at start of DOM (`<a href="#main-content" className="sr-only focus:not-sr-only">`) | Required |
| 2.4.2 — Page Titled | A | Each page has unique, descriptive `<title>` tags (e.g., "Patient List — PTCMS") | Required |
| 2.4.3 — Focus Order | A | Tab order follows logical visual flow; no `tabindex > 0` unless absolutely necessary | Required |
| 2.4.4 — Link Purpose | A | All links and buttons have descriptive text or `aria-label` (e.g., not "click here") | Required |
| 2.4.6 — Headings and Labels | AA | Every section has an appropriate `<h1>`–`<h6>` heading; only one `<h1>` per page | Required |
| 2.4.7 — Focus Visible | AA | Focus rings visible on all interactive elements: `ring-2 ring-cyan-600 ring-offset-2` | Required |
| 2.5.3 — Label in Name | A | All interactive components' accessible name includes the visible label text | Required |
| 2.5.5 — Target Size | AAA | All touch targets ≥ 44×44px | Target |

### Understandable

| Criterion | Level | Implementation | Status |
|---|---|---|---|
| 3.1.1 — Language of Page | A | `<html lang="ar">` for Arabic sessions; `<html lang="en">` for English | Required |
| 3.1.2 — Language of Parts | AA | Arabic content fragments have `lang="ar"` attribute on the containing element | Required |
| 3.2.1 — On Focus | A | Focus never triggers unexpected context changes | Required |
| 3.2.2 — On Input | A | Form inputs do not auto-submit on value change | Required |
| 3.3.1 — Error Identification | A | Errors identified in text, not color alone; error role applied | Required |
| 3.3.2 — Labels or Instructions | A | All form fields have visible `<label>` elements; required fields marked with `*` and `aria-required="true"` | Required |
| 3.3.3 — Error Suggestion | AA | Inline error messages explain what is wrong and how to fix it | Required |
| 3.3.4 — Error Prevention | AA | Destructive actions (delete, deactivate) require confirmation dialogs | Required |

### Robust

| Criterion | Level | Implementation | Status |
|---|---|---|---|
| 4.1.1 — Parsing | A | Valid HTML5; no duplicate IDs | Required |
| 4.1.2 — Name, Role, Value | A | All custom components use correct ARIA roles and properties | Required |
| 4.1.3 — Status Messages | AA | Live regions (`aria-live="polite"`) for toast notifications, activity feed updates, and async search results | Required |

---

## Keyboard Navigation Requirements

### Global Tab Order

The application-level tab order follows the Z-pattern reading flow:

1. Skip-to-main-content link (sr-only, appears on first Tab)
2. App header (logo, user menu)
3. Sidebar navigation items (top to bottom)
4. Main content area (page-by-page Tab order)
5. Footer (if present)

Bottom navigation bar on mobile also follows this order but is visually last in the viewport.

### Key Bindings Reference

| Key | Context | Action |
|---|---|---|
| `Tab` | Global | Move forward through focusable elements |
| `Shift+Tab` | Global | Move backward through focusable elements |
| `Enter` | Button, link, select item | Activate element |
| `Space` | Checkbox, radio, button | Toggle / activate |
| `Esc` | Modal, dialog, sheet, dropdown, popover, combobox | Close / dismiss |
| `Arrow Up / Down` | Select dropdown, combobox, radio group, date picker | Navigate options |
| `Arrow Left / Right` | Tab navigation, slider | Change tab / adjust slider value |
| `Home` | Slider | Jump to minimum value |
| `End` | Slider | Jump to maximum value |
| `Page Up / Down` | Date picker calendar | Navigate months |
| `Enter` (in table row) | Patient list, appointment list | Navigate to detail page |

### Sidebar Navigation

- Each nav item is a `<a>` or `<button>` element.
- Active item has `aria-current="page"`.
- Collapsed sidebar: items still focusable with `aria-label` including the nav item name.

### Date Picker (Shadcn Calendar)

```
- Tab into the calendar widget
- Arrow keys navigate between dates
- Enter selects the focused date
- Page Up / Page Down navigates months
- Esc closes the calendar popover
- Disabled dates have aria-disabled="true" and are skipped by arrow keys
```

### PainSlider

The PainSlider is implemented as an `<input type="range">`:

```tsx
<input
  type="range"
  min={0}
  max={10}
  step={1}
  value={value}
  aria-label="Pain level before session (0 = no pain, 10 = worst pain)"
  aria-valuemin={0}
  aria-valuemax={10}
  aria-valuenow={value}
  aria-valuetext={`${value} out of 10`}
  className="w-full h-2 cursor-pointer"
/>
```

Arrow Left/Right decrement/increment by 1. Arrow Up/Down also supported. Home = 0, End = 10.

### SignatureCanvas

The signature canvas has a keyboard fallback for accessibility:

- Receives focus with `tabindex="0"` and `role="application"`.
- `aria-label="Digital signature canvas. Draw your signature using mouse or touch."`.
- For users who cannot draw: a "Type Name Instead" link opens a text field for typed signature (admin-configurable to accept or reject).
- Clear button is a standard `<button>` with `aria-label="Clear signature"`.

---

## Screen Reader Support (ARIA)

### ARIA Landmarks

Every page must have the following landmark structure:

```html
<header role="banner">          <!-- App top bar -->
<nav role="navigation">         <!-- Sidebar nav -->
<main id="main-content" role="main">  <!-- Page content -->
<aside role="complementary">    <!-- Activity feed, side panels -->
<footer role="contentinfo">     <!-- Footer (if any) -->
```

### Live Regions

| Component | ARIA Live Setting | Reason |
|---|---|---|
| Toast notifications (Sonner) | `aria-live="assertive"` for errors, `aria-live="polite"` for success | Critical errors need immediate announcement |
| Dashboard activity feed | `aria-live="polite"` | Real-time updates without interrupting user |
| Search results count | `aria-live="polite"` | "12 patients found" announced after debounce |
| Form validation messages | `aria-live="assertive"` | Errors need immediate announcement |
| Loading states | `aria-busy="true"` on the loading region | Screen reader knows content is updating |

### Icon-Only Buttons

Every button that shows only an icon must have `aria-label`:

```tsx
// Correct
<Button variant="ghost" size="icon" aria-label="View patient profile">
  <Eye className="h-4 w-4" aria-hidden="true" />
</Button>

// Correct — using Tooltip for sighted users + aria-label for screen readers
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon" aria-label="Edit appointment">
        <Pencil className="h-4 w-4" aria-hidden="true" />
      </Button>
    </TooltipTrigger>
    <TooltipContent>Edit appointment</TooltipContent>
  </Tooltip>
</TooltipProvider>
```

All Lucide icons inside buttons must have `aria-hidden="true"` — the button's `aria-label` provides the accessible name.

### StatusBadge Screen Reader Text

Badges convey status through color and icon. Screen reader users need the text equivalent:

```tsx
<StatusBadge status="completed">
  <CheckCircle className="h-3 w-3" aria-hidden="true" />
  <span>Completed</span>
  {/* sr-only text adds additional context if needed */}
  <span className="sr-only"> appointment</span>
</StatusBadge>
```

### Table Accessibility

```tsx
<table role="grid" aria-label="Patient list">
  <thead>
    <tr>
      <th scope="col" aria-sort="ascending">
        Full Name
        <ChevronUp className="h-3 w-3 inline" aria-hidden="true" />
      </th>
      <th scope="col" aria-sort="none">Phone</th>
    </tr>
  </thead>
  <tbody>
    <tr
      tabIndex={0}
      role="row"
      aria-label={`Patient ${patient.full_name}, file ${patient.file_number}`}
      onClick={() => router.push(`/patients/${patient.patient_id}`)}
      onKeyDown={(e) => e.key === 'Enter' && router.push(`/patients/${patient.patient_id}`)}
    >
      ...
    </tr>
  </tbody>
</table>
```

### RTL Screen Reader Support

When the application language is Arabic:
- `<html lang="ar" dir="rtl">` is set at the document level.
- Arabic content fragments within an English page have `lang="ar"` on their wrapper element.
- Screen readers announce Arabic text in the correct language when `lang` is set properly.
- The Noto Sans Arabic font is pre-loaded to prevent FOUT (Flash of Unstyled Text) that can disrupt screen reader timing.

---

## Color Contrast Ratios

### Primary Text on Backgrounds

| Foreground | Background | Contrast Ratio | Level | Usage |
|---|---|---|---|---|
| `#134E4A` (teal-900) | `#FFFFFF` (white) | 11.2:1 | AAA | Primary headings on white cards |
| `#134E4A` (teal-900) | `#F0FDFA` (teal-50) | 10.8:1 | AAA | Headings on app background |
| `#0F766E` (teal-700) | `#FFFFFF` (white) | 6.3:1 | AAA | Secondary text on white |
| `#475569` (slate-600) | `#FFFFFF` (white) | 5.9:1 | AA | Muted / caption text |
| `#0891B2` (cyan-600) | `#FFFFFF` (white) | 4.6:1 | AA | Primary buttons, links |
| `#FFFFFF` (white) | `#0891B2` (cyan-600) | 4.6:1 | AA | White text on teal button |
| `#FFFFFF` (white) | `#0E7490` (cyan-700) | 5.5:1 | AA | White text on hover button |

### Status Badge Contrast

| Badge State | Text Color | Background | Contrast Ratio | Level |
|---|---|---|---|---|
| Completed / Paid | `#166534` (green-800) | `#F0FDF4` (green-50) | 8.4:1 | AAA |
| Pending | `#374151` (gray-700) | `#F9FAFB` (gray-50) | 9.7:1 | AAA |
| Confirmed | `#1D4ED8` (blue-700) | `#EFF6FF` (blue-50) | 8.2:1 | AAA |
| Cancelled | `#9F1239` (rose-800) | `#FFF1F2` (rose-50) | 8.9:1 | AAA |
| No-show | `#9A3412` (orange-800) | `#FFF7ED` (orange-50) | 7.1:1 | AAA |
| Overdue | `#991B1B` (red-800) | `#FEF2F2` (red-50) | 8.1:1 | AAA |
| Partial | `#854D0E` (yellow-800) | `#FEFCE8` (yellow-50) | 8.6:1 | AAA |

### Prohibited Combinations

The following combinations are explicitly banned in PTCMS because they fail WCAG AA:

- `slate-400` (#94A3B8) on `white` — 2.9:1 (FAIL)
- `cyan-400` (#22D3EE) on `white` — 1.8:1 (FAIL)
- `green-400` (#4ADE80) on `white` — 2.1:1 (FAIL)
- Any light color on `teal-50` background without verification

---

## Focus Management in Modals

### Dialogs (Shadcn Dialog)

Radix UI's Dialog primitive handles focus trapping automatically. The following behavior is guaranteed:

1. When a Dialog opens, focus moves to the first focusable element inside the dialog (or the dialog container if no focusable element exists).
2. Tab and Shift+Tab cycle only within the dialog content — focus cannot escape.
3. When the dialog closes (Esc, backdrop click, or close button), focus returns to the element that triggered the dialog open.
4. The page behind the dialog has `aria-hidden="true"` and `inert` applied while the dialog is open.

```tsx
// Do NOT manage focus manually — Radix Dialog handles it
<Dialog>
  <DialogTrigger asChild>
    <Button>Add Package</Button>  {/* Focus returns here on close */}
  </DialogTrigger>
  <DialogContent>
    {/* Focus moves here on open */}
    <DialogHeader>
      <DialogTitle>Add Package</DialogTitle>
    </DialogHeader>
    <form>
      <Input autoFocus name="name" />  {/* Optional: explicit first focus */}
      ...
    </form>
  </DialogContent>
</Dialog>
```

### Sheet (Side Drawer)

Same focus management as Dialog — Radix Sheet is also a Radix Dialog variant. Focus traps within the Sheet. Esc closes.

### Confirmation Dialogs

Confirmation dialogs for destructive actions (delete, deactivate, cancel appointment):

- Focus moves to the **Cancel** button by default (safe choice first).
- The destructive action button (e.g., "Deactivate") is accessible but not auto-focused — prevents accidental activation.
- `aria-describedby` links the dialog body text to the dialog for screen readers.

```tsx
<AlertDialog>
  <AlertDialogContent aria-describedby="confirm-desc">
    <AlertDialogHeader>
      <AlertDialogTitle>Deactivate User?</AlertDialogTitle>
      <AlertDialogDescription id="confirm-desc">
        This action will prevent the user from logging in. Their data will be preserved.
      </AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel autoFocus>Cancel</AlertDialogCancel>
      <AlertDialogAction className="bg-red-600">Deactivate</AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

---

## Form Accessibility

### Label Association

Every form field must have an associated `<label>` using `htmlFor` + `id` pairing:

```tsx
<div className="space-y-1">
  <Label htmlFor="patient-phone">
    Phone Number <span aria-hidden="true">*</span>
    <span className="sr-only">(required)</span>
  </Label>
  <Input
    id="patient-phone"
    name="phone"
    type="tel"
    inputMode="tel"
    autoComplete="tel"
    aria-required="true"
    aria-describedby="patient-phone-error patient-phone-hint"
    aria-invalid={!!errors.phone}
    placeholder="01XXXXXXXXX"
  />
  <p id="patient-phone-hint" className="text-xs text-slate-500">
    Egyptian mobile number format: 01XXXXXXXXX
  </p>
  {errors.phone && (
    <p id="patient-phone-error" role="alert" className="text-xs text-red-600">
      {errors.phone.message}
    </p>
  )}
</div>
```

### Required Field Marking

- Required fields are marked with an asterisk `*` (visible) and `aria-required="true"` (programmatic).
- A legend above the form states: "Fields marked with * are required."
- The asterisk itself has `aria-hidden="true"` — the `aria-required` attribute is the machine-readable signal.

### Error Announcements

- Inline errors appear below the field immediately on blur (for single-field errors) or on submit attempt.
- Each error `<p>` has `role="alert"` so it is announced by screen readers immediately on insertion.
- For form-level errors (e.g., "Please fix 3 errors"), a summary `<div role="alert" aria-live="assertive">` at the top of the form lists the errors.
- Error messages are in the user's current language (Arabic if `dir="rtl"` is active).

### Fieldset / Legend for Radio Groups

```tsx
<fieldset>
  <legend className="text-sm font-medium text-slate-700">
    Gender <span aria-hidden="true">*</span>
  </legend>
  <RadioGroup defaultValue="male" aria-required="true">
    <div className="flex items-center gap-2">
      <RadioGroupItem value="male" id="gender-male" />
      <Label htmlFor="gender-male">Male</Label>
    </div>
    <div className="flex items-center gap-2">
      <RadioGroupItem value="female" id="gender-female" />
      <Label htmlFor="gender-female">Female</Label>
    </div>
  </RadioGroup>
</fieldset>
```

### Autocomplete Attributes

| Field | `autocomplete` Value |
|---|---|
| User full name | `name` |
| Email | `email` |
| Phone | `tel` |
| Password | `current-password` (login) / `new-password` (creation) |
| Date of birth | `bday` |
| Address | `street-address` |

---

## Testing Tools & Procedures

### Automated Testing

| Tool | When Used | What It Checks |
|---|---|---|
| **axe-core** (via `@axe-core/react`) | Development (dev mode only) | WCAG A/AA violations in component tree |
| **Playwright + axe** | CI pipeline on every PR | Regression testing for accessibility violations |
| **Lighthouse CI** | CI pipeline on every PR | Accessibility score ≥ 95 required to pass |
| **eslint-plugin-jsx-a11y** | Pre-commit (eslint) | Static analysis of JSX for ARIA and HTML accessibility errors |

### Manual Testing Procedures

#### Screen Reader Testing

| Screen Reader | Browser | OS | Frequency |
|---|---|---|---|
| NVDA | Chrome | Windows | Every sprint |
| VoiceOver | Safari | macOS / iOS | Every sprint |
| TalkBack | Chrome | Android | Monthly |

**Key flows to test with each screen reader:**
1. Login and authentication
2. Create new patient (full form submission)
3. Book an appointment (multi-step flow)
4. Log a session (PainSlider + SignatureCanvas)
5. Navigate the patient profile tabs
6. View and dismiss a toast notification

#### Keyboard-Only Testing

Every sprint, a QA engineer must complete the following using keyboard only (no mouse):

- [ ] Log in with valid credentials
- [ ] Search for a patient and open their profile
- [ ] Navigate all 7 tabs in patient profile
- [ ] Open and close a Dialog (Add Package)
- [ ] Submit a form with validation errors and fix them
- [ ] Dismiss a toast notification (via Esc)
- [ ] Navigate the appointment calendar with arrow keys

#### Color Contrast Verification

Use the **Colour Contrast Analyser** desktop tool (TPGI) to spot-check any new color combinations introduced during development. Check must be performed before merging any PR that changes color tokens or adds new UI elements.

### Browser / AT Compatibility Matrix

| Browser | Version | Support Level |
|---|---|---|
| Chrome | Latest | Full (primary target) |
| Safari | Latest | Full |
| Firefox | Latest | Full |
| Edge | Latest | Full |
| Chrome Android | Latest | Mobile-optimized |
| Safari iOS | Latest | Mobile-optimized |

---

## Audit Schedule

| Audit Type | Frequency | Responsible | Output |
|---|---|---|---|
| Automated axe scan (full app) | Every PR (CI) | CI pipeline | Pass/fail report in PR |
| Lighthouse accessibility score | Every PR (CI) | CI pipeline | Score ≥ 95 required |
| Manual screen reader walkthrough | Every 2-week sprint | Frontend QA | Issues logged in JIRA |
| Color contrast spot check | Every sprint (on new UI) | Frontend Engineer | Sign-off in PR description |
| Full WCAG 2.1 AA manual audit | Quarterly | External / Senior QA | Formal audit report |
| RTL accessibility check | On any RTL-related change | Frontend Engineer | RTL parity confirmed |

### Remediation SLAs

| Severity | WCAG Impact | Remediation SLA |
|---|---|---|
| Critical | Level A failure | Must fix before merge — PR blocked |
| High | Level AA failure | Must fix within current sprint |
| Medium | Level AAA failure | Backlog — prioritized for next sprint |
| Low | Best practice / enhancement | Backlog — addressed in quarterly audit cycle |

---

*DOC-06-004 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*

# UI States Documentation

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-001 |
| **Version** | 1.0 |
| **Status** | Complete |
| **Date** | 2026-05-24 |
| **Purpose** | All application UI states and expected behavior for each. |
| **Owner** | UX Designer / Frontend Engineer |
| **Dependencies** | design-system.md |
| **Priority** | P2 |
| **Estimated Pages** | 10–14 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | UX Designer / Frontend Engineer | Initial stub |
| 1.0 | 2026-05-24 | UX Designer / Frontend Engineer | Full documentation |

---

## Table of Contents

- [Loading States (Skeleton, Spinner, Progress)](#loading-states-skeleton-spinner-progress)
- [Empty States (No Data, First-time, Filtered Empty)](#empty-states-no-data-first-time-filtered-empty)
- [Error States (Network, Server, Not Found, Permission Denied)](#error-states-network-server-not-found-permission-denied)
- [Success States](#success-states)
- [Warning States](#warning-states)
- [Disabled States](#disabled-states)
- [Offline / Connection Lost](#offline--connection-lost)

---

## Loading States (Skeleton, Spinner, Progress)

### Design Principle

Never show a blank screen during data fetching. Every page that fetches remote data must render a skeleton layout matching the shape of the final content. This prevents layout shift and maintains spatial continuity for the user.

### 1.1 Skeleton Screen (Primary Loading Pattern)

**When to use:** Initial page load, tab switches, filter changes, search results.

**Visual design:**
- Skeleton blocks are `bg-slate-200` with `animate-pulse` (1500ms shimmer cycle)
- Shape must match the final content dimensions as closely as possible
- Use `rounded` corners matching the real component's border-radius

```tsx
// Patient list skeleton — 5 rows
function PatientListSkeleton() {
  return (
    <div className="space-y-2" aria-label="Loading patients..." aria-busy="true">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="flex items-center gap-4 p-4 border border-slate-100 rounded-lg">
          <Skeleton className="h-10 w-10 rounded-full" />       {/* Avatar */}
          <div className="flex-1 space-y-2">
            <Skeleton className="h-4 w-48" />                   {/* Name */}
            <Skeleton className="h-3 w-32" />                   {/* Phone */}
          </div>
          <Skeleton className="h-6 w-20 rounded-full" />        {/* Status badge */}
          <Skeleton className="h-8 w-8 rounded" />              {/* Action button */}
        </div>
      ))}
    </div>
  );
}
```

**Accessibility:** The skeleton container carries `aria-busy="true"` and an `aria-label` describing what is loading. Screen readers announce "Loading patients…" immediately.

### 1.2 KPI Card Skeleton (Dashboard)

```
┌────────────────────────────┐
│  ████████████ (label)      │
│                            │
│  ████████████████ (value)  │
│  ██████ (trend)            │
└────────────────────────────┘
```

All 8 KPI cards render skeleton placeholders simultaneously during initial dashboard load. The skeleton card maintains the exact same height as the real card (approx. 120px) to prevent layout reflow.

### 1.3 Table Skeleton

Tables display 5 skeleton rows by default (matches the visual density of a typical table load). Columns widths approximate the real column proportions:

| Column | Skeleton Width |
|---|---|
| File # | 72px |
| Patient Name | 160px |
| Phone | 120px |
| Status badge | 80px |
| Actions | 40px |

### 1.4 Inline Spinner (Secondary Loading Pattern)

**When to use:** Button async actions (save, confirm, delete), small inline refreshes.

```tsx
<Button disabled={isLoading}>
  {isLoading && <Loader2 className="me-2 h-4 w-4 animate-spin" aria-hidden="true" />}
  {isLoading ? 'Saving...' : 'Save Session'}
</Button>
```

**Rules:**
- Button text changes from action label to progressive label (e.g., "Save" → "Saving…")
- Button is `disabled` during loading — prevents double-submission
- Spinner icon uses `animate-spin` at `h-4 w-4`, color inherits from button text
- `aria-live="polite"` region nearby announces completion

### 1.5 Progress Bar (File Uploads)

**When to use:** Patient document uploads, photo uploads.

```tsx
<div className="space-y-1">
  <div className="flex justify-between text-xs text-slate-500">
    <span>Uploading report.pdf</span>
    <span>{progress}%</span>
  </div>
  <div className="h-2 bg-slate-200 rounded-full overflow-hidden">
    <div
      className="h-full bg-cyan-500 rounded-full transition-all duration-300"
      style={{ width: `${progress}%` }}
      role="progressbar"
      aria-valuenow={progress}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-label="File upload progress"
    />
  </div>
</div>
```

**Trigger:** Fires on every Supabase Storage upload event. Shows per-file progress (0–100%).

### 1.6 Full-Page Loading (Initial Auth Check)

During the JWT session verification on first page load, show a centered spinner on the teal background — identical in branding to the login page:

```
┌─────────────────────────────────┐
│                                 │
│         [Clinic Logo]           │
│                                 │
│         ○ (spinning)            │
│       Checking session…         │
│                                 │
└─────────────────────────────────┘
```

This state lasts less than 500ms in typical conditions. The spinner uses `h-8 w-8 text-cyan-600 animate-spin`.

---

## Empty States (No Data, First-time, Filtered Empty)

### Design Principle

Empty states are not errors — they are opportunities. Each empty state explains what is missing, why the view is empty, and offers a direct action to remedy it. Never show a blank white box.

### 2.1 First-time Empty State (No Records Exist Yet)

**Trigger:** A new clinic installation where a list has never been populated.

**Visual structure:**
```
┌─────────────────────────────────┐
│                                 │
│    [Lucide Icon — large, muted] │
│                                 │
│       Primary message           │
│       Secondary explanation     │
│                                 │
│       [Primary Action Button]   │
│                                 │
└─────────────────────────────────┘
```

**Per-page configurations:**

| Page | Icon | Primary Message | Secondary Message | CTA Button |
|---|---|---|---|---|
| Patients List | `Users` | No patients yet | Register your first patient to get started. | Register Patient |
| Appointments | `CalendarOff` | No appointments scheduled | Book the first appointment for a patient. | Book Appointment |
| Treatment Plans | `ClipboardList` | No treatment plans | Create a treatment plan for this patient. | Create Plan |
| Sessions | `Activity` | No sessions logged | Log the first session after an appointment is completed. | Log Session |
| Packages | `Package` | No packages defined | Create packages to offer pre-paid session bundles. | Create Package |
| Invoices | `FileText` | No invoices yet | Invoices are auto-generated when payments are recorded. | Record Payment |
| Campaigns | `Megaphone` | No campaigns created | Create your first WhatsApp campaign to reach patients. | Create Campaign |
| Users | `UserPlus` | No team members yet | Add staff members to grant them system access. | Add User |

**Accessibility:** Icon is `aria-hidden="true"`. The container has a descriptive heading visible to screen readers.

### 2.2 Search / Filter Empty State

**Trigger:** A search query or active filter combination returns zero results.

**Visual:**
```
┌─────────────────────────────────┐
│                                 │
│    [Search icon — muted]        │
│                                 │
│   No results for "Ahmed"        │
│   Try different search terms    │
│   or clear your filters.        │
│                                 │
│   [Clear Filters]               │
│                                 │
└─────────────────────────────────┘
```

The "Clear Filters" button resets all active filters and the search field. It does not navigate away.

### 2.3 Tab Empty State (Patient Profile Tabs)

When a patient profile tab has no content (e.g., no appointments, no sessions):

```
┌─────────────────────────────────┐
│    [CalendarOff icon]           │
│    No appointments found        │
│    for this patient.            │
│                                 │
│    [Book Appointment]           │
└─────────────────────────────────┘
```

The CTA deep-links to the appointment booking flow with the current patient pre-selected.

### 2.4 Chart Empty State

**Trigger:** No data available for the selected date range in a dashboard chart.

```tsx
<div className="flex flex-col items-center justify-center h-48 text-slate-400">
  <BarChart2 className="h-10 w-10 mb-3" aria-hidden="true" />
  <p className="text-sm font-medium">No data for this period</p>
  <p className="text-xs mt-1">Try expanding the date range.</p>
</div>
```

---

## Error States (Network, Server, Not Found, Permission Denied)

### Design Principle

Errors must be honest, specific, and actionable. Generic "something went wrong" messages without a recovery path are prohibited. Every error state tells the user what happened, what they can do, and gives a direct action (retry, go back, contact support).

### 3.1 Inline Form Error

**Trigger:** Form validation failure (client-side or server-side rejection).

**Visual design:**
- Error message appears directly below the offending field
- Input border turns `border-red-400`
- Error text: `text-sm text-red-600` with `role="alert"` for immediate screen reader announcement
- Error icon: `AlertCircle` (16px) prefixed to the message

```tsx
{error && (
  <p id="phone-error" className="flex items-center gap-1.5 text-sm text-red-600 mt-1" role="alert">
    <AlertCircle className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
    {error.message}
  </p>
)}
```

**Never use:** A modal or toast as the sole error communication for a form field. Inline is mandatory.

### 3.2 Toast Error Notification

**Trigger:** Server-side save failure, network timeout, unexpected API error.

```tsx
toast.error('Failed to save session. Check your connection and try again.', {
  duration: Infinity, // stays until dismissed — errors should not auto-dismiss
  action: {
    label: 'Retry',
    onClick: () => handleSave(),
  },
});
```

**Rules:**
- Error toasts stay until the user dismisses them (no auto-dismiss)
- Include a "Retry" action when the operation is idempotent
- Position: `top-right` desktop, `top-center` mobile
- Max 2 stacked toasts before older ones are removed

### 3.3 Network Error State (Page-Level)

**Trigger:** API call fails due to network unavailability.

```
┌────────────────────────────────────────┐
│                                        │
│   [WifiOff icon — h-12 w-12]          │
│                                        │
│   Connection problem                   │
│   Unable to load patient data.         │
│   Check your internet connection       │
│   and try again.                       │
│                                        │
│   [Try Again]    [Go to Dashboard]     │
│                                        │
└────────────────────────────────────────┘
```

The "Try Again" button re-triggers the same data fetch using `queryClient.invalidateQueries()` or equivalent.

### 3.4 Server Error (500)

**Trigger:** Supabase returns an unexpected 5xx error.

Same layout as network error but with:
- Icon: `ServerCrash`
- Message: "Server error. Our team has been notified. Please try again in a few minutes."
- No retry button — instead: "Refresh page"

### 3.5 Not Found State (404)

**Trigger:** Navigating to `/patients/[id]` where the ID does not exist or has been soft-deleted.

```
┌────────────────────────────────────────┐
│                                        │
│   [FileSearch icon]                    │
│                                        │
│   Patient not found                    │
│   This record may have been removed    │
│   or the link may be incorrect.        │
│                                        │
│   [Back to Patients]                   │
│                                        │
└────────────────────────────────────────┘
```

**Security note:** Do NOT distinguish between "record does not exist" and "you do not have permission to view it" — return the same 404-style message for both to prevent information leakage.

### 3.6 Permission Denied

**Trigger:** User attempts to access a route outside their role (edge cases bypassing middleware).

```tsx
// In the page component, after role check:
if (!hasPermission) {
  toast.warning("You don't have access to this page.");
  router.push(getRoleDefaultRoute(userRole));
}
```

The user is silently redirected to their default landing page with a toast warning. A separate error page for permission denied is not shown — the redirect is immediate.

### 3.7 Confirmation Error (Destructive Action Failed)

**Trigger:** A confirmed destructive action (delete, cancel, discharge) fails server-side.

Display:
1. An inline error banner within the confirmation dialog (red `bg-red-50 border border-red-200 rounded-lg p-3`)
2. Keep the dialog open so the user can retry or dismiss
3. Restore any optimistic UI changes

---

## Success States

### 4.1 Form Submit Success

**Trigger:** Create or update form submits successfully.

**Three-part success response:**
1. **Toast:** `toast.success('Patient registered successfully')` — auto-dismisses after 4 seconds
2. **Navigation:** Redirect to the newly created/updated record (e.g., patient profile page)
3. **Page state update:** The list or parent component refreshes to show the new record

### 4.2 Inline Success (Non-navigating Actions)

**Trigger:** Status change (confirm appointment, complete session), quick edit.

```tsx
// Success flash on table row
<TableRow className="bg-green-50 transition-colors duration-500">
  {/* Temporarily highlight the updated row */}
</TableRow>
```

The row highlight fades back to normal after 2 seconds via CSS `transition-colors`.

### 4.3 Session Log Submit Success

After saving a session log:
1. `toast.success('Session logged. Treatment plan updated.')` 
2. The "Log Session" button on the appointment detail changes to a checkmark: `CheckCircle2` icon, text "Session Logged", button disabled
3. The treatment plan progress bar increments visually

### 4.4 File Upload Success

After a patient document uploads:
- Progress bar fills to 100%
- Progress bar transitions to green: `bg-green-500`
- File appears in the file grid with a green checkmark overlay briefly
- `toast.success('Document uploaded successfully')`

---

## Warning States

### 5.1 Low Session Balance Warning

**Trigger:** Patient has ≤ 2 sessions remaining in their active package.

**Visual:** Yellow alert banner on the patient profile header.

```tsx
{remainingSessions <= 2 && (
  <div className="flex items-center gap-2 px-4 py-2 bg-yellow-50 border border-yellow-200 rounded-lg text-yellow-800 text-sm">
    <AlertTriangle className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
    <span>
      <strong>{remainingSessions} session{remainingSessions !== 1 ? 's' : ''} remaining.</strong>
      {' '}Consider renewing the patient's package.
    </span>
    <Button variant="outline" size="sm" className="ms-auto border-yellow-300 text-yellow-700 hover:bg-yellow-100">
      Record Payment
    </Button>
  </div>
)}
```

### 5.2 Overdue Payment Warning

**Trigger:** Patient has a payment with `status = 'overdue'`.

Same yellow banner pattern, with an "View Payment" action linking to the billing tab.

### 5.3 Unsaved Changes Warning

**Trigger:** User attempts to navigate away from a form with unsaved edits.

```tsx
// Use Next.js router.beforePopState or window.beforeunload
<Dialog open={showUnsavedWarning}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Unsaved changes</DialogTitle>
      <DialogDescription>
        You have unsaved changes on this form. Are you sure you want to leave?
        Your changes will be lost.
      </DialogDescription>
    </DialogHeader>
    <DialogFooter>
      <Button variant="outline" onClick={stayOnPage}>Keep Editing</Button>
      <Button variant="destructive" onClick={discardAndLeave}>Discard Changes</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

---

## Disabled States

### 6.1 Disabled Buttons

All disabled buttons use `disabled:opacity-50 disabled:cursor-not-allowed`. When a button is disabled, a tooltip explains why:

```tsx
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <span tabIndex={0}> {/* Wrapper needed for tooltip on disabled button */}
        <Button disabled={!canEdit} className="disabled:pointer-events-none">
          Edit Plan
        </Button>
      </span>
    </TooltipTrigger>
    <TooltipContent>
      <p>This plan is completed and cannot be edited.</p>
    </TooltipContent>
  </Tooltip>
</TooltipProvider>
```

**Common disabled scenarios:**

| Element | Disabled Condition | Tooltip Explanation |
|---|---|---|
| Edit Plan button | Plan status is `completed` or `cancelled` | "Completed plans cannot be edited." |
| Log Session button | Session already logged for appointment | "A session has already been logged for this appointment." |
| Confirm Appointment button | Already `confirmed`, `completed`, or `cancelled` | "Appointment is already confirmed." |
| Delete Package button | Package has active patient purchases | "Cannot delete a package with active purchases." |
| Export button | No data in the current report view | "No data to export. Adjust the date range." |

### 6.2 Read-Only Form Fields

Used for auto-generated values like `file_number` and `registration_date`:

```tsx
<Input
  value={fileNumber}
  readOnly
  className="bg-slate-50 text-slate-500 cursor-default select-all"
  aria-label="Auto-generated file number (read-only)"
/>
```

**Visual:** `bg-slate-50` background, `text-slate-500` text, no focus ring — visually distinct from editable fields.

### 6.3 Role-Restricted Fields

Fields a user's role cannot edit (e.g., `diagnosis` field for Receptionist):

```tsx
<Textarea
  value={diagnosis}
  disabled={userRole !== 'doctor' && userRole !== 'admin'}
  className="disabled:bg-slate-50 disabled:text-slate-500 disabled:cursor-not-allowed"
  aria-label="Diagnosis — editable by Doctor or Admin only"
/>
```

A small lock icon (`Lock`, 14px, `text-slate-400`) appears at the end of read-only fields with a tooltip: "Only Doctors can edit this field."

---

## Offline / Connection Lost

### 7.1 Global Offline Banner

**Trigger:** `window.navigator.onLine` becomes `false` OR a critical API call fails with a network error.

```tsx
// Global offline banner at the top of the viewport (above everything except modals)
{!isOnline && (
  <div
    className="fixed top-0 inset-x-0 z-[70] flex items-center justify-center gap-2
               bg-red-600 text-white text-sm font-medium py-2 px-4"
    role="alert"
    aria-live="assertive"
  >
    <WifiOff className="h-4 w-4" aria-hidden="true" />
    <span>You're offline. Some features may be unavailable. Changes will not be saved.</span>
  </div>
)}
```

**Behavior:**
- Banner slides down from the top with `animate-in slide-in-from-top duration-200`
- The banner is `role="alert"` with `aria-live="assertive"` — screen readers announce immediately
- All form submit buttons are disabled while offline
- When connection restores, banner shows "Connection restored" in green for 3 seconds then auto-dismisses

### 7.2 Reconnected State

```tsx
{justReconnected && (
  <div className="fixed top-0 inset-x-0 z-[70] flex items-center justify-center gap-2
                  bg-green-600 text-white text-sm font-medium py-2 px-4 animate-in slide-in-from-top"
    role="status"
    aria-live="polite"
  >
    <Wifi className="h-4 w-4" aria-hidden="true" />
    <span>Connection restored.</span>
  </div>
)}
```

Auto-dismisses after 3 seconds. The app does not auto-retry failed requests — user must manually retry to prevent unexpected side effects.

### 7.3 Realtime Feed Offline State (Dashboard)

When the Supabase Realtime connection drops:

```tsx
<div className="flex items-center gap-1.5 text-xs text-amber-600 mt-1">
  <AlertCircle className="h-3 w-3" aria-hidden="true" />
  <span>Live updates paused — reconnecting…</span>
</div>
```

Appears inline below the "Today's Activity Feed" heading. Disappears when Realtime reconnects.

---

*DOC-06-001 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*

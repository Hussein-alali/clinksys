# Components Catalog

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-C01 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | Master catalog of all reusable UI components with props, states, and usage. |
| **Owner** | Frontend Engineer |
| **Dependencies** | design-system.md |
| **Priority** | P1 |
| **Estimated Pages** | 20–40 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer | Initial stub |
| 1.0 | 2026-05-24 | Frontend Engineer | Full content added |

---

## Table of Contents

- [Layout Components](#layout-components)
- [Navigation Components](#navigation-components)
- [Form Components](#form-components)
- [Display Components](#display-components)
- [Modal & Dialog Components](#modal--dialog-components)
- [Chart Components](#chart-components)
- [Patient Components](#patient-components)
- [Appointment Components](#appointment-components)
- [Billing Components](#billing-components)
- [Notification Components](#notification-components)

---

## Layout Components

### PageHeader

A standardized page header appearing at the top of every main content area. Renders breadcrumb navigation, the page title, and an optional row of action buttons.

**Import**

```tsx
import { PageHeader } from '@/components/layout/page-header';
```

**Props**

| Prop | Type | Required | Description |
|---|---|---|---|
| `title` | `string` | Yes | Page title displayed as `<h1>` |
| `breadcrumbs` | `{ label: string; href?: string }[]` | No | Breadcrumb trail items. Last item is current page (no href). |
| `actions` | `React.ReactNode` | No | Action buttons rendered on the right. |
| `description` | `string` | No | Optional subtitle below the title. |

**Usage Example**

```tsx
<PageHeader
  title="Patient List"
  breadcrumbs={[{ label: 'Home', href: '/' }, { label: 'Patients' }]}
  actions={
    <Button onClick={openCreateDialog}>
      <Plus className="h-4 w-4 me-2" aria-hidden="true" />
      New Patient
    </Button>
  }
/>
```

**Responsive Behavior**

- Mobile (default): title and description stack above actions.
- sm+ (640px): title left, actions right in a flex row.
- lg+ (1024px): breadcrumb appears above the title row.

**Accessibility**

- Title renders as `<h1>` — only one per page.
- Breadcrumb uses `<nav aria-label="Breadcrumb">` with `<ol>` list structure.
- Current breadcrumb item has `aria-current="page"`.

---

### DataCard

A KPI summary card displaying a Lucide icon, a label, a primary value, and an optional trend indicator. Used in the dashboard grid.

**Import**

```tsx
import { DataCard } from '@/components/layout/data-card';
```

**Props**

| Prop | Type | Required | Description |
|---|---|---|---|
| `icon` | `LucideIcon` | Yes | Lucide icon component (e.g., `Users`, `Calendar`) |
| `label` | `string` | Yes | Metric label (e.g., "Total Patients") |
| `value` | `string \| number` | Yes | Primary metric value |
| `trend` | `{ value: number; direction: 'up' \| 'down' \| 'neutral'; label: string }` | No | Percentage trend vs. prior period |
| `loading` | `boolean` | No | Renders Skeleton shimmer when true |
| `className` | `string` | No | Additional Tailwind classes |

**Usage Example**

```tsx
<DataCard
  icon={Users}
  label="Total Patients"
  value="248"
  trend={{ value: 12, direction: 'up', label: 'vs last month' }}
/>
```

**States**

- **Default**: Icon in a teal-100 circle, label in muted text, value in bold 3xl/4xl, trend badge below.
- **Loading**: Full card replaced with a `<Skeleton>` block of the same dimensions.
- **Trend up**: Green upward arrow, green trend text.
- **Trend down**: Red downward arrow, red trend text.

**Accessibility**

- `aria-label` on trend icon: `"Trending up by 12% vs last month"`.
- Icon is decorative: `aria-hidden="true"`.

---

### Separator

Thin horizontal or vertical rule used to divide sections within a card or form.

**Import**

```tsx
import { Separator } from '@/components/ui/separator';
```

**Usage**

```tsx
<Separator className="my-4" />
<Separator orientation="vertical" className="h-6 mx-2" />
```

---

### Skeleton

Animated shimmer placeholder rendered during loading states. Used whenever data is being fetched asynchronously.

**Import**

```tsx
import { Skeleton } from '@/components/ui/skeleton';
```

**Animation**: A `background-position` CSS animation (1.5s linear infinite) over a gradient from `slate-200` to `slate-100` to `slate-200`, producing the shimmer effect.

**Usage Examples**

```tsx
{/* Table row skeleton */}
<div className="flex items-center space-x-4">
  <Skeleton className="h-10 w-10 rounded-full" />
  <div className="space-y-2">
    <Skeleton className="h-4 w-[200px]" />
    <Skeleton className="h-4 w-[160px]" />
  </div>
</div>

{/* DataCard skeleton */}
<Skeleton className="h-[120px] w-full rounded-lg" />
```

**Rule**: Every data-driven component must render `<Skeleton>` during its loading state. Never show empty content or a blank white card.

---

## Navigation Components

### AppSidebar

The primary navigation sidebar rendered on desktop (lg+). Contains the clinic logo, nav links grouped by section, and a footer with the logged-in user's avatar and logout button.

**Import**

```tsx
import { AppSidebar } from '@/components/layout/app-sidebar';
```

**Props**

| Prop | Type | Description |
|---|---|---|
| `role` | `'admin' \| 'receptionist' \| 'doctor' \| 'therapist'` | Controls which nav items are rendered. |
| `collapsed` | `boolean` | Rail mode (icon-only) when true. |
| `onToggle` | `() => void` | Called when the collapse/expand button is clicked. |

**Nav Sections by Role**

| Section | Items | Visible To |
|---|---|---|
| Overview | Dashboard | All roles |
| Clinical | Patients, Appointments, Treatment Plans, Session Log | All roles (filtered per role) |
| Finance | Payments, Invoices | Admin, Receptionist |
| Reports | Reports, Google Sheets Sync | Admin |
| Settings | Users, Clinic Settings | Admin |
| Marketing | Campaigns | Admin |

**Accessibility**

- `<nav role="navigation" aria-label="Main navigation">` wrapper.
- Active link: `aria-current="page"`.
- Collapsed state: each icon button has `aria-label` with the nav item name.
- Collapse toggle: `aria-expanded={!collapsed}` + `aria-label="Toggle sidebar"`.

**RTL Notes**

- Sidebar renders on the right in RTL mode (`dir="rtl"`).
- Uses logical CSS: `border-e` (end border) instead of `border-r`.
- Chevron icons for expand/collapse use `rotate-180` in RTL — handled automatically via `tailwindcss-rtl`.

---

### BottomNav

Mobile bottom navigation bar visible on screens below `lg:` (1024px). Shows 5 icon tabs.

**Import**

```tsx
import { BottomNav } from '@/components/layout/bottom-nav';
```

**Tabs**

| Icon | Label | Route | Roles |
|---|---|---|---|
| `Home` | Dashboard | `/dashboard` | All |
| `Calendar` | Appointments | `/appointments` | All |
| `Users` | Patients | `/patients` | All |
| `ClipboardList` | Sessions | `/sessions` | Therapist, Doctor |
| `MoreHorizontal` | More | Opens slide-up sheet | All |

**Accessibility**

- `<nav role="navigation" aria-label="Mobile navigation">`.
- Active tab: `aria-current="page"`.
- Each tab is a `<a>` or `<button>` with visible label below icon.
- Bottom safe area padding: `pb-safe` (uses `env(safe-area-inset-bottom)`).

---

## Form Components

### Button

The primary interactive control. Built on Shadcn/UI Button which wraps a Radix UI Slot.

**Import**

```tsx
import { Button } from '@/components/ui/button';
```

**Variants**

| Variant | Use Case | Visual Style |
|---|---|---|
| `default` (primary) | Primary actions (Save, Submit, Create) | Solid cyan-600 background, white text |
| `secondary` | Secondary/neutral actions (Cancel, Back) | Slate-100 background, slate-700 text |
| `destructive` | Destructive actions (Delete, Deactivate) | Red-600 background, white text |
| `ghost` | Subtle actions, icon buttons in tables | No background, slate-700 text; hover: slate-100 bg |
| `outline` | Less prominent primary (Filter, Export) | Transparent bg, slate-300 border, slate-700 text |
| `link` | Inline text-style links | No bg, cyan-600 text, underline on hover |

**Sizes**

| Size | Height | Padding | Font Size |
|---|---|---|---|
| `sm` | 32px | px-3 | text-xs |
| `default` | 40px | px-4 | text-sm |
| `lg` | 48px | px-6 | text-base |
| `icon` | 40×40px | p-0 | — |

**Loading State**

Buttons with async actions display a spinner and are disabled while loading:

```tsx
<Button disabled={isLoading}>
  {isLoading && <Loader2 className="h-4 w-4 me-2 animate-spin" aria-hidden="true" />}
  {isLoading ? 'Saving...' : 'Save Patient'}
</Button>
```

- When `disabled={true}`: `opacity-50 cursor-not-allowed` via Tailwind.
- `aria-disabled="true"` is set automatically by Shadcn when `disabled` is passed.

**Accessibility**

- Never use `<div>` or `<span>` as buttons. Always use `<Button>` or `<button>`.
- Icon-only buttons require `aria-label`: `<Button variant="ghost" size="icon" aria-label="Delete patient">`.
- All Lucide icons inside buttons: `aria-hidden="true"`.

**RTL Notes**

- Icon + text buttons: use `me-2` (margin-end) on the icon, not `mr-2`, so the icon appears before the text in both LTR and RTL.

---

### Input

Text input field. Wraps the native `<input>` element with PTCMS styling.

**Import**

```tsx
import { Input } from '@/components/ui/input';
```

**Type Variants**

| Type | `type` Attribute | `inputMode` | Notes |
|---|---|---|---|
| Text | `text` | — | Default; names, addresses |
| Email | `email` | `email` | Login form, user creation |
| Phone | `tel` | `tel` | Egyptian mobile numbers; `dir="ltr"` always |
| Number | `number` | `numeric` | Age, session count, prices |
| Date | `date` | — | Date of birth, appointment date |
| Password | `password` | — | Login form |

**Error State**

When a validation error is present, the input shows a red border and an error message appears below:

```tsx
<Input
  id="phone"
  type="tel"
  inputMode="tel"
  dir="ltr"
  aria-invalid={!!errors.phone}
  aria-describedby={errors.phone ? 'phone-error' : 'phone-hint'}
  className={cn('border-slate-300', errors.phone && 'border-red-400 focus-visible:ring-red-400')}
/>
{errors.phone && (
  <p id="phone-error" role="alert" className="mt-1 text-xs text-red-600 flex items-center gap-1">
    <AlertCircle className="h-3 w-3 flex-shrink-0" aria-hidden="true" />
    {errors.phone.message}
  </p>
)}
```

**RTL Notes**

- Phone number inputs always use `dir="ltr"` regardless of page direction.
- File numbers and numeric codes use `dir="ltr"`.
- All other inputs inherit `dir` from the document.

---

### Label

Associates a visible label with a form control.

**Import**

```tsx
import { Label } from '@/components/ui/label';
```

**Usage**

```tsx
<Label htmlFor="patient-name">
  Full Name <span aria-hidden="true">*</span>
  <span className="sr-only">(required)</span>
</Label>
<Input id="patient-name" aria-required="true" />
```

**Rules**

- `htmlFor` must always match the `id` of its associated control.
- Required fields: asterisk `*` is `aria-hidden`; `aria-required="true"` on the input is the machine-readable signal.
- Labels are never hidden. Use `sr-only` only for supplemental context, not as a replacement for a visible label.

---

### Select

Controlled dropdown selection built on Radix UI Select.

**Import**

```tsx
import {
  Select, SelectTrigger, SelectValue, SelectContent, SelectItem
} from '@/components/ui/select';
```

**Usage**

```tsx
<Select value={value} onValueChange={setValue}>
  <SelectTrigger id="gender" aria-label="Select gender">
    <SelectValue placeholder="Select gender..." />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="male">Male</SelectItem>
    <SelectItem value="female">Female</SelectItem>
  </SelectContent>
</Select>
```

**Searchable Select (Combobox)**

For long lists (patients, therapists, doctors), use a Combobox pattern built on Shadcn Command:

```tsx
import { Combobox } from '@/components/ui/combobox';

<Combobox
  options={patients.map(p => ({ value: p.patient_id, label: p.full_name }))}
  value={selectedPatientId}
  onValueChange={setSelectedPatientId}
  placeholder="Search patients..."
  emptyMessage="No patients found."
/>
```

**Accessibility**

- SelectTrigger: `aria-expanded`, `aria-haspopup="listbox"` managed by Radix.
- SelectItem: `role="option"`, `aria-selected` managed by Radix.
- Keyboard: Arrow keys navigate, Enter selects, Esc closes.

---

### Checkbox

**Import**

```tsx
import { Checkbox } from '@/components/ui/checkbox';
```

**Usage**

```tsx
<div className="flex items-center gap-2">
  <Checkbox
    id="terms"
    checked={checked}
    onCheckedChange={setChecked}
    aria-required="true"
  />
  <Label htmlFor="terms">I confirm the session was completed</Label>
</div>
```

---

### RadioGroup

Used for gender selection and payment method selection.

**Import**

```tsx
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
```

**Usage**

```tsx
<fieldset>
  <legend className="text-sm font-medium text-slate-700 mb-2">
    Gender <span aria-hidden="true">*</span>
  </legend>
  <RadioGroup value={gender} onValueChange={setGender} aria-required="true">
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

**Payment Method RadioGroup**

The payment form uses styled radio cards instead of standard radio buttons for better visual affordance on touch devices:

```tsx
<RadioGroup value={method} onValueChange={setMethod} className="grid grid-cols-2 gap-2 md:grid-cols-3">
  {PAYMENT_METHODS.map((m) => (
    <Label
      key={m.value}
      htmlFor={`method-${m.value}`}
      className={cn(
        'flex items-center gap-2 rounded-lg border p-3 cursor-pointer min-h-[60px]',
        method === m.value && 'border-cyan-600 bg-cyan-50'
      )}
    >
      <RadioGroupItem value={m.value} id={`method-${m.value}`} className="sr-only" />
      <m.Icon className="h-4 w-4" aria-hidden="true" />
      {m.label}
    </Label>
  ))}
</RadioGroup>
```

---

### Slider

Base Shadcn Slider (Radix UI range input). Extended into `PainSlider` for clinical use.

**Import**

```tsx
import { Slider } from '@/components/ui/slider';
```

---

### Textarea

Multi-line text input with optional auto-resize behavior.

**Import**

```tsx
import { Textarea } from '@/components/ui/textarea';
```

**Auto-Resize**

```tsx
// Auto-resize on content change using a ref
const textareaRef = useRef<HTMLTextAreaElement>(null);
const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
  const el = textareaRef.current;
  if (el) {
    el.style.height = 'auto';
    el.style.height = `${el.scrollHeight}px`;
  }
  onChange(e);
};
```

**Usage**

```tsx
<Textarea
  id="chief-complaint"
  ref={textareaRef}
  rows={3}
  maxLength={500}
  aria-required="true"
  aria-describedby="complaint-hint"
  onChange={handleChange}
  placeholder="Describe the patient's primary complaint..."
/>
<p id="complaint-hint" className="text-xs text-slate-500 mt-1">10–500 characters</p>
```

---

### Form (React Hook Form + Zod Integration)

All forms in PTCMS use React Hook Form with `zodResolver` for both client-side and server-consistent validation.

**Import**

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from '@/components/ui/form';
```

**Standard Form Setup**

```tsx
const form = useForm<PatientFormValues>({
  resolver: zodResolver(patientSchema),
  mode: 'onTouched',
  reValidateMode: 'onChange',
  defaultValues: { full_name: '', phone: '', gender: 'male', chief_complaint: '' },
});

return (
  <Form {...form}>
    <form onSubmit={form.handleSubmit(onSubmit)} noValidate>
      <FormField
        control={form.control}
        name="full_name"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Full Name <span aria-hidden="true">*</span></FormLabel>
            <FormControl>
              <Input {...field} aria-required="true" />
            </FormControl>
            <FormMessage /> {/* Renders Zod error message */}
          </FormItem>
        )}
      />
    </form>
  </Form>
);
```

**Rules**

- Never use uncontrolled inputs for PTCMS forms.
- Always pass `noValidate` on the `<form>` element — browser native validation is suppressed in favor of Zod.
- Error messages from `FormMessage` automatically link to the field via `aria-describedby`.

---

### Calendar (Date Picker)

Shadcn Calendar component wrapped in a Popover for inline date selection.

**Import**

```tsx
import { Calendar } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
```

**Usage**

```tsx
<Popover>
  <PopoverTrigger asChild>
    <Button variant="outline" aria-label={`Selected date: ${format(date, 'dd/MM/yyyy')}`}>
      <CalendarIcon className="h-4 w-4 me-2" aria-hidden="true" />
      {date ? format(date, 'dd/MM/yyyy') : 'Pick a date'}
    </Button>
  </PopoverTrigger>
  <PopoverContent align="start">
    <Calendar
      mode="single"
      selected={date}
      onSelect={setDate}
      disabled={(d) => d < new Date() || d > addDays(new Date(), 60)}
      locale={ar}
    />
  </PopoverContent>
</Popover>
```

**Keyboard Navigation**

- Arrow keys: navigate days.
- Page Up/Down: navigate months.
- Enter: select focused date.
- Esc: close the popover.

**RTL Notes**

- Pass `locale={ar}` from `date-fns/locale` for Arabic month/day names.
- Calendar grid direction mirrors correctly with `dir="rtl"` on the document.

---

### DropdownMenu

Contextual action menu for table rows and header actions.

**Import**

```tsx
import {
  DropdownMenu, DropdownMenuTrigger, DropdownMenuContent,
  DropdownMenuItem, DropdownMenuSeparator
} from '@/components/ui/dropdown-menu';
```

**Usage in Table Rows**

```tsx
<DropdownMenu>
  <DropdownMenuTrigger asChild>
    <Button variant="ghost" size="icon" aria-label={`Actions for patient ${patient.full_name}`}>
      <MoreHorizontal className="h-4 w-4" aria-hidden="true" />
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent align="end">
    <DropdownMenuItem onSelect={() => router.push(`/patients/${patient.patient_id}`)}>
      <Eye className="h-4 w-4 me-2" aria-hidden="true" />
      View Profile
    </DropdownMenuItem>
    <DropdownMenuItem onSelect={() => openEditDialog(patient)}>
      <Pencil className="h-4 w-4 me-2" aria-hidden="true" />
      Edit
    </DropdownMenuItem>
    <DropdownMenuSeparator />
    <DropdownMenuItem
      onSelect={() => openDeactivateDialog(patient)}
      className="text-red-600 focus:text-red-600"
    >
      <UserX className="h-4 w-4 me-2" aria-hidden="true" />
      Deactivate
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

**Accessibility**

- Trigger button must have a descriptive `aria-label` that identifies the row context.
- Esc key closes the menu and returns focus to the trigger.

---

### Table (with SortableHeader)

Data table for listing patients, appointments, payments, etc.

**Import**

```tsx
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table';
import { SortableHeader } from '@/components/ui/sortable-header';
```

**SortableHeader Props**

| Prop | Type | Description |
|---|---|---|
| `column` | `string` | Column key used for sort state |
| `currentSort` | `{ column: string; direction: 'asc' \| 'desc' }` | Current sort state |
| `onSort` | `(column: string) => void` | Callback when header is clicked |
| `children` | `React.ReactNode` | Column label text |

**Usage**

```tsx
<Table role="grid" aria-label="Patient list">
  <TableHeader>
    <TableRow>
      <TableHead>
        <SortableHeader column="full_name" currentSort={sort} onSort={handleSort}>
          Full Name
        </SortableHeader>
      </TableHead>
      <TableHead className="hidden md:table-cell">Phone</TableHead>
      <TableHead>Status</TableHead>
      <TableHead className="w-[60px]">Actions</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {patients.map((p) => (
      <TableRow
        key={p.patient_id}
        tabIndex={0}
        className="cursor-pointer hover:bg-slate-50"
        onClick={() => router.push(`/patients/${p.patient_id}`)}
        onKeyDown={(e) => e.key === 'Enter' && router.push(`/patients/${p.patient_id}`)}
        aria-label={`Patient ${p.full_name}, file ${p.file_number}`}
      >
        <TableCell className="font-medium">{p.full_name}</TableCell>
        <TableCell className="hidden md:table-cell">{p.phone}</TableCell>
        <TableCell><StatusBadge status={p.status} /></TableCell>
        <TableCell><ActionsDropdown patient={p} /></TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

**Responsive**

- Columns with `hidden md:table-cell` are hidden on mobile, visible from tablet up.
- On small mobile, the entire table is wrapped in `overflow-x-auto` with a minimum inner width of 640px.

---

### Tabs

Used in the patient profile page to organize information into 7 tabs.

**Import**

```tsx
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
```

**Patient Profile Tabs**

```tsx
<Tabs defaultValue="overview">
  <TabsList className="grid w-full grid-cols-4 lg:grid-cols-7">
    <TabsTrigger value="overview">Overview</TabsTrigger>
    <TabsTrigger value="appointments">Appointments</TabsTrigger>
    <TabsTrigger value="treatment-plans">Treatment Plans</TabsTrigger>
    <TabsTrigger value="sessions">Sessions</TabsTrigger>
    <TabsTrigger value="payments">Payments</TabsTrigger>
    <TabsTrigger value="invoices">Invoices</TabsTrigger>
    <TabsTrigger value="documents">Documents</TabsTrigger>
  </TabsList>
  <TabsContent value="overview">...</TabsContent>
  {/* ... */}
</Tabs>
```

**Accessibility**

- Radix Tabs implements `role="tablist"`, `role="tab"`, `role="tabpanel"` automatically.
- Arrow Left/Right navigate between tabs.
- Active tab: `aria-selected="true"`.
- Each `TabsContent` is linked to its trigger via `aria-controls`/`aria-labelledby`.

---

### Popover

Floating content panel anchored to a trigger element. Used for date pickers and filter panels.

**Import**

```tsx
import { Popover, PopoverTrigger, PopoverContent } from '@/components/ui/popover';
```

**Accessibility**

- Esc closes the popover and returns focus to the trigger.
- `role="dialog"` on content, managed by Radix.

---

## Display Components

### Card

Container for grouped content sections.

**Import**

```tsx
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card';
```

**Usage**

```tsx
<Card className="rounded-lg shadow-md">
  <CardHeader>
    <CardTitle>Patient Overview</CardTitle>
    <CardDescription>Last updated 2 hours ago</CardDescription>
  </CardHeader>
  <CardContent>
    {/* content */}
  </CardContent>
  <CardFooter className="flex justify-end gap-2">
    <Button variant="outline">Cancel</Button>
    <Button>Save</Button>
  </CardFooter>
</Card>
```

**Border Radius**: `rounded-lg` (12px) for cards. Do not use `rounded-xl` or `rounded-2xl`.

---

### Badge

Small inline label for status, categories, and counts.

**Import**

```tsx
import { Badge } from '@/components/ui/badge';
```

**Variants**

| Variant | Background | Text | Use Case |
|---|---|---|---|
| `default` | cyan-100 | cyan-800 | General tags |
| `secondary` | slate-100 | slate-700 | Neutral labels |
| `destructive` | red-100 | red-800 | Error/danger labels |
| `outline` | transparent | slate-700 | Subtle tags |

**Rule**: Never use badge color alone to convey meaning. Always include an icon or text.

---

### StatusBadge

PTCMS custom badge component for appointment status and payment status. Always includes an icon and text label.

**Import**

```tsx
import { StatusBadge } from '@/components/ui/status-badge';
```

**Props**

| Prop | Type | Description |
|---|---|---|
| `status` | `AppointmentStatus \| PaymentStatus` | The status value to display. |
| `className` | `string` | Additional classes. |

**Appointment Status Mappings**

| Status | Icon | Text Color | Background |
|---|---|---|---|
| `scheduled` | `Clock` | blue-700 | blue-50 |
| `confirmed` | `CheckCircle` | blue-700 | blue-50 |
| `completed` | `CheckCircle2` | green-800 | green-50 |
| `cancelled` | `XCircle` | rose-800 | rose-50 |
| `no_show` | `AlertTriangle` | orange-800 | orange-50 |

**Payment Status Mappings**

| Status | Icon | Text Color | Background |
|---|---|---|---|
| `paid` | `CheckCircle2` | green-800 | green-50 |
| `partial` | `Clock` | yellow-800 | yellow-50 |
| `unpaid` | `AlertCircle` | red-800 | red-50 |
| `overdue` | `AlertTriangle` | red-900 | red-100 |

**Implementation**

```tsx
export function StatusBadge({ status, className }: StatusBadgeProps) {
  const config = STATUS_CONFIG[status];
  return (
    <span className={cn('inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium', config.className, className)}>
      <config.Icon className="h-3 w-3" aria-hidden="true" />
      <span className="sr-only">Status: </span>
      {config.label}
    </span>
  );
}
```

**Accessibility**: Icon is `aria-hidden`. A `sr-only` "Status: " prefix is prepended for screen reader context.

---

### Avatar

Circular user/patient photo display with initials fallback.

**Import**

```tsx
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
```

**Usage**

```tsx
<Avatar className="h-10 w-10">
  <AvatarImage
    src={patient.profile_image_url}
    alt={`Profile photo of ${patient.full_name}`}
  />
  <AvatarFallback className="bg-cyan-100 text-cyan-800 text-sm font-semibold">
    {getInitials(patient.full_name)}
  </AvatarFallback>
</Avatar>
```

**Initials Logic**

```typescript
export function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
}
```

**Sizes**

| Context | Class |
|---|---|
| Patient list table | `h-8 w-8 md:h-10 md:w-10` |
| Patient profile header | `h-16 w-16 md:h-20 md:w-20` |
| User menu (sidebar footer) | `h-8 w-8` |
| Comment/feed items | `h-6 w-6` |

---

## Modal & Dialog Components

### Dialog

Full-feature modal dialog. Built on Radix UI Dialog. Handles focus trap, Esc to close, backdrop click to close, and focus restoration automatically.

**Import**

```tsx
import {
  Dialog, DialogTrigger, DialogContent, DialogHeader,
  DialogTitle, DialogDescription, DialogFooter, DialogClose
} from '@/components/ui/dialog';
```

**Behavior**

- **Open**: Focus moves to first focusable element inside `DialogContent` (or the container itself).
- **Esc key**: Closes the dialog.
- **Backdrop click**: Closes the dialog.
- **Close**: Focus returns to the `DialogTrigger` element.
- **Background**: `aria-hidden="true"` and `inert` applied to the page behind the dialog while open.

**Usage**

```tsx
<Dialog open={open} onOpenChange={setOpen}>
  <DialogTrigger asChild>
    <Button>Add Package</Button>
  </DialogTrigger>
  <DialogContent className="sm:max-w-[560px]">
    <DialogHeader>
      <DialogTitle>Add Treatment Package</DialogTitle>
      <DialogDescription>
        Create a new treatment package for this patient.
      </DialogDescription>
    </DialogHeader>
    <PackageForm onSuccess={() => setOpen(false)} />
    <DialogFooter>
      <DialogClose asChild>
        <Button variant="secondary">Cancel</Button>
      </DialogClose>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

**Responsive**

- Mobile (default): Full-screen (100vw, 100vh) via `DialogContent` override.
- sm+ (640px): Centered with `max-w-[560px]`, backdrop dimmed.
- lg+ (1024px): Centered with `max-w-[600px]`.

---

### Sheet

Side-drawer panel that slides in from the right (or left in RTL). Used for appointment detail view.

**Import**

```tsx
import { Sheet, SheetTrigger, SheetContent, SheetHeader, SheetTitle, SheetClose } from '@/components/ui/sheet';
```

**Usage**

```tsx
<Sheet open={open} onOpenChange={setOpen}>
  <SheetContent side="right" className="w-full sm:max-w-[400px] md:max-w-[500px]">
    <SheetHeader>
      <SheetTitle>Appointment Details</SheetTitle>
    </SheetHeader>
    <AppointmentDetail appointmentId={appointmentId} />
  </SheetContent>
</Sheet>
```

**RTL Notes**

- In RTL mode (`dir="rtl"`), set `side="left"` so the sheet slides in from the left (visually the "end" of the screen in RTL).
- Or use the logical variant: `side={dir === 'rtl' ? 'left' : 'right'}`.

---

## Chart Components

PTCMS uses Recharts for all data visualizations. Charts are responsive using `ResponsiveContainer` and use the design system's color tokens.

**Common Chart Colors**

```typescript
const CHART_COLORS = {
  primary: '#0891B2',   // cyan-600
  success: '#22C55E',   // green-500
  warning: '#F59E0B',   // amber-500
  danger: '#EF4444',    // red-500
  muted: '#94A3B8',     // slate-400
};
```

**Revenue Trend Chart**: `<LineChart>` — x-axis = weeks/months, y-axis = EGP revenue. Uses `primary` color.

**Appointment Status Breakdown**: `<PieChart>` with `<Cell>` per status using the status color map.

**Session Progress Chart**: `<BarChart>` — sessions by progress category (improved/same/declined/completed).

**All charts**:
- Have `<Tooltip>` with accessible content.
- Have `<Legend>` with text labels (not color-only).
- Are wrapped in `<ResponsiveContainer width="100%" height={280}>`.
- Render `<Skeleton className="h-[280px]" />` during data loading.

---

## Patient Components

### PainSlider

Custom component extending Shadcn Slider. Used in the Session Log form for pain level assessment (0–10 scale).

**Import**

```tsx
import { PainSlider } from '@/components/patient/pain-slider';
```

**Props**

| Prop | Type | Required | Description |
|---|---|---|---|
| `value` | `number` | Yes | Current pain level (0–10) |
| `onChange` | `(value: number) => void` | Yes | Called on value change |
| `label` | `string` | Yes | Accessible label (e.g., "Pain level before session") |
| `id` | `string` | Yes | For aria-labelledby association |

**Visual Design**

- Track: gradient background from `red-500` (0) through `yellow-400` (5) to `green-500` (10).
- Thumb: large 44×44px (touch-optimized), shows current numeric value inside.
- Below the track: emoji hints at key positions — `😰` (0), `😐` (5), `😊` (10).
- Above the thumb: large numeric display showing the current value in 4xl bold.

**Implementation**

```tsx
export function PainSlider({ value, onChange, label, id }: PainSliderProps) {
  return (
    <div className="space-y-3">
      <div className="text-center">
        <span className="text-4xl font-bold text-slate-900" aria-live="polite" aria-atomic="true">
          {value}
        </span>
        <span className="text-sm text-slate-500 ms-1">/ 10</span>
      </div>
      <div className="relative">
        <input
          id={id}
          type="range"
          min={0}
          max={10}
          step={1}
          value={value}
          onChange={(e) => onChange(Number(e.target.value))}
          aria-label={label}
          aria-valuemin={0}
          aria-valuemax={10}
          aria-valuenow={value}
          aria-valuetext={`${value} out of 10`}
          style={{
            background: `linear-gradient(to right,
              #EF4444 0%, #F59E0B 50%, #22C55E 100%)`,
          }}
          className="w-full h-3 rounded-full appearance-none cursor-pointer
            [&::-webkit-slider-thumb]:w-11 [&::-webkit-slider-thumb]:h-11
            [&::-webkit-slider-thumb]:appearance-none
            [&::-webkit-slider-thumb]:rounded-full
            [&::-webkit-slider-thumb]:bg-white
            [&::-webkit-slider-thumb]:shadow-md
            [&::-webkit-slider-thumb]:border-2
            [&::-webkit-slider-thumb]:border-slate-300"
          style={{ touchAction: 'none' }}
        />
      </div>
      <div className="flex justify-between text-lg">
        <span aria-hidden="true">😰</span>
        <span aria-hidden="true">😐</span>
        <span aria-hidden="true">😊</span>
      </div>
    </div>
  );
}
```

**Accessibility**

- `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, `aria-valuetext` on the range input.
- The large numeric display uses `aria-live="polite"` so screen readers announce the value as it changes.
- Emojis are `aria-hidden` — they are decorative hints only.
- `touch-action: none` prevents page scroll conflicts while dragging the slider on touch screens.

---

### SignatureCanvas

Patient digital signature collection component. Wraps `react-signature-canvas`. Used in Session Log form for therapist confirmation.

**Import**

```tsx
import { SignatureCanvas } from '@/components/patient/signature-canvas';
```

**Props**

| Prop | Type | Required | Description |
|---|---|---|---|
| `onSave` | `(dataUrl: string) => void` | Yes | Called with PNG base64 data URL when saved |
| `onClear` | `() => void` | Yes | Called when canvas is cleared |
| `hasError` | `boolean` | No | Shows red border when true |

**Implementation**

```tsx
import SignaturePad from 'react-signature-canvas';

export function SignatureCanvas({ onSave, onClear, hasError }: SignatureCanvasProps) {
  const padRef = useRef<SignaturePad>(null);

  const handleSave = () => {
    if (padRef.current?.isEmpty()) {
      // trigger error — canvas is empty
      return;
    }
    const dataUrl = padRef.current!.toDataURL('image/png');
    onSave(dataUrl);
  };

  return (
    <div
      role="application"
      tabIndex={0}
      aria-label="Digital signature canvas. Draw your signature using mouse or touch."
      className={cn(
        'rounded-md border-2 bg-white',
        hasError ? 'border-red-400' : 'border-slate-300'
      )}
    >
      <SignaturePad
        ref={padRef}
        canvasProps={{
          style: { touchAction: 'none', width: '100%', height: 160 },
        }}
      />
      <div className="flex justify-end gap-2 p-2 border-t border-slate-100">
        <Button
          type="button"
          variant="ghost"
          size="sm"
          onClick={() => { padRef.current?.clear(); onClear(); }}
          aria-label="Clear signature"
        >
          <Eraser className="h-4 w-4 me-1" aria-hidden="true" />
          Clear
        </Button>
      </div>
    </div>
  );
}
```

**Export Format**: PNG base64 data URL, stored in the `signature_image_url` field of the session log.

**RTL Notes**: The canvas draw surface is direction-neutral (pixel-based), so no RTL adjustment is needed for the drawing area itself.

---

## Appointment Components

### AppointmentDayList

Mobile-optimized list view of appointments grouped by day. Renders in place of the monthly calendar grid on sm/md screens.

**Structure per appointment item**:
- Time range (e.g., 09:00–10:00)
- Patient name + avatar
- Therapist name
- StatusBadge

Each item is a tappable card navigating to the appointment detail Sheet.

---

## Billing Components

### InvoicePreview

Read-only styled invoice display used inside a Dialog for preview before PDF download.

**Sections**: Clinic header, patient details, itemized service table, total/paid/balance row, payment method, invoice number, and date.

**PDF Export**: A "Download PDF" button triggers `react-pdf` rendering of the same layout to a PDF blob and downloads it.

---

## Notification Components

### Sonner (Toast Notifications)

PTCMS uses Sonner for all toast notifications. The `<Toaster>` component is placed once in the root layout.

**Import**

```tsx
import { Toaster } from '@/components/ui/sonner';
import { toast } from 'sonner';
```

**Setup (root layout)**

```tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl">
      <body>
        {children}
        <Toaster
          position="top-center"
          richColors
          duration={4000}
          closeButton
        />
      </body>
    </html>
  );
}
```

**Toast Variants**

| Variant | Function | Icon | Duration | Use Case |
|---|---|---|---|---|
| Success | `toast.success(msg)` | `CheckCircle` green | 4 seconds | Record saved, payment recorded |
| Error | `toast.error(msg)` | `XCircle` red | 6 seconds (longer for errors) | Save failed, conflict detected |
| Warning | `toast.warning(msg)` | `AlertTriangle` amber | 5 seconds | Soft warnings, near-expiry packages |
| Info | `toast.info(msg)` | `Info` blue | 4 seconds | Background sync complete, session count update |

**Usage Examples**

```tsx
// Success
toast.success('Patient registered successfully', {
  description: `File number: ${newPatient.file_number}`,
});

// Error
toast.error('Failed to save appointment', {
  description: error.message,
});

// Warning
toast.warning('Package balance is low', {
  description: `${patient.full_name} has 2 sessions remaining.`,
});
```

**Accessibility**

- Sonner renders toasts with `role="status"` for success/info (polite) and `role="alert"` for error (assertive).
- The close button allows keyboard dismissal.
- `richColors` ensures sufficient contrast for AAA compliance.
- Auto-dismiss: 4 seconds for success/info; errors stay until dismissed or 6 seconds.

---

*DOC-06-C01 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*

# Shared Components

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-006 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | Catalog of lowest-level atomic components shared across the entire application. |
| **Owner** | Frontend Engineer |
| **Dependencies** | design-system.md, theme-guide.md |
| **Priority** | P1 |
| **Estimated Pages** | 20–30 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer | Initial stub |
| 1.0 | 2026-05-24 | Frontend Engineer | Full content added |

---

## Table of Contents

- [Button System](#button-system)
- [Input Fields](#input-fields)
- [Select / Combobox](#select--combobox)
- [DatePicker / TimePicker](#datepicker--timepicker)
- [Checkbox / Radio / Toggle](#checkbox--radio--toggle)
- [Table Component](#table-component)
- [Badge / Status Indicator](#badge--status-indicator)
- [Avatar / AvatarGroup](#avatar--avatargroup)
- [Tooltip / Popover](#tooltip--popover)
- [Loading / Skeleton](#loading--skeleton)
- [Empty State](#empty-state)
- [Error Boundary](#error-boundary)

---

## Button System

### Overview

The Button component wraps Shadcn/UI `<Button>` with PTCMS-specific variants, loading state, and icon slot support.

### Variants

| Variant | Background | Text | Hover | Use Case |
|---|---|---|---|---|
| `primary` | `bg-cyan-600` | `text-white` | `bg-cyan-700` | Primary actions: Save, Submit, Confirm |
| `secondary` | `bg-slate-100` | `text-slate-900` | `bg-slate-200` | Secondary actions: Cancel, Back |
| `destructive` | `bg-red-600` | `text-white` | `bg-red-700` | Dangerous actions: Delete, Deactivate |
| `outline` | `bg-transparent border border-slate-300` | `text-slate-900` | `bg-slate-50` | Tertiary actions: Export, Filters |
| `ghost` | `bg-transparent` | `text-slate-700` | `bg-slate-100` | In-table actions, icon buttons |
| `success` | `bg-green-600` | `text-white` | `bg-green-700` | Confirm session, Complete plan |
| `link` | `bg-transparent` | `text-cyan-600 underline` | `text-cyan-700` | Inline text links |

### Sizes

| Size | Height | Padding | Font Size | Use Case |
|---|---|---|---|---|
| `sm` | 32px | `px-3 py-1.5` | `text-xs` | Compact table actions |
| `md` (default) | 40px | `px-4 py-2` | `text-sm` | Standard form submissions |
| `lg` | 48px | `px-6 py-3` | `text-base` | Primary CTA on mobile, prominent actions |
| `icon` | 40×40px | `p-2` | — | Icon-only buttons |
| `icon-sm` | 32×32px | `p-1.5` | — | Compact icon buttons |

All button sizes maintain ≥ 44×44px actual tap target via padding or `before:` pseudo-element extension.

### Loading State

When `isLoading={true}`:
- Button is `disabled`.
- Shows a `Loader2` icon with `animate-spin` at 16px, replacing the left icon slot.
- Button text remains visible alongside the spinner.
- `aria-disabled="true"` and `aria-busy="true"` are set.

```tsx
<Button variant="primary" isLoading={isSubmitting}>
  {isSubmitting ? 'Saving...' : 'Save Patient'}
</Button>
```

### Icon Support

```tsx
// Icon on the left
<Button variant="primary" leftIcon={<Plus className="h-4 w-4" aria-hidden="true" />}>
  Add Patient
</Button>

// Icon on the right
<Button variant="outline" rightIcon={<Download className="h-4 w-4" aria-hidden="true" />}>
  Export CSV
</Button>

// Icon only — always requires aria-label
<Button variant="ghost" size="icon" aria-label="Edit appointment">
  <Pencil className="h-4 w-4" aria-hidden="true" />
</Button>
```

### Focus Ring

All buttons apply: `focus-visible:ring-2 focus-visible:ring-cyan-600 focus-visible:ring-offset-2`

---

## Input Fields

### Anatomy

```
[Label]                           [optional hint text]
[Icon left?] [Input text area] [Icon right? / Clear button?]
[Error message]
```

### Types Supported

| Type | `inputMode` | `autoComplete` | Special Behavior |
|---|---|---|---|
| `text` | `text` | varies | Standard text |
| `email` | `email` | `email` | Lowercase transform on blur |
| `tel` | `tel` | `tel` | Phone format hint in placeholder |
| `number` | `numeric` | `off` | `min`/`max` attributes applied |
| `password` | — | `current-password` or `new-password` | Show/hide toggle via `Eye`/`EyeOff` icon |
| `search` | `search` | `off` | Debounced `onChange`, `X` clear button, `Search` icon left |

### States

| State | Visual Treatment |
|---|---|
| Default | `border-slate-300` |
| Focus | `border-cyan-600 ring-2 ring-cyan-600 ring-offset-0` |
| Error | `border-red-400 ring-2 ring-red-400` |
| Disabled | `bg-slate-50 text-slate-400 cursor-not-allowed` |
| Read-only | `bg-slate-50 border-transparent` |
| Loading (async check) | Right-side `Loader2 animate-spin h-4 w-4 text-slate-400` |
| Valid (async confirmed) | Right-side `CheckCircle h-4 w-4 text-green-500` (fades after 2s) |

### Example Usage

```tsx
<div className="space-y-1">
  <Label htmlFor="patient-name">
    Full Name <span aria-hidden="true" className="text-red-500">*</span>
  </Label>
  <Input
    id="patient-name"
    type="text"
    placeholder="Enter full name"
    aria-required="true"
    aria-invalid={!!errors.full_name}
    aria-describedby={errors.full_name ? 'name-error' : 'name-hint'}
    {...register('full_name')}
  />
  <p id="name-hint" className="text-xs text-slate-500">
    Arabic and English names are supported
  </p>
  {errors.full_name && (
    <p id="name-error" role="alert" className="text-xs text-red-600 flex gap-1 items-center">
      <AlertCircle className="h-3 w-3" aria-hidden="true" />
      {errors.full_name.message}
    </p>
  )}
</div>
```

### Password Show/Hide Toggle

```tsx
const [showPassword, setShowPassword] = useState(false);

<div className="relative">
  <Input type={showPassword ? 'text' : 'password'} {...register('password')} />
  <button
    type="button"
    className="absolute end-3 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-700"
    aria-label={showPassword ? 'Hide password' : 'Show password'}
    onClick={() => setShowPassword(!showPassword)}
  >
    {showPassword
      ? <EyeOff className="h-4 w-4" aria-hidden="true" />
      : <Eye className="h-4 w-4" aria-hidden="true" />}
  </button>
</div>
```

---

## Select / Combobox

### Simple Select (Shadcn Select)

Used for small, fixed option lists (e.g., gender, payment method, role).

```tsx
<Select onValueChange={field.onChange} defaultValue={field.value}>
  <SelectTrigger id="gender" aria-required="true" aria-invalid={!!errors.gender}>
    <SelectValue placeholder="Select gender" />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="male">Male</SelectItem>
    <SelectItem value="female">Female</SelectItem>
  </SelectContent>
</Select>
```

Keyboard: Arrow Up/Down to navigate, Enter to select, Esc to close.

### Searchable Combobox (Patient / Doctor / Therapist Selection)

For large datasets (patients, therapists, doctors), use the Shadcn Combobox (Popover + Command):

```tsx
<Popover open={open} onOpenChange={setOpen}>
  <PopoverTrigger asChild>
    <Button
      variant="outline"
      role="combobox"
      aria-expanded={open}
      aria-label="Select patient"
      className="w-full justify-between"
    >
      {selectedPatient ? selectedPatient.full_name : 'Search patient...'}
      <ChevronsUpDown className="ms-2 h-4 w-4 shrink-0 opacity-50" aria-hidden="true" />
    </Button>
  </PopoverTrigger>
  <PopoverContent className="w-[400px] p-0">
    <Command>
      <CommandInput placeholder="Search by name or file number..." />
      <CommandEmpty>No patient found.</CommandEmpty>
      <CommandGroup>
        {patients.map((patient) => (
          <CommandItem key={patient.patient_id} value={patient.full_name} onSelect={() => handleSelect(patient)}>
            <Check className={cn("me-2 h-4 w-4", selected === patient.patient_id ? "opacity-100" : "opacity-0")} />
            <div>
              <p className="text-sm font-medium">{patient.full_name}</p>
              <p className="text-xs text-slate-500">{patient.file_number} · {patient.phone}</p>
            </div>
          </CommandItem>
        ))}
      </CommandGroup>
    </Command>
  </PopoverContent>
</Popover>
```

The combobox search is debounced 300ms and queries the Supabase patients table via `ilike` on `full_name`, `phone`, and `file_number`.

---

## DatePicker / TimePicker

### DatePicker

Based on Shadcn Calendar component wrapped in a Popover:

```tsx
<Popover>
  <PopoverTrigger asChild>
    <Button
      variant="outline"
      className={cn("w-full justify-start text-start", !date && "text-slate-400")}
    >
      <CalendarIcon className="me-2 h-4 w-4" aria-hidden="true" />
      {date ? format(date, 'PPP') : 'Pick a date'}
    </Button>
  </PopoverTrigger>
  <PopoverContent className="w-auto p-0" align="start">
    <Calendar
      mode="single"
      selected={date}
      onSelect={setDate}
      disabled={(d) => d < new Date() || d > addDays(new Date(), 60)}
      initialFocus
    />
  </PopoverContent>
</Popover>
```

**Disable rules per context:**
- Appointment booking: disable past dates + dates > 60 days ahead.
- Payment due date: disable past dates.
- Treatment plan start date: disable dates > 30 days in the past.
- Patient date of birth: disable future dates.

On mobile (< 768px), the native `<input type="date">` is used instead of the Popover Calendar for better OS keyboard support.

### TimePicker

A simple time input with clinic-hours constraint:

```tsx
<Input
  type="time"
  min="08:00"
  max="20:00"
  step="1800"  // 30-minute intervals
  {...register('start_time')}
/>
```

---

## Checkbox / Radio / Toggle

### Checkbox

Shadcn Checkbox with label association:

```tsx
<div className="flex items-center gap-2">
  <Checkbox id="terms" {...register('accepted_terms')} />
  <Label htmlFor="terms" className="cursor-pointer">
    I confirm the session details are accurate
  </Label>
</div>
```

### Radio Group (Standard)

```tsx
<RadioGroup defaultValue="male" className="flex gap-4">
  <div className="flex items-center gap-2">
    <RadioGroupItem value="male" id="male" />
    <Label htmlFor="male">Male</Label>
  </div>
  <div className="flex items-center gap-2">
    <RadioGroupItem value="female" id="female" />
    <Label htmlFor="female">Female</Label>
  </div>
</RadioGroup>
```

### Radio Cards (Progress Assessment — Session Log)

Used in the Session Log for progress selection. Large touch targets (60px minimum height):

```tsx
<RadioGroup value={progress} onValueChange={setProgress} className="grid grid-cols-2 gap-3">
  {progressOptions.map((option) => (
    <label
      key={option.value}
      htmlFor={`progress-${option.value}`}
      className={cn(
        "flex items-center gap-3 p-4 rounded-lg border-2 cursor-pointer min-h-[60px] transition-colors",
        progress === option.value
          ? "border-cyan-600 bg-cyan-50"
          : "border-slate-200 bg-white hover:border-slate-300"
      )}
    >
      <RadioGroupItem value={option.value} id={`progress-${option.value}`} className="sr-only" />
      <option.icon className="h-5 w-5 flex-shrink-0" aria-hidden="true" />
      <div>
        <p className="text-sm font-semibold">{option.label}</p>
        <p className="text-xs text-slate-500">{option.description}</p>
      </div>
    </label>
  ))}
</RadioGroup>
```

### Toggle (Switch)

Used for Settings toggles (business hours open/closed, notification preferences):

```tsx
<div className="flex items-center justify-between">
  <Label htmlFor="monday-open">Monday</Label>
  <Switch id="monday-open" checked={isOpen} onCheckedChange={setIsOpen} />
</div>
```

---

## Table Component

### Structure

```tsx
<div className="rounded-md border border-slate-200 overflow-hidden">
  {/* Filter Bar */}
  <div className="flex items-center gap-3 p-4 border-b border-slate-200 bg-slate-50">
    <Input type="search" placeholder="Search..." className="max-w-xs" />
    {/* Additional filters */}
  </div>

  {/* Table */}
  <div className="overflow-x-auto">
    <Table>
      <TableHeader>
        <TableRow className="bg-slate-50">
          <TableHead
            className="cursor-pointer select-none hover:bg-slate-100"
            onClick={() => handleSort('full_name')}
            aria-sort={sortField === 'full_name' ? sortDir : 'none'}
          >
            <span className="flex items-center gap-1">
              Full Name
              {sortField === 'full_name'
                ? (sortDir === 'asc'
                  ? <ChevronUp className="h-3 w-3" aria-hidden="true" />
                  : <ChevronDown className="h-3 w-3" aria-hidden="true" />)
                : <ChevronsUpDown className="h-3 w-3 text-slate-400" aria-hidden="true" />}
            </span>
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {rows.map((row) => (
          <TableRow
            key={row.id}
            className="cursor-pointer hover:bg-slate-50 transition-colors"
            onClick={() => handleRowClick(row.id)}
            tabIndex={0}
            onKeyDown={(e) => e.key === 'Enter' && handleRowClick(row.id)}
          >
            <TableCell>{row.full_name}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  </div>

  {/* Pagination */}
  <div className="flex items-center justify-between px-4 py-3 border-t border-slate-200">
    <p className="text-sm text-slate-500">Showing {start}–{end} of {total}</p>
    <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
  </div>
</div>
```

### Default Settings

- **Page size**: 25 rows per page (user-adjustable: 10 / 25 / 50).
- **Sort**: Single column sort. Default sort defined per page.
- **Row hover**: `hover:bg-slate-50` for sighted users; focus ring for keyboard users.
- **Empty state**: Full empty state component (see Empty State section below).
- **Loading state**: SkeletonLoader replaces table rows during data fetch.

---

## Badge / Status Indicator

### StatusBadge Component

The `StatusBadge` displays status using color, icon, AND text — never color alone.

```tsx
type AppointmentStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'no_show';

const appointmentStatusConfig: Record<AppointmentStatus, {
  label: string;
  icon: LucideIcon;
  className: string;
}> = {
  pending:   { label: 'Pending',   icon: Clock,       className: 'bg-slate-100 text-slate-700 border-slate-200' },
  confirmed: { label: 'Confirmed', icon: CheckCircle,  className: 'bg-blue-100 text-blue-700 border-blue-200' },
  completed: { label: 'Completed', icon: CheckCircle2, className: 'bg-green-100 text-green-700 border-green-200' },
  cancelled: { label: 'Cancelled', icon: XCircle,      className: 'bg-red-100 text-red-700 border-red-200' },
  no_show:   { label: 'No-show',   icon: UserX,        className: 'bg-orange-100 text-orange-700 border-orange-200' },
};

export function StatusBadge({ status }: { status: AppointmentStatus }) {
  const config = appointmentStatusConfig[status];
  const Icon = config.icon;
  return (
    <span className={cn(
      "inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium border",
      config.className
    )}>
      <Icon className="h-3 w-3" aria-hidden="true" />
      {config.label}
    </span>
  );
}
```

### Payment Status Badge

| Status | Icon | Color |
|---|---|---|
| `paid` | `CheckCircle2` | `bg-green-100 text-green-800` |
| `partial` | `MinusCircle` | `bg-yellow-100 text-yellow-800` |
| `pending` | `Clock` | `bg-slate-100 text-slate-700` |
| `overdue` | `AlertCircle` | `bg-red-100 text-red-800` |
| `refunded` | `RotateCcw` | `bg-purple-100 text-purple-800` |

---

## Avatar / AvatarGroup

### Single Avatar

```tsx
<Avatar className="h-10 w-10">
  <AvatarImage src={patient.profile_image} alt={`Photo of ${patient.full_name}`} />
  <AvatarFallback className="bg-cyan-100 text-cyan-800 font-medium text-sm">
    {getInitials(patient.full_name)}
  </AvatarFallback>
</Avatar>
```

### AvatarGroup (Therapist List in Calendar)

Shows up to 3 avatars overlapping with a "+N" overflow indicator:

```tsx
<div className="flex -space-x-2">
  {therapists.slice(0, 3).map((t) => (
    <Avatar key={t.user_id} className="h-8 w-8 border-2 border-white">
      <AvatarImage src={t.photo} alt={t.name} />
      <AvatarFallback className="text-xs bg-teal-100 text-teal-800">
        {getInitials(t.name)}
      </AvatarFallback>
    </Avatar>
  ))}
  {therapists.length > 3 && (
    <div className="h-8 w-8 rounded-full border-2 border-white bg-slate-200 flex items-center justify-center text-xs font-medium text-slate-600">
      +{therapists.length - 3}
    </div>
  )}
</div>
```

---

## Tooltip / Popover

### Tooltip

For brief, non-interactive information (icon button labels, truncated text):

```tsx
<TooltipProvider delayDuration={300}>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon" aria-label="Download invoice PDF">
        <Download className="h-4 w-4" aria-hidden="true" />
      </Button>
    </TooltipTrigger>
    <TooltipContent side="top">
      <p>Download PDF</p>
    </TooltipContent>
  </Tooltip>
</TooltipProvider>
```

Tooltip delay: 300ms on hover. Tooltip disappears on Esc key (WCAG 1.4.13).

### Popover

For richer interactive content (date picker, filter panels):

- Always has an accessible trigger button.
- Closes on Esc and backdrop click.
- Focus moves into the Popover content on open.
- `align="start"` for LTR, `align="end"` for RTL.

---

## Loading / Skeleton

### SkeletonLoader

Used during data fetching to prevent layout shift and communicate loading state:

```tsx
// Table skeleton — 5 rows
function TableSkeleton() {
  return (
    <div className="space-y-2 p-4" aria-busy="true" aria-label="Loading patients...">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="flex items-center gap-4">
          <Skeleton className="h-10 w-10 rounded-full" />
          <div className="flex-1 space-y-2">
            <Skeleton className="h-4 w-3/4" />
            <Skeleton className="h-3 w-1/2" />
          </div>
          <Skeleton className="h-6 w-20 rounded-full" />
        </div>
      ))}
    </div>
  );
}

// Card skeleton (KPI DataCard)
function CardSkeleton() {
  return (
    <div className="p-6 rounded-xl border border-slate-200 space-y-3">
      <Skeleton className="h-4 w-1/2" />
      <Skeleton className="h-8 w-3/4" />
      <Skeleton className="h-3 w-1/3" />
    </div>
  );
}
```

The Shadcn `Skeleton` component renders a `div` with `bg-slate-200` and a shimmer animation via `animate-pulse`.

### PainSlider (Custom Component)

```tsx
interface PainSliderProps {
  value: number;
  onChange: (value: number) => void;
  disabled?: boolean;
  label?: string;
}

// Gradient: green at 0, yellow at 5, red at 10
const painGradient = 'linear-gradient(to right, #22c55e 0%, #eab308 50%, #ef4444 100%)';

export function PainSlider({ value, onChange, disabled, label }: PainSliderProps) {
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <Label>{label ?? 'Pain Level'}</Label>
        <span
          className={cn(
            "text-4xl font-bold tabular-nums",
            value <= 3 ? "text-green-600" : value <= 6 ? "text-yellow-600" : "text-red-600"
          )}
          aria-live="polite"
          aria-label={`Pain level: ${value} out of 10`}
        >
          {value}
        </span>
      </div>
      <input
        type="range"
        min={0}
        max={10}
        step={1}
        value={value}
        disabled={disabled}
        onChange={(e) => onChange(Number(e.target.value))}
        style={{ background: painGradient }}
        className="w-full h-3 rounded-full appearance-none cursor-pointer
                   [&::-webkit-slider-thumb]:h-6 [&::-webkit-slider-thumb]:w-6
                   [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-white
                   [&::-webkit-slider-thumb]:border-2 [&::-webkit-slider-thumb]:shadow-md"
        aria-label={`${label ?? 'Pain level'} slider (0 = no pain, 10 = worst pain)`}
        aria-valuemin={0}
        aria-valuemax={10}
        aria-valuenow={value}
        aria-valuetext={`${value} out of 10`}
      />
      <div className="flex justify-between text-xs text-slate-500">
        {Array.from({ length: 11 }, (_, i) => (
          <span key={i} className="w-4 text-center">{i}</span>
        ))}
      </div>
      <div className="flex justify-between text-xs">
        <span className="text-green-600 font-medium">No pain</span>
        <span className="text-red-600 font-medium">Worst pain</span>
      </div>
    </div>
  );
}
```

### SignatureCanvas (Custom Component)

```tsx
import SignaturePad from 'react-signature-canvas';

interface SignatureCanvasProps {
  onSave: (base64: string) => void;
  disabled?: boolean;
}

export function SignatureCanvas({ onSave, disabled }: SignatureCanvasProps) {
  const padRef = useRef<SignaturePad>(null);

  const handleClear = () => {
    padRef.current?.clear();
    onSave('');
  };

  const handleEnd = () => {
    if (!padRef.current?.isEmpty()) {
      onSave(padRef.current.toDataURL('image/png'));
    }
  };

  return (
    <div className="space-y-2">
      <div
        className={cn(
          "rounded-lg border-2 border-dashed relative",
          disabled ? "border-slate-200 bg-slate-50" : "border-slate-300 bg-white"
        )}
        role="application"
        aria-label="Digital signature canvas. Draw your signature using mouse or touch."
      >
        {!disabled && (
          <p className="absolute top-2 start-0 w-full text-center text-xs text-slate-400 pointer-events-none">
            Draw your signature here
          </p>
        )}
        <SignaturePad
          ref={padRef}
          canvasProps={{ className: 'w-full h-40 rounded-lg', style: { touchAction: 'none' } }}
          onEnd={handleEnd}
        />
      </div>
      {!disabled && (
        <Button type="button" variant="ghost" size="sm" onClick={handleClear}>
          <RotateCcw className="h-3 w-3 me-1" aria-hidden="true" />
          Clear Signature
        </Button>
      )}
    </div>
  );
}
```

### DataCard (KPI Card)

```tsx
interface DataCardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  trend?: { value: number; direction: 'up' | 'down'; label: string };
  valueClassName?: string;
}

export function DataCard({ label, value, icon: Icon, trend, valueClassName }: DataCardProps) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm">
      <div className="flex items-center justify-between mb-3">
        <p className="text-sm font-medium text-slate-600">{label}</p>
        <div className="h-9 w-9 rounded-lg bg-cyan-50 flex items-center justify-center">
          <Icon className="h-5 w-5 text-cyan-600" aria-hidden="true" />
        </div>
      </div>
      <p className={cn("text-3xl font-bold text-teal-900 tabular-nums", valueClassName)}>
        {value}
      </p>
      {trend && (
        <div className={cn("flex items-center gap-1 mt-1 text-xs font-medium",
          trend.direction === 'up' ? "text-green-600" : "text-red-600"
        )}>
          {trend.direction === 'up'
            ? <TrendingUp className="h-3 w-3" aria-hidden="true" />
            : <TrendingDown className="h-3 w-3" aria-hidden="true" />}
          <span>{trend.value}% {trend.label}</span>
        </div>
      )}
    </div>
  );
}
```

### PageHeader Component

```tsx
interface PageHeaderProps {
  title: string;
  breadcrumbs?: { label: string; href?: string }[];
  actions?: React.ReactNode;
}

export function PageHeader({ title, breadcrumbs, actions }: PageHeaderProps) {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-6">
      <div>
        {breadcrumbs && (
          <nav aria-label="Breadcrumb" className="mb-1">
            <ol className="flex items-center gap-1 text-xs text-slate-500">
              {breadcrumbs.map((crumb, i) => (
                <li key={i} className="flex items-center gap-1">
                  {i > 0 && <ChevronRight className="h-3 w-3" aria-hidden="true" />}
                  {crumb.href
                    ? <a href={crumb.href} className="hover:text-cyan-600 transition-colors">{crumb.label}</a>
                    : <span>{crumb.label}</span>}
                </li>
              ))}
            </ol>
          </nav>
        )}
        <h1 className="text-2xl font-bold text-teal-900">{title}</h1>
      </div>
      {actions && <div className="flex items-center gap-2 flex-shrink-0">{actions}</div>}
    </div>
  );
}
```

---

## Empty State

Shown when a list or table has no records to display.

```tsx
interface EmptyStateProps {
  icon?: LucideIcon;
  title: string;
  description?: string;
  action?: { label: string; onClick: () => void };
}

export function EmptyState({ icon: Icon = Inbox, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
      <div className="h-14 w-14 rounded-full bg-slate-100 flex items-center justify-center mb-4">
        <Icon className="h-7 w-7 text-slate-400" aria-hidden="true" />
      </div>
      <h3 className="text-base font-semibold text-slate-700 mb-1">{title}</h3>
      {description && (
        <p className="text-sm text-slate-500 max-w-xs mb-4">{description}</p>
      )}
      {action && (
        <Button variant="primary" onClick={action.onClick}>
          {action.label}
        </Button>
      )}
    </div>
  );
}
```

### Standard Empty State Messages

| Page | Title | Description |
|---|---|---|
| Patient list | "No patients found" | "Add your first patient or adjust your search filters." |
| Appointments calendar | "No appointments today" | "No appointments have been booked for this date." |
| Session history | "No sessions logged yet" | "Sessions will appear here after the therapist logs them." |
| Invoices | "No invoices yet" | "Invoices are generated automatically when a payment is created." |
| Campaigns | "No campaigns yet" | "Create your first WhatsApp campaign to reach your patients." |

---

## Error Boundary

A React error boundary wraps major page sections to catch rendering errors without crashing the entire app.

```tsx
export class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback?: React.ReactNode },
  { hasError: boolean; error?: Error }
> {
  state = { hasError: false };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div className="flex flex-col items-center justify-center py-16 text-center px-4">
          <AlertCircle className="h-10 w-10 text-red-400 mb-3" aria-hidden="true" />
          <h3 className="text-base font-semibold text-slate-700 mb-1">Something went wrong</h3>
          <p className="text-sm text-slate-500 mb-4">
            This section encountered an error. Please refresh the page.
          </p>
          <Button variant="outline" onClick={() => window.location.reload()}>
            <RefreshCw className="h-4 w-4 me-2" aria-hidden="true" />
            Refresh Page
          </Button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

Error boundaries are placed at:
1. The root layout (catches critical failures)
2. Each major page component (isolates failures to one page)
3. The dashboard chart section (charts fail gracefully, KPI cards still load)
4. The activity feed (realtime failures do not affect the rest of the dashboard)

---

*DOC-06-006 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*

# Validation Rules

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-005 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | Comprehensive catalog of all client-side and server-side validation rules. |
| **Owner** | Frontend Engineer / QA Engineer |
| **Dependencies** | functional-requirements-specification.md |
| **Priority** | P1 |
| **Estimated Pages** | 16–24 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / QA Engineer | Initial stub |
| 1.0 | 2026-05-24 | Frontend Engineer / QA Engineer | Full content added |

---

## Table of Contents

- [Validation Rule Catalog](#validation-rule-catalog)
- [Cross-field Validation Rules](#cross-field-validation-rules)
- [Async Validation (Uniqueness, Conflicts)](#async-validation-uniqueness-conflicts)
- [Error Message Standards](#error-message-standards)
- [Validation Trigger Events](#validation-trigger-events)
- [Zod Schema Reference](#zod-schema-reference)

---

## Validation Rule Catalog

### Patient Registration Form

| Field | Type | Required | Rules | Error Message (EN) | Error Message (AR) |
|---|---|---|---|---|---|
| `full_name` | text | Yes | 2–100 characters; letters, spaces, hyphens only (Arabic and Latin both accepted) | "Full name must be between 2 and 100 characters" | "يجب أن يكون الاسم الكامل بين 2 و 100 حرف" |
| `phone` | tel | Yes | Matches `^01[0125][0-9]{8}$` (Egyptian mobile); must be unique | "Enter a valid Egyptian mobile number (e.g. 01012345678)" | "أدخل رقم هاتف مصري صحي (مثال: 01012345678)" |
| `date_of_birth` | date | No | Valid date; must not be in the future; year ≥ 1900 | "Date of birth cannot be in the future" | "تاريخ الميلاد لا يمكن أن يكون في المستقبل" |
| `age` | number | Yes | Integer 1–120; auto-calculated from DOB if provided | "Age must be between 1 and 120" | "العمر يجب أن يكون بين 1 و 120" |
| `gender` | select | Yes | Must select one of: male, female | "Please select a gender" | "يرجى اختيار الجنس" |
| `address` | text | No | Max 250 characters | "Address must not exceed 250 characters" | "العنوان يجب ألا يتجاوز 250 حرف" |
| `job` | text | No | Max 100 characters | "Job title must not exceed 100 characters" | "المسمى الوظيفي يجب ألا يتجاوز 100 حرف" |
| `how_heard_about_us` | select | No | Must be one of predefined options or empty | — | — |
| `chief_complaint` | textarea | Yes | 10–500 characters | "Chief complaint must be at least 10 characters" | "الشكوى الرئيسية يجب أن تكون 10 أحرف على الأقل" |
| `previous_surgeries` | textarea | No | Max 1000 characters | "Must not exceed 1000 characters" | "يجب ألا يتجاوز 1000 حرف" |
| `chronic_diseases` | textarea | No | Max 1000 characters | "Must not exceed 1000 characters" | "يجب ألا يتجاوز 1000 حرف" |
| `profile_image` | file | No | JPG, PNG, WEBP only; max 5 MB | "Image must be JPG, PNG, or WEBP and under 5 MB" | "يجب أن تكون الصورة بصيغة JPG أو PNG أو WEBP ولا تتجاوز 5 ميجابايت" |
| `card_image` | file | No | JPG, PNG, PDF only; max 5 MB | "ID card must be JPG, PNG, or PDF and under 5 MB" | "بطاقة الهوية يجب أن تكون JPG أو PNG أو PDF ولا تتجاوز 5 ميجابايت" |

### Appointment Booking Form

| Field | Type | Required | Rules | Error Message (EN) | Error Message (AR) |
|---|---|---|---|---|---|
| `patient_id` | combobox | Yes | Must select a patient from the list | "Please select a patient" | "يرجى اختيار مريض" |
| `doctor_id` | select | Yes | Must select an active doctor | "Please select a doctor" | "يرجى اختيار طبيب" |
| `therapist_id` | select | Yes | Must select an active therapist | "Please select a therapist" | "يرجى اختيار معالج" |
| `date` | date | Yes | Must not be in the past; must not be more than 60 days from today | "Appointment date must be between today and 60 days ahead" | "تاريخ الموعد يجب أن يكون بين اليوم و 60 يوماً مقبلاً" |
| `start_time` | time | Yes | Must be within clinic hours 08:00–19:30 | "Start time must be between 08:00 and 19:30" | "وقت البدء يجب أن يكون بين 08:00 و 19:30" |
| `end_time` | time | Yes | Must be after `start_time`; must not exceed 20:00; therapist must be free in this slot | "End time must be after start time and within clinic hours" | "وقت الانتهاء يجب أن يكون بعد وقت البدء وضمن ساعات العمل" |
| `notes` | textarea | No | Max 500 characters | "Notes must not exceed 500 characters" | "الملاحظات يجب ألا تتجاوز 500 حرف" |

### Session Log Form

| Field | Type | Required | Rules | Error Message (EN) | Error Message (AR) |
|---|---|---|---|---|---|
| `pain_level_before` | slider | Yes | Integer 0–10 | "Pain level before session is required" | "مستوى الألم قبل الجلسة مطلوب" |
| `pain_level_after` | slider | No | Integer 0–10 if provided | "Pain level after must be between 0 and 10" | "مستوى الألم بعد يجب أن يكون بين 0 و 10" |
| `progress` | radio | Yes | Must select one of: improved, same, declined, completed | "Please select a progress status" | "يرجى اختيار حالة التقدم" |
| `methods_applied` | multi-select | No | Must be valid method IDs from the plan's method list | "Please select at least one method from the plan" | "يرجى اختيار طريقة علاج واحدة على الأقل من الخطة" |
| `notes` | textarea | No | Max 2000 characters | "Notes must not exceed 2000 characters" | "الملاحظات يجب ألا تتجاوز 2000 حرف" |
| `signature` | canvas | Yes | Canvas must not be empty (checked via `isEmpty()` method of react-signature-canvas) | "Please draw your signature to confirm the session" | "يرجى رسم توقيعك لتأكيد الجلسة" |

### Payment Form

| Field | Type | Required | Rules | Error Message (EN) | Error Message (AR) |
|---|---|---|---|---|---|
| `patient_id` | combobox | Yes | Must select a patient | "Please select a patient" | "يرجى اختيار مريض" |
| `package_id` | select | No | If provided, must be an active package ID | "Selected package is no longer active" | "الباقة المختارة لم تعد نشطة" |
| `total_price` | number | Yes | Must be > 0; max 9,999,999 | "Total price must be greater than zero" | "السعر الإجمالي يجب أن يكون أكبر من صفر" |
| `paid_amount` | number | Yes | Must be ≥ 0 and ≤ `total_price` | "Paid amount cannot exceed the total price" | "المبلغ المدفوع لا يمكن أن يتجاوز السعر الإجمالي" |
| `payment_method` | select | Yes | Must select one of: cash, visa, instapay, vodafone_cash, bank_transfer | "Please select a payment method" | "يرجى اختيار طريقة الدفع" |
| `due_date` | date | No | If provided, must not be in the past | "Due date cannot be in the past" | "تاريخ الاستحقاق لا يمكن أن يكون في الماضي" |
| `notes` | textarea | No | Max 500 characters | "Notes must not exceed 500 characters" | "الملاحظات يجب ألا تتجاوز 500 حرف" |

### User Creation Form (Admin Only)

| Field | Type | Required | Rules | Error Message (EN) | Error Message (AR) |
|---|---|---|---|---|---|
| `name` | text | Yes | 2–100 characters; letters and spaces | "Name must be between 2 and 100 characters" | "الاسم يجب أن يكون بين 2 و 100 حرف" |
| `email` | email | Yes | Valid email format; must be unique in the system | "Enter a valid email address" | "أدخل بريدًا إلكترونيًا صحيحًا" |
| `role` | select | Yes | Must select one of: admin, receptionist, doctor, therapist | "Please select a role" | "يرجى اختيار الدور" |
| `phone` | tel | No | If provided, must match `^01[0125][0-9]{8}$` | "Enter a valid Egyptian mobile number" | "أدخل رقم هاتف مصري صحي" |

### Treatment Plan Form (Doctor/Admin Only)

| Field | Type | Required | Rules | Error Message (EN) | Error Message (AR) |
|---|---|---|---|---|---|
| `patient_id` | combobox | Yes | Must select a patient with no active plan (or Doctor acknowledges override) | "Please select a patient" | "يرجى اختيار مريض" |
| `diagnosis` | textarea | Yes | 5–1000 characters | "Diagnosis must be at least 5 characters" | "التشخيص يجب أن يكون 5 أحرف على الأقل" |
| `goals` | textarea | Yes | 5–1000 characters | "Goals must be at least 5 characters" | "الأهداف يجب أن تكون 5 أحرف على الأقل" |
| `therapist_id` | select | Yes | Must select an active therapist | "Please assign a therapist" | "يرجى تعيين معالج" |
| `sessions_prescribed` | number | Yes | Integer ≥ 1, ≤ 200 | "Sessions prescribed must be at least 1" | "الجلسات الموصوفة يجب أن تكون 1 على الأقل" |
| `start_date` | date | Yes | Must not be more than 30 days in the past | "Start date cannot be more than 30 days in the past" | "تاريخ البدء لا يمكن أن يكون قبل 30 يوماً" |
| `expected_end_date` | date | No | If provided, must be after `start_date` | "Expected end date must be after start date" | "تاريخ الانتهاء المتوقع يجب أن يكون بعد تاريخ البدء" |
| `methods` | multi-select | Yes | At least 1 method must be selected | "At least one treatment method is required" | "طريقة علاج واحدة على الأقل مطلوبة" |

---

## Cross-field Validation Rules

These rules validate relationships between multiple fields and run on form submission (not on individual field blur).

### Appointment Booking

| Rule ID | Rule | Trigger | Error |
|---|---|---|---|
| APT-CV-01 | `end_time` must be strictly after `start_time` | On submit | "End time must be after start time" |
| APT-CV-02 | `date` + `start_time` must be at least 5 minutes from now (prevents booking in the immediate past) | On submit | "Cannot book an appointment that has already passed" |
| APT-CV-03 | `date` + `start_time` + `end_time` must not overlap with any existing appointment for the selected `therapist_id` (async check) | On submit | "This therapist already has an appointment at this time" |
| APT-CV-04 | `date` + `start_time` + `end_time` must not overlap with any existing appointment for the selected `doctor_id` (async check) | On submit | "This doctor already has an appointment at this time" |

### Payment Form

| Rule ID | Rule | Trigger | Error |
|---|---|---|---|
| PAY-CV-01 | `paid_amount` ≤ `total_price` | On change of either field | "Paid amount cannot exceed total price" |
| PAY-CV-02 | If `package_id` is selected, `total_price` is pre-filled from the package but can be overridden. If overridden to 0, warn. | On `package_id` change | "Total price has been set to 0. Is this a free session?" (warning, not error) |
| PAY-CV-03 | `due_date` must be today or in the future | On submit | "Due date cannot be in the past" |

### Treatment Plan

| Rule ID | Rule | Trigger | Error |
|---|---|---|---|
| TP-CV-01 | `expected_end_date` must be after `start_date` | On submit | "Expected end date must be after start date" |
| TP-CV-02 | Patient must not already have an `active` treatment plan (async check) | On submit | "This patient already has an active treatment plan. Complete or pause it first." |

---

## Async Validation (Uniqueness, Conflicts)

Some validation requires a round-trip to the server. These checks are implemented using React Hook Form's `validate` option with debouncing.

### Phone Number Uniqueness Check

**Field**: `patient.phone`  
**Trigger**: `onBlur` after the field loses focus  
**Debounce**: 500ms  
**API**: `GET /api/patients/check-phone?phone={phone}&excludeId={patientId}`  
**Response**: `{ unique: boolean, existingPatient?: { name: string, file_number: string } }`  
**UI Behavior**:  
- While checking: small spinner appears at right edge of input; field shows `aria-busy="true"`.
- If not unique: red border + error message: "This phone number is already registered to [Name] ([File#])."
- If unique: green check icon appears briefly, then disappears.

```tsx
// React Hook Form async validation
const { register } = useForm();

register('phone', {
  validate: async (value) => {
    if (!value || value.length < 11) return true; // Let sync validation handle it
    const res = await checkPhoneUniqueness(value, existingPatientId);
    if (!res.unique) {
      return `Phone already registered to ${res.existingPatient?.name} (${res.existingPatient?.file_number})`;
    }
    return true;
  }
});
```

### Appointment Conflict Check

**Fields**: `therapist_id`, `doctor_id`, `date`, `start_time`, `end_time`  
**Trigger**: On submit attempt only (not on blur — too expensive)  
**API**: `POST /api/appointments/check-conflict`  
**Body**: `{ therapist_id, doctor_id, date, start_time, end_time, excludeId? }`  
**Response**: `{ conflict: boolean, conflictingAppointment?: { time: string, patient: string } }`  
**UI Behavior**: If conflict found, submit is blocked and error banner appears above the form.

### Email Uniqueness (User Creation)

**Field**: `user.email`  
**Trigger**: `onBlur`  
**Debounce**: 500ms  
**API**: `GET /api/users/check-email?email={email}`  
**Response**: `{ unique: boolean }`  
**UI Behavior**: Red border + "This email is already registered in the system."

### Active Treatment Plan Check

**Field**: `patient_id` in treatment plan form  
**Trigger**: When `patient_id` changes  
**API**: `GET /api/patients/{id}/active-plan`  
**Response**: `{ hasActivePlan: boolean, plan?: { plan_id: string, diagnosis: string } }`  
**UI Behavior**: Warning banner below the patient select: "This patient already has an active treatment plan: [Diagnosis]. Complete or pause it before creating a new one." The form can still be submitted with an explicit checkbox: "I acknowledge this and will transition the existing plan."

---

## Error Message Standards

### Display Format

All inline validation errors follow this structure:

```tsx
// Error message component
<p
  id={`${fieldId}-error`}
  role="alert"
  className="mt-1 text-xs text-red-600 flex items-center gap-1"
>
  <AlertCircle className="h-3 w-3 flex-shrink-0" aria-hidden="true" />
  <span>{errorMessage}</span>
</p>
```

The input field itself when invalid:

```tsx
<Input
  id={fieldId}
  aria-invalid={!!error}
  aria-describedby={error ? `${fieldId}-error` : `${fieldId}-hint`}
  className={cn(
    "border-slate-300 focus:ring-cyan-600",
    error && "border-red-400 focus:ring-red-400"
  )}
/>
```

### Error Tone Guidelines

- **Be specific**: Say what is wrong, not just "Invalid input."
- **Be instructive**: Tell the user how to fix it.
- **Be non-blaming**: Use passive constructions ("Phone number already exists" not "You entered a duplicate phone").
- **Match language**: Error appears in Arabic if `dir="rtl"` is active, English otherwise. Both are defined in the Zod schema messages.

### Form-Level Error Summary

When a form submission fails (either validation or API error), a summary banner appears at the top of the form:

```tsx
<div role="alert" aria-live="assertive" className="rounded-md bg-red-50 border border-red-200 p-3">
  <div className="flex items-start gap-2">
    <XCircle className="h-4 w-4 text-red-600 mt-0.5" aria-hidden="true" />
    <div>
      <p className="text-sm font-medium text-red-800">Please fix the following errors:</p>
      <ul className="mt-1 text-sm text-red-700 list-disc list-inside">
        {errorList.map((err) => <li key={err.field}>{err.message}</li>)}
      </ul>
    </div>
  </div>
</div>
```

---

## Validation Trigger Events

| Event | Validation Type | Fields Affected | Notes |
|---|---|---|---|
| `onChange` | Sync format check | Phone (after 11 chars), email (after `@`), number fields | Only fire after field has been touched (dirty) |
| `onBlur` | Sync + async (uniqueness) | All fields with uniqueness checks | Debounced 500ms for async calls |
| `onSubmit` | Full sync + async | All fields | Blocks submission if any error; scrolls to first error |
| `onMount` | Pre-populate | Date of birth → Age | Auto-calculates age when editing a patient with existing DOB |

### Progressive Validation (After First Submit)

Before the user attempts submission, only `onBlur` errors are shown (non-intrusive). After the first submission attempt:
- Switch to `mode: 'onChange'` to give real-time feedback.
- This prevents the jarring experience of errors showing up as the user types for the first time.

React Hook Form configuration:

```tsx
const form = useForm<PatientFormValues>({
  resolver: zodResolver(patientSchema),
  mode: 'onTouched',       // Show errors after field is touched
  reValidateMode: 'onChange', // Real-time after first submit
});
```

---

## Zod Schema Reference

Full Zod schemas used for both client-side validation (React Hook Form) and server-side validation (API route / Edge Function).

### Patient Schema

```typescript
import { z } from 'zod';

export const patientSchema = z.object({
  full_name: z
    .string()
    .min(2, { message: 'Full name must be at least 2 characters' })
    .max(100, { message: 'Full name must not exceed 100 characters' })
    .regex(/^[\p{L}\s'-]+$/u, { message: 'Full name may only contain letters, spaces, hyphens, and apostrophes' }),

  phone: z
    .string()
    .regex(/^01[0125][0-9]{8}$/, { message: 'Enter a valid Egyptian mobile number (e.g. 01012345678)' }),

  age: z
    .number({ invalid_type_error: 'Age must be a number' })
    .int()
    .min(1, { message: 'Age must be at least 1' })
    .max(120, { message: 'Age must not exceed 120' }),

  date_of_birth: z
    .string()
    .optional()
    .refine((val) => !val || new Date(val) <= new Date(), {
      message: 'Date of birth cannot be in the future',
    }),

  gender: z.enum(['male', 'female'], { required_error: 'Please select a gender' }),

  address: z.string().max(250).optional(),

  job: z.string().max(100).optional(),

  how_heard_about_us: z
    .enum(['social_media', 'referral', 'walk_in', 'google', 'other'])
    .optional(),

  chief_complaint: z
    .string()
    .min(10, { message: 'Chief complaint must be at least 10 characters' })
    .max(500, { message: 'Chief complaint must not exceed 500 characters' }),

  previous_surgeries: z.string().max(1000).optional(),
  chronic_diseases: z.string().max(1000).optional(),
});

export type PatientFormValues = z.infer<typeof patientSchema>;
```

### Appointment Schema

```typescript
export const appointmentSchema = z.object({
  patient_id: z.string().uuid({ message: 'Please select a patient' }),
  doctor_id: z.string().uuid({ message: 'Please select a doctor' }),
  therapist_id: z.string().uuid({ message: 'Please select a therapist' }),
  date: z
    .string()
    .refine((val) => new Date(val) >= new Date(new Date().toDateString()), {
      message: 'Date cannot be in the past',
    })
    .refine((val) => {
      const maxDate = new Date();
      maxDate.setDate(maxDate.getDate() + 60);
      return new Date(val) <= maxDate;
    }, { message: 'Cannot book more than 60 days ahead' }),
  start_time: z
    .string()
    .regex(/^([01][0-9]|2[0-3]):[0-5][0-9]$/)
    .refine((val) => val >= '08:00' && val <= '19:30', {
      message: 'Start time must be between 08:00 and 19:30',
    }),
  end_time: z
    .string()
    .regex(/^([01][0-9]|2[0-3]):[0-5][0-9]$/),
  notes: z.string().max(500).optional(),
}).refine((data) => data.end_time > data.start_time, {
  path: ['end_time'],
  message: 'End time must be after start time',
}).refine((data) => data.end_time <= '20:00', {
  path: ['end_time'],
  message: 'Appointments must end by 20:00',
});
```

### Session Log Schema

```typescript
export const sessionLogSchema = z.object({
  pain_level_before: z
    .number({ required_error: 'Pain level before session is required' })
    .int()
    .min(0)
    .max(10),
  pain_level_after: z.number().int().min(0).max(10).optional(),
  progress: z.enum(['improved', 'same', 'declined', 'completed'], {
    required_error: 'Please select a progress status',
  }),
  methods_applied: z.array(z.string().uuid()).optional(),
  notes: z.string().max(2000).optional(),
  signature: z
    .string()
    .min(1, { message: 'Please draw your signature to confirm the session' }),
});
```

### Payment Schema

```typescript
export const paymentSchema = z.object({
  patient_id: z.string().uuid({ message: 'Please select a patient' }),
  package_id: z.string().uuid().optional(),
  total_price: z
    .number({ invalid_type_error: 'Total price must be a number' })
    .positive({ message: 'Total price must be greater than zero' }),
  paid_amount: z
    .number({ invalid_type_error: 'Paid amount must be a number' })
    .min(0, { message: 'Paid amount cannot be negative' }),
  payment_method: z.enum(['cash', 'visa', 'instapay', 'vodafone_cash', 'bank_transfer'], {
    required_error: 'Please select a payment method',
  }),
  due_date: z
    .string()
    .optional()
    .refine((val) => !val || new Date(val) >= new Date(new Date().toDateString()), {
      message: 'Due date cannot be in the past',
    }),
  notes: z.string().max(500).optional(),
}).refine((data) => data.paid_amount <= data.total_price, {
  path: ['paid_amount'],
  message: 'Paid amount cannot exceed total price',
});
```

### User Creation Schema

```typescript
export const userCreationSchema = z.object({
  name: z
    .string()
    .min(2, { message: 'Name must be at least 2 characters' })
    .max(100, { message: 'Name must not exceed 100 characters' }),
  email: z
    .string()
    .email({ message: 'Enter a valid email address' }),
  role: z.enum(['admin', 'receptionist', 'doctor', 'therapist'], {
    required_error: 'Please select a role',
  }),
  phone: z
    .string()
    .regex(/^01[0125][0-9]{8}$/, { message: 'Enter a valid Egyptian mobile number' })
    .optional()
    .or(z.literal('')),
});
```

---

*DOC-06-005 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*

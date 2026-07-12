-- ============================================================
-- Kinetic — Main admin account: "amir"
--
-- Run this ONCE in the Supabase SQL editor, AFTER running
-- supabase-schema.sql.
--
--   Email:    amir@kinetic.eg
--   Password: Amir@2026!     ←  CHANGE THIS after first login
--                                (Supabase Dashboard → Authentication →
--                                 Users → amir@kinetic.eg → Reset password)
--
-- What it does:
--   1. Creates the Supabase Auth user with role "admin" in
--      user_metadata (this is what the app's RLS policies and the
--      login screen read).
--   2. Creates the matching row in the `staff` table, linked via
--      auth_uid, so the app can resolve the display name and role.
--
-- Safe to re-run: it skips the auth user if the email already exists
-- and upserts the staff row.
-- ============================================================

create extension if not exists pgcrypto;

do $$
declare
  uid uuid;
begin
  select id into uid from auth.users where email = 'amir@kinetic.eg';

  if uid is null then
    uid := gen_random_uuid();

    -- NOTE: the *_token / *_change columns must be '' (not NULL) — GoTrue
    -- returns 500 "Database error" on login when they are NULL, which is
    -- the classic pitfall of SQL-created auth users.
    insert into auth.users (
      instance_id, id, aud, role, email,
      encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at,
      confirmation_token, recovery_token,
      email_change, email_change_token_new, email_change_token_current,
      phone_change, phone_change_token, reauthentication_token,
      is_sso_user
    ) values (
      '00000000-0000-0000-0000-000000000000',
      uid,
      'authenticated',
      'authenticated',
      'amr@clinic.eg',
      crypt('Amr@2026!', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"role":"admin","name":"أمير"}'::jsonb,
      now(), now()
    );react-dom.development.js:29905 Download the React DevTools for a better development experience: https://reactjs.org/link/react-devtools
transformScriptTags.ts:271 You are using the in-browser Babel transformer. Be sure to precompile your scripts for production - https://babeljs.io/docs/setup/
(anonymous) @ transformScriptTags.ts:271
supabase-js@2:13  POST https://yjtyvtyqyiqnqdctxpyz.supabase.co/rest/v1/clinic_settings 400 (Bad Request)
(anonymous) @ supabase-js@2:13
(anonymous) @ supabase-js@2:13
await in (anonymous)
(anonymous) @ supabase-js@2:7
then @ supabase-js@2:7
supabase-js@2:14  POST https://yjtyvtyqyiqnqdctxpyz.supabase.co/auth/v1/signup 400 (Bad Request)
(anonymous) @ supabase-js@2:14
Lr @ supabase-js@2:14
Y @ supabase-js@2:14
signUp @ supabase-js@2:16
(anonymous) @ supabase.jsx:336
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
_adminCreateUser @ supabase.jsx:351
adminCreateUser @ supabase.jsx:313
(anonymous) @ screens2.jsx:3133
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
_submit @ screens2.jsx:3139
submit @ screens2.jsx:3131
callCallback @ react-dom.development.js:4151
invokeGuardedCallbackDev @ react-dom.development.js:4200
invokeGuardedCallback @ react-dom.development.js:4264
invokeGuardedCallbackAndCatchFirstError @ react-dom.development.js:4278
executeDispatch @ react-dom.development.js:9051
processDispatchQueueItemsInOrder @ react-dom.development.js:9083
processDispatchQueue @ react-dom.development.js:9096
dispatchEventsForPlugins @ react-dom.development.js:9107
(anonymous) @ react-dom.development.js:9298
batchedUpdates$1 @ react-dom.development.js:26189
batchedUpdates @ react-dom.development.js:3978
dispatchEventForPluginEventSystem @ react-dom.development.js:9297
dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ react-dom.development.js:6475
dispatchEvent @ react-dom.development.js:6467
dispatchDiscreteEvent @ react-dom.development.js:6440
supabase-js@2:16 GoTrueClient@kinetic-provision:1 (2.110.2) 2026-07-12T00:21:35.887Z Multiple GoTrueClient instances detected in the same browser context. It is not an error, but this should be avoided as it may produce undefined behavior when used concurrently under the same storage key.
e @ supabase-js@2:16
Di @ supabase-js@2:17
_initSupabaseAuthClient @ supabase-js@2:17
Oi @ supabase-js@2:17
ki @ supabase-js@2:17
(anonymous) @ supabase.jsx:333
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
adminCreateUser @ supabase.jsx:313
(anonymous) @ screens2.jsx:3133
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
_submit @ screens2.jsx:3139
submit @ screens2.jsx:3131
callCallback @ react-dom.development.js:4151
invokeGuardedCallbackDev @ react-dom.development.js:4200
invokeGuardedCallback @ react-dom.development.js:4264
invokeGuardedCallbackAndCatchFirstError @ react-dom.development.js:4278
executeDispatch @ react-dom.development.js:9051
processDispatchQueueItemsInOrder @ react-dom.development.js:9083
processDispatchQueue @ react-dom.development.js:9096
dispatchEventsForPlugins @ react-dom.development.js:9107
(anonymous) @ react-dom.development.js:9298
batchedUpdates$1 @ react-dom.development.js:26189
batchedUpdates @ react-dom.development.js:3978
dispatchEventForPluginEventSystem @ react-dom.development.js:9297
dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ react-dom.development.js:6475
dispatchEvent @ react-dom.development.js:6467
dispatchDiscreteEvent @ react-dom.development.js:6440
supabase-js@2:14  POST https://yjtyvtyqyiqnqdctxpyz.supabase.co/auth/v1/signup 400 (Bad Request)
(anonymous) @ supabase-js@2:14
Lr @ supabase-js@2:14
Y @ supabase-js@2:14
signUp @ supabase-js@2:16
(anonymous) @ supabase.jsx:336
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
adminCreateUser @ supabase.jsx:313
(anonymous) @ screens2.jsx:3133
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
_submit @ screens2.jsx:3139
submit @ screens2.jsx:3131
callCallback @ react-dom.development.js:4151
invokeGuardedCallbackDev @ react-dom.development.js:4200
invokeGuardedCallback @ react-dom.development.js:4264
invokeGuardedCallbackAndCatchFirstError @ react-dom.development.js:4278
executeDispatch @ react-dom.development.js:9051
processDispatchQueueItemsInOrder @ react-dom.development.js:9083
processDispatchQueue @ react-dom.development.js:9096
dispatchEventsForPlugins @ react-dom.development.js:9107
(anonymous) @ react-dom.development.js:9298
batchedUpdates$1 @ react-dom.development.js:26189
batchedUpdates @ react-dom.development.js:3978
dispatchEventForPluginEventSystem @ react-dom.development.js:9297
dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ react-dom.development.js:6475
dispatchEvent @ react-dom.development.js:6467
dispatchDiscreteEvent @ react-dom.development.js:6440
supabase-js@2:16 GoTrueClient@kinetic-provision:2 (2.110.2) 2026-07-12T00:21:54.541Z Multiple GoTrueClient instances detected in the same browser context. It is not an error, but this should be avoided as it may produce undefined behavior when used concurrently under the same storage key.
e @ supabase-js@2:16
Di @ supabase-js@2:17
_initSupabaseAuthClient @ supabase-js@2:17
Oi @ supabase-js@2:17
ki @ supabase-js@2:17
(anonymous) @ supabase.jsx:333
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
adminCreateUser @ supabase.jsx:313
(anonymous) @ screens2.jsx:3133
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
_submit @ screens2.jsx:3139
submit @ screens2.jsx:3131
callCallback @ react-dom.development.js:4151
invokeGuardedCallbackDev @ react-dom.development.js:4200
invokeGuardedCallback @ react-dom.development.js:4264
invokeGuardedCallbackAndCatchFirstError @ react-dom.development.js:4278
executeDispatch @ react-dom.development.js:9051
processDispatchQueueItemsInOrder @ react-dom.development.js:9083
processDispatchQueue @ react-dom.development.js:9096
dispatchEventsForPlugins @ react-dom.development.js:9107
(anonymous) @ react-dom.development.js:9298
batchedUpdates$1 @ react-dom.development.js:26189
batchedUpdates @ react-dom.development.js:3978
dispatchEventForPluginEventSystem @ react-dom.development.js:9297
dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ react-dom.development.js:6475
dispatchEvent @ react-dom.development.js:6467
dispatchDiscreteEvent @ react-dom.development.js:6440
supabase-js@2:14  POST https://yjtyvtyqyiqnqdctxpyz.supabase.co/auth/v1/signup 429 (Too Many Requests)
(anonymous) @ supabase-js@2:14
Lr @ supabase-js@2:14
Y @ supabase-js@2:14
signUp @ supabase-js@2:16
(anonymous) @ supabase.jsx:336
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
adminCreateUser @ supabase.jsx:313
(anonymous) @ screens2.jsx:3133
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
asyncGeneratorStep @ screens2.jsx:2
_next @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
(anonymous) @ screens2.jsx:2
_submit @ screens2.jsx:3139
submit @ screens2.jsx:3131
callCallback @ react-dom.development.js:4151
invokeGuardedCallbackDev @ react-dom.development.js:4200
invokeGuardedCallback @ react-dom.development.js:4264
invokeGuardedCallbackAndCatchFirstError @ react-dom.development.js:4278
executeDispatch @ react-dom.development.js:9051
processDispatchQueueItemsInOrder @ react-dom.development.js:9083
processDispatchQueue @ react-dom.development.js:9096
dispatchEventsForPlugins @ react-dom.development.js:9107
(anonymous) @ react-dom.development.js:9298
batchedUpdates$1 @ react-dom.development.js:26189
batchedUpdates @ react-dom.development.js:3978
dispatchEventForPluginEventSystem @ react-dom.development.js:9297
dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ react-dom.development.js:6475
dispatchEvent @ react-dom.development.js:6467
dispatchDiscreteEvent @ react-dom.development.js:6440

      id, user_id, provider_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(),
      uid,
      uid::text,
      jsonb_build_object('sub', uid::text, 'email', 'amr@clinic.eg', 'email_verified', true),
      'email',
      now(), now(), now()
    );
  end if;

  -- Repair pass: if the user was created by an earlier version of this
  -- script (or any SQL insert) with NULL token columns, GoTrue answers
  -- every login with 500. Normalize them to '' so sign-in works.
  update auth.users set
    confirmation_token         = coalesce(confirmation_token, ''),
    recovery_token             = coalesce(recovery_token, ''),
    email_change               = coalesce(email_change, ''),
    email_change_token_new     = coalesce(email_change_token_new, ''),
    email_change_token_current = coalesce(email_change_token_current, ''),
    phone_change               = coalesce(phone_change, ''),
    phone_change_token         = coalesce(phone_change_token, ''),
    reauthentication_token     = coalesce(reauthentication_token, ''),
    email_confirmed_at         = coalesce(email_confirmed_at, now()),
    raw_user_meta_data         = coalesce(raw_user_meta_data, '{}'::jsonb)
                                   || '{"role":"admin","name":"أمير"}'::jsonb
  where email = 'amir@kinetic.eg';

  insert into staff (staff_id, name, role, email, auth_uid)
  values ('ST-AMR', 'عمرو', 'admin', 'amr@clinic.eg', uid)
  on conflict (staff_id) do update
    set auth_uid = excluded.auth_uid,
        role     = 'admin',
        email    = excluded.email,
        name     = excluded.name;
end $$;

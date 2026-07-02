import { chromium } from 'playwright';
const browser = await chromium.launch({ headless: true });
const page = await browser.newContext({ locale: 'ar-EG' }).then(c => c.newPage());
const errs = [];
page.on('pageerror', (e) => errs.push('pageerror: ' + e.message));
page.on('response', (r) => { if (r.status() >= 400) errs.push(`${r.status()} ${r.url()}`); });
await page.goto('http://127.0.0.1:8123/index.html?demo=1', { waitUntil: 'load' });
await page.waitForTimeout(1200);
await page.locator('button', { hasText: /^مدير$/ }).first().click().catch(()=>{});
await page.locator('input[type="password"]').first().fill('demo').catch(()=>{});
await page.locator('button', { hasText: /^تسجيل الدخول$/ }).first().click().catch(()=>{});
await page.waitForTimeout(1200);
const state = await page.evaluate(() => ({
  hasReact: !!window.React,
  hasKD: !!window.KineticData,
  hasRowMenu: typeof window.RowMenu,
  ME: window.ME ? { role: window.ME.role, name: window.ME.name } : null,
  h1: document.querySelector('h1, .h1')?.textContent || '',
  allButtons: Array.from(document.querySelectorAll('button')).map(b => b.textContent.trim()).filter(Boolean),
  sidebarLinks: Array.from(document.querySelectorAll('aside a, aside button, nav a, nav button, .sidebar a, .sidebar button')).map(el => el.textContent.trim()).filter(Boolean),
}));
console.log('STATE:', JSON.stringify(state, null, 2));
console.log('ERRORS:');
errs.forEach(e => console.log(' -', e));
await page.screenshot({ path: 'qa-probe.png', fullPage: true });
await browser.close();

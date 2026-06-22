/**
 * Send test notification (legal/terms, promo, etc.)
 * Local:  node scripts/test-push.mjs feitanfeitan61@gmail.com
 * Prod:    node scripts/test-push.mjs feitanfeitan61@gmail.com --prod --admin-email=... --admin-password=...
 */
const args = process.argv.slice(2);
const flags = args.filter((a) => a.startsWith('--'));
const positional = args.filter((a) => !a.startsWith('--'));

const email = positional[0] || 'feitanfeitan61@gmail.com';
const type = positional[1] || 'legal';
const isProd = flags.includes('--prod');

const adminEmail = flags.find((f) => f.startsWith('--admin-email='))?.split('=')[1]
  || process.env.ADMIN_EMAIL;
const adminPassword = flags.find((f) => f.startsWith('--admin-password='))?.split('=')[1]
  || process.env.ADMIN_PASSWORD;

const base = isProd
  ? (process.env.API_BASE || 'https://geva-backend.onrender.com/api')
  : (process.env.API_BASE || 'http://localhost:3000/api');

const path = isProd ? '/admin/test-notification' : '/dev/test-push';

const body = {
  email,
  type,
  title: 'Үйлчилгээний нөхцөл шинэчлэгдлээ',
  body: 'Gevabal.mn-ийн үйлчилгээний нөхцөл шинэчлэгдлээ. Та уншиж танилцана уу.',
  actionPath: '/profile/terms',
};

let headers = { 'Content-Type': 'application/json' };

if (isProd) {
  if (!adminEmail || !adminPassword) {
    console.error('Production: --admin-email and --admin-password шаардлагатай');
    process.exit(1);
  }
  const loginRes = await fetch(`${base}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: adminEmail, password: adminPassword }),
  });
  const login = await loginRes.json();
  if (!login.token) {
    console.error('Admin login failed:', login);
    process.exit(1);
  }
  headers.Authorization = `Bearer ${login.token}`;
}

const res = await fetch(`${base}${path}`, {
  method: 'POST',
  headers,
  body: JSON.stringify(body),
});

const data = await res.json();
console.log(JSON.stringify(data, null, 2));

if (data.ok || data.saved) {
  console.log('\n✅ Мэдэгдэл үүслээ');
  if (data.pushed) {
    console.log('📱 Push илгээгдлээ →', email);
  } else {
    console.log('⚠️  Push илгээгдээгүй — FCM token:', data.hasFcmToken ? 'байгаа ч алдаа' : 'байхгүй');
    console.log('   Апп нээгээд нэвтэрнэ үү (мэдэгдлийн төвөнд хадгалагдана)');
  }
}

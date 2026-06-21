/**
 * Trigger test incoming call from Buyntsog → client (dev API + FCM).
 * Usage: node scripts/test-incoming-call.mjs [clientEmail]
 */
const clientEmail = process.argv[2] || 'feitanfeitan61@gmail.com';
const base = process.env.API_BASE || 'http://localhost:3000/api';

const res = await fetch(`${base}/dev/test-incoming-call`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ clientEmail, monkName: 'Buyntsog' }),
});

const body = await res.json();
console.log(JSON.stringify(body, null, 2));

if (body.ok) {
  console.log('\n✅ Test call queued!');
  console.log('App (debug mode) will show incoming call within ~2 seconds.');
  console.log('Booking:', body.bookingId);
}

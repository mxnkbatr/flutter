import 'dotenv/config';
import { connectDb, User, Monk, Booking } from '../src/db.js';
import { notifyIncomingCall } from '../src/notificationService.js';
import { todayDateStr, currentTimeMinutes } from '../src/timezoneUtils.js';

const clientEmail = (process.argv[2] || 'feitanfeitan61@gmail.com').toLowerCase();
const monkQuery = process.argv[3] || 'Buyntsog';

async function main() {
  await connectDb();

  const client = await User.findOne({ email: clientEmail });
  if (!client) {
    console.error('Client not found:', clientEmail);
    process.exit(1);
  }

  const monk = await Monk.findOne({
    $or: [
      { 'name.mn': new RegExp(monkQuery, 'i') },
      { 'name.en': new RegExp(monkQuery, 'i') },
    ],
  });
  if (!monk) {
    console.error('Monk not found:', monkQuery);
    process.exit(1);
  }

  const monkName = monk.name?.mn ?? monk.name?.en ?? monkQuery;
  let booking = await Booking.findOne({
    clientId: client._id,
    monkId: monk._id,
    status: 'confirmed',
    paid: true,
  }).sort({ updatedAt: -1 });

  const today = todayDateStr();
  const nowMin = currentTimeMinutes();
  const slot = `${String(Math.floor(nowMin / 60)).padStart(2, '0')}:${nowMin % 60 < 30 ? '00' : '30'}`;

  if (!booking) {
    booking = await Booking.create({
      clientId: client._id,
      monkId: monk._id,
      serviceName: 'Тест дуудлага',
      date: today,
      slot,
      amount: 50000,
      status: 'confirmed',
      paid: true,
    });
    console.log('Created test booking:', booking._id.toString());
  } else {
    await Booking.findByIdAndUpdate(booking._id, { date: today, slot });
    console.log('Updated booking:', booking._id.toString());
  }

  const payload = {
    callerName: monkName,
    callerImage: monk.image || '',
    bookingId: booking._id.toString(),
    recipientRole: 'client',
  };

  const result = await notifyIncomingCall(client, payload);
  console.log(JSON.stringify({
    ok: true,
    clientEmail: client.email,
    monkName,
    bookingId: booking._id.toString(),
    pushed: result.pushed,
    hasFcmToken: Boolean(client.fcmToken),
    fcmTokenPrefix: client.fcmToken ? client.fcmToken.slice(0, 12) + '...' : null,
  }, null, 2));

  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

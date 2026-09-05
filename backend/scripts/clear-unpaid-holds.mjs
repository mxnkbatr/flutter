import 'dotenv/config';
import { connectDb, Booking, Payment } from '../src/db.js';
import { cancelInvoice } from '../src/qpay.js';

await connectDb();
const holds = await Booking.find({
  paid: false,
  status: { $in: ['pending', 'approved'] },
});
let n = 0;
for (const b of holds) {
  b.status = 'cancelled';
  await b.save();
  n += 1;
  const p = await Payment.findOne({
    bookingId: b._id,
    paid: false,
    qpayInvoiceId: { $exists: true, $ne: null },
  });
  if (p?.qpayInvoiceId) {
    try {
      await cancelInvoice(p.qpayInvoiceId);
    } catch {
      /* ignore */
    }
  }
}
console.log('cleared unpaid holds', n);
process.exit(0);

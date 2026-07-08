import 'dotenv/config';
import mongoose from 'mongoose';
import { User } from '../src/db.js';

await mongoose.connect(process.env.MONGODB_URI, {
  dbName: process.env.MONGO_DB || 'Buddha',
});

const withToken = await User.find(
  { fcmToken: { $exists: true, $nin: [null, ''] } },
  'email name role fcmToken updatedAt',
).lean();

console.log('Users with FCM token:', withToken.length);
for (const u of withToken) {
  console.log(`- ${u.email} (${u.role}) updated=${u.updatedAt}`);
}

const feitan = await User.findOne({ email: 'feitanfeitan61@gmail.com' }).lean();
console.log('\nfeitanfeitan61@gmail.com:');
console.log('  fcmToken:', feitan?.fcmToken ? `${feitan.fcmToken.slice(0, 24)}...` : '(empty)');
console.log('  updatedAt:', feitan?.updatedAt);

await mongoose.disconnect();

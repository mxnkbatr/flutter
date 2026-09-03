import 'dotenv/config';
import { connectDb, Monk } from '../src/db.js';

await connectDb();
const monks = await Monk.find({}).limit(15).lean();
for (const m of monks) {
  console.log(m._id.toString(), m.name?.mn || m.name?.en || '?');
}
process.exit(0);

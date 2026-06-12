import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { connectDb, User } from './db.js';

const email = process.argv[2]?.toLowerCase();
const password = process.argv[3];
const name = process.argv[4] || 'Админ';

if (!email || !password) {
  console.error('Usage: node src/create-admin.js <email> <password> [name]');
  process.exit(1);
}

async function main() {
  await connectDb();

  const hash = await bcrypt.hash(password, 10);
  const existing = await User.findOne({ email });

  if (existing) {
    existing.password = hash;
    existing.role = 'admin';
    existing.name = name;
    existing.isActive = true;
    await existing.save();
    console.log(`Updated admin: ${email}`);
  } else {
    await User.create({
      email,
      password: hash,
      name,
      role: 'admin',
    });
    console.log(`Created admin: ${email}`);
  }

  process.exit(0);
}

main().catch((e) => {
  console.error('Failed:', e.message);
  process.exit(1);
});

import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { connectDb, User } from './db.js';
import { normalizePhone, isValidPhone, looksLikeEmail } from './phoneUtils.js';

/**
 * Usage:
 *   node src/create-admin.js <email-or-phone> [password] [name]
 * If user exists and password omitted, only promotes to admin (keeps password).
 */
const identifier = process.argv[2];
const password = process.argv[3];
const name = process.argv[4] || 'Админ';

if (!identifier) {
  console.error('Usage: node src/create-admin.js <email-or-phone> [password] [name]');
  process.exit(1);
}

async function main() {
  await connectDb();
  const isEmail = looksLikeEmail(identifier);
  let phone = '';

  let existing;
  if (isEmail) {
    existing = await User.findOne({ email: identifier.toLowerCase() });
  } else {
    phone = normalizePhone(identifier);
    if (!isValidPhone(phone)) {
      console.error('Invalid phone number');
      process.exit(1);
    }
    existing = await User.findOne({ phone });
  }

  if (existing) {
    existing.role = 'admin';
    existing.name = name || existing.name;
    existing.isActive = true;
    if (!isEmail) existing.phone = phone;
    else existing.email = identifier.toLowerCase();
    if (password) {
      existing.password = await bcrypt.hash(password, 10);
    }
    await existing.save();
    console.log(
      `Updated admin: ${identifier} (role=admin${password ? ', password reset' : ', password kept'})`,
    );
  } else {
    if (!password) {
      console.error('New admin requires a password: node src/create-admin.js <id> <password> [name]');
      process.exit(1);
    }
    const doc = {
      password: await bcrypt.hash(password, 10),
      name,
      role: 'admin',
      isActive: true,
    };
    if (isEmail) doc.email = identifier.toLowerCase();
    else doc.phone = phone;
    await User.create(doc);
    console.log(`Created admin: ${identifier}`);
  }

  process.exit(0);
}

main().catch((e) => {
  console.error('Failed:', e.message);
  process.exit(1);
});

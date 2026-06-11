import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { connectDb, User, Monk, Review } from './db.js';

function slotsForDate(dateStr) {
  return ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];
}

function nextDays(count) {
  const days = [];
  const now = new Date();
  for (let i = 0; i < count; i++) {
    const d = new Date(now);
    d.setDate(d.getDate() + i);
    const iso = d.toISOString().slice(0, 10);
    days.push({ date: iso, slots: slotsForDate(iso) });
  }
  return days;
}

async function seed() {
  await connectDb();

  const existing = await Monk.countDocuments();
  if (existing > 0) {
    console.log('Seed skipped — monks already exist');
    process.exit(0);
  }

  const hash = async (pw) => bcrypt.hash(pw, 10);

  const admin = await User.create({
    email: 'admin@test.com',
    password: await hash('admin123'),
    name: 'Админ',
    role: 'admin',
  });

  const monkUser1 = await User.create({
    email: 'monk@test.com',
    password: await hash('monk123'),
    name: 'Батбаяр',
    role: 'monk',
  });

  const monkUser2 = await User.create({
    email: 'monk2@test.com',
    password: await hash('monk123'),
    name: 'Ганбат',
    role: 'monk',
  });

  await User.create({
    email: 'client@test.com',
    password: await hash('client123'),
    name: 'Сараа',
    role: 'client',
  });

  const monk1 = await Monk.create({
    userId: monkUser1._id,
    name: { mn: 'Батбаяр', en: 'Batbayar' },
    title: { mn: 'Ерөөлийн лам', en: 'Prayer monk' },
    temple: 'Гандантэгчинлэн',
    bio: '20 жилийн туршлагатай ерөөл, тахилгын үйлчилгээ үзүүлдэг.',
    categories: ['Ерөөл', 'Тахилга'],
    rating: 4.9,
    reviewCount: 128,
    isAvailable: true,
    isSpecial: true,
    startingPrice: 50000,
    services: [
      { name: 'Ерөөл', description: 'Богино ерөөл', durationMinutes: 30, price: 50000, category: 'Ерөөл' },
      { name: 'Тахилга', description: 'Гэрийн тахилга', durationMinutes: 60, price: 80000, category: 'Тахилга' },
    ],
    schedule: nextDays(14),
  });

  const monk2 = await Monk.create({
    userId: monkUser2._id,
    name: { mn: 'Ганбат', en: 'Ganbat' },
    title: { mn: 'Зурхайч лам', en: 'Astrologer' },
    temple: 'Амарбаясгалант',
    bio: 'Зурхай, номын тайлбарын мэргэжилтэн.',
    categories: ['Зурхай', 'Номын тайлбар'],
    rating: 4.7,
    reviewCount: 86,
    isAvailable: true,
    isVip: true,
    startingPrice: 70000,
    services: [
      { name: 'Зурхай', description: 'Жилийн зурхай', durationMinutes: 45, price: 70000, category: 'Зурхай' },
      { name: 'Номын тайлбар', description: 'Богино тайлбар', durationMinutes: 30, price: 45000, category: 'Номын тайлбар' },
    ],
    schedule: nextDays(14),
  });

  const monk3 = await Monk.create({
    name: { mn: 'Даваажав', en: 'Davaajav' },
    title: { mn: 'Номын багш', en: 'Teacher' },
    temple: 'Бурханы сүм',
    bio: 'Номын тайлбар, медитаци заана.',
    categories: ['Номын тайлбар'],
    rating: 4.6,
    reviewCount: 42,
    isAvailable: true,
    startingPrice: 40000,
    services: [
      { name: 'Медитаци', description: 'Удирдлагатай медитаци', durationMinutes: 40, price: 40000, category: 'Номын тайлбар' },
    ],
    schedule: nextDays(14),
  });

  monkUser1.monkProfileId = monk1._id;
  monkUser2.monkProfileId = monk2._id;
  await monkUser1.save();
  await monkUser2.save();

  await Review.create([
    { monkId: monk1._id, clientName: 'Болд', rating: 5, comment: 'Маш сайн ерөөл авлаа' },
    { monkId: monk1._id, clientName: 'Оюунаа', rating: 5, comment: 'Талархаж байна' },
    { monkId: monk2._id, clientName: 'Тэмүүлэн', rating: 4, comment: 'Зурхай үнэн байсан' },
  ]);

  console.log('Seed complete');
  console.log('Admin: admin@test.com / admin123');
  console.log('Monk: monk@test.com / monk123');
  console.log('Client: client@test.com / client123');
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});

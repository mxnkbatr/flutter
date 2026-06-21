import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { connectDb, User, Monk, Review, Product } from './db.js';
import { DEFAULT_WEEKLY_SCHEDULE } from './scheduleUtils.js';

async function seedShopProducts() {
  const productCount = await Product.countDocuments();
  if (productCount < 6) {
    if (productCount > 0) await Product.deleteMany({});
    await Product.insertMany([
      {
        name: 'Буддын сургаалын ном',
        description: 'Монгол хэлээр хөрвүүлсэн буддын сургаалын үндсэн ном. Эхлэгчдэд тохиромжтой.',
        price: 25000,
        image: '',
        category: 'Ном',
        stock: 20,
        isActive: true,
      },
      {
        name: 'Бурхны тахилын тос',
        description: 'Цэвэр цагаан буюу шар өнгийн тахилын тос. 200гр савлагаатай.',
        price: 15000,
        image: '',
        category: 'Тос',
        stock: 50,
        isActive: true,
      },
      {
        name: 'Нандин чулуу — Нефрит',
        description: 'Байгалийн нефрит чулуу. Амар амгалан, эрүүл мэндийг авчирна гэж үздэг.',
        price: 45000,
        image: '',
        category: 'Эрдэнэ',
        stock: 10,
        isActive: true,
      },
      {
        name: 'Мэдрэлийн тайвшруулах утлага',
        description: 'Сандал, жижиглэсэн утлагын нунтаг. Гэр дотор ашиглахад тохиромжтой.',
        price: 12000,
        image: '',
        category: 'Бусад',
        stock: 30,
        isActive: true,
      },
      {
        name: 'Ламын ерөөлийн ном',
        description: 'Өдөр тутмын ерөөл, залбирлын ном. Богино ба урт хэлбэрийн ерөөлүүд.',
        price: 35000,
        image: '',
        category: 'Ном',
        stock: 15,
        isActive: true,
      },
      {
        name: 'Луу загварын бугуйн зүүлт',
        description: 'Мөнгөн луу загвартай бугуйн зүүлт. Хамгаалах тэмдэглэгдэж байдаг.',
        price: 55000,
        image: '',
        category: 'Эрдэнэ',
        stock: 8,
        isActive: true,
      },
    ]);
    console.log('✅ Shop products seeded');
  }
}

async function seed() {
  await connectDb();

  const existing = await Monk.countDocuments();
  if (existing > 0) {
    console.log('Seed skipped — monks already exist');
    await seedShopProducts();
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
    schedule: DEFAULT_WEEKLY_SCHEDULE,
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
    schedule: DEFAULT_WEEKLY_SCHEDULE,
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
    schedule: DEFAULT_WEEKLY_SCHEDULE,
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

  await seedShopProducts();

  console.log('✅ Seed complete');
  console.log('Admin: admin@test.com / admin123');
  console.log('Monk: monk@test.com / monk123');
  console.log('Client: client@test.com / client123');
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});

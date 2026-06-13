import 'dotenv/config';
import { connectDb, Product } from './db.js';

const SAMPLE_PRODUCTS = [
  {
    name: 'Монгол бурханы шашны ном',
    description:
      'Бурханы шашны үндсэн сургааль, ерөөл, ёс зүйн талаар бичсэн монгол хэл дээрх ном.',
    price: 35000,
    category: 'Ном',
    stock: 25,
    image: '',
    isActive: true,
  },
  {
    name: 'Улаан агарын үнэрт тос',
    description:
      'Гэрийн тахилга, медитацид зориулсан чанартай улаан агарын үнэрт тос. 50г.',
    price: 18000,
    category: 'Тос',
    stock: 40,
    image: '',
    isActive: true,
  },
];

async function seedShop() {
  await connectDb();

  let created = 0;
  for (const item of SAMPLE_PRODUCTS) {
    const exists = await Product.findOne({ name: item.name });
    if (exists) {
      console.log(`Skipped (exists): ${item.name}`);
      continue;
    }
    await Product.create(item);
    created++;
    console.log(`Created: ${item.name}`);
  }

  console.log(created > 0 ? `Shop seed done — ${created} бараа нэмэгдлээ` : 'Shop seed — бүх бараа аль хэдийн байна');
  process.exit(0);
}

seedShop().catch((e) => {
  console.error(e);
  process.exit(1);
});

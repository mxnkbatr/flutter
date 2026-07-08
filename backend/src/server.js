import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { AccessToken } from 'livekit-server-sdk';
import {
  connectDb,
  User,
  Monk,
  Booking,
  Payment,
  Conversation,
  Message,
  Review,
  Product,
  Order,
  MonkCategory,
  Notification,
} from './db.js';
import { authRequired, adminRequired, signToken } from './middleware/auth.js';
import {
  DEFAULT_SERVICES,
  DEFAULT_WEEKLY_SCHEDULE,
  getScheduleOverview,
  getSlotsForDate,
} from './scheduleUtils.js';
import { isPastSlot, todayDateStr, currentTimeMinutes, slotToMinutes } from './timezoneUtils.js';
import {
  notifyBookingStatus,
  notifyMessage,
  notifyIncomingCall,
  notifyCallTime,
  notifyLegalUpdate,
  notifyPromo,
  notifyUser,
  notificationJson,
  prefsForUser,
  DEFAULT_NOTIFICATION_PREFS,
} from './notificationService.js';
import {
  isQPayConfigured,
  createInvoice as createQPayInvoice,
  checkInvoicePayment,
  cancelInvoice as cancelQPayInvoice,
  mapQPayUrls,
} from './qpay.js';
import {
  ensureUploadsDir,
  uploadsRoot,
  uploadBase64Image,
  isCloudinaryConfigured,
} from './uploadUtils.js';

const app = express();
const PORT = process.env.PORT || 3000;

const TIER_DISCOUNTS = {
  free: 0,
  premium: 20,
  vip: 20, // legacy — VIP tier removed, existing users keep discount
};

const PLATFORM_FEE_RATE = 0.1;

/** Premium subscriptions — disabled until a future app release. */
const PREMIUM_SUBSCRIPTIONS_ENABLED = false;

const DEFAULT_MONK_CATEGORIES = ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

/** Dev-only: simulate incoming call for clients without FCM (polled by Flutter debug). */
const pendingTestCalls = new Map();

async function ensureMonkCategories() {
  const count = await MonkCategory.countDocuments();
  if (count > 0) return;
  await MonkCategory.insertMany(
    DEFAULT_MONK_CATEGORIES.map((name, i) => ({ name, sortOrder: i })),
  );
}

async function listMonkCategoryNames() {
  await ensureMonkCategories();
  const rows = await MonkCategory.find().sort({ sortOrder: 1, name: 1 }).lean();
  return rows.map((c) => c.name);
}

ensureUploadsDir('monks');

app.use(cors());
app.use(express.json({ limit: '8mb' }));
app.use('/uploads', express.static(uploadsRoot));

function mapName(obj) {
  if (!obj?.name) return obj;
  const name = obj.name instanceof Map ? Object.fromEntries(obj.name) : obj.name;
  const title = obj.title instanceof Map ? Object.fromEntries(obj.title) : obj.title;
  return { ...obj.toObject?.() ?? obj, name, title };
}

function monkJson(m) {
  const o = mapName(m);
  return {
    id: o._id.toString(),
    _id: o._id.toString(),
    name: o.name,
    title: o.title,
    image: o.image,
    temple: o.temple,
    bio: o.bio,
    categories: o.categories || [],
    rating: o.rating,
    reviewCount: o.reviewCount,
    isAvailable: o.isAvailable,
    isSpecial: o.isSpecial,
    isVip: o.isVip,
    sortOrder: o.sortOrder ?? 0,
    isOnline: o.isOnline,
    startingPrice: o.startingPrice,
    status: o.status,
  };
}

function productJson(p) {
  return {
    id: p._id.toString(),
    name: p.name,
    description: p.description || '',
    price: p.price,
    image: p.image || '',
    category: p.category || 'Бусад',
    stock: p.stock ?? 0,
    isActive: p.isActive ?? true,
    createdAt: p.createdAt?.toISOString?.() ?? '',
  };
}

function orderJson(o) {
  return {
    id: o._id.toString(),
    userId: o.userId?.toString() ?? '',
    items: (o.items || []).map((item) => ({
      productId: item.productId?.toString() ?? '',
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      image: item.image,
    })),
    totalAmount: o.totalAmount,
    status: o.status,
    paid: o.paid,
    invoiceId: o.invoiceId || '',
    address: o.address || '',
    phone: o.phone || '',
    createdAt: o.createdAt?.toISOString?.() ?? '',
  };
}

async function markShopOrderPaid(orderId) {
  if (!orderId) return;
  const order = await Order.findById(orderId);
  if (!order || order.paid) return;
  order.paid = true;
  order.status = 'paid';
  await order.save();
  for (const item of order.items || []) {
    if (item.productId) {
      await Product.findByIdAndUpdate(item.productId, { $inc: { stock: -(item.quantity || 1) } });
    }
  }
}

function bookingJson(b, extra = {}) {
  return {
    id: b._id.toString(),
    _id: b._id.toString(),
    monkId: b.monkId?.toString(),
    clientId: b.clientId?.toString(),
    serviceName: b.serviceName,
    date: b.date,
    slot: b.slot,
    amount: b.amount,
    status: b.status,
    paid: b.paid,
    reviewed: b.reviewed ?? false,
    bankTransferPending: b.bankTransferPending === true,
    ...extra,
  };
}

function userJson(u) {
  return {
    id: u._id.toString(),
    _id: u._id.toString(),
    email: u.email,
    name: u.name,
    phone: u.phone || '',
    role: u.role,
    tier: u.tier,
    tierExpiresAt: u.tierExpiresAt?.toISOString(),
  };
}

// ─── Upload ───
app.post('/api/upload/image', authRequired, async (req, res) => {
  try {
    const allowed = ['admin', 'monk'];
    if (!allowed.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { image, folder } = req.body;
    if (!image) return res.status(400).json({ error: 'Image is required' });

    const subfolder = folder === 'products' ? 'products' : 'monks';
    const stored = await uploadBase64Image(image, subfolder);
    const base = `${req.protocol}://${req.get('host')}`;
    const url = stored.startsWith('http') ? stored : `${base}${stored}`;
    const path = stored.startsWith('http') ? stored : stored;
    res.json({ url, path, storage: isCloudinaryConfigured() ? 'cloudinary' : 'local' });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// ─── Auth ───
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Missing fields' });
    }
    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) return res.status(400).json({ error: 'Email already registered' });
    const user = await User.create({
      email: email.toLowerCase(),
      password: await bcrypt.hash(password, 10),
      name,
      role: 'client',
    });
    const token = signToken(user);
    res.json({ token, user: userJson(user) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email: email?.toLowerCase() });
    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    if (user.isActive === false) {
      return res.status(403).json({ error: 'Account disabled' });
    }
    const token = signToken(user);
    res.json({ token, user: userJson(user) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/auth/me', authRequired, (req, res) => {
  res.json(userJson(req.user));
});

// ─── Monk categories (public list for filters) ───
app.get('/api/categories', async (_req, res) => {
  try {
    const names = await listMonkCategoryNames();
    res.json(names);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/categories', authRequired, adminRequired, async (_req, res) => {
  try {
    await ensureMonkCategories();
    const rows = await MonkCategory.find().sort({ sortOrder: 1, name: 1 }).lean();
    res.json(
      rows.map((c) => ({
        id: c._id.toString(),
        name: c.name,
        sortOrder: c.sortOrder ?? 0,
      })),
    );
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/categories', authRequired, adminRequired, async (req, res) => {
  try {
    const name = String(req.body.name || '').trim();
    if (!name) return res.status(400).json({ error: 'Ангиллын нэр шаардлагатай' });
    const exists = await MonkCategory.findOne({ name });
    if (exists) return res.status(409).json({ error: 'Энэ ангилал аль хэдийн байна' });
    const maxOrder = await MonkCategory.findOne().sort({ sortOrder: -1 }).lean();
    const cat = await MonkCategory.create({
      name,
      sortOrder: (maxOrder?.sortOrder ?? -1) + 1,
    });
    res.json({ id: cat._id.toString(), name: cat.name, sortOrder: cat.sortOrder });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/admin/categories/:id', authRequired, adminRequired, async (req, res) => {
  try {
    const cat = await MonkCategory.findById(req.params.id);
    if (!cat) return res.status(404).json({ error: 'Олдсонгүй' });
    await MonkCategory.deleteOne({ _id: cat._id });
    await Monk.updateMany({}, { $pull: { categories: cat.name } });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Monks ───
app.get('/api/monks', async (req, res) => {
  try {
    let query = { status: { $in: ['active', 'pending'] } };
    if (req.query.category) {
      query.categories = req.query.category;
    }
    let monks = await Monk.find(query).lean();
    monks = monks.map((m) => monkJson(m));

    if (req.query.recommended === 'true') {
      monks = monks.filter((m) => m.isSpecial).slice(0, Number(req.query.limit) || 3);
    }

    const sort = req.query.sort;
    if (sort === 'price_desc') monks.sort((a, b) => (b.startingPrice || 0) - (a.startingPrice || 0));
    else if (sort === 'price_asc') monks.sort((a, b) => (a.startingPrice || 0) - (b.startingPrice || 0));
    else if (sort === 'newest') monks.reverse();
    else if (sort === 'rating') monks.sort((a, b) => (b.rating || 0) - (a.rating || 0));
    else {
      monks.sort((a, b) => {
        const ao = a.sortOrder ?? 999999;
        const bo = b.sortOrder ?? 999999;
        if (ao !== bo) return ao - bo;
        return (b.rating || 0) - (a.rating || 0);
      });
    }

    res.json(monks);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/monks/:id', async (req, res) => {
  try {
    const monk = await Monk.findById(req.params.id);
    if (!monk) return res.status(404).json({ error: 'Not found' });
    res.json({ monk: monkJson(monk) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/monks/:id/services', async (req, res) => {
  try {
    const monk = await Monk.findById(req.params.id);
    if (!monk) return res.status(404).json({ error: 'Not found' });
    const services = (monk.services || []).map((s, i) => ({
      id: `${monk._id}_svc_${i}`,
      _id: `${monk._id}_svc_${i}`,
      name: s.name,
      description: s.description,
      durationMinutes: s.durationMinutes,
      price: s.price,
      category: s.category,
    }));
    res.json(services);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/monks/:id/schedule', async (req, res) => {
  try {
    const monk = await Monk.findById(req.params.id);
    if (!monk) return res.status(404).json({ error: 'Not found' });
    const schedule = monk.schedule || [];

    if (req.query.date) {
      const data = await getSlotsForDate(monk._id, schedule, req.query.date);
      return res.json(data);
    }

    const overview = await getScheduleOverview(monk._id, schedule);
    res.json(overview);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/monks/:id/reviews', async (req, res) => {
  try {
    const reviews = await Review.find({ monkId: req.params.id }).sort({ createdAt: -1 }).limit(20);
    res.json(
      reviews.map((r) => ({
        id: r._id.toString(),
        clientName: r.clientName,
        rating: r.rating,
        comment: r.comment,
        createdAt: r.createdAt?.toISOString(),
      })),
    );
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Сэтгэгдэл бичих — зөвхөн тухайн ламаас completed захиалгатай client
app.post('/api/monks/:id/reviews', authRequired, async (req, res) => {
  try {
    const { rating, comment, bookingId } = req.body;
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ error: 'Үнэлгээ 1-5 хооронд байх ёстой' });
    }

    const booking = await Booking.findById(bookingId);
    if (!booking) return res.status(404).json({ error: 'Захиалга олдсонгүй' });
    if (booking.clientId?.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }
    if (booking.monkId?.toString() !== req.params.id) {
      return res.status(400).json({ error: 'Захиалга тохирохгүй байна' });
    }
    if (booking.status !== 'completed') {
      return res.status(400).json({ error: 'Зөвхөн дууссан захиалгад сэтгэгдэл бичнэ' });
    }
    if (booking.reviewed) {
      return res.status(400).json({ error: 'Энэ захиалгад сэтгэгдэл бичсэн байна' });
    }

    await Review.create({
      monkId: req.params.id,
      clientName: req.user.name,
      rating,
      comment: comment || '',
    });

    booking.reviewed = true;
    await booking.save();

    const allReviews = await Review.find({ monkId: req.params.id });
    const avgRating =
      allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length;

    await Monk.findByIdAndUpdate(req.params.id, {
      rating: Math.round(avgRating * 10) / 10,
      reviewCount: allReviews.length,
    });

    res.status(201).json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Bookings ───
app.get('/api/bookings', authRequired, async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'client') {
      filter.clientId = req.user._id;
    } else if (req.user.role === 'monk' && req.user.monkProfileId) {
      filter.monkId = req.user.monkProfileId;
    } else if (req.user.role === 'admin') {
      // all
    } else {
      filter.clientId = req.user._id;
    }

    if (req.query.month) {
      filter.date = { $regex: `^${req.query.month}` };
    }

    const bookings = await Booking.find(filter).sort({ createdAt: -1 }).limit(100);
    const result = [];
    for (const b of bookings) {
      const monk = await Monk.findById(b.monkId);
      const client = await User.findById(b.clientId);
      result.push(
        bookingJson(b, {
          monkName: monk ? (monk.name?.get?.('mn') || monk.name?.mn) : '',
          clientName: client?.name || '',
          monkImage: monk?.image,
        }),
      );
    }
    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/bookings/:id', authRequired, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id).lean();
    if (!booking) return res.status(404).json({ error: 'Not found' });

    const userId = req.user._id.toString();
    const monk = await Monk.findById(booking.monkId).lean();
    const isClient = booking.clientId?.toString() === userId;
    const isMonk = monk?.userId?.toString() === userId;
    const isAdmin = req.user.role === 'admin';
    if (!isClient && !isMonk && !isAdmin) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const client = await User.findById(booking.clientId).lean();
    res.json({
      ...bookingJson(booking),
      clientName: client?.name ?? '',
      monkName: monk?.name?.mn ?? monk?.name?.get?.('mn') ?? '',
      monkImage: monk?.image ?? '',
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/bookings', authRequired, async (req, res) => {
  try {
    const { monkId, serviceId, date, slot } = req.body;
    const monk = await Monk.findById(monkId);
    if (!monk) return res.status(404).json({ error: 'Monk not found' });
    if (monk.status !== 'active') {
      return res.status(403).json({ error: 'Monk is not available' });
    }

    const dateStr = date?.slice(0, 10);
    if (!dateStr || !slot) {
      return res.status(400).json({ error: 'Date and slot are required' });
    }

    const { slots, bookedSlots } = await getSlotsForDate(
      monk._id,
      monk.schedule,
      dateStr,
    );
    if (!slots.includes(slot)) {
      return res.status(400).json({ error: 'Invalid time slot' });
    }
    if (bookedSlots.includes(slot)) {
      return res.status(409).json({ error: 'Time slot already booked' });
    }
    if (isPastSlot(dateStr, slot)) {
      return res.status(400).json({ error: 'Энэ цаг өнгөрсөн байна' });
    }

    const svcIdx = serviceId?.split('_svc_')[1];
    const service = svcIdx != null ? monk.services[Number(svcIdx)] : monk.services[0];
    if (!service) return res.status(400).json({ error: 'Service not found' });

    const basePrice = service.price || 0;
    const tier = effectiveTier(req.user);
    const discountPercent = TIER_DISCOUNTS[tier] || 0;
    const discounted = Math.round(basePrice * (1 - discountPercent / 100));
    const platformFee = Math.round(discounted * PLATFORM_FEE_RATE);
    const finalAmount = discounted + platformFee;

    const booking = await Booking.create({
      clientId: req.user._id,
      monkId: monk._id,
      serviceId,
      serviceName: service?.name || 'Үйлчилгээ',
      date: dateStr,
      slot,
      amount: finalAmount,
      discountPercent,
      status: 'pending',
      paid: false,
    });

    res.json({ bookingId: booking._id.toString(), id: booking._id.toString() });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/bookings/:id/confirm', authRequired, async (req, res) => {
  try {
    if (!(await assertMonkNotBlocked(req.user, res))) return;
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Олдсонгүй' });

    const monk = await Monk.findById(booking.monkId);
    const isMonkOwner = monk?.userId?.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';
    if (!isMonkOwner && !isAdmin) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }
    if (booking.status !== 'pending') {
      return res.status(400).json({ error: 'Зөвхөн хүлээгдэж буй захиалгыг батална' });
    }

    booking.status = booking.paid ? 'confirmed' : 'approved';
    booking.approvedAt = new Date();
    await booking.save();

    const client = await User.findById(booking.clientId);
    if (client) {
      await notifyBookingStatus(client, {
        status: 'approved',
        monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
        bookingId: booking._id.toString(),
      });
    }

    res.json({ ok: true, status: 'approved' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

async function bookingAccess(bookingId, user) {
  const booking = await Booking.findById(bookingId).lean();
  if (!booking) return { error: 'Not found', status: 404 };
  const monk = await Monk.findById(booking.monkId).lean();
  const userId = user._id.toString();
  const isClient = booking.clientId?.toString() === userId;
  const isMonk = monk?.userId?.toString() === userId;
  const isAdmin = user.role === 'admin';
  if (!isClient && !isMonk && !isAdmin) {
    return { error: 'Forbidden', status: 403 };
  }
  return { booking, monk, isClient, isMonk, isAdmin };
}

function effectiveTier(user) {
  if (!PREMIUM_SUBSCRIPTIONS_ENABLED) return 'free';
  const tier = user.tier || 'free';
  if (user.tierExpiresAt && new Date(user.tierExpiresAt) < new Date()) return 'free';
  return tier;
}

async function paymentAccess(payment, user) {
  if (!payment) return { error: 'Not found', status: 404 };
  if (user.role === 'admin') return { ok: true };
  if (payment.userId?.toString() === user._id.toString()) return { ok: true };
  return { error: 'Forbidden', status: 403 };
}

async function assertMonkNotBlocked(user, res) {
  if (user.role !== 'monk' || !user.monkProfileId) return true;
  const monk = await Monk.findById(user.monkProfileId).lean();
  if (monk?.status === 'blocked') {
    res.status(403).json({ error: 'Monk account is blocked' });
    return false;
  }
  return true;
}

const PLATFORM_BANK = {
  bankName: process.env.PLATFORM_BANK_NAME || 'Төрийн банк',
  accountNumber: process.env.PLATFORM_BANK_ACCOUNT || '888889896666',
  accountHolder: process.env.PLATFORM_BANK_HOLDER || 'Gevabal.mn ХХК',
  iban: process.env.PLATFORM_BANK_IBAN || '400034',
};

function qpayCallbackUrl() {
  const base = (process.env.APP_BASE_URL || `http://localhost:${PORT}`).replace(/\/$/, '');
  return `${base}/api/payment/qpay/callback`;
}

function paymentQPayPayload(payment) {
  return {
    invoiceId: payment.invoiceId,
    amount: payment.amount,
    qrImage: payment.qrImage || fakeQrBase64(payment.amount),
    urls: payment.qpayUrls?.length
      ? payment.qpayUrls
      : mapQPayUrls([]),
  };
}

async function completePaymentRecord(payment) {
  if (!payment || payment.paid) return;
  payment.paid = true;
  payment.paidAt = new Date();
  await payment.save();

  if (payment.bookingId) {
    const booking = await Booking.findById(payment.bookingId);
    if (booking) {
      booking.paid = true;
      booking.bankTransferPending = false;
      if (booking.status === 'approved') {
        booking.status = 'confirmed';
      }
      await booking.save();
      const client = await User.findById(booking.clientId);
      const monk = await Monk.findById(booking.monkId).lean();
      if (client) {
        await notifyBookingStatus(client, {
          status: 'confirmed',
          monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
          bookingId: booking._id.toString(),
        });
      }
    }
  }
  if (payment.type === 'shop_order' && payment.orderId) {
    await markShopOrderPaid(payment.orderId);
  }
  if (payment.type === 'subscription' && payment.tier) {
    const expires = new Date();
    expires.setMonth(expires.getMonth() + (payment.months || 1));
    await User.findByIdAndUpdate(payment.userId, {
      tier: payment.tier,
      tierExpiresAt: expires,
    });
  }
}

async function syncQPayPaymentStatus(payment) {
  if (!payment || payment.paid) return true;

  if (!isQPayConfigured()) {
    const age = Date.now() - payment.createdAt.getTime();
    if (age > 15000) {
      await completePaymentRecord(payment);
      return true;
    }
    return false;
  }

  if (!payment.qpayInvoiceId) return false;

  const result = await checkInvoicePayment(payment.qpayInvoiceId);
  if ((result.count || 0) > 0) {
    await completePaymentRecord(payment);
    return true;
  }
  return false;
}

async function issueQPayForPayment(payment, description) {
  if (!isQPayConfigured()) {
    const qrImage = fakeQrBase64(payment.amount);
    payment.qrImage = qrImage;
    payment.qpayUrls = mapQPayUrls([
      { name: 'Khan Bank', link: 'https://qpay.mn' },
      { name: 'Golomt', link: 'https://qpay.mn' },
    ]);
    await payment.save();
    return paymentQPayPayload(payment);
  }

  const invoice = await createQPayInvoice({
    senderInvoiceNo: payment.invoiceId,
    description,
    amount: payment.amount,
    callbackUrl: qpayCallbackUrl(),
  });

  payment.qpayInvoiceId = invoice.invoice_id;
  payment.qrImage = invoice.qr_image || fakeQrBase64(payment.amount);
  payment.qpayUrls = mapQPayUrls(invoice.urls);
  await payment.save();

  return paymentQPayPayload(payment);
}

app.put('/api/bookings/:id/cancel', authRequired, async (req, res) => {
  try {
    if (!(await assertMonkNotBlocked(req.user, res))) return;
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Олдсонгүй' });

    const monk = await Monk.findById(booking.monkId);
    const userId = req.user._id.toString();
    const isClient = booking.clientId?.toString() === userId;
    const isMonkOwner = monk?.userId?.toString() === userId;
    const isAdmin = req.user.role === 'admin';

    if (!isClient && !isMonkOwner && !isAdmin) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }
    if (['completed', 'cancelled'].includes(booking.status)) {
      return res.status(400).json({ error: 'Энэ захиалгыг цуцлах боломжгүй' });
    }
    if (isMonkOwner && booking.paid) {
      return res.status(400).json({ error: 'Төлсөн захиалгыг цуцлах боломжгүй' });
    }

    booking.status = 'cancelled';
    await booking.save();

    const notifyUserId = isMonkOwner ? booking.clientId : monk?.userId;
    if (notifyUserId) {
      const recipient = await User.findById(notifyUserId);
      if (recipient) {
        await notifyBookingStatus(recipient, {
          status: 'cancelled',
          monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
          bookingId: booking._id.toString(),
        });
      }
    }

  res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/bookings/:id/complete', authRequired, async (req, res) => {
  try {
    if (!(await assertMonkNotBlocked(req.user, res))) return;
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Олдсонгүй' });

    const monk = await Monk.findById(booking.monkId);
    const userId = req.user._id.toString();
    const isMonkOwner = monk?.userId?.toString() === userId;
    const isAdmin = req.user.role === 'admin';

    if (!isMonkOwner && !isAdmin) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }
    if (booking.status !== 'confirmed') {
      return res.status(400).json({ error: 'Зөвхөн баталгаажсан захиалгыг дуусгана' });
    }
    if (!booking.paid) {
      return res.status(400).json({ error: 'Төлбөр төлөгдөөгүй байна' });
    }

    booking.status = 'completed';
    await booking.save();

    const client = await User.findById(booking.clientId);
    if (client) {
      await notifyBookingStatus(client, {
        status: 'completed',
        monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
        bookingId: booking._id.toString(),
      });
    }

  res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Payment / QPay (mock + real hook) ───
function fakeQrBase64(amount) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect fill="#fff" width="200" height="200"/><text x="100" y="100" text-anchor="middle" font-size="14">QPay ₮${amount}</text></svg>`;
  return Buffer.from(svg).toString('base64');
}

app.post('/api/payment/qpay/create', authRequired, async (req, res) => {
  try {
    const { bookingId, regenerate } = req.body;
    const access = await bookingAccess(bookingId, req.user);
    if (access.error) return res.status(access.status).json({ error: access.error });
    const { booking, isClient, monk } = access;
    if (!isClient && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Only client can initiate payment' });
    }
    if (!['pending', 'approved'].includes(booking.status)) {
      return res.status(400).json({ error: 'Booking not available for payment' });
    }
    if (booking.paid) {
      return res.status(400).json({ error: 'Already paid' });
    }

    if (regenerate) {
      const oldPayments = await Payment.find({
        bookingId,
        type: 'booking',
        paid: false,
        method: 'qpay',
      });
      for (const p of oldPayments) {
        if (p.qpayInvoiceId) await cancelQPayInvoice(p.qpayInvoiceId);
      }
      await Payment.deleteMany({
        bookingId,
        type: 'booking',
        paid: false,
        method: 'qpay',
      });
    }

    let payment = await Payment.findOne({
      bookingId,
      type: 'booking',
      paid: false,
      method: 'qpay',
    });

    if (!payment) {
    const invoiceId = `INV-${uuidv4().slice(0, 8)}`;
      payment = await Payment.create({
      invoiceId,
      type: 'booking',
      bookingId,
      userId: req.user._id,
        amount: booking.amount,
        method: 'qpay',
      paid: false,
    });
    }

    const monkName = monk?.name?.mn ?? monk?.name?.en ?? 'Лам';
    const description = `Gevabal захиалга — ${monkName} (${booking.serviceName || 'үйлчилгээ'})`;

    if (!payment.qpayInvoiceId || !payment.qrImage) {
      const payload = await issueQPayForPayment(payment, description);
      return res.json(payload);
    }

    res.json(paymentQPayPayload(payment));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/payment/booking/:bookingId', authRequired, async (req, res) => {
  try {
    const access = await bookingAccess(req.params.bookingId, req.user);
    if (access.error) return res.status(access.status).json({ error: access.error });
    const { booking, monk, isClient, isAdmin } = access;

    const client = await User.findById(booking.clientId).lean();
    const canPay =
      isClient &&
      ['pending', 'approved'].includes(booking.status) &&
      !booking.paid;

    let payment = await Payment.findOne({
      bookingId: booking._id,
      type: 'booking',
      paid: false,
      method: 'qpay',
    }).sort({ createdAt: -1 });

    const monkName = monk?.name?.mn ?? monk?.name?.en ?? 'Лам';
    const description = `Gevabal захиалга — ${monkName} (${booking.serviceName || 'үйлчилгээ'})`;

    if (canPay) {
      if (!payment) {
        payment = await Payment.create({
          invoiceId: `INV-${uuidv4().slice(0, 8)}`,
          type: 'booking',
          bookingId: booking._id,
          userId: req.user._id,
          amount: booking.amount,
          method: 'qpay',
          paid: false,
        });
      }
      if (!payment.qpayInvoiceId || !payment.qrImage) {
        try {
          await issueQPayForPayment(payment, description);
          payment = await Payment.findById(payment._id);
        } catch (e) {
          console.error('QPay invoice error:', e.message);
        }
      }
    } else {
      payment = await Payment.findOne({
        bookingId: booking._id,
        type: 'booking',
        paid: false,
      }).sort({ createdAt: -1 });
    }

    const showQpay = isClient || isAdmin;

    res.json({
      booking: {
        ...bookingJson(booking),
        monkName,
        monkImage: monk?.image ?? '',
        clientName: client?.name ?? '',
      },
      bank: PLATFORM_BANK,
      reference: booking._id.toString().slice(-8).toUpperCase(),
      canPay,
      paymentPending: booking.bankTransferPending === true,
      qpay: showQpay && payment?.method === 'qpay' && payment?.qrImage
          ? paymentQPayPayload(payment)
          : null,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/payment/order/:orderId', authRequired, async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);
    if (!order) return res.status(404).json({ error: 'Not found' });

    const isOwner = order.userId?.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }

    const payment = await Payment.findOne({
      orderId: order._id,
      type: 'shop_order',
      paid: false,
    }).sort({ createdAt: -1 });

    res.json({
      order: orderJson(order),
      canPay: isOwner && !order.paid,
      qpay: payment ? paymentQPayPayload(payment) : null,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/payment/bank-transfer/:bookingId', authRequired, async (req, res) => {
  try {
    const access = await bookingAccess(req.params.bookingId, req.user);
    if (access.error) return res.status(access.status).json({ error: access.error });
    const { booking, isClient } = access;
    if (!isClient) {
      return res.status(403).json({ error: 'Only client can submit bank transfer' });
    }
    if (booking.status !== 'approved' || booking.paid) {
      return res.status(400).json({ error: 'Payment not available' });
    }

    await Booking.findByIdAndUpdate(booking._id, { bankTransferPending: true });
    const invoiceId = `BNK-${uuidv4().slice(0, 8)}`;
    await Payment.create({
      invoiceId,
      type: 'booking',
      bookingId: booking._id,
      userId: req.user._id,
      amount: booking.amount,
      method: 'bank',
      paid: false,
    });

    if (!process.env.QPAY_USERNAME) {
      await Booking.findByIdAndUpdate(booking._id, {
        paid: true,
        status: 'confirmed',
        bankTransferPending: false,
      });
      await Payment.updateOne({ invoiceId }, { paid: true, paidAt: new Date() });
      return res.json({ ok: true, paid: true, dev: true });
    }

    res.json({ ok: true, paid: false, message: 'Админ баталгаажуулах хүлээнэ' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/payment/qpay/check/:invoiceId', authRequired, async (req, res) => {
  try {
  const payment = await Payment.findOne({ invoiceId: req.params.invoiceId });
    const access = await paymentAccess(payment, req.user);
    if (access.error) return res.status(access.status).json({ error: access.error });

    await syncQPayPaymentStatus(payment);
    const fresh = await Payment.findOne({ invoiceId: req.params.invoiceId });
    res.json({ paid: fresh?.paid === true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/payment/qpay/callback', async (req, res) => {
  try {
    const qpayInvoiceId = req.body?.invoice_id || req.body?.invoiceId;
    if (!qpayInvoiceId) {
      return res.status(400).json({ error: 'invoice_id required' });
    }

    const payment = await Payment.findOne({ qpayInvoiceId });
    if (payment) {
      await syncQPayPaymentStatus(payment);
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Dev: manually mark paid (owner or admin only)
app.post('/api/payment/qpay/simulate/:invoiceId', authRequired, async (req, res) => {
  if (process.env.QPAY_USERNAME) {
    return res.status(403).json({ error: 'Not available in production' });
  }
  const payment = await Payment.findOne({ invoiceId: req.params.invoiceId });
  const access = await paymentAccess(payment, req.user);
  if (access.error) return res.status(access.status).json({ error: access.error });
  await completePaymentRecord(payment);
  res.json({ paid: true });
});

// ─── LiveKit ───
app.get('/api/livekit', authRequired, async (req, res) => {
  try {
    const room = req.query.room || '';
    const username = req.query.username || req.user.name || 'user';

    const match = /^booking-(.+)$/.exec(room);
    if (match) {
      const bookingId = match[1];
      const booking = await Booking.findById(bookingId).lean();
      if (!booking) return res.status(404).json({ error: 'Booking not found' });

      const monk = await Monk.findById(booking.monkId).lean();
      const userId = req.user._id.toString();
      const isClient = booking.clientId?.toString() === userId;
      const isMonk = monk?.userId?.toString() === userId;
      const isAdmin = req.user.role === 'admin';

      if (!isClient && !isMonk && !isAdmin) {
        return res.status(403).json({ error: 'Эрх байхгүй' });
      }
      if (!booking.paid || booking.status !== 'confirmed') {
        return res.status(403).json({ error: 'Захиалга баталгаажаагүй байна' });
      }
    } else {
      if (req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Эрх байхгүй' });
      }
    }

    const apiKey = process.env.LIVEKIT_API_KEY;
    const apiSecret = process.env.LIVEKIT_API_SECRET;
    const wsUrl = process.env.LIVEKIT_URL;

    if (!apiKey || !apiSecret || !wsUrl) {
      return res.status(500).json({ error: 'LiveKit not configured' });
    }

    const at = new AccessToken(apiKey, apiSecret, {
      identity: req.user._id.toString(),
      name: username,
    });
    at.addGrant({ roomJoin: true, room, canPublish: true, canSubscribe: true });

    if (match) {
      const bookingId = match[1];
      const booking = await Booking.findById(bookingId).lean();
      if (booking) {
        const isCallerMonk = req.user.role === 'monk';
        let recipientUser;
        let monkDoc;

        if (isCallerMonk) {
          recipientUser = await User.findById(booking.clientId);
        } else {
          monkDoc = await Monk.findById(booking.monkId);
          recipientUser = monkDoc?.userId ? await User.findById(monkDoc.userId) : null;
        }

        if (recipientUser) {
          const recipientRole = isCallerMonk ? 'client' : 'monk';
          const callerImage = isCallerMonk
              ? (req.user.avatar || '')
              : (monkDoc?.image ?? '');
          await notifyIncomingCall(recipientUser, {
            callerName: req.user.name,
            callerImage,
            bookingId,
            recipientRole,
          });
        }
      }
    }

    res.json({ token: await at.toJwt(), wsUrl, url: wsUrl });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Subscription ───
const TIER_PRICES = { premium: 300000 };

app.get('/api/subscription/status', authRequired, (req, res) => {
  const expires = req.user.tierExpiresAt;
  let daysLeft = 0;
  if (expires) {
    daysLeft = Math.max(0, Math.ceil((expires - Date.now()) / 86400000));
  }
  res.json({
    tier: req.user.tier,
    expiresAt: expires?.toISOString(),
    daysLeft,
  });
});

app.post('/api/subscription/subscribe', authRequired, async (req, res) => {
  const { tier, months } = req.body;
  const monthly = TIER_PRICES[tier];
  if (!monthly) return res.status(400).json({ error: 'Invalid tier' });
  const amount = monthly * (months || 1);
  const invoiceId = `SUB-${uuidv4().slice(0, 8)}`;
  await Payment.create({
    invoiceId,
    type: 'subscription',
    userId: req.user._id,
    tier,
    months: months || 1,
    amount,
    paid: false,
  });
  res.json({
    invoiceId,
    amount,
    qrImage: fakeQrBase64(amount),
    urls: [{ name: 'QPay', link: 'https://qpay.mn' }],
  });
});

app.post('/api/subscription/activate', authRequired, async (req, res) => {
  const { tier, invoiceId } = req.body;
  const payment = await Payment.findOne({ invoiceId, userId: req.user._id });
  if (!payment?.paid) {
    return res.status(400).json({ error: 'Payment not completed' });
  }
  const expires = new Date();
  expires.setMonth(expires.getMonth() + (payment.months || 1));
  req.user.tier = tier;
  req.user.tierExpiresAt = expires;
  await req.user.save();
  res.json({ tier, expiresAt: expires.toISOString(), tierExpiresAt: expires.toISOString() });
});

// ─── Users profile / FCM ───
app.put('/api/users/profile', authRequired, async (req, res) => {
  const { fcmToken, name, phone } = req.body;
  if (fcmToken !== undefined) req.user.fcmToken = fcmToken || null;
  if (name) req.user.name = name;
  if (phone !== undefined) req.user.phone = phone;
  await req.user.save();
  res.json(userJson(req.user));
});

// Apple App Store: in-app account deletion (Guideline 5.1.1)
app.delete('/api/users/me', authRequired, async (req, res) => {
  try {
    const user = req.user;
    if (user.role === 'admin') {
      return res.status(403).json({ error: 'Админ бүртгэлийг аппаас устгах боломжгүй' });
    }

    const force = req.query.force === '1' || req.query.force === 'true';

    if (user.role === 'monk' && user.monkProfileId) {
      const monk = await Monk.findById(user.monkProfileId);
      if (!monk) {
        await User.deleteOne({ _id: user._id });
        return res.json({ ok: true });
      }

      const activeBookings = await Booking.countDocuments({
        monkId: monk._id,
        status: { $nin: ['completed', 'cancelled'] },
      });
      if (activeBookings > 0 && !force) {
        return res.status(400).json({
          error: 'Идэвхтэй захиалга байна. Устгахын өмнө захиалгуудыг цуцлах уу?',
          code: 'ACTIVE_BOOKINGS',
          activeBookings,
        });
      }
      if (activeBookings > 0 && force) {
        await Booking.updateMany(
          { monkId: monk._id, status: { $nin: ['completed', 'cancelled'] } },
          { $set: { status: 'cancelled' } },
        );
      }

      const monkId = monk._id;
      await Booking.deleteMany({ monkId });
      await Review.deleteMany({ monkId });
      const conversations = await Conversation.find({ monkId });
      const conversationIds = conversations.map((c) => c._id);
      if (conversationIds.length) {
        await Message.deleteMany({ conversationId: { $in: conversationIds } });
      }
      await Conversation.deleteMany({ monkId });
      await Monk.deleteOne({ _id: monkId });
      await Notification.deleteMany({ userId: user._id });
      await User.deleteOne({ _id: user._id });
      return res.json({ ok: true });
    }

    const userId = user._id;
    const activeBookings = await Booking.countDocuments({
      clientId: userId,
      status: { $nin: ['completed', 'cancelled'] },
    });
    if (activeBookings > 0 && !force) {
      return res.status(400).json({
        error: 'Идэвхтэй захиалга байна. Устгахын өмнө захиалгуудыг цуцлах уу?',
        code: 'ACTIVE_BOOKINGS',
        activeBookings,
      });
    }
    if (activeBookings > 0 && force) {
      await Booking.updateMany(
        { clientId: userId, status: { $nin: ['completed', 'cancelled'] } },
        { $set: { status: 'cancelled' } },
      );
    }

    const clientBookings = await Booking.find({ clientId: userId }).select('_id');
    const bookingIds = clientBookings.map((b) => b._id);
    if (bookingIds.length) {
      await Payment.deleteMany({ bookingId: { $in: bookingIds } });
      await Booking.deleteMany({ clientId: userId });
    }
    await Payment.deleteMany({ userId });
    await Order.deleteMany({ userId });
    await Notification.deleteMany({ userId });

    const conversations = await Conversation.find({ clientId: userId });
    const conversationIds = conversations.map((c) => c._id);
    if (conversationIds.length) {
      await Message.deleteMany({ conversationId: { $in: conversationIds } });
    }
    await Conversation.deleteMany({ clientId: userId });
    await User.deleteOne({ _id: userId });

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Notification settings ───
app.get('/api/users/notification-settings', authRequired, (req, res) => {
  res.json(prefsForUser(req.user));
});

app.put('/api/users/notification-settings', authRequired, async (req, res) => {
  const body = req.body || {};
  const prefs = req.user.notificationPrefs || {};
  for (const key of Object.keys(DEFAULT_NOTIFICATION_PREFS)) {
    if (typeof body[key] === 'boolean') {
      prefs[key] = body[key];
    }
  }
  req.user.notificationPrefs = prefs;
  req.user.markModified('notificationPrefs');
  await req.user.save();
  res.json(prefsForUser(req.user));
});

// ─── In-app notifications ───
app.get('/api/notifications', authRequired, async (req, res) => {
  try {
    const limit = Math.min(parseInt(req.query.limit, 10) || 50, 100);
    const items = await Notification.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();
    res.json(items.map((n) => notificationJson(n)));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/notifications/unread-count', authRequired, async (req, res) => {
  try {
    const count = await Notification.countDocuments({
      userId: req.user._id,
      isRead: false,
    });
    res.json({ count });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/notifications/read-all', authRequired, async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user._id, isRead: false },
      { $set: { isRead: true } },
    );
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/notifications/:id/read', authRequired, async (req, res) => {
  try {
    const n = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { $set: { isRead: true } },
      { new: true },
    );
    if (!n) return res.status(404).json({ error: 'Not found' });
    res.json(notificationJson(n));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Monk dashboard ───
app.get('/api/monk/dashboard', authRequired, async (req, res) => {
  if (req.user.role !== 'monk' || !req.user.monkProfileId) {
    return res.status(403).json({ error: 'Not a monk' });
  }
  const monkId = req.user.monkProfileId;
  const monk = await Monk.findById(monkId);
  const today = new Date().toISOString().slice(0, 10);
  const month = today.slice(0, 7);

  const allBookings = await Booking.find({ monkId, status: { $ne: 'cancelled' } });
  const monthBookings = allBookings.filter((b) => b.date?.startsWith(month));
  const monthlyEarnings = monthBookings
    .filter((b) => b.paid)
    .reduce((s, b) => s + Math.round((b.amount || 0) * 0.8), 0);

  const todayBookings = await Booking.find({ monkId, date: today });
  const clients = await User.find({ _id: { $in: todayBookings.map((b) => b.clientId) } });
  const clientMap = Object.fromEntries(clients.map((c) => [c._id.toString(), c.name]));

  res.json({
    monkName: monk?.name?.get?.('mn') || req.user.name,
    monthlyEarnings,
    earningsChangePercent: 12.5,
    totalBookings: allBookings.length,
    weeklyBookings: allBookings.filter((b) => {
      const d = new Date(b.createdAt);
      const w = new Date();
      w.setDate(w.getDate() - 7);
      return d >= w;
    }).length,
    rating: monk?.rating || 0,
    reviewCount: monk?.reviewCount || 0,
    pendingCount: allBookings.filter((b) => b.status === 'pending').length,
    isAvailable: monk?.isAvailable ?? true,
    todayBookings: todayBookings.map((b) =>
      bookingJson(b, { clientName: clientMap[b.clientId?.toString()] || '' }),
    ),
  });
});

app.put('/api/monk/availability', authRequired, async (req, res) => {
  if (req.user.role !== 'monk' || !req.user.monkProfileId) {
    return res.status(403).json({ error: 'Not a monk' });
  }
  if (!(await assertMonkNotBlocked(req.user, res))) return;
  await Monk.findByIdAndUpdate(req.user.monkProfileId, {
    isAvailable: req.body.isAvailable,
  });
  res.json({ ok: true });
});

app.get('/api/monk/schedule', authRequired, async (req, res) => {
  if (req.user.role !== 'monk' || !req.user.monkProfileId) {
    return res.status(403).json({ error: 'Not a monk' });
  }
  const monk = await Monk.findById(req.user.monkProfileId);
  res.json({ days: monk?.schedule || [] });
});

app.put('/api/monk/schedule', authRequired, async (req, res) => {
  if (req.user.role !== 'monk' || !req.user.monkProfileId) {
    return res.status(403).json({ error: 'Not a monk' });
  }
  if (!(await assertMonkNotBlocked(req.user, res))) return;
  const days = req.body.days || req.body;
  await Monk.findByIdAndUpdate(req.user.monkProfileId, { schedule: days });
  res.json({ ok: true });
});

app.get('/api/monk/profile', authRequired, async (req, res) => {
  try {
    if (!req.user.monkProfileId) return res.status(403).json({ error: 'Not a monk' });
    const monk = await Monk.findById(req.user.monkProfileId);
    if (!monk) return res.status(404).json({ error: 'Profile not found' });
    const o = mapName(monk);
    res.json({
      ...monkJson(monk),
      services: (monk.services || []).map((s, i) => ({
        id: `${monk._id}_svc_${i}`,
        name: s.name,
        description: s.description,
        durationMinutes: s.durationMinutes,
        price: s.price,
        category: s.category,
      })),
      schedule: o.schedule || [],
      email: req.user.email,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/monk/profile', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'monk' || !req.user.monkProfileId) {
      return res.status(403).json({ error: 'Not a monk' });
    }
    if (!(await assertMonkNotBlocked(req.user, res))) return;
    const { name, temple, bio, categories, title, image } = req.body;
    const updates = {};
    if (name != null) {
      updates.name = typeof name === 'object' ? name : { mn: name, en: name };
    }
    if (title != null) {
      updates.title = typeof title === 'object' ? title : { mn: title, en: title };
    }
    if (temple != null) updates.temple = temple;
    if (bio != null) updates.bio = bio;
    if (categories != null) updates.categories = categories;
    if (image != null) updates.image = image;

    const monk = await Monk.findByIdAndUpdate(req.user.monkProfileId, updates, {
      new: true,
    });
    if (name && typeof name === 'string') {
      req.user.name = name;
      await req.user.save();
    }
    res.json(monkJson(monk));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/monk/services', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'monk' || !req.user.monkProfileId) {
      return res.status(403).json({ error: 'Not a monk' });
    }
    if (!(await assertMonkNotBlocked(req.user, res))) return;
    const services = (req.body.services || []).map((s) => ({
      name: typeof s.name === 'object' ? s.name.mn || s.name.en : s.name,
      description: s.description || '',
      durationMinutes: Number(s.durationMinutes) || 30,
      price: Number(s.price) || 0,
      category: s.category || '',
    }));
    const startingPrice = services.length
      ? Math.min(...services.map((s) => s.price || 0))
      : 0;
    const monk = await Monk.findByIdAndUpdate(
      req.user.monkProfileId,
      { services, startingPrice },
      { new: true },
    );
    res.json({
      services: (monk.services || []).map((s, i) => ({
        id: `${monk._id}_svc_${i}`,
        name: s.name,
        description: s.description,
        durationMinutes: s.durationMinutes,
        price: s.price,
        category: s.category,
      })),
      startingPrice: monk.startingPrice,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/monk/salary', authRequired, async (req, res) => {
  if (req.user.role !== 'monk' || !req.user.monkProfileId) {
    return res.status(403).json({ error: 'Not a monk' });
  }
  const month = req.query.month || new Date().toISOString().slice(0, 7);
  const bookings = await Booking.find({
    monkId: req.user.monkProfileId,
    status: 'completed',
    date: { $regex: `^${month}` },
  });
  const gross = bookings.reduce((s, b) => s + (b.amount || 0), 0);
  const platformFee = Math.round(gross * 0.2);
  const qpayFee = Math.round(gross * 0.015);
  const net = gross - platformFee - qpayFee;
  const clients = await User.find({ _id: { $in: bookings.map((b) => b.clientId) } });
  const clientMap = Object.fromEntries(clients.map((c) => [c._id.toString(), c.name]));

  res.json({
    month,
    completedCount: bookings.length,
    grossAmount: gross,
    platformFee,
    qpayFee,
    netEarnings: net,
    transactions: bookings.map((b) => ({
      bookingId: b._id.toString(),
      clientName: clientMap[b.clientId?.toString()] || '',
      serviceName: b.serviceName,
      date: b.date,
      amount: b.amount,
      monkEarns: Math.round((b.amount || 0) * 0.8),
    })),
  });
});

// ─── Messenger ───
async function conversationAccess(conversationId, user) {
  const convo = await Conversation.findById(conversationId).lean();
  if (!convo) return { error: 'Not found', status: 404 };

  const userId = user._id.toString();
  const isClient = convo.clientId?.toString() === userId;
  const isMonkUser = convo.monkUserId?.toString() === userId;
  const isAdmin = user.role === 'admin';

  if (!isClient && !isMonkUser && !isAdmin) {
    return { error: 'Forbidden', status: 403 };
  }
  return { convo };
}

app.get('/api/messenger/conversations', authRequired, async (req, res) => {
  let filter;
  if (req.user.role === 'monk' && req.user.monkProfileId) {
    filter = { monkUserId: req.user._id };
  } else {
    filter = { clientId: req.user._id };
  }
  const convos = await Conversation.find(filter).sort({ updatedAt: -1 });
  const result = [];
  for (const c of convos) {
    const monk = await Monk.findById(c.monkId);
    const other =
      req.user.role === 'monk'
        ? await User.findById(c.clientId)
        : null;
    result.push({
      id: c._id.toString(),
      monkId: c.monkId?.toString(),
      monkName: monk?.name?.get?.('mn') || monk?.name?.mn || '',
      monkImage: monk?.image,
      clientName: other?.name,
      lastMessage: c.lastMessage,
      lastMessageAt: c.lastMessageAt?.toISOString(),
    });
  }
  res.json(result);
});

app.get('/api/messenger/conversations/:id/messages', authRequired, async (req, res) => {
  const access = await conversationAccess(req.params.id, req.user);
  if (access.error) return res.status(access.status).json({ error: access.error });

  const msgs = await Message.find({ conversationId: req.params.id }).sort({ createdAt: 1 });
  res.json(
    msgs.map((m) => ({
      id: m._id.toString(),
      senderId: m.senderId.toString(),
      text: m.text,
      isMine: m.senderId.toString() === req.user._id.toString(),
      createdAt: m.createdAt?.toISOString(),
    })),
  );
});

app.post('/api/messenger/conversations/:id/messages', authRequired, async (req, res) => {
  const access = await conversationAccess(req.params.id, req.user);
  if (access.error) return res.status(access.status).json({ error: access.error });

  const { text } = req.body;
  if (!text?.trim()) return res.status(400).json({ error: 'Text required' });

  const msg = await Message.create({
    conversationId: req.params.id,
    senderId: req.user._id,
    text: text.trim(),
  });
  await Conversation.findByIdAndUpdate(req.params.id, {
    lastMessage: text.trim(),
    lastMessageAt: new Date(),
  });

  const convo = access.convo;
  const recipientId =
    convo.clientId?.toString() === req.user._id.toString()
      ? convo.monkUserId
      : convo.clientId;
  if (recipientId) {
    const recipient = await User.findById(recipientId);
    if (recipient) {
      await notifyMessage(recipient, {
        senderName: req.user.name,
        text: text.trim(),
        conversationId: req.params.id,
      });
    }
  }

  res.json({
    id: msg._id.toString(),
    senderId: msg.senderId.toString(),
    text: msg.text,
    isMine: true,
    createdAt: msg.createdAt?.toISOString(),
  });
});

app.post('/api/messenger/conversations', authRequired, async (req, res) => {
  const { monkId } = req.body;
  const monk = await Monk.findById(monkId);
  if (!monk) return res.status(404).json({ error: 'Monk not found' });

  let convo = await Conversation.findOne({ clientId: req.user._id, monkId });
  if (!convo) {
    convo = await Conversation.create({
      clientId: req.user._id,
      monkId: monk._id,
      monkUserId: monk.userId,
    });
  }
  res.json({ id: convo._id.toString() });
});

// ─── Admin (simplified) ───
app.get('/api/admin/dashboard', authRequired, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
  const allBookings = await Booking.find({ paid: true }).lean();
  const totalRevenue = allBookings.reduce((s, b) => s + (b.amount || 0), 0);
  const monks = await Monk.find().lean();
  const users = await User.find({ role: 'client' }).lean();
  const pending = monks.filter((m) => m.status === 'pending');

  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const newUsersThisWeek = users.filter(
    (u) => u.createdAt && new Date(u.createdAt) >= weekAgo,
  ).length;

  const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const thisMonthCount = allBookings.filter(
    (b) => b.createdAt && new Date(b.createdAt) >= thisMonthStart,
  ).length;
  const lastMonthCount = allBookings.filter((b) => {
    if (!b.createdAt) return false;
    const d = new Date(b.createdAt);
    return d >= lastMonthStart && d < thisMonthStart;
  }).length;
  const bookingsGrowth =
    lastMonthCount > 0
      ? Math.round(((thisMonthCount - lastMonthCount) / lastMonthCount) * 1000) / 10
      : thisMonthCount > 0
        ? 100
        : 0;

  const monthlyRevenue = [];
  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const monthStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    const amount = allBookings
      .filter((b) => b.date?.startsWith(monthStr))
      .reduce((s, b) => s + (b.amount || 0), 0);
    monthlyRevenue.push({ label: `${d.getMonth() + 1}-р`, amount });
  }

  const recentRaw = [...allBookings]
    .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0))
    .slice(0, 5);
  const clientIds = [...new Set(recentRaw.map((b) => b.clientId?.toString()).filter(Boolean))];
  const monkIds = [...new Set(recentRaw.map((b) => b.monkId?.toString()).filter(Boolean))];
  const [clients, monksForRecent] = await Promise.all([
    User.find({ _id: { $in: clientIds } }, 'name').lean(),
    Monk.find({ _id: { $in: monkIds } }, 'name').lean(),
  ]);
  const clientMap = Object.fromEntries(clients.map((u) => [u._id.toString(), u.name]));
  const monkMap = Object.fromEntries(
    monksForRecent.map((m) => [m._id.toString(), m.name?.mn ?? m.name?.en ?? '']),
  );

  res.json({
    totalRevenue,
    totalBookings: allBookings.length,
    bookingsGrowth,
    activeMonks: monks.filter((m) => m.status === 'active').length,
    pendingMonks: pending.length,
    totalUsers: users.length,
    newUsersThisWeek,
    qpayConfigured: isQPayConfigured(),
    appBaseUrl: process.env.APP_BASE_URL || '',
    monthlyRevenue,
    pendingMonksList: pending.map(monkJson),
    recentBookings: recentRaw.map((b) =>
      bookingJson(b, {
        clientName: clientMap[b.clientId?.toString()] ?? '',
        monkName: monkMap[b.monkId?.toString()] ?? '',
        serviceName: b.serviceName ?? '',
        amount: b.amount,
      }),
    ),
  });
});

app.get('/api/admin/monks', authRequired, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
  const status = req.query.status || 'all';
  let q = {};
  if (status !== 'all') q.status = status;
  const monks = await Monk.find(q).sort({ sortOrder: 1, createdAt: 1 });
  res.json(monks.map(monkJson));
});

app.put('/api/admin/monks/reorder', authRequired, adminRequired, async (req, res) => {
  try {
    const { ids } = req.body;
    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ error: 'ids array required' });
    }
    await Promise.all(
      ids.map((id, index) => Monk.findByIdAndUpdate(id, { sortOrder: index })),
    );
  res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/monks', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const {
      email,
      password,
      name,
      temple,
      bio,
      categories,
      services,
      schedule,
      status,
      title,
      image,
    } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Email, password, and name are required' });
    }

    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) return res.status(400).json({ error: 'Email already registered' });

    const monkServices = (services?.length ? services : DEFAULT_SERVICES).map((s) => ({
      name: typeof s.name === 'object' ? s.name.mn || s.name.en : s.name,
      description: s.description || '',
      durationMinutes: Number(s.durationMinutes) || 30,
      price: Number(s.price) || 0,
      category: s.category || '',
    }));

    const monkSchedule = schedule?.length ? schedule : DEFAULT_WEEKLY_SCHEDULE;
    const startingPrice = monkServices.length
      ? Math.min(...monkServices.map((s) => s.price || 0))
      : 0;

    const maxOrderMonk = await Monk.findOne().sort({ sortOrder: -1 }).select('sortOrder').lean();
    const nextSortOrder = (maxOrderMonk?.sortOrder ?? -1) + 1;

    const monk = await Monk.create({
      name: { mn: name, en: name },
      title: title ? { mn: title, en: title } : { mn: 'Лам', en: 'Monk' },
      image: image || '',
      temple: temple || '',
      bio: bio || '',
      categories: categories || [],
      services: monkServices,
      schedule: monkSchedule,
      startingPrice,
      status: status || 'active',
      isAvailable: true,
      sortOrder: nextSortOrder,
    });

    const user = await User.create({
      email: email.toLowerCase(),
      password: await bcrypt.hash(password, 10),
      name,
      role: 'monk',
      monkProfileId: monk._id,
    });

    monk.userId = user._id;
    await monk.save();

    res.status(201).json({
      monk: monkJson(monk),
      user: userJson(user),
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/admin/monks/:id', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const { name, temple, bio, categories, services, schedule, status, title, image, isSpecial, email } =
      req.body;
    const updates = {};

    if (name != null) {
      updates.name = typeof name === 'object' ? name : { mn: name, en: name };
    }
    if (title != null) {
      updates.title = typeof title === 'object' ? title : { mn: title, en: title };
    }
    if (temple != null) updates.temple = temple;
    if (bio != null) updates.bio = bio;
    if (categories != null) updates.categories = categories;
    if (schedule != null) updates.schedule = schedule;
    if (status != null) updates.status = status;
    if (image != null) updates.image = image;
    if (typeof isSpecial === 'boolean') updates.isSpecial = isSpecial;

    if (services != null) {
      updates.services = services.map((s) => ({
        name: typeof s.name === 'object' ? s.name.mn || s.name.en : s.name,
        description: s.description || '',
        durationMinutes: Number(s.durationMinutes) || 30,
        price: Number(s.price) || 0,
        category: s.category || '',
      }));
      updates.startingPrice = updates.services.length
        ? Math.min(...updates.services.map((s) => s.price || 0))
        : 0;
    }

    const monk = await Monk.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!monk) return res.status(404).json({ error: 'Monk not found' });

    if (name && typeof name === 'string') {
      const linkedUser = await User.findOne({ monkProfileId: monk._id });
      if (linkedUser) {
        linkedUser.name = name;
        await linkedUser.save();
      }
    }

    if (email != null && typeof email === 'string') {
      const normalized = email.trim().toLowerCase();
      if (!normalized) {
        return res.status(400).json({ error: 'И-мэйл хоосон байж болохгүй' });
      }
      const linkedUser = await User.findOne({ monkProfileId: monk._id });
      if (!linkedUser) {
        return res.status(400).json({ error: 'Ламын нэвтрэх бүртгэл олдсонгүй' });
      }
      if (normalized !== linkedUser.email) {
        const taken = await User.findOne({ email: normalized, _id: { $ne: linkedUser._id } });
        if (taken) {
          return res.status(400).json({ error: 'Энэ и-мэйл аль хэдийн бүртгэлтэй байна' });
        }
        linkedUser.email = normalized;
        await linkedUser.save();
      }
    }

    res.json(monkJson(monk));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/monks/:id', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const monk = await Monk.findById(req.params.id);
    if (!monk) return res.status(404).json({ error: 'Monk not found' });

    const user = await User.findOne({ monkProfileId: monk._id });
    const o = mapName(monk);

    res.json({
      ...monkJson(monk),
      services: (monk.services || []).map((s, i) => ({
        id: `${monk._id}_svc_${i}`,
        name: s.name,
        description: s.description,
        durationMinutes: s.durationMinutes,
        price: s.price,
        category: s.category,
      })),
      schedule: monk.schedule || [],
      email: user?.email || '',
      userId: user?._id?.toString() || '',
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/admin/monks/:id', authRequired, adminRequired, async (req, res) => {
  try {
    const monk = await Monk.findById(req.params.id);
    if (!monk) return res.status(404).json({ error: 'Monk not found' });

    const force = req.query.force === '1' || req.query.force === 'true';
    const activeBookings = await Booking.countDocuments({
      monkId: monk._id,
      status: { $nin: ['completed', 'cancelled'] },
    });
    if (activeBookings > 0 && !force) {
      return res.status(400).json({
        error: 'Идэвхтэй захиалга байна. Устгахын өмнө захиалгуудыг цуцлах уу?',
        code: 'ACTIVE_BOOKINGS',
        activeBookings,
      });
    }

    if (activeBookings > 0 && force) {
      await Booking.updateMany(
        { monkId: monk._id, status: { $nin: ['completed', 'cancelled'] } },
        { $set: { status: 'cancelled' } },
      );
    }

    const user = await User.findOne({ monkProfileId: monk._id });
    const monkId = monk._id;

    await Booking.deleteMany({ monkId });
    await Review.deleteMany({ monkId });
    const conversations = await Conversation.find({ monkId });
    const conversationIds = conversations.map((c) => c._id);
    if (conversationIds.length) {
      await Message.deleteMany({ conversationId: { $in: conversationIds } });
    }
    await Conversation.deleteMany({ monkId });
    if (user) await User.deleteOne({ _id: user._id });
    await Monk.deleteOne({ _id: monkId });

  res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/monks/:id/approve', authRequired, adminRequired, async (req, res) => {
  const monk = await Monk.findByIdAndUpdate(req.params.id, { status: 'active' }, { new: true });
  if (!monk) return res.status(404).json({ error: 'Not found' });
  res.json({ ok: true });
});

app.post('/api/admin/monks/:id/block', authRequired, adminRequired, async (req, res) => {
  const monk = await Monk.findByIdAndUpdate(req.params.id, { status: 'blocked' }, { new: true });
  if (!monk) return res.status(404).json({ error: 'Not found' });
  res.json({ ok: true });
});

app.post('/api/admin/users/:id/block', authRequired, adminRequired, async (req, res) => {
  try {
    const target = await User.findById(req.params.id);
    if (!target) return res.status(404).json({ error: 'Not found' });
    if (target.role === 'admin') {
      return res.status(403).json({ error: 'Cannot block admin accounts' });
    }
    await User.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/users/:id/unblock', authRequired, adminRequired, async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isActive: true });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/admin/users/:id', authRequired, adminRequired, async (req, res) => {
  try {
    const target = await User.findById(req.params.id);
    if (!target) return res.status(404).json({ error: 'Хэрэглэгч олдсонгүй' });
    if (target.role === 'admin') {
      return res.status(403).json({ error: 'Админ бүртгэл устгах боломжгүй' });
    }
    if (target.role === 'monk' && target.monkProfileId) {
      return res.status(400).json({
        error: 'Ламын бүртгэлийг "Лам" хэсгээс устгана уу',
        code: 'USE_MONK_DELETE',
      });
    }

    const force = req.query.force === '1' || req.query.force === 'true';
    const userId = target._id;
    const activeBookings = await Booking.countDocuments({
      clientId: userId,
      status: { $nin: ['completed', 'cancelled'] },
    });
    if (activeBookings > 0 && !force) {
      return res.status(400).json({
        error: 'Идэвхтэй захиалга байна. Устгахын өмнө захиалгуудыг цуцлах уу?',
        code: 'ACTIVE_BOOKINGS',
        activeBookings,
      });
    }

    if (activeBookings > 0 && force) {
      await Booking.updateMany(
        { clientId: userId, status: { $nin: ['completed', 'cancelled'] } },
        { $set: { status: 'cancelled' } },
      );
    }

    const clientBookings = await Booking.find({ clientId: userId }).select('_id');
    const bookingIds = clientBookings.map((b) => b._id);
    if (bookingIds.length) {
      await Payment.deleteMany({ bookingId: { $in: bookingIds } });
      await Booking.deleteMany({ clientId: userId });
    }
    await Payment.deleteMany({ userId });
    await Order.deleteMany({ userId });

    const conversations = await Conversation.find({ clientId: userId });
    const conversationIds = conversations.map((c) => c._id);
    if (conversationIds.length) {
      await Message.deleteMany({ conversationId: { $in: conversationIds } });
    }
    await Conversation.deleteMany({ clientId: userId });
    await User.deleteOne({ _id: userId });

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/users', authRequired, adminRequired, async (req, res) => {
  const users = await User.find();
  res.json(
    users.map((u) => ({
      id: u._id.toString(),
      name: u.name,
      email: u.email,
      role: u.role,
      isActive: u.isActive !== false,
    })),
  );
});

app.get('/api/admin/bookings', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
  let q = {};
  if (req.query.status && req.query.status !== 'all') q.status = req.query.status;

    const bookings = await Booking.find(q).sort({ createdAt: -1 }).limit(100).lean();

    const clientIds = [...new Set(bookings.map((b) => b.clientId?.toString()).filter(Boolean))];
    const monkIds = [...new Set(bookings.map((b) => b.monkId?.toString()).filter(Boolean))];

    const [clients, monks] = await Promise.all([
      User.find({ _id: { $in: clientIds } }, 'name').lean(),
      Monk.find({ _id: { $in: monkIds } }, 'name').lean(),
    ]);

    const clientMap = Object.fromEntries(clients.map((u) => [u._id.toString(), u.name]));
    const monkMap = Object.fromEntries(
      monks.map((m) => [m._id.toString(), m.name?.mn ?? m.name?.en ?? '']),
    );

    res.json(
      bookings.map((b) =>
        bookingJson(b, {
          clientName: clientMap[b.clientId?.toString()] ?? '',
          monkName: monkMap[b.monkId?.toString()] ?? '',
          serviceName: b.serviceName ?? '',
        }),
      ),
    );
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/admin/bookings/:id/approve', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Not found' });
    if (booking.status !== 'pending') {
      return res.status(400).json({ error: 'Only pending bookings can be approved' });
    }
    booking.status = booking.paid ? 'confirmed' : 'approved';
    booking.approvedAt = new Date();
    booking.approvedBy = req.user._id;
    await booking.save();

    const monk = await Monk.findById(booking.monkId);
    const client = await User.findById(booking.clientId);
    if (client) {
      await notifyBookingStatus(client, {
        status: booking.status === 'confirmed' ? 'confirmed' : 'approved',
        monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
        bookingId: booking._id.toString(),
      });
    }

    res.json({ ok: true, status: booking.status });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/admin/bookings/:id/reject', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Not found' });
    if (booking.status !== 'pending') {
      return res.status(400).json({ error: 'Only pending bookings can be rejected' });
    }
    booking.status = 'cancelled';
    await booking.save();

    const monk = await Monk.findById(booking.monkId);
    const client = await User.findById(booking.clientId);
    if (client) {
      await notifyBookingStatus(client, {
        status: 'cancelled',
        monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
        bookingId: booking._id.toString(),
      });
    }

    res.json({ ok: true, status: 'cancelled' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/admin/bookings/:id/confirm-payment', authRequired, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ error: 'Not found' });

    const monk = await Monk.findById(booking.monkId);
    const userId = req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isAdmin) {
      return res.status(403).json({ error: 'Зөвхөн админ банкны төлбөр батална' });
    }
    if (booking.status !== 'approved' || booking.paid) {
      return res.status(400).json({ error: 'Invalid booking state' });
    }
    if (!booking.bankTransferPending) {
      return res.status(400).json({ error: 'No pending bank transfer' });
    }
    booking.paid = true;
    booking.status = 'confirmed';
    booking.bankTransferPending = false;
    await booking.save();
    await Payment.updateMany(
      { bookingId: booking._id, type: 'booking', paid: false },
      { paid: true, paidAt: new Date() },
    );

    const client = await User.findById(booking.clientId);
    if (client) {
      await notifyBookingStatus(client, {
        status: 'confirmed',
        monkName: monk?.name?.mn ?? monk?.name?.en ?? 'Лам',
        bookingId: booking._id.toString(),
      });
    }

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/bookings/:id', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const booking = await Booking.findById(req.params.id).lean();
    if (!booking) return res.status(404).json({ error: 'Not found' });

    const [client, monk] = await Promise.all([
      User.findById(booking.clientId, 'name email').lean(),
      Monk.findById(booking.monkId, 'name image').lean(),
    ]);

    res.json({
      ...bookingJson(booking, {
        clientName: client?.name ?? '',
        monkName: monk?.name?.mn ?? monk?.name?.en ?? '',
        serviceName: booking.serviceName ?? '',
      }),
      clientEmail: client?.email ?? '',
      monkImage: monk?.image ?? '',
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/finance', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

  const month = req.query.month || new Date().toISOString().slice(0, 7);
    const bookings = await Booking.find({
      paid: true,
      status: { $in: ['completed', 'confirmed'] },
      date: { $regex: `^${month}` },
    }).lean();

  const totalRevenue = bookings.reduce((s, b) => s + (b.amount || 0), 0);
  const platformFees = Math.round(totalRevenue * 0.2);
  const qpayFees = Math.round(totalRevenue * 0.015);

    const byMonk = {};
    for (const b of bookings) {
      const mid = b.monkId?.toString();
      if (!mid) continue;
      if (!byMonk[mid]) byMonk[mid] = { bookingCount: 0, gross: 0 };
      byMonk[mid].bookingCount++;
      byMonk[mid].gross += b.amount || 0;
    }

    const monkIds = Object.keys(byMonk);
    const monks = await Monk.find({ _id: { $in: monkIds } }, 'name image').lean();
    const monkInfoMap = Object.fromEntries(
      monks.map((m) => [
        m._id.toString(),
        {
          name: m.name?.mn ?? m.name?.en ?? '',
          image: m.image ?? '',
        },
      ]),
    );

    const monkSalaries = monkIds.map((mid) => {
      const d = byMonk[mid];
      const gross = d.gross;
      const fee = Math.round(gross * 0.2);
      const qpay = Math.round(gross * 0.015);
      return {
        monkId: mid,
        monkName: monkInfoMap[mid]?.name ?? '',
        monkImage: monkInfoMap[mid]?.image ?? '',
        bookingCount: d.bookingCount,
        grossAmount: gross,
        platformFee: fee,
        qpayFee: qpay,
        netEarnings: gross - fee - qpay,
      };
    });

  res.json({
    month,
    totalRevenue,
    platformFees,
    qpayFees,
    netProfit: totalRevenue - platformFees - qpayFees,
      monkSalaries,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ═══════════════════════════════════════
// SHOP — БҮТЭЭГДЭХҮҮН
// ═══════════════════════════════════════

app.get('/api/shop/products', async (req, res) => {
  try {
    const { category } = req.query;
    const q = { isActive: true };
    if (category && category !== 'Бүгд') q.category = category;
    const products = await Product.find(q).sort({ createdAt: -1 });
    res.json(products.map((p) => productJson(p)));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/shop/products/:id', async (req, res) => {
  try {
    const p = await Product.findById(req.params.id);
    if (!p || !p.isActive) return res.status(404).json({ error: 'Not found' });
    res.json(productJson(p));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/products', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const { name, description, price, image, category, stock } = req.body;
    if (!name || price == null) return res.status(400).json({ error: 'name, price заавал' });
    if (Number(price) < 0) return res.status(400).json({ error: 'Үнэ сөрөг байж болохгүй' });
    if (stock != null && Number(stock) < 0) {
      return res.status(400).json({ error: 'Үлдэгдэл сөрөг байж болохгүй' });
    }
    const p = await Product.create({
      name,
      description,
      price: Number(price),
      image,
      category,
      stock: Number(stock) || 0,
    });
    res.status(201).json(productJson(p));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/admin/products/:id', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const { name, description, price, image, category, stock, isActive } = req.body;
    const updates = {};
    if (price != null) {
      if (Number(price) < 0) return res.status(400).json({ error: 'Үнэ сөрөг байж болохгүй' });
      updates.price = Number(price);
    }
    if (stock != null) {
      if (Number(stock) < 0) return res.status(400).json({ error: 'Үлдэгдэл сөрөг байж болохгүй' });
      updates.stock = Number(stock);
    }
    if (name != null) updates.name = name;
    if (description != null) updates.description = description;
    if (image != null) updates.image = image;
    if (category != null) updates.category = category;
    if (isActive != null) updates.isActive = isActive;
    const p = await Product.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!p) return res.status(404).json({ error: 'Not found' });
    res.json(productJson(p));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/admin/products/:id', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    await Product.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/products', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const products = await Product.find({}).sort({ createdAt: -1 });
    res.json(products.map((p) => productJson(p)));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ═══════════════════════════════════════
// SHOP — ЗАХИАЛГА
// ═══════════════════════════════════════

app.post('/api/shop/orders', authRequired, async (req, res) => {
  try {
    const { items, address, phone } = req.body;
    if (!items?.length) return res.status(400).json({ error: 'items хоосон' });

    const productIds = items.map((i) => i.productId);
    const products = await Product.find({ _id: { $in: productIds }, isActive: true });
    const productMap = Object.fromEntries(products.map((p) => [p._id.toString(), p]));

    let totalAmount = 0;
    const orderItems = items.map((item) => {
      const p = productMap[item.productId];
      if (!p) throw new Error(`Бүтээгдэхүүн олдсонгүй: ${item.productId}`);
      const qty = Number(item.quantity) || 1;
      if (qty > (p.stock ?? 0)) {
        throw new Error(`Үлдэгдэл хүрэлцэхгүй: ${p.name}`);
      }
      totalAmount += p.price * qty;
      return {
        productId: p._id,
        name: p.name,
        price: p.price,
        quantity: qty,
        image: p.image,
      };
    });

    const order = await Order.create({
      userId: req.user._id,
      items: orderItems,
      totalAmount,
      address: address || '',
      phone: phone || '',
    });

    if (!process.env.QPAY_USERNAME) {
      order.paid = true;
      order.status = 'paid';
      await order.save();
      await markShopOrderPaid(order._id);
      return res.status(201).json({ order: orderJson(order), dev: true });
    }

    const invoiceId = `SHOP-${uuidv4().slice(0, 8)}`;
    order.invoiceId = invoiceId;
    await order.save();

    await Payment.create({
      userId: req.user._id,
      invoiceId,
      amount: totalAmount,
      type: 'shop_order',
      orderId: order._id,
      paid: false,
      method: 'qpay',
    });

    const payment = await Payment.findOne({
      orderId: order._id,
      type: 'shop_order',
      paid: false,
    }).sort({ createdAt: -1 });

    const description = `Gevabal дэлгүүр — ${orderItems.length} бараа`;
    const qpayPayload = await issueQPayForPayment(payment, description);

    res.status(201).json({
      order: orderJson(order),
      ...qpayPayload,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/shop/orders/:id/qpay', authRequired, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: 'Not found' });
    if (order.userId?.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }
    if (order.paid) return res.status(400).json({ error: 'Already paid' });

    if (req.body?.regenerate) {
      const oldPayments = await Payment.find({
        orderId: order._id,
        type: 'shop_order',
        paid: false,
      });
      for (const p of oldPayments) {
        if (p.qpayInvoiceId) await cancelQPayInvoice(p.qpayInvoiceId);
      }
      await Payment.deleteMany({
        orderId: order._id,
        type: 'shop_order',
        paid: false,
      });
    }

    let payment = await Payment.findOne({
      orderId: order._id,
      type: 'shop_order',
      paid: false,
    }).sort({ createdAt: -1 });

    if (!payment) {
      const invoiceId = `SHOP-${uuidv4().slice(0, 8)}`;
      order.invoiceId = invoiceId;
      await order.save();
      payment = await Payment.create({
        userId: req.user._id,
        invoiceId,
        amount: order.totalAmount,
        type: 'shop_order',
        orderId: order._id,
        paid: false,
        method: 'qpay',
      });
    }

    const description = `Gevabal дэлгүүр — ${order.items?.length || 0} бараа`;
    if (!payment.qpayInvoiceId || !payment.qrImage) {
      const payload = await issueQPayForPayment(payment, description);
      return res.json(payload);
    }

    res.json(paymentQPayPayload(payment));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/shop/orders/:id/check', authRequired, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: 'Not found' });

    const isOwner = order.userId?.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ error: 'Эрх байхгүй' });
    }

    if (order.paid) return res.json({ paid: true, status: order.status });

    const payment = await Payment.findOne({
      orderId: order._id,
      type: 'shop_order',
      paid: false,
    }).sort({ createdAt: -1 });

    if (payment) {
      await syncQPayPaymentStatus(payment);
      const freshOrder = await Order.findById(order._id);
      if (freshOrder?.paid) {
        return res.json({ paid: true, status: freshOrder.status });
      }
    }

    res.json({ paid: false, status: order.status });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/shop/orders', authRequired, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user._id }).sort({ createdAt: -1 });
    res.json(orders.map((o) => orderJson(o)));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/orders', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
    const orders = await Order.find({}).sort({ createdAt: -1 }).limit(100);
    const userIds = [...new Set(orders.map((o) => o.userId?.toString()).filter(Boolean))];
    const users = await User.find({ _id: { $in: userIds } }, 'name').lean();
    const userMap = Object.fromEntries(users.map((u) => [u._id.toString(), u.name]));
    res.json(
      orders.map((o) => ({
        ...orderJson(o),
        userName: userMap[o.userId?.toString()] ?? '',
      })),
    );
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/admin/orders/:id/status', authRequired, adminRequired, async (req, res) => {
  try {
    const { status } = req.body;
    const valid = ['pending', 'paid', 'shipped', 'delivered', 'cancelled'];
    if (!valid.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: 'Not found' });
    order.status = status;
    if (status === 'paid' && !order.paid) {
      order.paid = true;
      await order.save();
      await markShopOrderPaid(order._id);
    } else {
      await order.save();
    }
    res.json(orderJson(order));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/health', (_, res) => {
  res.json({
    ok: true,
    imageStorage: isCloudinaryConfigured() ? 'cloudinary' : 'local',
  });
});

async function triggerTestIncomingCall(clientEmail, monkQuery = 'Buyntsog') {
  const client = await User.findOne({ email: clientEmail.toLowerCase() });
  if (!client) {
    const err = new Error('Client not found');
    err.status = 404;
    throw err;
  }

  const monk = await Monk.findOne({
    $or: [
      { 'name.mn': new RegExp(monkQuery, 'i') },
      { 'name.en': new RegExp(monkQuery, 'i') },
    ],
  });
  if (!monk) {
    const err = new Error('Monk not found');
    err.status = 404;
    throw err;
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
  } else {
    await Booking.findByIdAndUpdate(booking._id, { date: today, slot });
  }

  const bookingId = booking._id.toString();
  const payload = {
    callerName: monkName,
    callerImage: monk.image || '',
    bookingId,
    recipientRole: 'client',
  };

  if (process.env.NODE_ENV !== 'production') {
    pendingTestCalls.set(client._id.toString(), payload);
  }

  let pushed = false;
  let pushError = null;
  const notifyResult = await notifyIncomingCall(client, payload);
  pushed = notifyResult.pushed;
  if (!pushed) {
    pushError = client.fcmToken
      ? 'FCM send failed'
      : 'FCM token байхгүй — TestFlight дээр апп нээгээд notification зөвшөөрнө үү';
  }

  return {
    ok: true,
    bookingId,
    clientEmail: client.email,
    monkName,
    pushed,
    hasFcmToken: Boolean(client.fcmToken),
    pushError,
    polled: process.env.NODE_ENV !== 'production',
  };
}

app.post('/api/admin/test-incoming-call', authRequired, adminRequired, async (req, res) => {
  try {
    const clientEmail = (req.body?.clientEmail || '').toLowerCase();
    const monkName = req.body?.monkName || 'Buyntsog';
    if (!clientEmail) {
      return res.status(400).json({ error: 'clientEmail required' });
    }
    const result = await triggerTestIncomingCall(clientEmail, monkName);
    res.json(result);
  } catch (e) {
    res.status(e.status || 500).json({ error: e.message });
  }
});

app.post('/api/admin/test-notification', authRequired, adminRequired, async (req, res) => {
  try {
    const email = (req.body?.email || '').toLowerCase();
    const type = req.body?.type || 'legal';
    const title = req.body?.title || 'Gevabal мэдэгдэл';
    const body = req.body?.body || 'Тест мэдэгдэл';
    const actionPath = req.body?.actionPath || '/profile/terms';

    if (!email) return res.status(400).json({ error: 'email required' });

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: 'User not found' });

    let result;
    if (type === 'legal') {
      result = await notifyLegalUpdate(user, { title, body, actionPath });
    } else if (type === 'promo') {
      result = await notifyPromo(user, { title, body, actionPath });
    } else {
      result = await notifyUser(user, {
        category: type,
        title,
        body,
        type: type === 'system' ? 'system' : type,
        actionPath,
        pushData: { type: 'app_notification', actionPath },
      });
    }

    res.json({
      ok: true,
      email,
      saved: result.saved,
      pushed: result.pushed,
      hasFcmToken: Boolean(user.fcmToken),
      notification: result.notification,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/notifications/broadcast', authRequired, adminRequired, async (req, res) => {
  try {
    const {
      title,
      body,
      type = 'legal',
      actionPath = '/profile/terms',
      role = 'client',
    } = req.body || {};

    if (!title || !body) {
      return res.status(400).json({ error: 'title and body required' });
    }

    const q = { isActive: { $ne: false } };
    if (role && role !== 'all') q.role = role;

    const users = await User.find(q);
    let saved = 0;
    let pushed = 0;

    for (const user of users) {
      let result;
      if (type === 'legal') {
        result = await notifyLegalUpdate(user, { title, body, actionPath });
      } else if (type === 'promo') {
        result = await notifyPromo(user, { title, body, actionPath });
      } else {
        result = await notifyUser(user, {
          category: type,
          title,
          body,
          type,
          actionPath,
          pushData: { type: 'app_notification', actionPath },
        });
      }
      if (result.saved) saved += 1;
      if (result.pushed) pushed += 1;
    }

    res.json({ ok: true, total: users.length, saved, pushed });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

if (process.env.NODE_ENV !== 'production') {
  app.post('/api/dev/test-push', async (req, res) => {
    try {
      const email = (req.body?.email || 'feitanfeitan61@gmail.com').toLowerCase();
      const title = req.body?.title || 'Gevabal тест';
      const body = req.body?.body || 'Push notification амжилттай ирлээ!';

      const user = await User.findOne({ email });
      if (!user) return res.status(404).json({ error: 'User not found' });

      const result = await notifyLegalUpdate(user, {
        title,
        body,
        actionPath: req.body?.actionPath || '/profile/terms',
      });

      res.json({
        ok: true,
        email,
        saved: result.saved,
        pushed: result.pushed,
        hasFcmToken: Boolean(user.fcmToken),
        notification: result.notification,
      });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  app.post('/api/dev/test-incoming-call', async (req, res) => {
    try {
      const clientEmail = (req.body?.clientEmail || '').toLowerCase();
      const monkQuery = req.body?.monkName || 'Buyntsog';
      const result = await triggerTestIncomingCall(clientEmail, monkQuery);
      res.json(result);
    } catch (e) {
      res.status(e.status || 500).json({ error: e.message });
    }
  });

  app.get('/api/dev/incoming-call-pending', authRequired, (req, res) => {
    const userId = req.user._id.toString();
    const pending = pendingTestCalls.get(userId);
    if (pending) {
      pendingTestCalls.delete(userId);
      return res.json(pending);
    }
    res.json(null);
  });
}

async function processCallTimeReminders() {
  try {
    const today = todayDateStr();
    const nowMin = currentTimeMinutes();

    const bookings = await Booking.find({
      status: 'confirmed',
      paid: true,
      callReminderSent: { $ne: true },
      date: { $regex: `^${today}` },
    }).lean();

    for (const booking of bookings) {
      const slotMin = slotToMinutes(booking.slot || '00:00');
      if (nowMin < slotMin || nowMin >= slotMin + 5) continue;

      const monk = await Monk.findById(booking.monkId).lean();
      const client = await User.findById(booking.clientId).lean();
      const monkUser = monk?.userId
          ? await User.findById(monk.userId).lean()
          : null;

      const monkName = monk?.name?.mn ?? monk?.name?.en ?? 'Лам';
      const clientName = client?.name ?? 'Хэрэглэгч';
      const bookingId = booking._id.toString();

      if (client) {
        await notifyCallTime(client, {
          peerName: monkName,
          peerImage: monk?.image ?? '',
          bookingId,
          recipientRole: 'client',
        });
      }
      if (monkUser) {
        await notifyCallTime(monkUser, {
          peerName: clientName,
          peerImage: client?.avatar ?? '',
          bookingId,
          recipientRole: 'monk',
        });
      }

      await Booking.findByIdAndUpdate(booking._id, { callReminderSent: true });
    }
  } catch (e) {
    console.warn('Call reminder алдаа:', e.message);
  }
}

async function start() {
  await connectDb();
  await ensureMonkCategories();
  setInterval(processCallTimeReminders, 60_000);
  processCallTimeReminders();
  app.listen(PORT, () => {
    console.log(`Sacred API running on http://localhost:${PORT}/api`);
  });
}

start().catch((e) => {
  console.error(e);
  process.exit(1);
});

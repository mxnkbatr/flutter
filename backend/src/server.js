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
} from './db.js';
import { authRequired, signToken } from './middleware/auth.js';
import {
  DEFAULT_SERVICES,
  DEFAULT_WEEKLY_SCHEDULE,
  getScheduleOverview,
  getSlotsForDate,
} from './scheduleUtils.js';
import { ensureUploadsDir, uploadsRoot, saveBase64Image } from './uploadUtils.js';

const app = express();
const PORT = process.env.PORT || 3000;

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
    isOnline: o.isOnline,
    startingPrice: o.startingPrice,
    status: o.status,
  };
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
    ...extra,
  };
}

function userJson(u) {
  return {
    id: u._id.toString(),
    _id: u._id.toString(),
    email: u.email,
    name: u.name,
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

    const subfolder = folder === 'monks' ? 'monks' : 'monks';
    const relativePath = saveBase64Image(image, subfolder);
    const base = `${req.protocol}://${req.get('host')}`;
    res.json({ url: `${base}${relativePath}`, path: relativePath });
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
    const token = signToken(user);
    res.json({ token, user: userJson(user) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/auth/me', authRequired, (req, res) => {
  res.json(userJson(req.user));
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
    else monks.sort((a, b) => (b.rating || 0) - (a.rating || 0));

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
    const { monkId, serviceId, date, slot, amount, discountPercent } = req.body;
    const monk = await Monk.findById(monkId);
    if (!monk) return res.status(404).json({ error: 'Monk not found' });
    if (monk.status === 'blocked') {
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

    const svcIdx = serviceId?.split('_svc_')[1];
    const service = svcIdx != null ? monk.services[Number(svcIdx)] : monk.services[0];

    const booking = await Booking.create({
      clientId: req.user._id,
      monkId: monk._id,
      serviceId,
      serviceName: service?.name || 'Үйлчилгээ',
      date: date?.slice(0, 10),
      slot,
      amount,
      discountPercent: discountPercent || 0,
      status: 'pending',
      paid: false,
    });

    res.json({ bookingId: booking._id.toString(), id: booking._id.toString() });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/api/bookings/:id/confirm', authRequired, async (req, res) => {
  await Booking.findByIdAndUpdate(req.params.id, { status: 'confirmed' });
  res.json({ ok: true });
});

app.put('/api/bookings/:id/cancel', authRequired, async (req, res) => {
  await Booking.findByIdAndUpdate(req.params.id, { status: 'cancelled' });
  res.json({ ok: true });
});

app.put('/api/bookings/:id/complete', authRequired, async (req, res) => {
  await Booking.findByIdAndUpdate(req.params.id, { status: 'completed' });
  res.json({ ok: true });
});

// ─── Payment / QPay (mock + real hook) ───
function fakeQrBase64(amount) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect fill="#fff" width="200" height="200"/><text x="100" y="100" text-anchor="middle" font-size="14">QPay ₮${amount}</text></svg>`;
  return Buffer.from(svg).toString('base64');
}

app.post('/api/payment/qpay/create', authRequired, async (req, res) => {
  try {
    const { bookingId, amount } = req.body;
    const invoiceId = `INV-${uuidv4().slice(0, 8)}`;
    await Payment.create({
      invoiceId,
      type: 'booking',
      bookingId,
      userId: req.user._id,
      amount,
      paid: false,
    });
    res.json({
      invoiceId,
      amount,
      qrImage: fakeQrBase64(amount),
      urls: [
        { name: 'Khan Bank', link: 'https://qpay.mn', logo: null },
        { name: 'Golomt', link: 'https://qpay.mn', logo: null },
      ],
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/payment/qpay/check/:invoiceId', authRequired, async (req, res) => {
  const payment = await Payment.findOne({ invoiceId: req.params.invoiceId });
  if (!payment) return res.status(404).json({ error: 'Not found' });

  // Auto-simulate paid after 15s in dev (no QPay credentials)
  if (!payment.paid && !process.env.QPAY_USERNAME) {
    const age = Date.now() - payment.createdAt.getTime();
    if (age > 15000) {
      payment.paid = true;
      payment.paidAt = new Date();
      await payment.save();
      if (payment.bookingId) {
        await Booking.findByIdAndUpdate(payment.bookingId, { paid: true, status: 'confirmed' });
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
  }

  res.json({ paid: payment.paid });
});

// Dev: manually mark paid
app.post('/api/payment/qpay/simulate/:invoiceId', authRequired, async (req, res) => {
  const payment = await Payment.findOne({ invoiceId: req.params.invoiceId });
  if (!payment) return res.status(404).json({ error: 'Not found' });
  payment.paid = true;
  payment.paidAt = new Date();
  await payment.save();
  if (payment.bookingId) {
    await Booking.findByIdAndUpdate(payment.bookingId, { paid: true, status: 'confirmed' });
  }
  res.json({ paid: true });
});

// ─── LiveKit ───
app.get('/api/livekit', authRequired, async (req, res) => {
  try {
    const room = req.query.room || 'default';
    const username = req.query.username || req.user.name || 'user';
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

    res.json({ token: await at.toJwt(), wsUrl, url: wsUrl });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Subscription ───
const TIER_PRICES = { premium: 9900, vip: 29900 };

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
  const { fcmToken, name } = req.body;
  if (fcmToken) req.user.fcmToken = fcmToken;
  if (name) req.user.name = name;
  await req.user.save();
  res.json(userJson(req.user));
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
  if (!req.user.monkProfileId) return res.status(403).json({ error: 'Not a monk' });
  await Monk.findByIdAndUpdate(req.user.monkProfileId, {
    isAvailable: req.body.isAvailable,
  });
  res.json({ ok: true });
});

app.get('/api/monk/schedule', authRequired, async (req, res) => {
  const monk = await Monk.findById(req.user.monkProfileId);
  res.json({ days: monk?.schedule || [] });
});

app.put('/api/monk/schedule', authRequired, async (req, res) => {
  if (!req.user.monkProfileId) return res.status(403).json({ error: 'Not a monk' });
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
    if (!req.user.monkProfileId) return res.status(403).json({ error: 'Not a monk' });
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
    if (!req.user.monkProfileId) return res.status(403).json({ error: 'Not a monk' });
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
  const { text } = req.body;
  const msg = await Message.create({
    conversationId: req.params.id,
    senderId: req.user._id,
    text,
  });
  await Conversation.findByIdAndUpdate(req.params.id, {
    lastMessage: text,
    lastMessageAt: new Date(),
  });
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
  const bookings = await Booking.find({ paid: true });
  const totalRevenue = bookings.reduce((s, b) => s + (b.amount || 0), 0);
  const monks = await Monk.find();
  const users = await User.find({ role: 'client' });
  const pending = monks.filter((m) => m.status === 'pending');

  res.json({
    totalRevenue,
    totalBookings: bookings.length,
    bookingsGrowth: 8.5,
    activeMonks: monks.filter((m) => m.status === 'active').length,
    pendingMonks: pending.length,
    totalUsers: users.length,
    newUsersThisWeek: 5,
    monthlyRevenue: [
      { label: '1-р', amount: Math.round(totalRevenue * 0.1) },
      { label: '2-р', amount: Math.round(totalRevenue * 0.12) },
      { label: '3-р', amount: Math.round(totalRevenue * 0.15) },
      { label: '4-р', amount: Math.round(totalRevenue * 0.18) },
      { label: '5-р', amount: Math.round(totalRevenue * 0.2) },
      { label: '6-р', amount: Math.round(totalRevenue * 0.25) },
    ],
    pendingMonksList: pending.map(monkJson),
    recentBookings: bookings.slice(-5).reverse().map((b) =>
      bookingJson(b, { clientName: '', monkName: '', serviceName: b.serviceName, amount: b.amount }),
    ),
  });
});

app.get('/api/admin/monks', authRequired, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
  const status = req.query.status || 'all';
  let q = {};
  if (status !== 'all') q.status = status;
  const monks = await Monk.find(q);
  res.json(monks.map(monkJson));
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

    const { name, temple, bio, categories, services, schedule, status, title, image } =
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

app.delete('/api/admin/monks/:id', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const monk = await Monk.findById(req.params.id);
    if (!monk) return res.status(404).json({ error: 'Monk not found' });

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

app.post('/api/admin/monks/:id/approve', authRequired, async (req, res) => {
  await Monk.findByIdAndUpdate(req.params.id, { status: 'active' });
  res.json({ ok: true });
});

app.post('/api/admin/monks/:id/block', authRequired, async (req, res) => {
  await Monk.findByIdAndUpdate(req.params.id, { status: 'blocked' });
  res.json({ ok: true });
});

app.get('/api/admin/users', authRequired, async (req, res) => {
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
  let q = {};
  if (req.query.status && req.query.status !== 'all') q.status = req.query.status;
  const bookings = await Booking.find(q).sort({ createdAt: -1 }).limit(50);
  res.json(bookings.map((b) => bookingJson(b, { clientName: '', monkName: '', serviceName: b.serviceName })));
});

app.get('/api/admin/finance', authRequired, async (req, res) => {
  const month = req.query.month || new Date().toISOString().slice(0, 7);
  const bookings = await Booking.find({ paid: true, date: { $regex: `^${month}` } });
  const totalRevenue = bookings.reduce((s, b) => s + (b.amount || 0), 0);
  const platformFees = Math.round(totalRevenue * 0.2);
  const qpayFees = Math.round(totalRevenue * 0.015);
  res.json({
    month,
    totalRevenue,
    platformFees,
    qpayFees,
    netProfit: totalRevenue - platformFees - qpayFees,
    monkSalaries: [],
  });
});

app.get('/api/health', (_, res) => res.json({ ok: true }));

async function start() {
  await connectDb();
  app.listen(PORT, () => {
    console.log(`Sacred API running on http://localhost:${PORT}/api`);
  });
}

start().catch((e) => {
  console.error(e);
  process.exit(1);
});

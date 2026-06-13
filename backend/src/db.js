import mongoose from 'mongoose';

export async function connectDb() {
  const uri = process.env.MONGODB_URI;
  const dbName = process.env.MONGO_DB || 'Buddha';
  if (!uri) throw new Error('MONGODB_URI is required');

  await mongoose.connect(uri, { dbName });
  console.log(`MongoDB connected (${dbName})`);
}

const serviceSchema = new mongoose.Schema({
  name: String,
  description: String,
  durationMinutes: Number,
  price: Number,
  category: String,
});

const scheduleDaySchema = new mongoose.Schema(
  {
    date: String,
    slots: [String],
    name: String,
    day: String,
    active: Boolean,
    isActive: Boolean,
    start: String,
    end: String,
  },
  { _id: false },
);

const monkSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    name: { type: Map, of: String, default: () => ({ mn: '', en: '' }) },
    title: { type: Map, of: String },
    image: String,
    temple: String,
    bio: String,
    categories: [String],
    rating: { type: Number, default: 4.8 },
    reviewCount: { type: Number, default: 0 },
    isAvailable: { type: Boolean, default: true },
    isSpecial: { type: Boolean, default: false },
    isVip: { type: Boolean, default: false },
    isOnline: { type: Boolean, default: false },
    status: { type: String, default: 'active' },
    startingPrice: Number,
    services: [serviceSchema],
    schedule: [scheduleDaySchema],
  },
  { timestamps: true },
);

const userSchema = new mongoose.Schema(
  {
    email: { type: String, unique: true, lowercase: true },
    password: String,
    name: String,
    role: { type: String, default: 'client' },
    tier: { type: String, default: 'free' },
    tierExpiresAt: Date,
    fcmToken: String,
    monkProfileId: { type: mongoose.Schema.Types.ObjectId, ref: 'Monk' },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true },
);

const bookingSchema = new mongoose.Schema(
  {
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    monkId: { type: mongoose.Schema.Types.ObjectId, ref: 'Monk' },
    serviceId: String,
    serviceName: String,
    date: String,
    slot: String,
    amount: Number,
    discountPercent: { type: Number, default: 0 },
    status: { type: String, default: 'pending' },
    paid: { type: Boolean, default: false },
    approvedAt: Date,
    approvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    bankTransferPending: { type: Boolean, default: false },
  },
  { timestamps: true },
);

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, default: '' },
    price: { type: Number, required: true },
    image: { type: String, default: '' },
    category: { type: String, default: 'Бусад' },
    stock: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true },
);

const orderSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    items: [
      {
        productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
        name: String,
        price: Number,
        quantity: { type: Number, default: 1 },
        image: String,
      },
    ],
    totalAmount: { type: Number, required: true },
    status: { type: String, default: 'pending' },
    invoiceId: { type: String, default: '' },
    paid: { type: Boolean, default: false },
    address: { type: String, default: '' },
    phone: { type: String, default: '' },
  },
  { timestamps: true },
);

const paymentSchema = new mongoose.Schema(
  {
    invoiceId: { type: String, unique: true },
    type: { type: String, default: 'booking' },
    bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking' },
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    tier: String,
    months: Number,
    amount: Number,
    method: { type: String, default: 'qpay' },
    paid: { type: Boolean, default: false },
    paidAt: Date,
  },
  { timestamps: true },
);

const conversationSchema = new mongoose.Schema(
  {
    clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    monkId: { type: mongoose.Schema.Types.ObjectId, ref: 'Monk' },
    monkUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    lastMessage: String,
    lastMessageAt: Date,
  },
  { timestamps: true },
);

const messageSchema = new mongoose.Schema(
  {
    conversationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Conversation' },
    senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    text: String,
  },
  { timestamps: true },
);

const reviewSchema = new mongoose.Schema({
  monkId: { type: mongoose.Schema.Types.ObjectId, ref: 'Monk' },
  clientName: String,
  rating: Number,
  comment: String,
  createdAt: { type: Date, default: Date.now },
});

export const User = mongoose.model('User', userSchema);
export const Monk = mongoose.model('Monk', monkSchema);
export const Booking = mongoose.model('Booking', bookingSchema);
export const Payment = mongoose.model('Payment', paymentSchema);
export const Conversation = mongoose.model('Conversation', conversationSchema);
export const Message = mongoose.model('Message', messageSchema);
export const Product = mongoose.model('Product', productSchema);
export const Order = mongoose.model('Order', orderSchema);
export const Review = mongoose.model('Review', reviewSchema);

import { Notification } from './db.js';
import { sendPush } from './push.js';

export const DEFAULT_NOTIFICATION_PREFS = {
  booking: true,
  bookingReminder: true,
  message: true,
  promo: true,
  call: true,
  legal: true,
};

export function prefsForUser(user) {
  const stored = user?.notificationPrefs;
  if (!stored) return { ...DEFAULT_NOTIFICATION_PREFS };
  return {
    booking: stored.booking !== false,
    bookingReminder: stored.bookingReminder !== false,
    message: stored.message !== false,
    promo: stored.promo !== false,
    call: stored.call !== false,
    legal: stored.legal !== false,
  };
}

export function prefKeyForCategory(category) {
  const map = {
    booking: 'booking',
    booking_reminder: 'bookingReminder',
    message: 'message',
    promo: 'promo',
    call: 'call',
    legal: 'legal',
    system: 'promo',
  };
  return map[category] || 'promo';
}

export function shouldNotify(user, category) {
  const prefs = prefsForUser(user);
  const key = prefKeyForCategory(category);
  return prefs[key] !== false;
}

function notificationJson(n) {
  return {
    id: n._id.toString(),
    _id: n._id.toString(),
    title: n.title,
    body: n.body,
    type: n.type,
    category: n.category,
    actionPath: n.actionPath || '',
    refId: n.refId || '',
    isRead: n.isRead === true,
    createdAt: n.createdAt?.toISOString(),
  };
}

export async function notifyUser(
  user,
  {
    category,
    title,
    body,
    type,
    actionPath = '',
    refId = '',
    pushData = {},
    saveInApp = true,
  },
) {
  if (!user?._id) return { saved: false, pushed: false };

  let saved = null;
  if (saveInApp && shouldNotify(user, category)) {
    saved = await Notification.create({
      userId: user._id,
      title,
      body,
      type,
      category,
      actionPath,
      refId,
    });
  }

  if (!shouldNotify(user, category) || !user.fcmToken) {
    return { saved: !!saved, pushed: false, notification: saved ? notificationJson(saved) : null };
  }

  const data = {
    type: pushData.type || type,
    category,
    actionPath,
    refId,
    notificationId: saved?._id?.toString() || '',
    title,
    body,
    ...pushData,
  };

  const pushed = await sendPush(user.fcmToken, { title, body, data });
  return { saved: !!saved, pushed, notification: saved ? notificationJson(saved) : null };
}

export async function notifyBookingStatus(user, { status, monkName, bookingId }) {
  const messages = {
    approved: {
      title: 'Захиалга хүлээн авлаа',
      body: `${monkName} таны захиалгыг хүлээн авлаа. Төлбөр төлж баталгаажуулна уу`,
      actionPath: `/payment/${bookingId}`,
    },
    confirmed: {
      title: 'Захиалга баталгаажлаа',
      body: 'Төлбөр амжилттай. Одоо үйлчилгээнд орох боломжтой',
      actionPath: '/bookings',
    },
    cancelled: {
      title: 'Захиалга цуцлагдлаа',
      body: `${monkName}-тэй захиалга цуцлагдлаа`,
      actionPath: '/bookings',
    },
    completed: {
      title: 'Уулзалт дууслаа',
      body: 'Сэтгэгдэл үлдээхийг хүсвэл апп-аа нээнэ үү',
      actionPath: '/bookings',
    },
  };
  const m = messages[status];
  if (!m) return { saved: false, pushed: false };

  return notifyUser(user, {
    category: 'booking',
    title: m.title,
    body: m.body,
    type: 'booking',
    actionPath: m.actionPath,
    refId: bookingId,
    pushData: { type: 'booking_status', status, bookingId },
  });
}

export async function notifyMessage(user, { senderName, text, conversationId }) {
  return notifyUser(user, {
    category: 'message',
    title: senderName || 'Шинэ мессеж',
    body: text?.slice(0, 100) || '',
    type: 'message',
    actionPath: `/messenger/${conversationId}`,
    refId: conversationId,
    pushData: { type: 'new_message', conversationId },
  });
}

export async function notifyIncomingCall(user, { callerName, callerImage, bookingId, recipientRole }) {
  return notifyUser(user, {
    category: 'call',
    title: 'Дуудлага ирж байна',
    body: `${callerName} видео дуудлага хийж байна`,
    type: 'call',
    actionPath: `/call/${bookingId}?role=${recipientRole || 'client'}`,
    refId: bookingId,
    saveInApp: true,
    pushData: {
      type: 'incoming_call',
      callerName: callerName || '',
      callerImage: callerImage || '',
      bookingId: bookingId || '',
      recipientRole: recipientRole || 'client',
    },
  });
}

export async function notifyCallTime(user, { peerName, peerImage, bookingId, recipientRole }) {
  return notifyUser(user, {
    category: 'booking_reminder',
    title: 'Уулзалтын цаг боллоо',
    body: `${peerName} — одоо видео дуудлагад орох боломжтой`,
    type: 'booking',
    actionPath: `/call/${bookingId}?role=${recipientRole || 'client'}`,
    refId: bookingId,
    pushData: {
      type: 'call_time',
      callerName: peerName || '',
      callerImage: peerImage || '',
      bookingId: bookingId || '',
      recipientRole: recipientRole || 'client',
    },
  });
}

export async function notifyLegalUpdate(user, { title, body, actionPath = '/profile/terms' }) {
  return notifyUser(user, {
    category: 'legal',
    title,
    body,
    type: 'legal',
    actionPath,
    pushData: { type: 'legal_update', actionPath },
  });
}

export async function notifyPromo(user, { title, body, actionPath = '/home' }) {
  return notifyUser(user, {
    category: 'promo',
    title,
    body,
    type: 'promo',
    actionPath,
    pushData: { type: 'promo', actionPath },
  });
}

export { notificationJson };

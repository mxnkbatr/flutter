import admin from 'firebase-admin';
import { getMessaging } from 'firebase-admin/messaging';

let initialized = false;

function ensureInit() {
  if (initialized) return true;
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

  if (!projectId || !clientEmail || !privateKey) {
    console.warn('⚠️  Firebase push тохиргоо дутуу — push notification идэвхгүй');
    return false;
  }

  try {
    admin.initializeApp({
      credential: admin.cert({ projectId, clientEmail, privateKey }),
    });
    initialized = true;
    return true;
  } catch (e) {
    console.error('Firebase admin init алдаа:', e.message);
    return false;
  }
}

/**
 * Нэг хэрэглэгчид push илгээх
 * @param {string} fcmToken
 * @param {{title: string, body: string, data?: Record<string,string>}} payload
 */
export async function sendPush(fcmToken, payload) {
  if (!fcmToken) return false;
  if (!ensureInit()) return false;

  try {
    await getMessaging().send({
      token: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data || {},
      android: { priority: 'high' },
      apns: {
        payload: {
          aps: { sound: 'default', contentAvailable: true },
        },
      },
    });
    return true;
  } catch (e) {
    console.warn('Push илгээхэд алдаа:', e.message);
    return false;
  }
}

/**
 * Дуудлагын мэдэгдэл — incoming_call төрөл
 */
export async function sendIncomingCallPush(fcmToken, { callerName, callerImage, bookingId }) {
  return sendPush(fcmToken, {
    title: 'Дуудлага ирж байна',
    body: `${callerName} видео дуудлага хийж байна`,
    data: {
      type: 'incoming_call',
      callerName: callerName || '',
      callerImage: callerImage || '',
      bookingId: bookingId || '',
    },
  });
}

/**
 * Захиалгын статус мэдэгдэл
 */
export async function sendBookingStatusPush(fcmToken, { status, monkName, bookingId }) {
  const messages = {
    approved: {
      title: 'Захиалга хүлээн авлаа',
      body: `${monkName} таны захиалгыг хүлээн авлаа. Төлбөр төлж баталгаажуулна уу`,
    },
    confirmed: {
      title: 'Захиалга баталгаажлаа',
      body: 'Төлбөр амжилттай. Одоо үйлчилгээнд орох боломжтой',
    },
    cancelled: {
      title: 'Захиалга цуцлагдлаа',
      body: `${monkName}-тэй захиалга цуцлагдлаа`,
    },
    completed: {
      title: 'Уулзалт дууслаа',
      body: 'Сэтгэгдэл үлдээхийг хүсвэл апп-аа нээнэ үү',
    },
  };
  const m = messages[status];
  if (!m) return false;
  return sendPush(fcmToken, {
    ...m,
    data: { type: 'booking_status', status, bookingId: bookingId || '' },
  });
}

/**
 * Шинэ мессеж мэдэгдэл
 */
export async function sendMessagePush(fcmToken, { senderName, text, conversationId }) {
  return sendPush(fcmToken, {
    title: senderName || 'Шинэ мессеж',
    body: text?.slice(0, 100) || '',
    data: { type: 'new_message', conversationId: conversationId || '' },
  });
}

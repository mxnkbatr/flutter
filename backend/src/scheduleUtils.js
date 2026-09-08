import { Booking } from './db.js';
import {
  SLOT_INTERVAL_MINUTES,
  addDaysToDateStr,
  getPastSlotsForDate,
  todayDateStr,
  weekdayIndexUlaanbaatar,
} from './timezoneUtils.js';
import { UNPAID_BOOKING_TTL_MS } from './riskGuards.js';

export const DAY_NAMES = [
  'Ням',
  'Даваа',
  'Мягмар',
  'Лхагва',
  'Пүрэв',
  'Баасан',
  'Бямба',
];

export function generateSlotsFromRange(
  start,
  end,
  intervalMinutes = SLOT_INTERVAL_MINUTES,
) {
  const slots = [];
  const [sh, sm] = start.split(':').map(Number);
  const [eh, em] = end.split(':').map(Number);
  let minutes = sh * 60 + (sm || 0);
  const endMinutes = eh * 60 + (em || 0);
  while (minutes < endMinutes) {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    slots.push(
      `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`,
    );
    minutes += intervalMinutes;
  }
  return slots;
}

function scheduleDays(schedule) {
  if (!schedule) return [];
  if (Array.isArray(schedule)) return schedule;
  if (Array.isArray(schedule.days)) return schedule.days;
  return [];
}

function isUsableDayConfig(day) {
  if (!day || typeof day !== 'object') return false;
  if (day.name || day.day) return true;
  if (typeof day.date === 'string' && day.date.length >= 10) return true;
  return false;
}

/** True when entries are weekday-named (Даваа…) rather than date-keyed. */
export function isWeeklySchedule(days) {
  return days.some((d) => d?.name || d?.day);
}

export function normalizeSchedule(schedule) {
  const days = scheduleDays(schedule);
  if (!days.length || !days.some(isUsableDayConfig)) {
    return DEFAULT_WEEKLY_SCHEDULE;
  }
  return days;
}

export function getWeeklyDayConfig(schedule, dateStr) {
  const days = normalizeSchedule(schedule);
  const dayName = DAY_NAMES[weekdayIndexUlaanbaatar(dateStr)];
  const normalizedDate = dateStr.slice(0, 10);

  if (isWeeklySchedule(days)) {
    return days.find((x) => (x.name || x.day) === dayName) || null;
  }

  // Legacy date-keyed schedules (e.g. 14 fixed days). Exact match only.
  return (
    days.find((x) => x.date?.startsWith(normalizedDate)) || null
  );
}

export function slotsForDayConfig(dayConfig) {
  if (!dayConfig) return [];
  if (dayConfig.slots?.length) return dayConfig.slots;
  if (dayConfig.active === false || dayConfig.isActive === false) return [];
  if (dayConfig.start && dayConfig.end) {
    return generateSlotsFromRange(dayConfig.start, dayConfig.end);
  }
  return [];
}

/**
 * Resolve day config for booking. Date-keyed schedules that only cover a past
 * window fall back to the default Mon–Fri weekly hours so clients can still book.
 */
export function resolveDayConfig(schedule, dateStr) {
  const normalizedDate = dateStr.slice(0, 10);
  const fromMonk = getWeeklyDayConfig(schedule, normalizedDate);
  if (fromMonk) return fromMonk;

  const days = normalizeSchedule(schedule);
  // Missing date in a date-keyed calendar → use default weekly template.
  if (!isWeeklySchedule(days)) {
    return getWeeklyDayConfig(DEFAULT_WEEKLY_SCHEDULE, normalizedDate);
  }
  // Weekly schedule with that weekday missing / inactive → no slots.
  return null;
}

export async function getSlotsForDate(monkId, schedule, dateStr) {
  const normalizedDate = dateStr.slice(0, 10);
  const dayConfig = resolveDayConfig(schedule, normalizedDate);
  let slots = slotsForDayConfig(dayConfig);

  // Soft-release abandoned unpaid holds before computing availability.
  const holdCutoff = new Date(Date.now() - UNPAID_BOOKING_TTL_MS);
  await Booking.updateMany(
    {
      monkId,
      date: normalizedDate,
      paid: false,
      status: { $in: ['pending', 'approved'] },
      createdAt: { $lt: holdCutoff },
    },
    { $set: { status: 'cancelled' } },
  );

  const bookings = await Booking.find({
    monkId,
    date: normalizedDate,
    status: { $nin: ['cancelled'] },
  });
  const bookedSlots = bookings.map((b) => b.slot).filter(Boolean);
  // Keep confirmed bookings visible even if the weekday was later disabled.
  for (const slot of bookedSlots) {
    if (!slots.includes(slot)) slots = [...slots, slot];
  }
  const pastSlots = getPastSlotsForDate(normalizedDate, slots);

  return { date: normalizedDate, slots, bookedSlots, pastSlots };
}

/**
 * Fast month overview: 1 soft-release + 1 booking query for the whole window
 * (instead of 60 sequential DB round-trips).
 */
export async function getScheduleOverview(monkId, schedule, dayCount = 60) {
  const today = todayDateStr();
  const endDate = addDaysToDateStr(today, dayCount - 1);
  const dates = [];
  for (let i = 0; i < dayCount; i++) {
    dates.push(addDaysToDateStr(today, i));
  }

  const holdCutoff = new Date(Date.now() - UNPAID_BOOKING_TTL_MS);
  await Booking.updateMany(
    {
      monkId,
      date: { $gte: today, $lte: endDate },
      paid: false,
      status: { $in: ['pending', 'approved'] },
      createdAt: { $lt: holdCutoff },
    },
    { $set: { status: 'cancelled' } },
  );

  const bookings = await Booking.find({
    monkId,
    date: { $gte: today, $lte: endDate },
    status: { $nin: ['cancelled'] },
  })
    .select('date slot')
    .lean();

  const bookedByDate = new Map();
  for (const b of bookings) {
    const d = String(b.date || '').slice(0, 10);
    if (!d || !b.slot) continue;
    if (!bookedByDate.has(d)) bookedByDate.set(d, []);
    bookedByDate.get(d).push(b.slot);
  }

  return dates.map((dateStr) => {
    const dayConfig = resolveDayConfig(schedule, dateStr);
    let slots = slotsForDayConfig(dayConfig);
    const bookedSlots = bookedByDate.get(dateStr) || [];
    // Keep booked days visible when weekday was later disabled.
    for (const slot of bookedSlots) {
      if (!slots.includes(slot)) slots = [...slots, slot];
    }
    const pastSlots = getPastSlotsForDate(dateStr, slots);
    const availableSlots = slots.filter(
      (s) => !bookedSlots.includes(s) && !pastSlots.includes(s),
    );
    return {
      date: dateStr,
      isAvailable: availableSlots.length > 0,
      isBooked: slots.length > 0 && availableSlots.length === 0,
      slotCount: availableSlots.length,
    };
  });
}

export const DEFAULT_WEEKLY_SCHEDULE = [
  { name: 'Даваа', active: true, start: '09:00', end: '18:00' },
  { name: 'Мягмар', active: true, start: '09:00', end: '18:00' },
  { name: 'Лхагва', active: true, start: '09:00', end: '18:00' },
  { name: 'Пүрэв', active: true, start: '09:00', end: '18:00' },
  { name: 'Баасан', active: true, start: '09:00', end: '18:00' },
  { name: 'Бямба', active: false, start: '09:00', end: '18:00' },
  { name: 'Ням', active: false, start: '09:00', end: '18:00' },
];

export const DEFAULT_SERVICES = [
  {
    name: 'Ерөөл',
    description: 'Ерөөл өргөх үйлчилгээ',
    durationMinutes: 30,
    price: 50000,
    category: 'Ерөөл',
  },
  {
    name: 'Чулуут цаг',
    description: 'Чулуут цагийн үйлчилгээ',
    durationMinutes: 30,
    price: 80000,
    category: 'Тахилга',
  },
];

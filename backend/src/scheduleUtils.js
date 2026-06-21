import { Booking } from './db.js';
import {
  SLOT_INTERVAL_MINUTES,
  addDaysToDateStr,
  getPastSlotsForDate,
  todayDateStr,
  weekdayIndexUlaanbaatar,
} from './timezoneUtils.js';

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

export function normalizeSchedule(schedule) {
  if (!schedule || (Array.isArray(schedule) && schedule.length === 0)) {
    return DEFAULT_WEEKLY_SCHEDULE;
  }
  if (Array.isArray(schedule)) return schedule;
  return schedule.days || DEFAULT_WEEKLY_SCHEDULE;
}

export function getWeeklyDayConfig(schedule, dateStr) {
  const days = normalizeSchedule(schedule);
  const dayName = DAY_NAMES[weekdayIndexUlaanbaatar(dateStr)];

  if (days.length && (days[0]?.name || days[0]?.day)) {
    return days.find((x) => (x.name || x.day) === dayName);
  }

  return days.find((x) => x.date?.startsWith(dateStr.slice(0, 10)));
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

export async function getSlotsForDate(monkId, schedule, dateStr) {
  const normalizedDate = dateStr.slice(0, 10);
  const dayConfig = getWeeklyDayConfig(schedule, normalizedDate);
  const slots = slotsForDayConfig(dayConfig);

  const bookings = await Booking.find({
    monkId,
    date: normalizedDate,
    status: { $nin: ['cancelled'] },
  });
  const bookedSlots = bookings.map((b) => b.slot).filter(Boolean);
  const pastSlots = getPastSlotsForDate(normalizedDate, slots);

  return { date: normalizedDate, slots, bookedSlots, pastSlots };
}

export async function getScheduleOverview(monkId, schedule, dayCount = 14) {
  const result = [];
  const today = todayDateStr();

  for (let i = 0; i < dayCount; i++) {
    const dateStr = addDaysToDateStr(today, i);
    const { slots, bookedSlots, pastSlots } = await getSlotsForDate(
      monkId,
      schedule,
      dateStr,
    );
    const availableSlots = slots.filter(
      (s) => !bookedSlots.includes(s) && !pastSlots.includes(s),
    );
    result.push({
      date: dateStr,
      isAvailable: availableSlots.length > 0,
      isBooked: slots.length > 0 && availableSlots.length === 0,
      slotCount: availableSlots.length,
      slots: availableSlots,
    });
  }

  return result;
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

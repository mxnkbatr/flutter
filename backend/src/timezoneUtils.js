/** Mongolia (Ulaanbaatar) — UTC+8, no DST. */
export const APP_TIMEZONE = 'Asia/Ulaanbaatar';

export const SLOT_INTERVAL_MINUTES = 30;

export function todayDateStr() {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: APP_TIMEZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date());
}

export function slotToMinutes(slot) {
  const [h, m] = slot.split(':').map(Number);
  return h * 60 + (m || 0);
}

export function currentTimeMinutes() {
  const time = new Intl.DateTimeFormat('en-GB', {
    timeZone: APP_TIMEZONE,
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(new Date());
  return slotToMinutes(time);
}

export function isPastSlot(dateStr, slot) {
  if (dateStr.slice(0, 10) !== todayDateStr()) return false;
  return slotToMinutes(slot) < currentTimeMinutes();
}

export function getPastSlotsForDate(dateStr, slots) {
  if (dateStr.slice(0, 10) !== todayDateStr()) return [];
  const nowMin = currentTimeMinutes();
  return slots.filter((s) => slotToMinutes(s) < nowMin);
}

export function weekdayIndexUlaanbaatar(dateStr) {
  const d = new Date(`${dateStr.slice(0, 10)}T12:00:00+08:00`);
  return d.getUTCDay();
}

export function addDaysToDateStr(dateStr, days) {
  const d = new Date(`${dateStr.slice(0, 10)}T00:00:00+08:00`);
  d.setUTCDate(d.getUTCDate() + days);
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, '0');
  const day = String(d.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

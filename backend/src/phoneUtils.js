/** Normalize Mongolian (or intl) phone to digits-only local form when possible. */
export function normalizePhone(input) {
  if (input == null) return '';
  let digits = String(input).replace(/\D/g, '');
  if (digits.startsWith('976') && digits.length > 8) {
    digits = digits.slice(3);
  }
  return digits;
}

/** Valid if 8 digits (MN mobile) or 10–15 international digits. */
export function isValidPhone(input) {
  const phone = normalizePhone(input);
  if (phone.length === 8) return true;
  return phone.length >= 10 && phone.length <= 15;
}

export function looksLikeEmail(input) {
  const s = String(input || '').trim();
  return s.includes('@');
}

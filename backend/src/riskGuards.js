/**
 * Lightweight guards: TTL cleanup, auth rate limit.
 * Keeps inventory + auth abuse under control without external deps.
 */

export const UNPAID_BOOKING_TTL_MS = 20 * 60 * 1000; // 20 min hold
export const UNPAID_ORDER_TTL_MS = 30 * 60 * 1000;

/**
 * In-memory sliding window rate limiter.
 * keyFn(req) → bucket key (e.g. ip + route).
 */
export function createRateLimiter({
  windowMs = 15 * 60 * 1000,
  max = 30,
  keyFn = (req) => req.ip || 'unknown',
  message = 'Хэт олон оролдлого. Түр хүлээнэ үү',
} = {}) {
  const hits = new Map();

  function prune(now) {
    for (const [key, entry] of hits) {
      if (now - entry.start > windowMs) hits.delete(key);
    }
  }

  return function rateLimit(req, res, next) {
    const now = Date.now();
    if (hits.size > 5000) prune(now);

    const key = keyFn(req);
    let entry = hits.get(key);
    if (!entry || now - entry.start > windowMs) {
      entry = { start: now, count: 0 };
      hits.set(key, entry);
    }
    entry.count += 1;
    if (entry.count > max) {
      return res.status(429).json({ error: message });
    }
    return next();
  };
}

export function clientKey(req, suffix = '') {
  const ip = req.headers['x-forwarded-for']?.toString().split(',')[0]?.trim()
    || req.ip
    || 'unknown';
  return `${ip}:${suffix}`;
}

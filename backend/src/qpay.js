const DEFAULT_BASE_URL = 'https://merchant.qpay.mn/v2';

let cachedToken = null;
let tokenExpiresAt = 0;
let cachedRefreshToken = null;

function baseUrl() {
  return (process.env.QPAY_URL || DEFAULT_BASE_URL).replace(/\/$/, '');
}

export function isQPayConfigured() {
  return Boolean(
    process.env.QPAY_USERNAME &&
      process.env.QPAY_PASSWORD &&
      process.env.QPAY_INVOICE_CODE,
  );
}

async function fetchJson(path, options = {}) {
  const res = await fetch(`${baseUrl()}${path}`, options);
  const text = await res.text();
  let body = {};
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = { raw: text };
    }
  }
  if (!res.ok) {
    const msg =
      body.message ||
      body.error ||
      body.error_code ||
      `QPay HTTP ${res.status}`;
    throw new Error(msg);
  }
  return body;
}

async function getAccessToken() {
  if (!isQPayConfigured()) {
    throw new Error('QPay credentials not configured');
  }

  const now = Date.now();
  if (cachedToken && now < tokenExpiresAt - 30_000) {
    return cachedToken;
  }

  if (cachedRefreshToken) {
    try {
      const refreshed = await fetchJson('/auth/refresh', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${cachedRefreshToken}`,
          'Content-Type': 'application/json',
        },
      });
      cachedToken = refreshed.access_token;
      cachedRefreshToken = refreshed.refresh_token || cachedRefreshToken;
      tokenExpiresAt = now + (refreshed.expires_in || 600) * 1000;
      return cachedToken;
    } catch {
      cachedRefreshToken = null;
    }
  }

  const basic = Buffer.from(
    `${process.env.QPAY_USERNAME}:${process.env.QPAY_PASSWORD}`,
  ).toString('base64');

  const auth = await fetchJson('/auth/token', {
    method: 'POST',
    headers: {
      Authorization: `Basic ${basic}`,
      'Content-Type': 'application/json',
    },
  });

  cachedToken = auth.access_token;
  cachedRefreshToken = auth.refresh_token || null;
  tokenExpiresAt = now + (auth.expires_in || 600) * 1000;
  return cachedToken;
}

async function authorizedRequest(path, options = {}) {
  const token = await getAccessToken();
  try {
    return await fetchJson(path, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
        Authorization: `Bearer ${token}`,
      },
    });
  } catch (e) {
    if (String(e.message).includes('401') || /expired|invalid/i.test(e.message)) {
      cachedToken = null;
      tokenExpiresAt = 0;
      const retryToken = await getAccessToken();
      return fetchJson(path, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(options.headers || {}),
          Authorization: `Bearer ${retryToken}`,
        },
      });
    }
    throw e;
  }
}

export async function createInvoice({
  senderInvoiceNo,
  description,
  amount,
  callbackUrl,
}) {
  const roundedAmount = Math.round(amount);
  return authorizedRequest('/invoice', {
    method: 'POST',
    body: JSON.stringify({
      invoice_code: process.env.QPAY_INVOICE_CODE,
      sender_invoice_no: senderInvoiceNo,
      invoice_receiver_code: 'terminal',
      invoice_description: description,
      amount: roundedAmount,
      callback_url: callbackUrl,
      lines: [
        {
          line_description: description || 'Gevabal төлбөр',
          line_quantity: '1',
          line_unit_price: String(roundedAmount),
        },
      ],
    }),
  });
}

export async function checkInvoicePayment(invoiceId) {
  return authorizedRequest('/payment/check', {
    method: 'POST',
    body: JSON.stringify({
      object_type: 'INVOICE',
      object_id: invoiceId,
      offset: { page_number: 1, page_limit: 10 },
    }),
  });
}

export async function cancelInvoice(invoiceId) {
  try {
    await authorizedRequest(`/invoice/${invoiceId}`, { method: 'DELETE' });
  } catch {
    // Ignore cancel failures for expired/paid invoices.
  }
}

export function mapQPayUrls(urls = []) {
  return urls.map((u) => ({
    name: u.name || u.description || 'Bank',
    link: u.link || u.url || '',
    logo: u.logo || null,
  }));
}

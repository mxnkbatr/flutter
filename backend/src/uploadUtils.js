import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { v2 as cloudinary } from 'cloudinary';
import { v4 as uuidv4 } from 'uuid';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const uploadsRoot = path.join(__dirname, '..', 'uploads');

/** Only raster formats safe for display (no SVG/HTML XSS). */
const ALLOWED_IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'webp']);

function envValue(name) {
  const value = process.env[name];
  if (typeof value !== 'string') return '';
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : '';
}

export function isCloudinaryConfigured() {
  const url = envValue('CLOUDINARY_URL');
  if (url) return true;

  return Boolean(
    envValue('CLOUDINARY_CLOUD_NAME') &&
      envValue('CLOUDINARY_API_KEY') &&
      envValue('CLOUDINARY_API_SECRET'),
  );
}

function configureCloudinary() {
  if (!isCloudinaryConfigured()) {
    throw new Error('Cloudinary is not configured');
  }

  const url = envValue('CLOUDINARY_URL');
  if (url) {
    // SDK accepts the cloudinary:// URL string directly.
    cloudinary.config(url);
    return;
  }

  cloudinary.config({
    cloud_name: envValue('CLOUDINARY_CLOUD_NAME'),
    api_key: envValue('CLOUDINARY_API_KEY'),
    api_secret: envValue('CLOUDINARY_API_SECRET'),
    secure: true,
  });
}

function detectImageExt(buffer) {
  if (!buffer || buffer.length < 12) return null;
  const b0 = buffer[0];
  const b1 = buffer[1];
  const b2 = buffer[2];
  const b3 = buffer[3];

  if (b0 === 0xff && b1 === 0xd8 && b2 === 0xff) return 'jpg';
  if (b0 === 0x89 && b1 === 0x50 && b2 === 0x4e && b3 === 0x47) return 'png';
  if (
    buffer.toString('ascii', 0, 4) === 'RIFF' &&
    buffer.toString('ascii', 8, 12) === 'WEBP'
  ) {
    return 'webp';
  }
  // HEIC/HEIF — common from iPhone; Cloudinary can ingest, local cannot.
  if (buffer.toString('ascii', 4, 8) === 'ftyp') {
    const brand = buffer.toString('ascii', 8, 12);
    if (/heic|heif|mif1|msf1/i.test(brand)) return 'heic';
  }
  return null;
}

function normalizeMimeExt(mimePart) {
  let ext = String(mimePart || '').toLowerCase();
  if (ext === 'jpeg' || ext === 'jpg') return 'jpg';
  if (ext === 'svg+xml' || ext === 'svg') return 'svg';
  if (ext === 'heic' || ext === 'heif') return 'heic';
  return ext;
}

/**
 * Accepts data-URL images. Prefers magic-byte detection over declared MIME
 * so phone gallery exports still upload reliably.
 */
export function parseBase64Image(dataUrl) {
  const match = /^data:image\/([a-z0-9+.-]+);base64,(.+)$/i.exec(dataUrl || '');
  if (!match) {
    throw new Error('Invalid image data');
  }

  const declared = normalizeMimeExt(match[1]);
  if (declared === 'svg') {
    throw new Error('SVG зураг зөвшөөрөгдөхгүй');
  }

  const buffer = Buffer.from(match[2], 'base64');
  if (!buffer.length) {
    throw new Error('Зургийн өгөгдөл хоосон байна');
  }
  if (buffer.length > 8 * 1024 * 1024) {
    throw new Error('Image too large (max 8MB)');
  }

  const detected = detectImageExt(buffer);
  let ext = detected || declared;

  // Allow HEIC only when Cloudinary can convert it.
  if (ext === 'heic') {
    if (!isCloudinaryConfigured()) {
      throw new Error('HEIC зураг дэмжигдэхгүй. JPG/PNG сонгоно уу');
    }
    // Cloudinary will convert; store as jpg locally if needed.
    ext = 'jpg';
  }

  if (!ALLOWED_IMAGE_EXTS.has(ext) && ext !== 'jpeg') {
    // Last resort: if bytes look unknown but MIME is allowed raster, trust MIME
    // only when Cloudinary will re-encode.
    if (isCloudinaryConfigured() && ALLOWED_IMAGE_EXTS.has(declared)) {
      ext = declared === 'jpeg' ? 'jpg' : declared;
    } else {
      throw new Error('Зөвхөн JPG, PNG, WEBP зураг оруулна уу');
    }
  }

  if (ext === 'jpeg') ext = 'jpg';

  return { ext, buffer, dataUrl: `data:image/${ext === 'jpg' ? 'jpeg' : ext};base64,${match[2]}` };
}

export function ensureUploadsDir(subfolder = '') {
  const dir = subfolder ? path.join(uploadsRoot, subfolder) : uploadsRoot;
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

export function saveBase64Image(dataUrl, subfolder = 'monks') {
  const { ext, buffer } = parseBase64Image(dataUrl);

  const dir = ensureUploadsDir(subfolder);
  const filename = `${uuidv4()}.${ext}`;
  const filepath = path.join(dir, filename);
  fs.writeFileSync(filepath, buffer);

  return `/uploads/${subfolder}/${filename}`;
}

async function uploadToCloudinary(dataUrl, subfolder = 'monks') {
  const parsed = parseBase64Image(dataUrl);
  configureCloudinary();

  const uploadOptions = {
    folder: `gevabal/${subfolder}`,
    resource_type: 'image',
    // Let Cloudinary normalize format for mobile HEIC/odd MIME.
    format: parsed.ext === 'jpg' ? 'jpg' : parsed.ext,
  };
  const preset = envValue('CLOUDINARY_UPLOAD_PRESET');
  if (preset) {
    uploadOptions.upload_preset = preset;
  }

  const result = await cloudinary.uploader.upload(parsed.dataUrl, uploadOptions);
  if (!result?.secure_url) {
    throw new Error('Cloudinary URL буцаасангүй');
  }
  return result.secure_url;
}

/**
 * Upload base64 image. Returns full HTTPS URL (Cloudinary) or relative /uploads/... path (local).
 * Cloudinary env байхгүй эсвэл upload алдаатай бол local storage руу fallback хийнэ.
 */
export async function uploadBase64Image(dataUrl, subfolder = 'monks') {
  // Validate early so callers get clear errors.
  parseBase64Image(dataUrl);

  if (!isCloudinaryConfigured()) {
    return saveBase64Image(dataUrl, subfolder);
  }

  try {
    return await uploadToCloudinary(dataUrl, subfolder);
  } catch (err) {
    console.warn('Cloudinary upload failed, using local storage:', err?.message || err);
    return saveBase64Image(dataUrl, subfolder);
  }
}

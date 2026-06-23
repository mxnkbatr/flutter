import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { v2 as cloudinary } from 'cloudinary';
import { v4 as uuidv4 } from 'uuid';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const uploadsRoot = path.join(__dirname, '..', 'uploads');

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
    cloudinary.config({ cloudinary_url: url, secure: true });
    return;
  }

  cloudinary.config({
    cloud_name: envValue('CLOUDINARY_CLOUD_NAME'),
    api_key: envValue('CLOUDINARY_API_KEY'),
    api_secret: envValue('CLOUDINARY_API_SECRET'),
    secure: true,
  });
}

function parseBase64Image(dataUrl) {
  const match = /^data:image\/(\w+);base64,(.+)$/.exec(dataUrl || '');
  if (!match) {
    throw new Error('Invalid image data');
  }

  const ext = match[1] === 'jpeg' ? 'jpg' : match[1];
  const buffer = Buffer.from(match[2], 'base64');
  if (buffer.length > 5 * 1024 * 1024) {
    throw new Error('Image too large (max 5MB)');
  }

  return { ext, buffer };
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
  parseBase64Image(dataUrl);
  configureCloudinary();

  const uploadOptions = {
    folder: `gevabal/${subfolder}`,
    resource_type: 'image',
  };
  const preset = envValue('CLOUDINARY_UPLOAD_PRESET');
  if (preset) {
    uploadOptions.upload_preset = preset;
  }

  const result = await cloudinary.uploader.upload(dataUrl, uploadOptions);

  return result.secure_url;
}

/**
 * Upload base64 image. Returns full HTTPS URL (Cloudinary) or relative /uploads/... path (local).
 * Cloudinary env байхгүй эсвэл upload алдаатай бол local storage руу fallback хийнэ.
 */
export async function uploadBase64Image(dataUrl, subfolder = 'monks') {
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

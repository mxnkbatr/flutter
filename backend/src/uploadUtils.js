import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { v2 as cloudinary } from 'cloudinary';
import { v4 as uuidv4 } from 'uuid';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const uploadsRoot = path.join(__dirname, '..', 'uploads');

export function isCloudinaryConfigured() {
  if (process.env.CLOUDINARY_URL) return true;
  return Boolean(
    process.env.CLOUDINARY_CLOUD_NAME &&
      process.env.CLOUDINARY_API_KEY &&
      process.env.CLOUDINARY_API_SECRET,
  );
}

function configureCloudinary() {
  if (process.env.CLOUDINARY_URL) {
    cloudinary.config({ secure: true });
    return;
  }
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
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
  if (process.env.CLOUDINARY_UPLOAD_PRESET) {
    uploadOptions.upload_preset = process.env.CLOUDINARY_UPLOAD_PRESET;
  }

  const result = await cloudinary.uploader.upload(dataUrl, uploadOptions);

  return result.secure_url;
}

/**
 * Upload base64 image. Returns full HTTPS URL (Cloudinary) or relative /uploads/... path (local).
 */
export async function uploadBase64Image(dataUrl, subfolder = 'monks') {
  if (isCloudinaryConfigured()) {
    return uploadToCloudinary(dataUrl, subfolder);
  }
  return saveBase64Image(dataUrl, subfolder);
}

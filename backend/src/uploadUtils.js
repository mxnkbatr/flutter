import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { v4 as uuidv4 } from 'uuid';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const uploadsRoot = path.join(__dirname, '..', 'uploads');

export function ensureUploadsDir(subfolder = '') {
  const dir = subfolder ? path.join(uploadsRoot, subfolder) : uploadsRoot;
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

export function saveBase64Image(dataUrl, subfolder = 'monks') {
  const match = /^data:image\/(\w+);base64,(.+)$/.exec(dataUrl || '');
  if (!match) {
    throw new Error('Invalid image data');
  }

  const ext = match[1] === 'jpeg' ? 'jpg' : match[1];
  const buffer = Buffer.from(match[2], 'base64');
  if (buffer.length > 5 * 1024 * 1024) {
    throw new Error('Image too large (max 5MB)');
  }

  const dir = ensureUploadsDir(subfolder);
  const filename = `${uuidv4()}.${ext}`;
  const filepath = path.join(dir, filename);
  fs.writeFileSync(filepath, buffer);

  return `/uploads/${subfolder}/${filename}`;
}

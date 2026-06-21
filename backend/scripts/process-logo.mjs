import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { PNG } from 'pngjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const logoPath = path.join(__dirname, '../../assets/images/gevabal_logo.png');

function isGoldPixel(r, g, b) {
  // Warm golden emblem — keep these opaque.
  if (r < 70) return false;
  if (r > g && g > b * 0.55 && r - b > 35) return true;
  if (r > 140 && g > 90 && b < 120) return true;
  return false;
}

function isBackgroundSeed(r, g, b) {
  const avg = (r + g + b) / 3;
  const spread = Math.max(r, g, b) - Math.min(r, g, b);

  if (isGoldPixel(r, g, b)) return false;

  // Cream / off-white
  if (r > 215 && g > 205 && b > 175 && spread < 45) return true;
  // Black / near-black
  if (avg < 18 && spread < 20) return true;
  // Neutral light gray fringe
  if (avg > 190 && spread < 28) return true;
  return false;
}

const input = fs.readFileSync(logoPath);
const png = PNG.sync.read(input);
const { width, height } = png;
const visited = new Uint8Array(width * height);
const queue = [];

function idx(x, y) {
  return y * width + x;
}

function pushIfBg(x, y) {
  if (x < 0 || y < 0 || x >= width || y >= height) return;
  const i = idx(x, y);
  if (visited[i]) return;
  const pi = i << 2;
  const r = png.data[pi];
  const g = png.data[pi + 1];
  const b = png.data[pi + 2];
  if (!isBackgroundSeed(r, g, b)) return;
  visited[i] = 1;
  queue.push(i);
}

// Flood from all border pixels.
for (let x = 0; x < width; x++) {
  pushIfBg(x, 0);
  pushIfBg(x, height - 1);
}
for (let y = 0; y < height; y++) {
  pushIfBg(0, y);
  pushIfBg(width - 1, y);
}

while (queue.length) {
  const i = queue.pop();
  const x = i % width;
  const y = (i - x) / width;
  pushIfBg(x - 1, y);
  pushIfBg(x + 1, y);
  pushIfBg(x, y - 1);
  pushIfBg(x, y + 1);
}

let transparent = 0;
for (let i = 0; i < width * height; i++) {
  const pi = i << 2;
  if (visited[i]) {
    png.data[pi + 3] = 0;
    transparent++;
    continue;
  }

  const r = png.data[pi];
  const g = png.data[pi + 1];
  const b = png.data[pi + 2];
  const avg = (r + g + b) / 3;

  // Feather remaining light halos around the emblem.
  if (!isGoldPixel(r, g, b) && avg > 175 && r > 190 && g > 175) {
    const t = Math.min(1, (avg - 175) / 55);
    png.data[pi + 3] = Math.round((1 - t) * 255);
  } else {
    png.data[pi + 3] = 255;
  }
}

fs.writeFileSync(logoPath, PNG.sync.write(png));
console.log(
  `Transparent logo ready (${width}x${height}) — ${(
    (transparent / (width * height)) *
    100
  ).toFixed(1)}% cleared`,
);

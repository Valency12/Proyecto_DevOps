#!/usr/bin/env node
/**
 * Genera client/config.user.js desde server/.env (SUPABASE_URL, SUPABASE_ANON_KEY).
 * Uso: node scripts/sync-client-config.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const envPath = path.join(root, 'server', '.env');
const outPath = path.join(root, 'client', 'config.user.js');

function parseEnv(content) {
  const out = {};
  for (const line of content.split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i === -1) continue;
    const k = t.slice(0, i).trim();
    let v = t.slice(i + 1).trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
      v = v.slice(1, -1);
    }
    out[k] = v;
  }
  return out;
}

if (!fs.existsSync(envPath)) {
  console.error('No existe server/.env. Copia server/.env.example y rellena SUPABASE_*');
  process.exit(1);
}

const env = parseEnv(fs.readFileSync(envPath, 'utf8'));
const url = (env.SUPABASE_URL || '').trim();
const anon = (env.SUPABASE_ANON_KEY || '').trim();

if (!url || !anon) {
  console.error('En server/.env deben estar definidos SUPABASE_URL y SUPABASE_ANON_KEY (clave publishable del dashboard).');
  process.exit(1);
}

const esc = (s) => s.replace(/\\/g, '\\\\').replace(/'/g, "\\'");

const body = `// Auto-generado por: npm run sync:client (no subas este archivo si contiene secretos)
window.SUPABASE_URL = '${esc(url)}';
window.SUPABASE_ANON_KEY = '${esc(anon)}';
`;

fs.writeFileSync(outPath, body, 'utf8');
console.log('OK:', outPath);

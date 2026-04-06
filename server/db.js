const path = require('path');
const dns = require('dns');
const { Pool } = require('pg');
// Evita fallos ENETUNREACH si solo hay ruta IPv6 al host de Supabase
if (typeof dns.setDefaultResultOrder === 'function') {
  dns.setDefaultResultOrder('ipv4first');
}
require('dotenv').config({ path: path.resolve(__dirname, '.env') });

const getEnv = (k, fallback) => {
  const v = process.env[k];
  if (typeof v === 'string') return v.trim();
  return fallback;
};

// Supabase/PostgreSQL: usar DATABASE_URL (conexión directa)
// Formato: postgresql://postgres:[YOUR-PASSWORD]@db.xxxx.supabase.co:5432/postgres
const connectionString = getEnv('DATABASE_URL', '');

if (!connectionString) {
  console.warn('DATABASE_URL no está definida. Configura la conexión directa de Supabase en server/.env');
}

const pool = new Pool({
  connectionString,
  ssl: connectionString && connectionString.includes('supabase.co') ? { rejectUnauthorized: false } : false,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000
});

module.exports = {
  pool
};

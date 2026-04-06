// Valores por defecto; config.user.js (generado con npm run sync:client) puede sobrescribir Supabase.
// No abras index.html con file:// — usa: npm run client → http://localhost:8080
if (typeof window.API_BASE === 'undefined') window.API_BASE = 'http://localhost:4000';
if (typeof window.SUPABASE_URL === 'undefined') window.SUPABASE_URL = '';
if (typeof window.SUPABASE_ANON_KEY === 'undefined') window.SUPABASE_ANON_KEY = '';
// Debe coincidir con ALLOWED_EMAIL_DOMAINS en server/.env (registro con correo/contraseña)
window.ALLOWED_EMAIL_DOMAINS = 'tecmilenio.mx,gmail.com';

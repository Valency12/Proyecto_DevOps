Resumen rápido de la API

Endpoints principales:
- GET /api/ping -> comprobar si el servidor está activo
- POST /api/auth/register -> { name, email, password, user_type } (email debe terminar en @tecmilenio.mx)
- POST /api/auth/verify -> { email, code }
- POST /api/auth/login -> { email, password }
- GET /api/profiles -> obtener perfiles visibles (solo usuarios verificados)
- POST /api/profiles -> { user_id, name, role } crear perfil para usuario

La **página web** de la app está en GitHub Pages. El backend (`server/`) debe desplegarse en un host (Render, Railway, etc.) y la variable **API_BASE_URL** configurarse en el repositorio. Ver `docs/DEPLOYMENT.md`.

Para desplegar este backend:
1. En el host, configura **DATABASE_URL** (Supabase), **EMAIL_*** (SMTP) y **PORT**.
2. Comando de build/start: `npm install && npm run migrate && npm start`.
3. En el repo GitHub: **Settings → Variables → API_BASE_URL** = URL del backend (sin barra final).

Notas:
- Usa nodemailer para enviar el código de verificación
- El servidor habilita rate-limiting (60 req/min por IP)
- El servidor emite eventos en tiempo real vía Socket.IO (evento `user_verified`) cuando un usuario verifica su correo. El servidor también emite `profile_created` cuando se crea un perfil mediante la API. El frontend puede suscribirse a estos eventos para actualizar la lista de perfiles sin necesidad de polling.

Consejos:
- Para pruebas de email sin mandar correos reales usa Mailtrap o servicios similares; configura `EMAIL_*` en `.env`.
- Si vas a desplegar, no uses credenciales en texto plano; usa un secret manager y un SMTP confiable.


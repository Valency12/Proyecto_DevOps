# Despliegue - PlusZone (Avance-proyecto-PlusZone)

Repositorio: **leodaniel-rgb/Avance-proyecto-PlusZone**.  
URL de la app: **https://leodaniel-rgb.github.io/Avance-proyecto-PlusZone/**

La aplicación está pensada para usarse entrando **solo al enlace de GitHub Pages**. El frontend se despliega automáticamente; el backend debe desplegarse aparte y configurarse con variables del repositorio.

---

## Hacer funcional la página web (pasos necesarios)

### 1. Habilitar GitHub Pages

- Repositorio **Avance-proyecto-PlusZone** → **Settings** → **Pages**.
- **Source:** **GitHub Actions**.
- Con cada push a `main`, el workflow desplegará el frontend. URL: **https://leodaniel-rgb.github.io/Avance-proyecto-PlusZone/**

### 2. Desplegar el backend (API)

Despliega la carpeta `server/` en un servicio con Node.js (Render, Railway, Vercel con servidor, etc.):

- Variables de entorno: **DATABASE_URL** (Supabase), **SUPABASE_URL**, **SUPABASE_ANON_KEY**, **SUPABASE_JWT_SECRET** (ver `server/.env.example`). Opcional: **EMAIL_*** si usas flujo legacy con código 7 dígitos.
- Comando de inicio: `npm install && npm run migrate && npm start`.
- Anota la URL pública del backend (ej. `https://pluszone-api.onrender.com`), **sin barra final**.

### 3. Configurar Supabase (verificación de correo sin SMTP)

- En **Supabase** → **Authentication** → **Providers** → **Email**: activa **Confirm email**.
- En **Authentication** → **URL Configuration** → **Redirect URLs**, añade:  
  `https://leodaniel-rgb.github.io/Avance-proyecto-PlusZone/**`  
  (Supabase redirige aquí tras confirmar el correo.)

### 4. Variables del repositorio (GitHub Actions)

- Repositorio → **Settings** → **Secrets and variables** → **Actions** → **Variables**.
- Crea:
  - **`API_BASE_URL`**: URL del backend (sin barra final).
  - **`SUPABASE_URL`**: URL del proyecto (ej. `https://xxxx.supabase.co`).
  - **`SUPABASE_ANON_KEY`**: clave anon/public del proyecto (API).
- Haz un push a `main` o ejecuta el workflow "Deploy to GitHub Pages". El frontend usará estas variables y la página quedará funcional (registro con correo @tecmilenio.mx, confirmación por enlace enviado por Supabase, login y perfiles).

---

## Despliegue del backend (resumen por tipo de host)

Opción A — VPS (Linux) (ej. DigitalOcean, AWS EC2)
1. Crear servidor con Node.js. La base de datos es Supabase (en la nube); no hace falta instalar MySQL.
2. Subir código (git clone o FTP) al servidor.
3. Crear un archivo `.env` en `server/` con DATABASE_URL (Supabase), EMAIL_*, etc. (no subir `.env` a git).
4. Desde la raíz ejecutar: `npm run install-server` y `npm run migrate` (desde `server/`) si usas AUTO_MIGRATE=false.
5. Iniciar con un proceso manager (pm2): `pm2 start server/index.js --name pluszone`.
6. Configurar firewall y dominio/SSL (Let's Encrypt via Certbot) para servir la app.
7. Configurar un SMTP real (SendGrid, Mailgun) para envío de correos.

Opción B — Platform-as-a-Service (Render / Heroku / Railway)
1. Crear un servicio web para la app Node. La base de datos es Supabase (externa); no hace falta servicio MySQL.
2. Subir repo y setear variables de entorno en el dashboard: **DATABASE_URL** (URI Supabase), EMAIL_*, AUTO_MIGRATE.
3. En Deploy script, ejecutar `npm run install-server` y `npm run migrate` (desde `server/`) si necesitas aplicar el esquema.
4. Asegura que la app escuche en el puerto indicado por la plataforma (PORT).

La **variable `API_BASE_URL`** (paso 3 arriba) es la que usa el workflow para inyectar la URL del backend en el frontend desplegado. No hace falta editar `client/config.js` a mano para producción.

Pruebas E2E sugeridas
- Usar Mailtrap para pruebas de email (sandbox) y un script con Playwright para:
  1) registrarse con email `@tecmilenio.mx`, 2) leer el código en Mailtrap, 3) verificar, 4) confirmar que el perfil aparece en `/api/profiles`.

Depuración de envíos de correo (fallback local) ⚠️
- Si no tienes configurado un SMTP (o el servicio no está disponible), el servidor ahora registra los códigos de verificación en `server/verification_debug.log` en modo desarrollo.
- Controla este comportamiento con la variable de entorno `EMAIL_FALLBACK` (true/false). Por seguridad, desactiva fallback en producción (`EMAIL_FALLBACK=false`).

Problemas y soluciones comunes al enviar correo
- Error `451 DNS temporary failure (#4.3.0)` al ejecutar `sendMail`: normalmente indica un problema de resolución DNS del dominio del remitente (`MAIL FROM`) o del servidor SMTP. Revisa los siguientes puntos:
  1. **Remitente (`EMAIL_FROM`)**: evita errores tipográficos (por ejemplo `outlock.com` vs `outlook.com`). Usa un dominio válido con registros MX configurados o una dirección que tu proveedor SMTP haya verificado.
  2. **Credenciales y puerto**: asegúrate de usar las credenciales correctas (consumer key/secret para TurboSMTP) y un puerto compatible (`465` para SSL, `587/2525` para STARTTLS). Ajusta `EMAIL_SECURE` según el puerto.
  3. **Usar la API de TurboSMTP**: si tu proveedor ofrece la API REST, actívala con `EMAIL_API_ENABLED=true` y configura `EMAIL_CONSUMER_KEY` y `EMAIL_CONSUMER_SECRET`. El servidor intentará autorizar y usar la API (`/authorize` + `/mail/send`) antes de caer al SMTP. Esto puede evitar problemas DNS en el cliente SMTP en algunos entornos.
  4. **Prueba básica**: usa `openssl s_client -crlf -connect pro.eu.turbo-smtp.com:587` y ejecuta un diálogo SMTP manual para comprobar conectividad, o usa `telnet`/`nc` según el entorno.
  5. **Logs**: si el envío falla, el servidor intentará guardar el código en `server/verification_debug.log` si `EMAIL_FALLBACK=true`.
  6. **Solución rápida**: si no requieres envío real en desarrollo, deja `EMAIL_FALLBACK=true` y obtén el código desde `server/verification_debug.log`.

Recomendación específica para tu caso
- Verifica el valor de `EMAIL_FROM` en `server/.env` (corrige `outlock.com` a la variante correcta o usa una dirección verificada por TurboSMTP). Después reinicia el servidor. Si después de eso sigues con `451 DNS temporary failure`, activa `EMAIL_API_ENABLED=true` (si tu cuenta soporta API) y prueba envío vía API antes de intentar más cambios o contactar soporte de TurboSMTP con el mensaje de error.

Soporte y troubleshooting
- Si ves error de conexión a la base de datos, revisa **DATABASE_URL** (Supabase → Database → Connection string → Direct connection). Reemplaza `[YOUR-PASSWORD]` por la contraseña real.
- Revisa los logs del backend desplegado y `server/init_db.js` si la migración falla. Esquema en `supabase/migrations/` o `database/pluszone_supabase.sql`.

---

## Desarrollo local (opcional)

Si quieres probar backend y frontend en tu máquina: en `server/` crea `.env` con DATABASE_URL y SMTP, ejecuta `npm install`, `npm run migrate`, `npm run dev` y abre `http://localhost:4000`. La app servida por Express usará la API en el mismo origen.

# Inicio de sesión con Google (Gmail) — PlusZone

Esta guía configura **OAuth de Google** a través de **Supabase Auth**, que es lo que usa el frontend (`Continuar con Google` en `client/index.html`).

Requisitos previos:

- Proyecto en [Supabase](https://supabase.com/) (mismo proyecto donde tienes `SUPABASE_URL` y el secreto JWT).
- Cuenta en [Google Cloud Console](https://console.cloud.google.com/).

---

## ¿Es obligatorio poner Supabase en Google Cloud?

**Sí, en el campo “URI de redireccionamiento”**, si usas **“Continuar con Google” con Supabase**. No es algo raro: Google solo pregunta *“¿a qué dirección web envío al usuario después de que inicie sesión?”*.

En tu caso el flujo es:

1. El usuario hace clic en “Continuar con Google” en tu web.
2. Va a Google y acepta.
3. Google **no** devuelve al usuario directamente a GitHub Pages primero: lo envía a **los servidores de Supabase** (`…supabase.co/auth/v1/callback`), porque **Supabase es quien gestiona la sesión** (el token que luego usa tu app).
4. Supabase redirige ya a tu página (GitHub Pages, localhost, etc.).

Por eso en Google Cloud, en **“Authorized redirect URIs”**, debes poner **exactamente** la URL de callback de Supabase. Si pones solo la URL de tu app en GitHub Pages, **no funcionará** con este método.

**No** tienes que “instalar” Supabase en Google ni nada raro: solo **una línea** en redirect URIs (la de arriba) y el **Client ID / Secret** los copias **desde Google hacia Supabase** (Authentication → Providers → Google).

Los **“Orígenes de JavaScript”** sí son la URL de **tus** web (`https://tu-usuario.github.io`), sin `/nombre-repo`.

---

## Dónde está cada cosa en el dashboard de Supabase

Los nombres pueden variar un poco según el idioma o la versión del panel. Prueba en este orden:

| Qué necesitas | Dónde buscarlo |
|---------------|----------------|
| **Project URL** (para armar el callback `https://xxxx.supabase.co/...`) | Barra lateral izquierda: icono de **engranaje** ⚙️ o texto **“Project Settings”** / **“Configuración del proyecto”** → sección **“API”** (o **“Data API”**). Ahí verás **Project URL** (`https://algo.supabase.co`). Ese `algo` es tu referencia del proyecto. |
| **JWT Secret** (para `server/.env` → `SUPABASE_JWT_SECRET`) | Mismo sitio: **Project Settings** → **API** → **JWT Secret** (a veces hay que pulsar **Reveal** para verla). **No** es la clave “anon public”. |
| **anon key** (para `client/config.js`) | **Project Settings** → **API** → **Project API keys** → **anon** **public**. |
| **Callback de Google** (por si quieres copiar la URI exacta) | **Authentication** → **Sign In / Providers** → **Google** → suele mostrarse la **Callback URL** o texto de ayuda con `https://…supabase.co/auth/v1/callback`. |
| **Redirect URLs de tu app** (GitHub Pages, localhost) | **Authentication** → **URL Configuration** → **Redirect URLs** y **Site URL**. |

Si no ves **“Project Settings”**:

- Mira **abajo del menú lateral** (icono de tu proyecto o engranaje).
- O en [app.supabase.com](https://app.supabase.com) entra al proyecto y en la URL del navegador suele aparecer `/project/<id>/...`; puedes ir a **Settings** desde el menú del proyecto (tres puntos o engranaje junto al nombre del proyecto).

**Atajo directo (sustituye `TU_PROJECT_ID`):**  
`https://supabase.com/dashboard/project/TU_PROJECT_ID/settings/api`  
El ID del proyecto lo ves en la URL de Supabase cuando abres cualquier pantalla de tu proyecto.

---

## Paso 1 — Crear credenciales OAuth en Google Cloud

1. Entra a **Google Cloud Console** → selecciona o crea un **proyecto**.
2. Menú **APIs y servicios** → **Biblioteca** → busca **Google+ API** (o “Google People API”) y **Habilitar** si te lo pide (Supabase usa el flujo OAuth estándar).
3. Ve a **APIs y servicios** → **Pantalla de consentimiento OAuth**.
   - Tipo: **Externo** (salvo que uses Workspace solo interno).
   - Rellena nombre de la app, correo de soporte y dominios si aplica.
   - Añade tu correo como **usuario de prueba** mientras la app esté en modo prueba.
4. Ve a **Credenciales** → **Crear credenciales** → **ID de cliente OAuth** → tipo **Aplicación web**.

5. **Orígenes autorizados de JavaScript** (campo “Authorized JavaScript origins”)

   Google pide solo el **origen** del sitio: `https` + dominio + puerto (si aplica). **No** incluyas la ruta del repo (`/Avance-proyecto-PlusZone` ni nada después de `.github.io`).

   | Entorno | Pon exactamente esta línea (un origen por fila) |
   |--------|--------------------------------------------------|
   | GitHub Pages (proyecto en subruta) | `https://TU_USUARIO.github.io` |
   | Ejemplo de este repo (si tu usuario es `leodaniel-rgb`) | `https://leodaniel-rgb.github.io` |
   | Pruebas en local (Live Server en 5500) | `http://localhost:5500` |
   | Otro puerto local | `http://localhost:PUERTO` (el mismo puerto que uses en el navegador) |

   **Error habitual:** poner `https://usuario.github.io/NombreDelRepo` — **eso falla**. Aunque la app viva en `https://usuario.github.io/NombreDelRepo/`, el **origen** sigue siendo solo `https://usuario.github.io`.

6. **URI de redireccionamiento autorizados** (campo “Authorized redirect URIs”)

   Aquí **no** va GitHub Pages. Con Supabase, Google debe redirigir primero a Supabase. Añade **exactamente**:

   `https://REF_DE_TU_PROYECTO.supabase.co/auth/v1/callback`

   Sustituye `REF_DE_TU_PROYECTO` por el host de tu proyecto (está en **Supabase → Project Settings → API → Project URL**, la parte `https://xxxx.supabase.co` → el `xxxx` es el ref). También aparece en **Authentication → Providers → Google** como callback.

   Opcional en desarrollo local con Supabase CLI: a veces se usa `http://localhost:54321/auth/v1/callback`; solo si trabajas así.

7. Guarda y copia el **ID de cliente** y el **Secreto del cliente** en Supabase (paso 2).

---

## Paso 2 — Activar Google en Supabase

1. Abre el **dashboard de Supabase** → tu proyecto.
2. **Authentication** → **Providers** → **Google**.
3. Activa el proveedor y pega:
   - **Client ID** (de Google Cloud).
   - **Client Secret** (de Google Cloud).
4. Guarda los cambios.

---

## Paso 3 — URLs de redirección en Supabase

1. En Supabase → **Authentication** → **URL Configuration**:
   - **Site URL**: la URL principal de tu app (ej. `https://<usuario>.github.io/Avance-proyecto-PlusZone/` o `http://localhost:5500` si usas Live Server).
   - **Redirect URLs**: añade **todas** las URLs desde las que el usuario puede volver tras el login, por ejemplo:
     - `http://localhost:5500/**`
     - `http://127.0.0.1:5500/**`
     - `https://<usuario>.github.io/**`
2. Sin esto, el navegador puede bloquear el retorno o Supabase rechazará el redirect.

---

## Paso 4 — Variables en el cliente (`client/config.js`)

Deben estar definidos (o inyectados en el pipeline de deploy):

- `window.SUPABASE_URL` — Project URL de Supabase.
- `window.SUPABASE_ANON_KEY` — anon public key.
- `window.API_BASE` — URL del servidor Node (ej. `http://localhost:4000`) para que tras el login se llame a `POST /api/auth/session`.

El botón **Continuar con Google** usa `signInWithOAuth({ provider: 'google' })` y `redirectTo` = URL actual de la página.

---

## Paso 5 — Variables en el servidor (`server/.env`)

- **`SUPABASE_JWT_SECRET`**: en Supabase → **Project Settings** → **API** → **JWT Secret** (cadena larga). **No** uses la clave `anon` como secreto JWT.
- **`ALLOWED_EMAIL_DOMAINS`**: debe incluir `gmail.com` si quieres cuentas de Google personales, por ejemplo:  
  `tecmilenio.mx,gmail.com`
- Reinicia el servidor Node tras cambiar `.env`.

---

## Paso 6 — Probar el flujo

1. Arranca el backend: `npm run server:start` (o `node server/index.js`).
2. Sirve el frontend (por ejemplo Live Server o `npx serve client`) en la misma URL que pusiste en **Redirect URLs** de Supabase.
3. Abre la app → **Iniciar sesión** → **Continuar con Google**.
4. Tras elegir la cuenta Gmail, deberías volver a la app con sesión; el cliente llama a `POST /api/auth/session` con el Bearer token de Supabase y el servidor crea o actualiza el usuario en PostgreSQL.

Si ves **403** con mensaje de dominio no permitido, revisa `ALLOWED_EMAIL_DOMAINS` en `server/.env`.

Si el popup o redirect falla, revisa que la **URI de callback** en Google Cloud sea exactamente la de Supabase (`.../auth/v1/callback`) y que **Redirect URLs** en Supabase incluya tu origen.

---

## Referencia rápida de archivos

| Archivo | Rol |
|--------|-----|
| `client/app.js` | `handleGoogleLogin`, `syncBackendSession` → `/api/auth/session` |
| `client/config.js` | `API_BASE`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `ALLOWED_EMAIL_DOMAINS` (solo validación de registro en cliente) |
| `server/index.js` | `POST /api/auth/session`, dominios permitidos vía `ALLOWED_EMAIL_DOMAINS` |

Para más contexto del proyecto, ver **[DOCUMENTACION.md](../DOCUMENTACION.md)**.

# Documentación del proyecto PlusZone

Este archivo explica cómo funciona el código del proyecto PlusZone (app de matching tipo Tinder + LinkedIn para empleados y empresas).

---

## Resumen de implementaciones (requisitos del curso)

Se integraron de forma explícita tres frentes: **Python**, **inicio de sesión (Supabase + backend)** y **Docker**.

### Python (microservicio FastAPI)

- Carpeta **`python/`**: aplicación **FastAPI** (`main.py`) con **`GET /health`** y **`POST /api/match/score`**, que calcula afinidad candidato ↔ oferta por **similitud Jaccard** sobre listas de skills (respuesta con `score` 0–100 y skills coincidentes).
- Dependencias en **`python/requirements.txt`** (FastAPI, Uvicorn, Pydantic, etc.).
- El backend **Node** (`server/index.js`) puede actuar como **proxy** hacia ese servicio si en **`server/.env`** existe **`PYTHON_SERVICE_URL`**:
  - **`GET /api/python/health`** — comprueba que el proceso Node alcanza el microservicio.
  - **`POST /api/match/score`** — reenvía el JSON al mismo contrato que expone FastAPI.
- Sin `PYTHON_SERVICE_URL`, esas rutas responden **503** con un mensaje orientativo.
- En desarrollo local: **`npm run python:dev`** (Uvicorn en `127.0.0.1:5050`). En Docker, el compose define el servicio **`python-match`** y la API usa **`http://python-match:5050`** (ver sección [Docker](#9-docker)).

### Inicio de sesión (correo/contraseña, Google OAuth y sesión con el backend)

- **Cliente:** **Supabase Auth** (`@supabase/supabase-js`) para registro e inicio con correo/contraseña y **“Continuar con Google”** (OAuth). Las claves públicas y la URL del proyecto se cargan con **`client/config.user.js`**, generado desde **`server/.env`** mediante **`npm run sync:client`** (escribe `SUPABASE_URL` y `SUPABASE_ANON_KEY`). **`client/config.js`** se carga después y fija por defecto **`API_BASE`** (p. ej. `http://localhost:4000`) y dominios de correo permitidos en el cliente.
- Tras obtener sesión en Supabase, el front llama **`POST /api/auth/session`** con **`Authorization: Bearer <access_token>`** y, si aplica, **`{ "user_type": "employee" | "company" }`** (útil en OAuth cuando hay que fijar el rol la primera vez).
- **Servidor:** valida el JWT con **`SUPABASE_JWT_SECRET`**, comprueba el dominio del correo contra **`ALLOWED_EMAIL_DOMAINS`** (por defecto `tecmilenio.mx` y `gmail.com`) y sincroniza usuario/perfil en PostgreSQL.
- Flujo **legacy** con código de **7 dígitos** sigue disponible (`POST /api/auth/register`, `/verify`, `/resend`, `/login` con **bcryptjs**), con fallback **`devCode`** en desarrollo cuando no hay envío real de correo.
- Documentación paso a paso de Google + Supabase: **[docs/GOOGLE_LOGIN.md](docs/GOOGLE_LOGIN.md)**.

### Docker

- En la **raíz del repositorio**: **`docker-compose.yml`** orquesta tres servicios:
  - **`python-match`** — imagen construida desde **`python/Dockerfile`** (Uvicorn en el puerto **5050**).
  - **`api`** — imagen desde **`server/Dockerfile`** (Express en **4000**), lee variables de **`server/.env`** y fuerza **`PYTHON_SERVICE_URL=http://python-match:5050`** para comunicación interna entre contenedores.
  - **`client`** — **nginx** sirve la carpeta **`client/`** en el host en el puerto **8080**.
- La base de datos sigue siendo **Supabase (PostgreSQL en la nube)**; no se contiene un Postgres en el compose: solo hace falta **`DATABASE_URL`** y el resto de secretos en **`server/.env`**.
- Comandos de conveniencia en la raíz: **`npm run docker:up`** y **`npm run docker:down`**. Detalle en **[docs/DOCKER.md](docs/DOCKER.md)**.

---

## 1. ¿Funciona el código de la API (verificación)?

**Sí.** El flujo del código de verificación funciona así:

- **Con servidor (API)**  
  - Al registrarte con un correo `@tecmilenio.mx`, el servidor genera un **código de 7 dígitos** y intenta enviarlo por correo (SMTP o API de email).  
  - Si **no** puede enviar el correo (sin SMTP configurado, etc.), hace *fallback*: guarda el código en `server/verification_debug.log` y, en entorno de desarrollo, lo devuelve en la respuesta como **`devCode`**.  
  - El cliente muestra ese código en el modal de verificación (“Tu código (desarrollo): 1234567”) y rellena el campo para que puedas verificar sin abrir el log.  
  - Tras verificar, puedes iniciar sesión con tu email y contraseña.

- **Sin servidor (solo frontend)**  
  - No hay código de verificación: el registro y el login usan la base de datos local del navegador (localStorage). No se usa ningún código de acceso.

Para usar la API en local, en `client/config.js` define por ejemplo:  
`window.API_BASE = 'http://localhost:4000';`  
y arranca el servidor (por ejemplo `node server/index.js` o `npm start` en `server/`).

---

## 2. Visión general del proyecto

- **PlusZone** es una aplicación web para conectar candidatos (empleados) con ofertas de trabajo (empresas).
- Los **empleados** ven ofertas en “Descubrir” y pueden dar like (match) o pasar.
- Las **empresas** ven candidatos en “Buscar candidatos” y pueden hacer match con ellos.
- Hay **perfil** (editar datos), **matches**, **mensajes** (estructura lista, lógica por implementar) y **dashboard** con estadísticas.

**Tecnologías:**

- **Frontend:** HTML, CSS, JavaScript (vanilla). Sin framework.
- **Base de datos en el navegador:** `client/database.js` — simula una DB con localStorage (usuarios, perfiles, swipes, matches, mensajes).
- **Servidor (opcional):** Node.js + Express en `server/`. API REST para registro con verificación por correo, login, perfiles; usa PostgreSQL y opcionalmente SMTP/API de email para el código.
- **Autenticación en la nube:** Supabase Auth (correo/contraseña y **Google OAuth**); el backend valida el JWT en `POST /api/auth/session`.
- **Servicio Python (opcional):** microservicio FastAPI en `python/` para puntuar afinidad candidato ↔ oferta por skills; el Node puede hacer de proxy en `POST /api/match/score` si defines `PYTHON_SERVICE_URL`.
- **Docker (opcional):** `docker-compose.yml` en la raíz para levantar API, Python y cliente estático con nginx; ver [5.5 Docker](#55-docker).

**Guías separadas:**

- **[docs/GOOGLE_LOGIN.md](docs/GOOGLE_LOGIN.md)** — configuración paso a paso del inicio de sesión con Google (Google Cloud + Supabase + URLs).
- **[docs/DOCKER.md](docs/DOCKER.md)** — Docker Compose, puertos y uso de contenedores.

---

## 3. Estructura del proyecto

```
Proyecto_DevOps/   (nombre de carpeta puede variar)
├── client/                 # Frontend
│   ├── index.html          # Carga config.user.js antes de config.js
│   ├── styles.css          # Estilos globales
│   ├── app.js              # Lógica principal: auth (Supabase + /api/auth/session), Discover, …
│   ├── database.js         # “Base de datos” en localStorage (seed, usuarios, perfiles, etc.)
│   ├── config.js           # API_BASE por defecto; Supabase puede venir de config.user.js
│   ├── config.user.js      # Opcional, generado: SUPABASE_URL / SUPABASE_ANON_KEY (no versionar si es sensible)
│   ├── DEMO-CREDENTIALS.md # Credenciales de ejemplo (empleado y empresa)
│   └── ...
├── server/                 # Backend (opcional)
│   ├── Dockerfile          # Imagen Docker de la API
│   ├── index.js            # Express: /api/auth/*, proxy Python, Socket.IO, …
│   ├── db.js               # Conexión a PostgreSQL
│   ├── init_db.js          # Migración y seed de la DB
│   ├── .env                # Variables locales (gitignore); ejemplo en .env.example si existe
│   └── ...
├── python/                 # Microservicio opcional (matching por skills)
│   ├── Dockerfile          # Imagen Docker del servicio FastAPI
│   ├── main.py             # FastAPI: /health, /api/match/score
│   ├── requirements.txt
│   └── README.md
├── scripts/
│   └── sync-client-config.mjs   # npm run sync:client → genera client/config.user.js desde server/.env
├── docs/
│   ├── GOOGLE_LOGIN.md     # Login con Google
│   └── DOCKER.md           # Uso de Docker Compose
├── docker-compose.yml      # api + python-match + client (nginx)
├── database/               # Esquema SQL (PostgreSQL/Supabase)
│   └── pluszone_supabase.sql
├── DOCUMENTACION.md        # Este archivo
└── ...
```

---

## 4. Cliente (client/)

### 4.1 index.html

- **Pantalla de carga** (`#loadingScreen`): se oculta cuando la app está lista.
- **Pantalla de auth** (`#authScreen`): pestañas Iniciar sesión / Registrarse; formularios que llaman a `handleLogin` y `handleRegister`.
- **App principal** (`#app`): sidebar (navegación según tipo de usuario: empleado o empresa), área de contenido (Discover, Matches, Mensajes, Dashboard, Mi Perfil), footer.
- **Modales:** verificación de correo (`#verifyModal`), crear oferta (`#createJobModal`), overlay de match (`#matchOverlay`).
- **Toast:** `#appToast` para mensajes in-app (por ejemplo “Perfil actualizado”).

### 4.2 app.js — flujos principales

- **Estado global (`state`):**  
  `allProfiles`, `profiles` (filtrados), `currentIndex`, `swipedProfiles`, `matchedProfiles`, `currentUser`, `companyJobs`, etc.

- **Inicio:**
  - Si hay `API_BASE` válida y no es `file://`, puede intentar Supabase o API legacy para sesión/login.
  - Si no, o si falla, usa login contra **database.js** (localStorage). Tras login correcto: `loadAllProfilesFromDatabase()` (o perfiles desde API), `filterProfilesByUserType()`, `renderCards()`, `showMainApp()`.

- **Discover:**
  - Muestra las cards (ofertas para empleado, candidatos para empresa). Cada card tiene `data-profile-id`.
  - **Swipe:** al dar like o pasar se llama `handleSwipe(direction)`. El perfil se toma de la **card visible** (`.card-top` + `data-profile-id`) para que el match sea siempre con la oferta/empresa correcta. Si hay match (probabilidad simulada), se añade el id a `matchedProfiles` y se muestra `showMatchOverlay(profile)` con ese mismo perfil.

- **Matches:**  
  `renderMatches()` pinta la lista con `state.profiles.filter(p => state.matchedProfiles.includes(p.id))`. Cada ítem puede desplegar detalles (tagline, descripción, etc.).

- **Perfil:**  
  Formularios rellenados con `state.currentUser`. Al guardar se llama `saveProfile`: actualiza `state.currentUser`, y si existe `Database`, actualiza usuario y perfil público (`updateUser`, `updateProfileByUserId`) para que empresas/empleados vean los cambios al recargar.

- **Dashboard:**  
  Usa `state.matchedProfiles`, `state.swipedProfiles`, `state.companyJobs` para mostrar números (matches, vistos, ofertas activas, etc.).

- **Código de verificación (cuando hay API):**
  - Tras registro exitoso por API, se abre `openVerifyModal(email, message, devCode)`. Si la API devolvió `devCode`, se muestra en el modal y se rellena el input.
  - Al confirmar se llama `POST /api/auth/verify` con `email` y `code`; si va bien, se hace auto-login con `_pendingVerification`.
  - “Reenviar código” llama `POST /api/auth/resend`; si la respuesta trae `devCode`, se actualiza el modal con ese código.

### 4.3 database.js

- **Database.init():**  
  Si no hay `pluszone_db` en localStorage, o si la versión guardada es menor que `SEED_VERSION`, guarda un seed con usuarios (empleados, empresas), perfiles (candidatos y ofertas con tagline, about_me, company_description, etc.), y arrays vacíos para swipes, matches, messages. Así siempre se actualiza a la última estructura de datos sin botón “Restablecer”.

- **Métodos:**  
  `getAll()`, `save()`, `getUserByEmail()`, `getUserById()`, `updateUser()`, `updateProfileByUserId()`, `getJobProfilesByUserId()`, `createJobProfile()`, `reset()` (borra localStorage), etc. Los perfiles de ofertas creados por la empresa se guardan aquí y se cargan en `loadAllProfilesFromDatabase()` para que los empleados los vean en Discover.

### 4.4 config.js y config.user.js

- **`config.js`** define valores por defecto: **`window.API_BASE`** (p. ej. `http://localhost:4000`), y si no existen aún, **`SUPABASE_URL`** y **`SUPABASE_ANON_KEY`**. También **`window.ALLOWED_EMAIL_DOMAINS`** para mensajes coherentes con el servidor.
- **`config.user.js`** (opcional) se carga **antes** que `config.js` en `index.html` y suele contener solo las claves de Supabase leídas del backend. Para no copiar a mano: **`npm run sync:client`**, que ejecuta **`scripts/sync-client-config.mjs`** leyendo **`server/.env`** y escribiendo **`client/config.user.js`**.
- No abras el front con **`file://`**: usa **`npm run client`** o **`npm run dev:web`** (puerto **8080**) o el contenedor **client** de Docker.

---

## 5. Servidor (server/)

### 5.1 Auth y código de verificación

- **Supabase Auth (recomendado en producción)**  
  - Registro e inicio de sesión con correo/contraseña o **Google** desde el cliente (`@supabase/supabase-js`).  
  - Tras obtener sesión, el cliente llama a **`POST /api/auth/session`** con `Authorization: Bearer <access_token>` y cuerpo opcional `{ "user_type": "employee" | "company" }` para usuarios nuevos (p. ej. OAuth sin metadata). La función **`syncBackendSession`** en `app.js` centraliza esa llamada; si Supabase responde bien pero el backend falla (servidor caído, JWT incorrecto, dominio no permitido), el usuario puede ver un **aviso (toast)** para distinguir el caso.  
  - El servidor verifica el JWT con `SUPABASE_JWT_SECRET` y comprueba el dominio del correo contra **`ALLOWED_EMAIL_DOMAINS`** (por defecto incluye `tecmilenio.mx` y `gmail.com`).  
  - El servidor carga **`server/.env`** con **dotenv** (ruta resuelta respecto al directorio del proceso) para `DATABASE_URL`, secretos de Supabase, dominios permitidos, etc.  
  - Configuración detallada de Google: **[docs/GOOGLE_LOGIN.md](docs/GOOGLE_LOGIN.md)**.

- **POST /api/auth/register** (flujo legacy con código de 7 dígitos)  
  - Solo acepta correos cuyo dominio esté en `ALLOWED_EMAIL_DOMAINS` (p. ej. `@tecmilenio.mx`, `@gmail.com`).  
  - Crea usuario en PostgreSQL (`is_active = false`) y un perfil asociado.  
  - Genera código de 7 dígitos con `generateCode()`, lo guarda en `email_verifications` con `expires_at`.  
  - Intenta enviar el código por email (`sendVerificationEmail`). Si no puede (SMTP no configurado, etc.), hace fallback: escribe el código en `verification_debug.log` y, si aplica (desarrollo), incluye **`devCode`** en la respuesta JSON para que el cliente lo muestre en el modal.

- **POST /api/auth/verify**  
  - Recibe `email` y `code`. Comprueba que el código exista, no esté usado y no esté expirado; marca la verificación y el usuario como `is_active = true`. Devuelve éxito para que el cliente haga auto-login.

- **POST /api/auth/resend**  
  - Genera un nuevo código, lo guarda, intenta enviar email; si hay fallback y está permitido, devuelve **`devCode`** en la respuesta.

- **POST /api/auth/login**  
  - Comprueba email + contraseña (**bcryptjs**) y que el usuario esté `is_active`. Devuelve datos del usuario para que el cliente llene `state.currentUser`.

### 5.2 Generación del código

- `generateCode()` devuelve un string de 7 dígitos (entre 1000000 y 9999999) con `Math.floor(1000000 + Math.random() * 9000000).toString()`.

### 5.3 Email y fallback

- `sendVerificationEmail()`: puede usar API de email (si está configurada) o SMTP. Si no puede enviar y el fallback está permitido (`NODE_ENV !== 'production'` o `ALLOW_DEV_CODE_IN_RESPONSE`), escribe en `verification_debug.log` y la ruta que llama a esta función devuelve `devCode` en el JSON para desarrollo.

### 5.4 Servicio Python (matching por skills)

Propósito: separar en **Python** la lógica que puede crecer (ML, pesos por skill, NLP) sin acoplarla al proceso principal de Node.

**Ubicación:** carpeta `python/` — aplicación **FastAPI** (`main.py`).

**Endpoints del microservicio (puerto por defecto 5050):**

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/health` | Comprueba que el servicio está vivo. |
| POST | `/api/match/score` | Cuerpo JSON: `{ "candidate_skills": ["React","Node"], "job_skills": ["React","TypeScript"] }`. Respuesta: `score` (0–100), `matched` (intersección), método **Jaccard**. |

**Integración con Node:**

1. En `server/.env` define **`PYTHON_SERVICE_URL=http://127.0.0.1:5050`** (sin barra final).
2. Arranca Python en una terminal:  
   `npm run python:dev`  
   (o manualmente: `cd python && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && python3 -m uvicorn main:app --host 127.0.0.1 --port 5050 --reload`).
3. Arranca el servidor Node en otra terminal (`npm run server:start`).
4. El cliente (o herramientas como `curl`) puede llamar al **mismo contrato** vía proxy:
   - **`GET /api/python/health`** — comprueba configuración y conectividad con Python.
   - **`POST /api/match/score`** — reenvía el body al servicio Python.

Si **`PYTHON_SERVICE_URL`** no está definido, esas rutas responden **503** con un mensaje indicando que hay que configurar y levantar el servicio.

**Instalación de dependencias Python (una vez):**  
En muchos sistemas Linux hay que usar un **venv** (PEP 668):  
`cd python && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`  
En Windows: `python -m venv .venv` y luego `.venv\Scripts\activate`.  
Alternativa: `npm run python:install` si tu `pip` apunta a un entorno donde está permitido instalar paquetes.

**Ampliaciones típicas en Python:** modelos de recomendación, embeddings de descripciones de perfil, pipelines de datos batch sobre PostgreSQL, o workers que consuman una cola; el patrón actual (HTTP + proxy desde Node) permite sustituir la implementación sin cambiar la URL que consume el frontend.

### 5.5 Docker

Contenerización añadida para cumplir el requisito de **DevOps** y facilitar que la API, el microservicio Python y el frontend se levanten juntos.

| Archivo / carpeta | Descripción |
|-------------------|-------------|
| **`docker-compose.yml`** (raíz) | Define tres servicios: **`python-match`** (FastAPI), **`api`** (Node), **`client`** (nginx con volumen de solo lectura sobre `./client`). |
| **`server/Dockerfile`** | Instala dependencias con `npm ci --omit=dev` y ejecuta `node index.js`. Expone el puerto **4000**. |
| **`python/Dockerfile`** | Instala `requirements.txt` y ejecuta Uvicorn en **0.0.0.0:5050**. |
| **`server/.dockerignore`**, **`python/.dockerignore`** | Evitan copiar `node_modules`, cachés, etc. al contexto de build. |

**Puertos habituales en el host:** **8080** → web estática, **4000** → API, **5050** → Python (opcional por fuera; entre contenedores la API usa el nombre DNS **`python-match`**).

**Variables:** el servicio **`api`** usa **`env_file: ./server/.env`** y, además, **`PYTHON_SERVICE_URL=http://python-match:5050`** y **`NODE_OPTIONS=--dns-result-order=ipv4first`** para priorizar IPv4 al conectar a Supabase/PostgreSQL desde el contenedor.

**Comandos:** `npm run docker:up` (build + up), `npm run docker:down`. Tras levantar, conviene **`npm run sync:client`** si actualizaste Supabase en `.env`, y comprobar que **`API_BASE`** en el navegador apunte a **`http://localhost:4000`** cuando uses el stack en local.

Documentación breve duplicada para consulta rápida: **[docs/DOCKER.md](docs/DOCKER.md)**.

---

## 6. Base de datos local vs API

- **Sin API (solo client):**  
  Todo se guarda en localStorage vía `database.js`. Login y registro usan solo esa “DB”. No hay código de verificación.

- **Con API:**  
  Registro y verificación pasan por el servidor; el código se envía por correo o se muestra como `devCode` en el modal. Login puede ser por API o, si la API no está disponible, el cliente puede caer a login local (según implementación actual).

---

## 7. Credenciales de demo

Están en **client/DEMO-CREDENTIALS.md**. Resumen:

- **Empleado:** por ejemplo `j.gonzalez@tecmilenio.mx` / `demo123`, `s.ramirez@tecmilenio.mx` / `demo123`, `carlos.lopez@email.com` / `demo123`, `ana.martinez@email.com` / `demo123`.
- **Empresa:** por ejemplo `empresa1@tecmilenio.mx` / `demo123`, `contacto@thefuentes.com` / `demo123`, y otras listadas en ese archivo.

Con esto puedes probar tanto el flujo con código de la API (registro + verificación + login) como el uso solo con cliente y base local.

---

## 8. Enlaces útiles

- **[docs/GOOGLE_LOGIN.md](docs/GOOGLE_LOGIN.md)** — Configuración paso a paso del inicio de sesión con Google (Google Cloud Console, Supabase, variables de entorno).
- **[docs/DOCKER.md](docs/DOCKER.md)** — Docker Compose, puertos y checklist (`server/.env`, `sync:client`).
- **[python/README.md](python/README.md)** — Arranque rápido del microservicio Python.

---

## 9. Docker (índice rápido)

El detalle técnico (tabla de archivos, puertos, variables) está en la sección **[5.5 Docker](#55-docker)** y en **[docs/DOCKER.md](docs/DOCKER.md)**. Pasos mínimos: **`server/.env`** completo → **`npm run docker:up`** → **`http://localhost:8080`** (front) y **`http://localhost:4000`** (API) → **`npm run sync:client`** si cambiaste Supabase en `.env`.

---

*Documentación generada para el proyecto PlusZone. Para más detalle, revisar los comentarios en `client/app.js`, `client/database.js`, `server/index.js` y `python/main.py`.*

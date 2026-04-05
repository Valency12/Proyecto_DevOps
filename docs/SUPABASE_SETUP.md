# Configuración de Supabase - Avance-proyecto-PlusZone

Guía siguiendo el flujo oficial de Supabase para el repositorio **Avance-proyecto-PlusZone**.

---

## 1. Instalar la Supabase CLI

**Windows (PowerShell):**
```powershell
scoop install supabase
```
O con npm (todas las plataformas):
```bash
npm install -g supabase
```

**macOS / Linux:**
```bash
brew install supabase/tap/supabase
```

Verifica la instalación:
```bash
supabase --version
```

---

## 2. Diseñar el esquema de la base de datos

El esquema está en **`supabase/migrations/`**:

- **`20240224000000_initial_pluszone_schema.sql`**: tablas `users`, `profiles`, `swipes`, `matches`, `messages`, `email_verifications`, `email_outbox`, tipos ENUM, índices y **políticas RLS**.

Para cambiar el diseño:
1. Edita o añade archivos en `supabase/migrations/` (nombres: `YYYYMMDDHHMMSS_descripcion.sql`).
2. Aplica con `supabase db push` (remoto) o `supabase db reset` (local).

---

## 3. Seed (datos iniciales)

Los datos iniciales están en **`supabase/seed.sql`**:

- Usuarios de prueba (admin, empleados, empresa) con contraseñas hasheadas con **pgcrypto** (`crypt('password', gen_salt('bf'))`).
- Perfiles de ejemplo y un match de prueba.

**Local:** al ejecutar `supabase db reset` se aplican migraciones y luego `seed.sql`.

**Remoto:** ejecuta el contenido de `supabase/seed.sql` en el SQL Editor de Supabase o usa `supabase db push` y luego corre el seed manualmente.

---

## 4. Asegurar los datos con RLS (Row Level Security)

Las políticas RLS están en la migración inicial:

- RLS **habilitado** en todas las tablas.
- Políticas **"Postgres full access"** para el rol `postgres` (conexión directa que usa el backend Express).

Si más adelante usas el **Supabase Client** desde el frontend (auth con JWT), puedes añadir políticas para los roles `authenticated` y `anon` en una nueva migración.

---

## 5. Conectar tu aplicación

- **Backend (Express):** usa **DATABASE_URL** en `server/.env` (Connection string → Direct connection en Supabase).
  - Formato: `postgresql://postgres:[YOUR-PASSWORD]@db.xxxx.supabase.co:5432/postgres`
- **Frontend:** si usas solo la API de tu backend, no necesitas claves de Supabase en el cliente. Para GitHub Pages configura `client/config.js` con la URL del backend (`window.API_BASE`).

---

## 6. Registrar el primer usuario

1. Entra a la **página web** de la app (GitHub Pages: `https://<owner>.github.io/Avance-proyecto-PlusZone/` una vez desplegada y con `API_BASE_URL` configurada).
2. Regístrate con un correo **@tecmilenio.mx**.
3. Verifica con el **código de 7 dígitos** que llega por email.
4. Inicia sesión.

---

## 7. Subir un archivo (Storage)

Opcional. Si quieres usar **Supabase Storage** (avatares, CVs, etc.):

1. En el dashboard: **Storage** → **New bucket** (por ejemplo `avatars`, público o privado).
2. Desde el backend o el cliente, usa la API de Storage de Supabase con la URL del proyecto y la clave anon/service según corresponda.

El proyecto actual no usa Storage; los `image_url` son enlaces externos (p. ej. Unsplash).

---

## 8. Desplegar una Edge Function

Opcional. Para lógica serverless en Supabase:

```bash
supabase functions deploy nombre-funcion
```

Las funciones van en `supabase/functions/`. Este proyecto no incluye Edge Functions por defecto.

---

## 9. Monitorear el uso del proyecto

- **Dashboard de Supabase:** [app.supabase.com](https://app.supabase.com) → tu proyecto → **Reports** / **Logs**.
- Revisa uso de base de datos, API, Storage y Auth.

---

## 10. Conectar a GitHub

### Opción A: Supabase vinculado al repo (recomendado)

1. En [Supabase Dashboard](https://app.supabase.com) → tu proyecto → **Project Settings** → **Integrations**.
2. **GitHub**: conectar la cuenta y elegir el repositorio **Avance-proyecto-PlusZone**.
3. Así puedes usar **Branching** (entornos por rama) y desplegar migraciones desde GitHub si lo configuras.

### Opción B: Solo GitHub Actions (este repo)

El repo ya incluye:

- **`.github/workflows/deploy-pages.yml`**: despliega el frontend (`client/`) en **GitHub Pages** en cada push a `main`.  
  URL: `https://<owner>.github.io/Avance-proyecto-PlusZone/`
- **`.github/workflows/supabase.yml`**: CI que valida que existan `supabase/config.toml`, `supabase/migrations/` y `supabase/seed.sql`.

**Habilitar GitHub Pages:**

1. Repositorio **Avance-proyecto-PlusZone** → **Settings** → **Pages**.
2. **Source:** **GitHub Actions**.
3. Tras el primer push a `main`, el workflow desplegará el sitio.

**Vincular Supabase CLI al proyecto (local):**

```bash
cd Avance-proyecto-PlusZone
supabase login
supabase link --project-ref TU_PROJECT_REF
```

El **Project ref** está en: Supabase Dashboard → Project Settings → General → **Reference ID**.

Luego puedes aplicar migraciones al remoto:

```bash
supabase db push
```

---

## Resumen de comandos útiles

| Acción              | Comando                |
|---------------------|------------------------|
| Iniciar Supabase local | `supabase start`    |
| Aplicar migraciones (remoto) | `supabase db push` |
| Reset local + seed  | `supabase db reset`   |
| Vincular proyecto   | `supabase link --project-ref <ref>` |
| Ver estado         | `supabase status`     |

Repositorio: **Avance-proyecto-PlusZone**

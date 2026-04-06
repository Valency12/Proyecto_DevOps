# Docker (PlusZone)

## Dónde está definido

| Archivo | Rol |
|--------|-----|
| `docker-compose.yml` (raíz) | Orquesta **API Node** (`server/`), **Python FastAPI** (`python/`) y **cliente estático** (nginx). |
| `server/Dockerfile` | Imagen del backend Express. |
| `python/Dockerfile` | Imagen del microservicio de matching. |

La base de datos sigue siendo **Supabase en la nube**: solo hace falta `DATABASE_URL` y el resto de variables en `server/.env` (no se versiona).

## Requisitos

- Docker y Docker Compose v2 (`docker compose`).
- `server/.env` configurado (igual que para desarrollo local).

## Uso

Desde la raíz del repositorio:

```bash
npm run docker:up
```

Puertos por defecto:

- **8080** — frontend (`http://localhost:8080`)
- **4000** — API (`http://localhost:4000`)
- **5050** — Python directo (opcional; la API ya usa `PYTHON_SERVICE_URL` interno hacia el contenedor `python-match`)

Antes de abrir el navegador, sincroniza la URL del API en el cliente si hace falta:

```bash
npm run sync:client
```

Asegúrate de que `API_BASE` / Supabase en `client/config.user.js` apunten a `http://localhost:4000` y a tu proyecto Supabase según tu entorno.

## Detener

```bash
npm run docker:down
```

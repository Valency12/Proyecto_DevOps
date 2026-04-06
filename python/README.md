# Servicio Python (matching)

Lógica de **afinidad** entre listas de habilidades (candidato vs oferta). Documentación de arquitectura y uso conjunta con Node en **[../DOCUMENTACION.md](../DOCUMENTACION.md)** (sección *Servicio Python*).

Arranque rápido (usa **venv**; en muchos Linux el `pip` del sistema no instala paquetes sin entorno virtual):

```bash
cd python
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn main:app --host 127.0.0.1 --port 5050 --reload
```

Desde la raíz del repo también: `npm run python:dev` (tras activar el venv e instalar dependencias).

Prueba: `GET http://127.0.0.1:5050/health`

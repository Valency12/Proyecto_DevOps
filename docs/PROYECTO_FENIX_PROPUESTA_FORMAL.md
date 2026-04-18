# Proyecto Fenix
## Estrategia de Re-arquitectura y Migracion a AWS

**Proyecto:** PlusZone (Proyecto_DevOps)  
**Materia/Curso:** DevOps y Arquitectura de Soluciones  
**Fecha:** 14 de abril de 2026  
**Equipo:** _[Integrantes del equipo]_  

---

## Indice

1. Objetivo del Proyecto  
2. Alcance del Proyecto  
3. Analisis de Infraestructura Actual vs Propuesta  
4. Estrategia de Migracion  
5. Plan de Implementacion (Roadmap)  
6. Estrategia de Seguridad y Escalabilidad  
7. Estimacion de Costos y Recursos  
8. Mapeo de Implementacion dentro del Repositorio  
9. Conclusiones Ejecutivas  

---

## 1. Objetivo del Proyecto

El objetivo de esta propuesta es definir una migracion estrategica de la aplicacion PlusZone hacia una arquitectura cloud en AWS que incremente la **disponibilidad**, **escalabilidad**, **seguridad** y **capacidad de despliegue continuo**.

La iniciativa no se limita a mover componentes actuales; busca modernizar la operacion y sentar las bases para crecimiento sostenible del sistema.

### Problemas actuales que se buscan resolver

- Limitaciones de escalado ante incrementos de trafico.
- Dependencia de configuraciones manuales entre ambientes.
- Ausencia de infraestructura como codigo para estandarizar despliegues.
- Seguridad operativa fragmentada y sin controles cloud centralizados.
- Mayor riesgo de indisponibilidad por falta de arquitectura de alta resiliencia.

---

## 2. Alcance del Proyecto

Se define una migracion por capas para reducir riesgo tecnico y operativo.

### Componentes incluidos en el alcance

1. **Frontend Web**
   - Estado actual: `client/` (sitio estatico).
   - Destino AWS: `Amazon S3` + `CloudFront` + `Route 53` + `ACM`.

2. **Backend API (Node.js/Express)**
   - Estado actual: `server/`.
   - Destino AWS: `Amazon ECS Fargate` (servicio administrado de contenedores).

3. **Microservicio Python (matching)**
   - Estado actual: `python/`.
   - Destino AWS: `Amazon ECS Fargate` como servicio independiente.

4. **Base de datos PostgreSQL**
   - Estado actual: Supabase PostgreSQL (externo).
   - Destino objetivo: `Amazon RDS for PostgreSQL` (fase final de migracion).

5. **Logs, backups y artefactos**
   - Destino AWS: `Amazon S3` + `CloudWatch`.

### Fuera de alcance en esta fase

- Reescritura funcional total del producto.
- Migracion multi-cloud.
- Cambios mayores de experiencia de usuario no asociados a infraestructura.

---

## 3. Analisis de Infraestructura Actual vs Propuesta

### Infraestructura actual (diagnostico)

- Separacion por carpetas: `client/`, `server/`, `python/`, `supabase/`.
- Contenerizacion local mediante `docker-compose.yml`.
- Frontend y backend desacoplados en despliegue.
- Dependencia de servicios externos para BD/autenticacion.
- Sin infraestructura AWS codificada en plantillas.

### Infraestructura propuesta (target architecture)

- Frontend global y de baja latencia con `S3 + CloudFront`.
- Servicios de aplicacion en `ECS Fargate` con escalado independiente.
- Persistencia administrada en `RDS PostgreSQL` con opcion Multi-AZ.
- Monitoreo centralizado con `CloudWatch` y auditoria con `CloudTrail`.
- Seguridad por capas con `IAM`, `VPC`, `Security Groups` y gestion de secretos.

### Justificacion de seleccion de servicios AWS

- **ECS Fargate:** elimina administracion de servidores y acelera despliegues.
- **RDS PostgreSQL:** confiabilidad, backups automatizados y mantenimiento administrado.
- **S3 + CloudFront:** alto rendimiento para contenido estatico y reduccion de latencia.
- **CloudFormation:** estandarizacion, repetibilidad y trazabilidad de cambios.

---

## 4. Estrategia de Migracion

Se propone una estrategia **Replatforming con Refactoring ligero**.

### Razon tecnica de la estrategia

- El proyecto ya utiliza contenedores localmente; por lo tanto, el paso natural es migrar a plataforma administrada.
- Se requiere elevar seguridad y automatizacion sin detener la evolucion funcional.
- Se minimiza riesgo evitando una reescritura completa.

### Fases recomendadas de migracion

1. **Fase 0 - Planeacion y preparacion**
   - Inventario de dependencias, variables de entorno, rutas criticas y SLAs.
   - Definicion de criterios de exito y plan de rollback.

2. **Fase 1 - Frontend**
   - Publicacion de frontend en S3 y distribucion por CloudFront.
   - Validacion funcional y de rendimiento sin cambiar backend.

3. **Fase 2 - Backend y microservicio**
   - Construccion de imagenes y publicacion en ECR.
   - Despliegue en ECS Fargate con balanceo mediante ALB.
   - Pruebas de humo y pruebas de contrato API.

4. **Fase 3 - Datos**
   - Escenario transitorio: mantener Supabase para continuidad.
   - Escenario objetivo: migrar a RDS con AWS DMS (full load + CDC).
   - Cutover controlado y cambio de endpoint de base de datos.

5. **Fase 4 - Estabilizacion**
   - Monitoreo reforzado, ajuste de alarmas y optimizacion de costos.

---

## 5. Plan de Implementacion (Roadmap)

### 5.1 Provisionamiento de infraestructura (CloudFormation)

Se implementaran stacks por dominio:

- **Networking:** VPC, subredes publicas/privadas, rutas, NAT.
- **Seguridad:** IAM roles/policies, Security Groups.
- **Compute:** ECS Cluster, Task Definitions, Services, ALB.
- **Datos:** RDS PostgreSQL, backup policy, subnet groups.
- **Frontend:** S3, CloudFront, certificados ACM.
- **Observabilidad:** log groups y alarmas en CloudWatch.

### 5.2 Migracion de datos

- Extraccion y validacion de esquema y datos actuales.
- Carga inicial en destino.
- Replicacion de cambios (CDC) hasta ventana de corte.
- Pruebas de consistencia, conteo y validacion funcional.
- Cambio final de cadena de conexion y monitoreo post-cutover.

### 5.3 CI/CD

Pipeline recomendado:

1. Pull Request: lint, pruebas unitarias y validaciones de calidad.
2. Merge a `main`: build de imagenes `server` y `python`.
3. Push de imagenes a ECR.
4. Deploy a ECS (rolling update).
5. Publicacion frontend a S3 e invalidacion CloudFront.
6. Aprobacion manual para produccion y registro de version.

---

## 6. Estrategia de Seguridad y Escalabilidad

### Seguridad

- Modelo IAM de minimo privilegio por servicio.
- Aislamiento de red con VPC y subredes privadas para datos.
- Security Groups por capa (ALB -> ECS -> RDS).
- Credenciales fuera del codigo usando `Secrets Manager` o `SSM Parameter Store`.
- Cifrado en transito (TLS) y en reposo (S3/RDS).
- Auditoria centralizada con CloudTrail y registros en CloudWatch.
- Opcional recomendado: WAF en capa de entrada.

### Escalabilidad

- Auto Scaling en ECS basado en CPU/Memoria y request count.
- ALB para distribucion de carga y alta disponibilidad.
- CloudFront para absorcion de trafico estatico.
- Escalado vertical/horizontal de RDS segun demanda.
- Patron de colas (SQS) para cargas asincronas futuras.

---

## 7. Estimacion de Costos y Recursos

### Rubros principales

- Costo de computo (ECS Fargate).
- Balanceador de carga (ALB).
- Base de datos (RDS + almacenamiento + backups).
- CDN y almacenamiento estatico (CloudFront + S3).
- Logs y monitoreo (CloudWatch).
- Registro de imagenes (ECR).

### Criterio de costo-efectividad

- Inicio con capacidades base y escalado elastico.
- Separacion de ambientes con politicas de ahorro en desarrollo.
- Ajuste iterativo por consumo real y metricas de uso.
- Evitar sobreaprovisionamiento inicial.

### Recomendacion financiera

Completar una corrida en **AWS Pricing Calculator** con:

- usuarios concurrentes en hora pico,
- trafico mensual estimado,
- volumen inicial y crecimiento de base de datos,
- retencion de logs por ambiente.

---

## 8. Mapeo de Implementacion dentro del Repositorio

Este bloque responde de forma directa: **en que parte del proyecto implementar cada requisito**.

- **Definicion y alcance funcional**
  - `README.md`
  - `DOCUMENTACION.md`
  - `docs/DEPLOYMENT.md`

- **Frontend para migracion cloud**
  - `client/`

- **Backend y microservicio para despliegue en contenedores**
  - `server/`
  - `python/`
  - `docker-compose.yml` (referencia local)

- **Datos y migracion de esquema**
  - `supabase/migrations/`
  - `supabase/seed.sql`
  - `database/pluszone_supabase.sql`
  - `docs/SUPABASE_SETUP.md`

- **Infraestructura como codigo (a crear)**
  - `infra/network.yaml`
  - `infra/compute.yaml`
  - `infra/database.yaml`
  - `infra/frontend.yaml`
  - `infra/security.yaml`

- **CI/CD (a crear)**
  - `.github/workflows/ci.yml`
  - `.github/workflows/deploy-staging.yml`
  - `.github/workflows/deploy-production.yml`

- **Gobierno operativo y seguridad (a crear)**
  - `docs/SECURITY_AWS.md`
  - `docs/OPERACION_AWS.md`

---

## 9. Conclusiones Ejecutivas

La propuesta establece una ruta de transformacion realista y de bajo riesgo para evolucionar PlusZone hacia una arquitectura cloud moderna en AWS.  

El enfoque por fases permite mantener continuidad del servicio mientras se incorporan capacidades clave de la industria: infraestructura como codigo, despliegue automatizado, escalabilidad elastica y seguridad por capas.

En terminos tecnicos y financieros, la estrategia prioriza control de costos iniciales, crecimiento progresivo por demanda y mejora continua basada en observabilidad.

---

### Anexo sugerido para entrega academica

Para fortalecer la presentacion final, se recomienda anexar:

1. Diagrama de arquitectura actual vs objetivo (1 pagina).  
2. Tabla de riesgos de migracion y mitigaciones.  
3. Captura de estimacion preliminar en AWS Pricing Calculator.  
4. Cronograma de 4 fases con semanas estimadas.


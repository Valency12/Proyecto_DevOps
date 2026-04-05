# Verificación de email (código de 7 dígitos)

## Opciones consideradas

Durante el desarrollo se evaluaron estas alternativas para la verificación de correo:

### Opción A: Código numérico de 7 dígitos (implementada)
- **Descripción**: Código entre 1000000 y 9999999, enviado por email, válido 15 minutos (configurable con `VERIFICATION_EXPIRATION_MINUTES`).
- **Ventajas**: Fácil de escribir para el usuario, suficiente entropía, ya existía flujo similar (antes 6 dígitos).
- **Desventajas**: Ligeramente más largo que 6 dígitos.
- **Recomendación**: Adecuada para la mayoría de usuarios (@tecmilenio.mx).

### Opción B: Código alfanumérico de 7 caracteres
- **Descripción**: Código con letras y números (ej. `A3K9X2M`), mismo tiempo de validez.
- **Ventajas**: Mayor entropía, más difícil de adivinar.
- **Desventajas**: Más incómodo de teclear y más fácil equivocarse (0/O, 1/I/l).
- **Cuándo elegirla**: Si se prioriza seguridad extra frente a usabilidad.

### Opción C: Código de 7 dígitos con límite de intentos
- **Descripción**: Igual que A, pero se invalida el código tras N intentos fallidos (ej. 5).
- **Ventajas**: Reduce ataques por fuerza bruta.
- **Desventajas**: Requiere persistir intentos por código y limpiar tras éxito/expiración.
- **Cuándo elegirla**: En entornos con requisitos de seguridad más estrictos.

Se implementó la **Opción A** por equilibrio entre usabilidad y seguridad, y porque el usuario no puede acceder a la aplicación hasta verificar (el login devuelve 403 si `is_active` es false).

## Flujo actual

1. **Registro** (`POST /api/auth/register`): Se crea el usuario con `is_active = false`, se genera un código de 7 dígitos, se guarda en `email_verifications` y se envía por correo.
2. **Verificación** (`POST /api/auth/verify`): Se comprueba email + código (no expirado, no ya verificado). Se marca la verificación y se pone `users.is_active = true`.
3. **Login** (`POST /api/auth/login`): Solo devuelve éxito si `is_active === true`; si no, responde 403 con mensaje para verificar con el código de 7 dígitos.
4. **Reenvío** (`POST /api/auth/resend`): Máximo 3 códigos por hora por usuario; se genera uno nuevo y se envía por correo.

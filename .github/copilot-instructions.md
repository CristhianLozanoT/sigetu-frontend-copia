# Instrucciones de Copilot para SIGETU

## Contexto del proyecto
- Proyecto Flutter/Dart para gestión de citas universitarias.
- Arquitectura por `features` y utilidades compartidas en `lib/core`.
- Backend REST principal en `/appointments`.

## Principios de implementación
- Hacer cambios pequeños, enfocados y con impacto mínimo fuera del alcance.
- Evitar duplicar lógica; preferir utilidades compartidas en `lib/core/utils`.
- Mantener consistencia visual con componentes y tema existentes.
- No introducir hardcode de colores o estilos fuera del sistema de tema.

## Fechas y horas (obligatorio)
- Mostrar hora en formato **AM/PM** en toda la app.
- Reutilizar `AppDateFormatter` para formateo de fecha/hora/rangos.
- Reutilizar `BackendDateTime` para parseo/serialización de datetimes con zona backend.
- No usar `toLocal()` directamente para valores de negocio de citas.
- `scheduled_at` debe enviarse en formato ISO con offset del backend.

## API y contratos
- Respetar nombres de payload del backend: `category`, `context`, `scheduled_at`.
- No renombrar campos del contrato sin requerimiento explícito.
- Mostrar mensajes útiles de error provenientes del backend cuando existan.
- Si frontend y backend se contradicen, priorizar el contrato backend y ajustar frontend.

## Pantallas y UX
- Mantener la UX simple, sin añadir pasos o modales no solicitados.
- No agregar funcionalidades “nice to have” sin pedido explícito.
- En validaciones, preferir mensajes claros y accionables para el usuario.

## Calidad de código
- Seguir convenciones actuales del repo (nombres, estructura, estilo).
- Evitar comentarios innecesarios; el código debe ser claro por sí mismo.
- Mantener funciones cortas y responsabilidades separadas.
- Si se crea una utilidad nueva, aplicarla en los lugares duplicados más relevantes.

## Verificación
- Tras cambios, revisar errores del archivo/modulo modificado.
- No arreglar bugs no relacionados salvo que bloqueen el cambio solicitado.

## Preferencias de colaboración
- Responder en español.
- Explicar de forma breve qué se cambió y en qué archivo.
- Proponer siguiente paso lógico cuando aporte valor (por ejemplo, validar o probar).

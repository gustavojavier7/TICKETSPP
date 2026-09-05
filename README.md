# 🎫 TICKETSPP — Sistema de Tickets Operativos

Repositorio para la gestión de tickets de infraestructura de videovigilancia (CCTV), control de acceso y sistemas asociados en planta.

## Flujo de trabajo

1. **Abrir un ticket** usando el template [Registrar ticket rápido](https://github.com/gustavojavier7/TICKETSPP/issues/new?template=registro-ticket-rapido.yml)
2. El workflow `assign-pp-ticket-id` asigna automáticamente un ID `PP-XXXX` al título
3. Ante una edición humana, el mismo workflow calcula un diff semántico por campo y publica una notificación nueva con los valores `Antes → Ahora` antes de resincronizar etiquetas
4. El workflow valida y sincroniza las etiquetas operativas al crear el ticket y cada vez que una persona edita el Issue
5. Si el ticket no define prioridad, `assign-pp-ticket-id` aplica automáticamente `prioridad:media` y lo informa en el reporte de validación
6. Si el ticket contiene una prioridad inválida, mantiene el error de validación pero aplica provisionalmente `prioridad:media` para evitar que el caso quede fuera del monitoreo
7. Si cualquier campo obligatorio queda inválido, se aplica `validacion:incompleta`; la label se retira automáticamente cuando el ticket vuelve a validar correctamente
8. El workflow `state-consistency-guard` reconcilia en cada ronda el estado nativo del Issue con `estado:cerrado`: si GitHub ya está `closed`, normaliza las labels; si un Issue sigue `open` pero tiene `estado:cerrado`, primero notifica la inconsistencia y luego lo cierra automáticamente
9. El workflow `inactivity-reminders` monitorea tickets abiertos y envía recordatorios según prioridad

## Labels

| Prefijo | Labels | Descripción |
|---|---|---|
| `tipo:` | `registrar-ticket` | Tipo de issue |
| `prioridad:` | `baja`, `media`, `alta`, `urgente` | Impacto del incidente |
| `estado:` | `abierto`, `en-curso`, `esperando-respuesta`, `cerrado` | Ciclo de vida |
| `sistema:` | `digifort`, `hikvision`, `ccure`, `windows`, `redes` | Sistema afectado |
| `solicitante:` | `evelin-sosa`, `jennifer-castilla`, `jesus-martin`, `gustavo-lopez` | Quién reporta |
| `validacion:` | `incompleta` | Ticket con campos pendientes de corrección; no lo excluye del monitoreo |
| `escalamiento:` | `respuesta-proveedor-recibida`, `requiere-reemplazos`, `visita-en-sitio`, `capex`, `bloqueado-tercero` | Acciones requeridas |

## Automatización

| Workflow | Disparador | Acción |
|---|---|---|
| `assign-pp-ticket-id` | Nuevo issue o edición humana | Asigna/conserva ID `PP-XXXX`; en ediciones humanas publica un diff semántico nuevo antes de cualquier resincronización; revalida campos, aplica prioridad media por defecto o como fallback seguro ante prioridad inválida, marca validaciones incompletas y resincroniza labels operativas |
| `state-consistency-guard` | Cada 8 h o manual | Reconcilia estado y labels: un Issue `closed` queda únicamente con `estado:cerrado`; un Issue `open` con `estado:cerrado` se notifica primero y se cierra automáticamente |
| `inactivity-reminders` | Cada 8 h | Notifica issues inactivos según prioridad con pausa de 7 días tras actividad humana |

### Notificaciones de edición

Toda edición humana del título o del cuerpo se analiza comparando el estado anterior incluido por GitHub en el evento `issues.edited` con el nuevo contenido del ticket.

El workflow parsea las secciones `###` del cuerpo y compara los valores semánticos de cada campo. Por eso una modificación puramente de espacios o saltos de línea no genera ruido, mientras que cualquier cambio real en un campo —incluidos campos no validados por el bot, como `Detalles o notas`, `Link`, `ID Ticket`, `Estado Anterior` o `Escalamiento condicional`— produce una notificación nueva.

La notificación agrupa todos los cambios de una misma edición en un único comentario y muestra `Antes → Ahora`. Para prioridad, estado, sistema y solicitante agrega además el efecto operativo esperado sobre las labels. Cada evento lleva un marcador único para evitar comentarios duplicados si GitHub reintenta la misma ejecución.

Bajo el principio **Fallar Primero**, este comentario se publica antes de resincronizar las etiquetas: si la notificación no puede crearse, el paso falla y no se continúa con cambios derivados silenciosos.

### Actividad humana

Para el cálculo de inactividad se consideran actividad humana:

- comentarios y ediciones de comentarios realizados por personas;
- ediciones del contenido o título del ticket;
- cierres y reaperturas;
- cambios humanos de labels, asignación y otros estados administrativos relevantes.

Las acciones realizadas por cuentas de tipo `Bot` no reinician el reloj de inactividad.

Después de una actividad humana posterior a un recordatorio automático, las nuevas notificaciones quedan pausadas durante 7 días.

### Consistencia de estado

La etiqueta `estado:cerrado` tiene una semántica operativa fuerte: representa que el ticket debe estar cerrado también en el estado nativo de GitHub.

El guardia aplica dos reglas de reconciliación:

1. **GitHub `closed` + labels inconsistentes:** publica un aviso visible, elimina cualquier `estado:*` anterior y deja únicamente `estado:cerrado`.
2. **GitHub `open` + `estado:cerrado`:** publica un aviso visible antes de actuar, cierra el Issue en GitHub y elimina cualquier otra label `estado:*` contradictoria, conservando `estado:cerrado`.

La notificación se crea antes de modificar estado o labels. Después de una reparación correcta, el mismo aviso confirma exactamente qué acción realizó el workflow. Si una corrección falla, la inconsistencia queda visible y la ronda siguiente vuelve a intentarla. Una vez alcanzado un estado canónico, no se generan avisos repetidos.

## Scripts

| Script | Uso |
|---|---|
| `scripts/sync_labels.sh` | Sincroniza labels canónicos en el repo |
| `scripts/normalize_legacy_labels.sh` | Migra labels legacy → canónicos y ejecuta sync |

```bash
# Sincronizar labels
bash scripts/sync_labels.sh

# Migrar labels legacy y sincronizar
bash scripts/normalize_legacy_labels.sh
```

## Campos del ticket

- **Solicitante**: dropdown (4 opciones)
- **Sistema afectado**: dropdown (HIKVISION / DIGIFORT / CCURE)
- **Describe la falla**: textarea con resumen para el título
- **Tipo de falla**: dropdown opcional
- **Prioridad**: dropdown (BAJA / MEDIA / ALTA / URGENTE). Si el campo falta se asigna automáticamente `MEDIA`; si contiene un valor inválido se conserva el error de validación pero se usa provisionalmente `MEDIA` para mantener el ticket dentro del monitoreo
- **Estado del ticket**: dropdown (ABIERTO / EN CURSO / ESPERANDO RESPUESTA / CERRADO)
- **Escalamiento condicional**: checkboxes múltiples
- **Detalles o notas**: textarea
- **Link / ID Ticket / Estado Anterior**: campos opcionales

Cuando un ticket se edita, Codex-Connector registra la edición como actividad humana, publica el diff semántico si existe un cambio real, vuelve a validar sus campos y mantiene sincronizadas las labels administradas (`prioridad:*`, `estado:*`, `sistema:*`, `solicitante:*`, `validacion:*`).

# 🎫 TICKETSPP — Sistema de Tickets Operativos

Repositorio para la gestión de tickets de infraestructura de videovigilancia (CCTV), control de acceso y sistemas asociados en planta.

## Flujo de trabajo

1. **Abrir un ticket** usando el template [Registrar ticket rápido](https://github.com/gustavojavier7/TICKETSPP/issues/new?template=registro-ticket-rapido.yml)
2. El workflow `assign-pp-ticket-id` asigna automáticamente un ID `PP-XXXX` al título
3. El mismo workflow valida y sincroniza las etiquetas operativas al crear el ticket y cada vez que una persona edita el Issue
4. Si el ticket no define prioridad, `assign-pp-ticket-id` aplica automáticamente `prioridad:media` y lo informa en el reporte de validación
5. Si el ticket contiene una prioridad inválida, mantiene el error de validación pero aplica provisionalmente `prioridad:media` para evitar que el caso quede fuera del monitoreo
6. Si cualquier campo obligatorio queda inválido, se aplica `validacion:incompleta`; la label se retira automáticamente cuando el ticket vuelve a validar correctamente
7. El workflow `state-consistency-guard` revisa en cada ronda los Issues cerrados. Si GitHub indica `closed` pero la etiqueta de estado no es `estado:cerrado`, primero notifica la inconsistencia y luego reemplaza las etiquetas `estado:*` por `estado:cerrado`
8. El workflow `inactivity-reminders` monitorea tickets abiertos y envía recordatorios según prioridad

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
| `assign-pp-ticket-id` | Nuevo issue o edición humana | Asigna/conserva ID `PP-XXXX`, revalida campos, aplica prioridad media por defecto o como fallback seguro ante prioridad inválida, marca validaciones incompletas y resincroniza labels operativas |
| `state-consistency-guard` | Cada 8 h o manual | Usa el estado nativo de GitHub como autoridad para Issues cerrados; si falta `estado:cerrado`, notifica primero, corrige la etiqueta y confirma la acción en el aviso |
| `inactivity-reminders` | Cada 8 h | Notifica issues inactivos según prioridad con pausa de 7 días tras actividad humana |

### Actividad humana

Para el cálculo de inactividad se consideran actividad humana:

- comentarios y ediciones de comentarios realizados por personas;
- ediciones del contenido o título del ticket;
- cierres y reaperturas;
- cambios humanos de labels, asignación y otros estados administrativos relevantes.

Las acciones realizadas por cuentas de tipo `Bot` no reinician el reloj de inactividad.

Después de una actividad humana posterior a un recordatorio automático, las nuevas notificaciones quedan pausadas durante 7 días.

### Consistencia de estado

Para un Issue cuyo estado nativo de GitHub sea `closed`, la etiqueta canónica obligatoria es `estado:cerrado`.

Si una ronda detecta un Issue `closed` con otra etiqueta `estado:*` o sin etiqueta de estado, el guardia de consistencia aplica un flujo de dos fases:

1. publica o actualiza un aviso visible indicando la inconsistencia y la corrección que va a intentar;
2. reemplaza las etiquetas `estado:*` por `estado:cerrado` y actualiza el aviso confirmando la reparación.

Si la reparación falla, la inconsistencia permanece visible y la siguiente ronda vuelve a intentarla. Un Issue ya consistente no vuelve a generar el aviso.

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

Cuando un ticket se edita, Codex-Connector vuelve a validar sus campos y mantiene sincronizadas las labels administradas (`prioridad:*`, `estado:*`, `sistema:*`, `solicitante:*`, `validacion:*`).

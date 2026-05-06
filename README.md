# 🎫 TICKETSPP — Sistema de Tickets Operativos

Repositorio para la gestión de tickets de infraestructura de videovigilancia (CCTV), control de acceso y sistemas asociados en planta.

## Flujo de trabajo

1. **Abrir un ticket** usando el template [Registrar ticket rápido](https://github.com/gustavojavier7/TICKETSPP/issues/new?template=registro-ticket-rapido.yml)
2. El workflow `assign-pp-ticket-id` asigna automáticamente un ID `PP-XXXX` al título
3. El workflow `inactivity-reminders` monitorea tickets abiertos y envía recordatorios según prioridad

## Labels

| Prefijo | Labels | Descripción |
|---|---|---|
| `tipo:` | `registrar-ticket` | Tipo de issue |
| `prioridad:` | `baja`, `media`, `alta`, `urgente` | Impacto del incidente |
| `estado:` | `abierto`, `en-curso`, `esperando-respuesta`, `cerrado` | Ciclo de vida |
| `sistema:` | `digifort`, `hikvision`, `ccure`, `windows`, `redes` | Sistema afectado |
| `solicitante:` | `evelin-sosa`, `jennifer-castilla`, `jesus-martin`, `gustavo-lopez` | Quién reporta |
| `escalamiento:` | `respuesta-proveedor-recibida`, `requiere-reemplazos`, `visita-en-sitio`, `capex`, `bloqueado-tercero` | Acciones requeridas |

## Automatización

| Workflow | Disparador | Acción |
|---|---|---|
| `assign-pp-ticket-id` | Nuevo issue | Asigna ID `PP-XXXX` y agrega comentario |
| `inactivity-reminders` | Cada 12 h | Notifica issues inactivos según prioridad con pausa de 14 días tras respuesta humana |

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
- **Prioridad**: dropdown (BAJA / MEDIA / ALTA / URGENTE)
- **Estado del ticket**: dropdown (ABIERTO / EN CURSO / ESPERANDO RESPUESTA / CERRADO)
- **Escalamiento condicional**: checkboxes múltiples
- **Detalles o notas**: textarea
- **Link / ID Ticket / Estado Anterior**: campos opcionales

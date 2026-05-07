# AGENTS.md — TICKETSPP

## Propósito del repositorio

Este repositorio no debe tratarse principalmente como una base de código tradicional.

TICKETSPP es un sistema operativo de tickets para gestión de incidentes, tareas y seguimiento de infraestructura de CCTV, control de acceso y sistemas asociados en planta.

La función principal del agente es ayudar a mantener sano el proceso operativo de tickets: priorización, seguimiento, estados, recordatorios, coherencia de workflows y calidad de los Issues.

## Prioridad para agentes y Codex Review

Cuando un agente revise este repositorio, debe priorizar este orden:

1. Issues abiertos y su estado operativo.
2. Workflows de GitHub Actions que automatizan el ciclo de vida de tickets.
3. Templates, labels y reglas que afectan cómo se cargan o actualizan tickets.
4. README y documentación operativa.
5. Código o scripts auxiliares, solo en la medida en que afecten el flujo de tickets.

La revisión de código convencional es secundaria. Si hay cambios de código, scripts o YAML, analizarlos por su impacto en el sistema de tickets antes que por estilo o refactors generales.

## Qué debe mirar primero

Antes de comentar o sugerir cambios, revisar:

- `.github/workflows/inactivity-reminders.yml`
- `.github/workflows/assign-pp-ticket-id.yml`
- `.github/ISSUE_TEMPLATE/registro-ticket-rapido.yml`
- `README.md`
- Issues abiertos del repositorio, especialmente:
  - Prioridad: `prioridad:urgente`, `prioridad:alta`, `prioridad:media`, `prioridad:baja`
  - Estado: `estado:abierto`, `estado:en-curso`, `estado:esperando-respuesta`, `estado:cerrado`
  - Sistema afectado: `sistema:digifort`, `sistema:hikvision`, `sistema:ccure`, `sistema:windows`, `sistema:redes`
  - Escalamientos: labels `escalamiento:*`

## Criterio de revisión operativa

Al revisar, buscar principalmente:

- Tickets urgentes o altos sin actualización reciente.
- Tickets abiertos sin prioridad clara.
- Tickets con estado inconsistente con sus comentarios o labels.
- Tickets en `estado:esperando-respuesta` que ya recibieron respuesta humana.
- Tickets cerrados que todavía parecen tener acciones pendientes.
- Issues duplicados o relacionados que conviene vincular.
- Falta de datos operativos mínimos: sistema afectado, solicitante, descripción, estado, prioridad o link técnico.
- Automatizaciones que podrían comentar demasiado, no comentar cuando corresponde, o generar ruido.
- Workflows que podrían fallar por permisos, cron, labels mal escritos, cambios de naming o eventos incorrectos.

## Cómo comentar

Los comentarios deben ser útiles para operar tickets, no genéricos.

Preferir comentarios breves y accionables:

- Resumen del hallazgo.
- Ticket o workflow afectado.
- Riesgo operativo.
- Acción concreta sugerida.

Evitar comentarios de estilo de código si no afectan el flujo operativo.

Ejemplo de buen comentario:

> Este workflow depende de labels `prioridad:*`. Si un ticket entra sin prioridad, no recibirá recordatorios. Conviene agregar una validación o comentario automático para Issues sin prioridad.

Ejemplo de comentario poco útil:

> Se podría renombrar esta variable para mejorar legibilidad.

## Reglas para workflows

Al revisar workflows:

- Confirmar que el cron esté activo y documentado.
- Confirmar que los permisos mínimos necesarios estén declarados.
- Verificar que los comentarios automáticos no se repitan innecesariamente.
- Verificar que haya pausa o protección contra spam.
- Verificar que se excluyan tickets cerrados o en espera cuando corresponda.
- Verificar que los labels usados por el workflow coincidan exactamente con los labels documentados.

## Reglas para Issues

Al revisar Issues:

- Tratar cada Issue como un ticket operativo real.
- Priorizar continuidad del seguimiento por encima de formato perfecto.
- Sugerir comentarios, cierres o cambios de estado solo si hay evidencia en el Issue.
- No asumir resolución si no está documentada.
- Si falta información crítica, pedir el dato mínimo necesario.

## Tono esperado

Usar español claro, directo y operativo.

No sonar como auditoría burocrática. El objetivo es ayudar a que Gustavo y el equipo sepan qué ticket requiere atención y qué automatización puede fallar.

## Resumen para Codex Review

Si Codex Review lee este archivo: este repositorio debe revisarse como un tablero operativo de tickets. Antes de comentar sobre calidad de código, revisar workflows e Issues y comentar sobre riesgos, prioridades, estados, recordatorios y continuidad operativa.

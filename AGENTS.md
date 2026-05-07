# Configuración de Agentes - TICKETSPP

## Agente: Codex Review - Análisis de Inactividad

### Descripción General
Este agente analiza automáticamente el periodo de inactividad de los Issues en el repositorio y envía un comentario de revisión cuando detecta inactividad significativa.

### Objetivo
- Detectar Issues inactivos
- Realizar revisión automática
- Notificar al equipo con un comentario estándar de Codex Review

---

## Configuración del Agente

### Trigger (Activadores)
```
Evento: schedule (programado diariamente)
Alternativa: workflow_dispatch (manual)
```

### Parámetros de Inactividad
```
INACTIVITY_DAYS: 7          # Días sin actividad para considerar "inactivo"
INCLUDE_LABELS: []          # Etiquetas a revisar (vacío = todas)
EXCLUDE_LABELS: ["blocked"] # Etiquetas a excluir
```

### Lógica de Análisis

1. **Detectar Issues Inactivos**
   - Comparar `updated_at` con fecha actual
   - Si diferencia > `INACTIVITY_DAYS`: marcar como inactivo
   - Ignorar Issues con etiquetas excluidas

2. **Validaciones**
   - Ignorar Issues cerrados
   - Ignorar Issues con label "wontfix" o "no-review"
   - Ignorar Issues con comentario reciente de Codex Review

3. **Realizar Revisión**
   - Analizar contenido del Issue
   - Evaluar descripción y contexto
   - Determinar si requiere acción

4. **Enviar Comentario**
   - Agregar comentario automático con formato estándar
   - Incluir fecha de revisión
   - Sugerir acciones si aplica

---

## Formato de Comentario

```
🤖 **Revisado por Codex Review**

**Estado:** Inactividad detectada
**Último cambio:** {fecha_ultima_actualizacion}
**Días sin actividad:** {dias_inactivo}

### Análisis
- ✅ Issue bien definido
- ⚠️ Descripción clara pero requiere detalles adicionales
- 📝 Se recomienda: {recomendacion}

**Acciones sugeridas:**
1. Actualizar estado del Issue
2. Asignar a un responsable si es urgente
3. Cerrar si ya no es relevante

---
*Revisión automática realizada el {fecha_revision} por Codex Review*
```

---

## Variables Internas

### Disponibles en el Contexto
```
ISSUE_NUMBER        = github.event.issue.number
ISSUE_TITLE         = github.event.issue.title
ISSUE_BODY          = github.event.issue.body
ISSUE_LABELS        = github.event.issue.labels[].name
ISSUE_UPDATED_AT    = github.event.issue.updated_at
ISSUE_CREATED_AT    = github.event.issue.created_at
ISSUE_STATE         = github.event.issue.state
REPO_NAME           = github.repository
WORKFLOW_DATE       = github.event.schedule (si aplica)
```

### Cálculos Derivados
```
DAYS_INACTIVE       = (TODAY - ISSUE_UPDATED_AT).days
LAST_COMMENT_DATE   = max(comment.created_at)
REQUIRES_REVIEW     = DAYS_INACTIVE > INACTIVITY_DAYS
```

---

## Configuración Técnica

### Archivo de Workflow
Ubicación: `.github/workflows/codex-review-inactivity.yml`

### Evento Recomendado
```yaml
on:
  schedule:
    - cron: '0 9 * * MON'  # Lunes a las 9 AM UTC
  workflow_dispatch:       # Permitir ejecución manual
```

### Permisos Requeridos
```yaml
permissions:
  issues: write           # Para agregar comentarios
  contents: read          # Para leer contenido
  repository-projects: read
```

---

## Opciones de Configuración

### Nivel 1: Básico
- Solo detectar inactividad
- Enviar comentario simple

### Nivel 2: Estándar (Recomendado)
- Detectar inactividad
- Analizar contenido
- Enviar comentario con recomendaciones

### Nivel 3: Avanzado
- Detectar inactividad
- Analizar contenido
- Asignar labels automáticamente
- Notificar a responsables
- Enviar comentario detallado

---

## Exclusiones Automáticas

Los siguientes Issues **NO serán revisados:**

- ✗ Issues cerrados
- ✗ Issues con label `blocked`
- ✗ Issues con label `wontfix`
- ✗ Issues con label `no-review`
- ✗ Issues con comentario de Codex Review en últimos 3 días
- ✗ Issues creados hace menos de 1 día

---

## Monitoreo

### Métricas Generadas
- Total de Issues analizados
- Issues inactivos detectados
- Comentarios enviados
- Tasa de seguimiento

### Logs
Todos los análisis se registran con:
- Timestamp
- Issue ID
- Resultado del análisis
- Acciones ejecutadas

---

## Contribución

Para modificar este agente:

1. Editar parámetros en `.github/workflows/codex-review-inactivity.yml`
2. Actualizar variables en la sección "Variables Internas"
3. Modificar template de comentario en la sección "Formato de Comentario"
4. Actualizar esta documentación
5. Crear PR para revisión

---

**Última actualización:** 2026-05-07
**Versión del Agente:** 1.0
**Estado:** Activo
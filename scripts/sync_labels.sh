#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-gustavojavier7/TICKETSPP}"

create_or_update_label () {
  local name="$1"
  local color="$2"
  local desc="$3"

  if gh label list --repo "$REPO" --limit 500 --json name -q '.[].name' | grep -Fxq "$name"; then
    gh label edit "$name" --repo "$REPO" --color "$color" --description "$desc" >/dev/null
    echo "Updated: $name"
  else
    gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" >/dev/null
    echo "Created: $name"
  fi
}

# Tipo
create_or_update_label "tipo:registrar-ticket" "0E8A16" "Alta rápida de ticket operativo"

# Prioridad
create_or_update_label "prioridad:baja" "0E8A16" "Impacto menor"
create_or_update_label "prioridad:media" "FBCA04" "Impacto moderado"
create_or_update_label "prioridad:alta" "D93F0B" "Impacto alto"
create_or_update_label "prioridad:urgente" "B60205" "Impacto crítico"

# Estado
create_or_update_label "estado:abierto" "1D76DB" "Ticket abierto"
create_or_update_label "estado:en-curso" "0052CC" "Trabajo en progreso"
create_or_update_label "estado:esperando-respuesta" "5319E7" "Esperando tercero/cliente"
create_or_update_label "estado:cerrado" "6A737D" "Ticket cerrado"

# Sistema
create_or_update_label "sistema:digifort" "0366D6" "Sistema DIGIFORT"
create_or_update_label "sistema:hikvision" "0366D6" "Sistema HIKVISION"
create_or_update_label "sistema:ccure" "0366D6" "Sistema CCURE"
create_or_update_label "sistema:windows" "0366D6" "Sistema WINDOWS"
create_or_update_label "sistema:redes" "0366D6" "Sistema REDES"

# Solicitante
create_or_update_label "solicitante:evelin-sosa" "C5DEF5" "Solicitante Evelin Sosa"
create_or_update_label "solicitante:jennifer-castilla" "C5DEF5" "Solicitante Jennifer Castilla"
create_or_update_label "solicitante:jesus-martin" "C5DEF5" "Solicitante Jesús Martín"
create_or_update_label "solicitante:gustavo-lopez" "C5DEF5" "Solicitante Gustavo López"

# Escalamiento
create_or_update_label "escalamiento:respuesta-proveedor-recibida" "F9D0C4" "Proveedor respondió"
create_or_update_label "escalamiento:requiere-reemplazos" "F9D0C4" "Requiere reemplazo de partes"

echo "✅ Labels sincronizados en $REPO"

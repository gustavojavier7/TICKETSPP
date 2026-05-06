#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-gustavojavier7/TICKETSPP}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "❌ Missing required command: $1" >&2
    exit 1
  }
}

require_cmd gh

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

legacy_labels=("digifort" "hikvision" "ccure")
canonical_labels=("sistema:digifort" "sistema:hikvision" "sistema:ccure")

# Inventory current labels
mapfile -t current_labels < <(gh label list --repo "$REPO" --limit 500 --json name -q '.[].name')
echo "📋 Label inventory for $REPO"
printf ' - %s\n' "${current_labels[@]}"

for i in "${!legacy_labels[@]}"; do
  legacy="${legacy_labels[$i]}"
  canonical="${canonical_labels[$i]}"

  has_legacy=false
  has_canonical=false

  if printf '%s\n' "${current_labels[@]}" | grep -Fxq "$legacy"; then
    has_legacy=true
  fi
  if printf '%s\n' "${current_labels[@]}" | grep -Fxq "$canonical"; then
    has_canonical=true
  fi

  if [[ "$has_legacy" == false ]]; then
    echo "ℹ️  Legacy label not found: $legacy"
    continue
  fi

  if [[ "$has_canonical" == false ]]; then
    echo "🔁 Renaming '$legacy' -> '$canonical'"
    gh label edit "$legacy" --repo "$REPO" --name "$canonical" >/dev/null
  else
    echo "➕ Both labels exist. Migrating issues from '$legacy' to '$canonical' and deleting legacy."
    mapfile -t issues_with_legacy < <(gh issue list --repo "$REPO" --state all --label "$legacy" --limit 1000 --json number -q '.[].number')

    for issue_number in "${issues_with_legacy[@]}"; do
      gh issue edit "$issue_number" --repo "$REPO" --add-label "$canonical" --remove-label "$legacy" >/dev/null
      echo "   updated issue #$issue_number"
    done

    gh label delete "$legacy" --repo "$REPO" --yes >/dev/null
  fi

done

# Validate no open issue is left with legacy-only labels
for legacy in "${legacy_labels[@]}"; do
  open_count=$(gh issue list --repo "$REPO" --state open --label "$legacy" --limit 1 --json number | jq 'length')
  if [[ "$open_count" != "0" ]]; then
    echo "❌ Validation failed: there are still open issues with legacy label '$legacy'"
    exit 1
  fi
  echo "✅ No open issues left with legacy label '$legacy'"
done

"$(dirname "$0")/sync_labels.sh" "$REPO"

echo "✅ Legacy label normalization completed for $REPO"

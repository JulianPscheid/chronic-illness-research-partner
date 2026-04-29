#!/usr/bin/env bash
set -euo pipefail

command -v jq >/dev/null || { echo "jq required; brew install jq" >&2; exit 1; }

PERSONA="${1:?usage: render-fixture.sh <persona-number>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PERSONA_FILE="$ROOT/scripts/personas/persona-$PERSONA.json"
OUT_DIR="$ROOT/scripts/renders/persona-$PERSONA"

[ -r "$PERSONA_FILE" ] || { echo "Persona file not found: $PERSONA_FILE" >&2; exit 1; }

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# Build a sed expression set from the JSON file
SED_EXPR=""
while IFS=$'\t' read -r key value; do
  # Escape sed special chars in value
  esc=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
  SED_EXPR="$SED_EXPR;s/{{$key}}/$esc/g"
done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$PERSONA_FILE")

# Apply to every .tmpl file under templates/
find "$ROOT/templates" -name '*.tmpl' -type f | while read -r tmpl; do
  rel="${tmpl#$ROOT/templates/}"
  out_path="$OUT_DIR/${rel%.tmpl}"
  mkdir -p "$(dirname "$out_path")"
  sed "$SED_EXPR" "$tmpl" > "$out_path"
done

echo "Rendered persona-$PERSONA into $OUT_DIR"

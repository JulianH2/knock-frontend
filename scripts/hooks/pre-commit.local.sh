#!/usr/bin/env sh
# Comprobaciones rápidas propias de knock-frontend (las llama .githooks/pre-commit con la lista de archivos).
STAGED="$1"
DART=$(echo "$STAGED" | grep -E '^app/.*\.dart$' | grep -v '^app/packages/knock_api/')
if [ -n "$DART" ] && command -v dart >/dev/null 2>&1; then
  echo "[pre-commit] formato Dart"
  dart format --set-exit-if-changed --output=none $DART || exit 1
fi
TS=$(echo "$STAGED" | grep -E '^panel/src/.*\.(ts|html)$' | grep -v '^panel/src/app/api/')
if [ -n "$TS" ] && [ -d panel/node_modules ]; then
  echo "[pre-commit] ESLint (archivos cambiados)"
  (cd panel && npx eslint $(echo "$TS" | sed 's#^panel/##')) || exit 1
fi

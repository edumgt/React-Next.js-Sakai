#!/usr/bin/env sh
set -eu

MODE="${1:-dev}"

ensure_deps() {
  if [ ! -d node_modules ]; then
    echo "[run-web] node_modules not found. Running npm ci..."
    npm ci
  fi
}

case "$MODE" in
  dev)
    ensure_deps
    echo "[run-web] starting development server..."
    npm run dev
    ;;
  prod)
    ensure_deps
    echo "[run-web] building production assets..."
    npm run build
    echo "[run-web] starting production server..."
    npm run start
    ;;
  install)
    echo "[run-web] installing dependencies..."
    npm ci
    ;;
  *)
    echo "Usage: $0 [dev|prod|install]"
    exit 1
    ;;
esac

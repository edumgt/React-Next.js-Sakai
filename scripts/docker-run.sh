#!/usr/bin/env sh
set -eu

IMAGE_NAME="${IMAGE_NAME:-sakai-react-web}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-sakai-react-web}"
HOST_PORT="${HOST_PORT:-3000}"
CONTAINER_PORT="${CONTAINER_PORT:-3000}"

echo "[docker-run] building image ${IMAGE_NAME}:${IMAGE_TAG}..."
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  echo "[docker-run] removing existing container ${CONTAINER_NAME}..."
  docker rm -f "${CONTAINER_NAME}" >/dev/null
fi

echo "[docker-run] starting container ${CONTAINER_NAME} (${HOST_PORT}:${CONTAINER_PORT})..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  -e NODE_ENV=production \
  -e HOSTNAME=0.0.0.0 \
  -e PORT="${CONTAINER_PORT}" \
  "${IMAGE_NAME}:${IMAGE_TAG}"

echo "[docker-run] done. open: http://localhost:${HOST_PORT}"

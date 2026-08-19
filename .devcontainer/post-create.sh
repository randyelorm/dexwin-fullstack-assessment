#!/usr/bin/env bash
set -euo pipefail

# Warm the host-side Java and Node toolchains (installed via devcontainer features)
# so the Java and TypeScript language servers can resolve the classpath/types
# immediately — without this, IntelliSense has nothing to work against, since the
# app itself only builds inside the nested docker compose containers below.
npm ci --prefix frontend >/tmp/frontend-warmup.log 2>&1 &
frontend_warmup_pid=$!
mvn -q -f backend/pom.xml dependency:go-offline >/tmp/backend-warmup.log 2>&1 &
backend_warmup_pid=$!

for attempt in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    break
  fi

  if [[ "${attempt}" == "30" ]]; then
    echo "Docker did not become ready in time." >&2
    exit 1
  fi

  sleep 2
done

docker compose up --build --detach

for attempt in $(seq 1 60); do
  if (exec 3<>/dev/tcp/127.0.0.1/5173) 2>/dev/null &&
    (exec 3<>/dev/tcp/127.0.0.1/8080) 2>/dev/null; then
    break
  fi

  if docker compose ps --status exited --services | grep -q .; then
    docker compose logs --no-color --tail 80
    echo "An application service stopped during startup." >&2
    exit 1
  fi

  if [[ "${attempt}" == "60" ]]; then
    docker compose logs --no-color --tail 80
    echo "The application did not become ready in time." >&2
    exit 1
  fi

  sleep 2
done

if ! wait "${frontend_warmup_pid}"; then
  echo "Warning: frontend dependency warm-up (npm ci) failed; see /tmp/frontend-warmup.log." >&2
fi
if ! wait "${backend_warmup_pid}"; then
  echo "Warning: backend dependency warm-up (mvn dependency:go-offline) failed; see /tmp/backend-warmup.log." >&2
fi

echo
echo "Assessment environment ready."
echo "Remain in source-review phase until the interviewer moves you to phase 2."
echo "When phase 2 begins, open the TaskFlow frontend from port 5173 in the Ports panel."

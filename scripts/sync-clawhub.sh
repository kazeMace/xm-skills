#!/usr/bin/env bash
# Based on scripts/sync-clawhub.sh from https://github.com/JimLiu/baoyu-skills.git
# Licensed under the MIT License
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${ROOT_DIR}/skills"

if command -v clawhub >/dev/null 2>&1; then
  CLAWHUB_CMD=(clawhub)
elif command -v npx >/dev/null 2>&1; then
  CLAWHUB_CMD=(npx -y clawhub)
else
  echo "Error: neither clawhub nor npx is available."
  echo "See https://docs.openclaw.ai/zh-CN/tools/clawhub"
  exit 1
fi

if [ "$#" -eq 0 ]; then
  set -- --all
fi

exec "${CLAWHUB_CMD[@]}" sync --root "${SKILLS_DIR}" "$@"

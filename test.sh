#!/bin/bash

# Test the binary, mirroring the workflow's Test step

set -euo pipefail

PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2026.9'}

SCRIPT_DIR=$(dirname "$0")
OUT=$(mktemp -d)
trap 'rm -rf "${OUT}"' EXIT

# Some sample diagrams contain deliberate syntax errors, so the exit
# code is ignored, but every diagram must produce a non-empty image
./out/plantuml-${PLANTUML_VERSION}-glibc-x86_64 -headless -o "${OUT}" \
  PlantUML-master/*/*.puml "${SCRIPT_DIR}"/tests/*.puml || true

IMAGES=$(ls "${OUT}" | wc -l)
EMPTY=$(find "${OUT}" -size 0 | wc -l)
echo "${IMAGES} images, ${EMPTY} empty"
test "${IMAGES}" -gt 250
test "${EMPTY}" -eq 0

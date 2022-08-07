#!/bin/bash

# Test the binary

PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2022.6'}

./out/plantuml-${PLANTUML_VERSION}-glibc-x86_64 -headless -o /tmp/out2 \
  PlantUML-master/*/*.puml ./scripts/tests/*.puml

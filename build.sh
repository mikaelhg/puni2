#!/bin/bash

# Build the binary

JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}
PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2022.6'}

java -agentlib:native-image-agent=config-output-dir=conf/META-INF/native-image \
  -cp jlatexmath-${JLATEXMATH_VERSION}.jar:plantuml-${PLANTUML_VERSION}.jar \
  net.sourceforge.plantuml.Run -headless -o /tmp/out \
    ./PlantUML-master/*/*.puml ./scripts/tests/*.puml

native-image --auto-fallback --enable-http --enable-https \
  --report-unsupported-elements-at-runtime \
  -H:Name=plantuml-${PLANTUML_VERSION}-glibc-x86_64 \
  -H:Path=./out \
  -H:IncludeResources="stdlib/.*repx$" \
  -H:IncludeResources="net/sourceforge/plantuml.*(png|svg|txt)$" \
  -cp jlatexmath-${JLATEXMATH_VERSION}.jar:plantuml-${PLANTUML_VERSION}.jar:./conf \
  net.sourceforge.plantuml.Run

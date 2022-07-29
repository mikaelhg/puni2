#!/bin/bash

JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}
PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2022.6'}

java -agentlib:native-image-agent=config-output-dir=conf/META-INF/native-image \
  -cp jlatexmath-${JLATEXMATH_VERSION}.jar:plantuml-${PLANTUML_VERSION}.jar \
  net.sourceforge.plantuml.Run \
    -headless -o out-java ./PlantUML-master/*/*.puml

native-image --auto-fallback --enable-http --enable-https \
  --report-unsupported-elements-at-runtime \
  -H:Name=plantuml-${PLANTUML_VERSION}-glibc-x86_64 \
  -H:IncludeResources="stdlib/.*repx" \
  -H:IncludeResources="net/sourceforge/plantuml.*(png|svg|txt)$" \
  -cp jlatexmath-${JLATEXMATH_VERSION}.jar:plantuml-${PLANTUML_VERSION}.jar:./conf \
  net.sourceforge.plantuml.Run

./plantuml-${PLANTUML_VERSION}-glibc-x86_64 -headless -o out-native PlantUML-master/*/*.puml

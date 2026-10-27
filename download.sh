#!/bin/bash

# Download dependencies, mirroring the workflow; already downloaded files
# are kept

set -euo pipefail

PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2026.9'}
JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}

[ -f plantuml-${PLANTUML_VERSION}.jar ] || curl -sS -f -L -o plantuml-${PLANTUML_VERSION}.jar \
  https://repo1.maven.org/maven2/net/sourceforge/plantuml/plantuml/${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar

[ -f jlatexmath-${JLATEXMATH_VERSION}.jar ] || curl -sS -f -L -o jlatexmath-${JLATEXMATH_VERSION}.jar \
  https://repo1.maven.org/maven2/org/scilab/forge/jlatexmath/${JLATEXMATH_VERSION}/jlatexmath-${JLATEXMATH_VERSION}.jar

[ -d PlantUML-master ] || curl -sS -f -L -o - https://github.com/coni2k/PlantUML/archive/refs/heads/master.tar.gz | tar -zxf -
